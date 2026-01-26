#!/bin/bash
# Vibe Dashboard - Worker進捗リアルタイム監視
#
# Usage: vibe-dashboard.sh [.spec_dir]
#
# キーバインド:
#   q - 終了
#   r - 強制リフレッシュ
#   d - 詳細表示 (plan-viewer.sh)
#   p - Plan表示 (glow)

# Homebrew PATH
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

SPEC_DIR="${1:-./.spec}"
REFRESH_INTERVAL=1
# セッション名でパスファイルを共有（tmux版）
SESSION_ID="$(tmux display-message -p '#S' 2>/dev/null || echo 'default')"
SPEC_PATH_FILE="/tmp/vibe-spec-path-${SESSION_ID}"

# 終了時にパスファイルを削除
cleanup() {
    rm -f "$SPEC_PATH_FILE" 2>/dev/null
    stty echo icanon 2>/dev/null
    exit 0
}

# パスファイルを更新（plan-watcherと共有）
update_spec_path() {
    echo "$SPEC_DIR" > "$SPEC_PATH_FILE"
}

# 色定義
C_RESET="\033[0m"
C_BOLD="\033[1m"
C_DIM="\033[2m"
C_GREEN="\033[32m"
C_YELLOW="\033[33m"
C_BLUE="\033[34m"
C_MAGENTA="\033[35m"
C_CYAN="\033[36m"
C_RED="\033[31m"
C_BG_BLUE="\033[44m"
C_WHITE="\033[97m"

# Worker設定（bash 3.x互換）
get_worker_icon() {
    case "$1" in
        frontend) echo "🎨" ;;
        backend) echo "⚙️ " ;;
        test) echo "🧪" ;;
        debug) echo "🔍" ;;
        *) echo "📦" ;;
    esac
}

get_worker_color() {
    case "$1" in
        frontend) echo "$C_MAGENTA" ;;
        backend) echo "$C_BLUE" ;;
        test) echo "$C_CYAN" ;;
        debug) echo "$C_YELLOW" ;;
        *) echo "$C_WHITE" ;;
    esac
}

# ステータスアイコン
get_status_icon() {
    case "$1" in
        done|completed) echo "✅" ;;
        active|in_progress) echo "🔄" ;;
        waiting|pending) echo "⏸️ " ;;
        error) echo "❌" ;;
        *) echo "❓" ;;
    esac
}

# Git情報取得
get_git_root() {
    git rev-parse --show-toplevel 2>/dev/null || pwd
}

get_worktree_name() {
    local dir="$1"
    if [[ "$dir" == *"/.branches/"* ]]; then
        echo "$dir" | sed 's|.*/.branches/||' | cut -d'/' -f1
    else
        local branch=$(git branch --show-current 2>/dev/null || echo "main")
        echo "$branch"
    fi
}

# 現在のシンボリックリンク先を取得
get_current_spec_target() {
    local git_root=$(get_git_root)
    local spec_link="$git_root/.spec"

    if [[ -L "$spec_link" ]]; then
        readlink "$spec_link"
    elif [[ -d "$spec_link" ]]; then
        echo "$spec_link"  # 実体の場合はそのまま
    else
        echo ""
    fi
}

# .specシンボリックリンクを切り替え
switch_spec_symlink() {
    local target_spec="$1"  # 切り替え先の.specパス
    local git_root=$(get_git_root)
    local spec_link="$git_root/.spec"
    local main_spec="$git_root/.spec.main"

    # 初回: 実体が存在する場合は.spec.mainに退避
    if [[ -d "$spec_link" && ! -L "$spec_link" ]]; then
        mv "$spec_link" "$main_spec"
    fi

    # mainが選択された場合は.spec.mainをターゲットに
    if [[ "$target_spec" == "$git_root/.spec" ]]; then
        target_spec="$main_spec"
    fi

    # ターゲットが存在しない場合は作成
    if [[ ! -d "$target_spec" ]]; then
        mkdir -p "$target_spec"
    fi

    # シンボリックリンクを張り替え
    rm -f "$spec_link"
    ln -s "$target_spec" "$spec_link"
}

# Worktree選択UI
show_worktrees() {
    local git_root=$(get_git_root)
    local branches_dir="$git_root/.branches"
    local current_target=$(get_current_spec_target)
    local main_spec="$git_root/.spec.main"

    {
        # メインリポジトリ (.spec.main または .spec実体)
        local main_path="$git_root/.spec"
        [[ -d "$main_spec" ]] && main_path="$main_spec"
        if [[ -d "$main_path" ]] || [[ -L "$git_root/.spec" && "$(readlink "$git_root/.spec")" == "$main_spec" ]]; then
            [[ "$current_target" == "$main_spec" || "$current_target" == "$git_root/.spec" ]] \
                && echo "▶ main	$git_root/.spec" \
                || echo "  main	$git_root/.spec"
        fi
        # .branches配下
        if [[ -d "$branches_dir" ]]; then
            for wt in "$branches_dir"/*/; do
                local wt_spec="${wt}.spec"
                local name=$(basename "$wt")
                # .specディレクトリが存在するか、作成可能な場合
                if [[ -d "$wt_spec" ]] || [[ -d "$wt" ]]; then
                    [[ "$current_target" == "$wt_spec" ]] \
                        && echo "▶ $name	$wt_spec" \
                        || echo "  $name	$wt_spec"
                fi
            done
        fi
    } | fzf --ansi --delimiter='\t' --with-nth=1 \
        --layout=reverse --height=100% \
        --border=rounded \
        --prompt="Worktree> " \
        --header=$'Enter:select  Esc:back  (symlink mode)' \
        --bind='enter:accept'
}

# agents.json からステータス取得（hooks経由で更新される）
get_agent_status_from_json() {
    local worker="$1"
    local agents_file="$SPEC_DIR/agents.json"

    if [[ -f "$agents_file" ]]; then
        local status=$(jq -r ".\"$worker\".status // empty" "$agents_file" 2>/dev/null)
        if [[ -n "$status" ]]; then
            echo "$status"
            return 0
        fi
    fi
    return 1
}

# agents.json から開始時刻取得
get_agent_started_from_json() {
    local worker="$1"
    local agents_file="$SPEC_DIR/agents.json"

    if [[ -f "$agents_file" ]]; then
        jq -r ".\"$worker\".started // empty" "$agents_file" 2>/dev/null
    fi
}

# Workerファイルからステータス解析（フォールバック）
parse_worker_status_from_file() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        echo "waiting"
        return
    fi

    # ## Status: xxx 形式を探す
    local status=$(grep -i "^## Status:" "$file" 2>/dev/null | head -1 | sed 's/.*: *//' | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')

    if [[ -n "$status" ]]; then
        echo "$status"
    else
        # フォールバック: ログから推測
        if grep -q "\[.*\] 完了:" "$file" 2>/dev/null && ! grep -q "\[.*\] 進捗:" "$file" 2>/dev/null; then
            echo "done"
        elif grep -q "\[.*\] 進捗:\|進行中\|実装中" "$file" 2>/dev/null; then
            echo "active"
        elif grep -q "\[.*\] エラー:" "$file" 2>/dev/null; then
            echo "error"
        elif grep -q "\[.*\] 開始:" "$file" 2>/dev/null; then
            echo "active"
        else
            echo "waiting"
        fi
    fi
}

# Workerステータス取得（agents.json優先、ファイルにフォールバック）
parse_worker_status() {
    local file="$1"
    local worker=$(basename "$file" .md)

    # 1. agents.json から取得を試みる
    local status
    if status=$(get_agent_status_from_json "$worker") && [[ -n "$status" ]]; then
        echo "$status"
        return
    fi

    # 2. フォールバック: ファイルから解析
    parse_worker_status_from_file "$file"
}

# Workerファイルから進捗率取得
parse_worker_progress() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        echo "0"
        return
    fi

    # ## Progress: xx 形式を探す
    local progress=$(grep -i "^## Progress:" "$file" 2>/dev/null | head -1 | sed 's/.*: *//' | tr -d '[:space:]%')

    if [[ "$progress" =~ ^[0-9]+$ ]]; then
        echo "$progress"
    else
        # フォールバック: タスクリストから計算
        local total=$(grep -c "^\s*- \[" "$file" 2>/dev/null || echo "0")
        local done=$(grep -c "^\s*- \[x\]" "$file" 2>/dev/null || echo "0")

        if [[ "$total" -gt 0 ]]; then
            echo "$((done * 100 / total))"
        else
            local status=$(parse_worker_status "$file")
            case "$status" in
                done|completed) echo "100" ;;
                active|in_progress) echo "50" ;;
                *) echo "0" ;;
            esac
        fi
    fi
}

# 最新のログ行を取得
get_latest_message() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        echo "-"
        return
    fi

    # [HH:MM] で始まるログ行を取得（新しいログが上なのでhead -1）
    local msg=$(grep "^\[" "$file" 2>/dev/null | head -1 | sed 's/^\[[^]]*\] //')

    if [[ -n "$msg" ]]; then
        # 40文字で切り詰め
        echo "${msg:0:40}"
    else
        echo "-"
    fi
}

# 文字を繰り返し出力（macOS互換）
repeat_char() {
    local char="$1"
    local count="$2"
    local i
    for ((i=0; i<count; i++)); do printf '%s' "$char"; done
}

# プログレスバー生成
progress_bar() {
    local percent=$1
    local width=${2:-20}
    local filled=$((percent * width / 100))
    local empty=$((width - filled))

    printf "${C_GREEN}"
    repeat_char '█' "$filled"
    printf "${C_DIM}"
    repeat_char '░' "$empty"
    printf "${C_RESET}"
}

# 全体の進捗計算
calc_overall_progress() {
    local total=0
    local count=0

    for worker in frontend backend test debug; do
        local file="$SPEC_DIR/${worker}.md"
        if [[ -f "$file" ]]; then
            local p=$(parse_worker_progress "$file")
            total=$((total + p))
            count=$((count + 1))
        fi
    done

    if [[ $count -gt 0 ]]; then
        echo $((total / count))
    else
        echo 0
    fi
}

# 最近のアクティビティ取得
get_recent_activities() {
    local limit=${1:-6}
    local activities=""

    for worker in frontend backend test debug; do
        local file="$SPEC_DIR/${worker}.md"
        if [[ -f "$file" ]]; then
            while IFS= read -r line; do
                if [[ -n "$line" ]]; then
                    echo "${worker}|${line}"
                fi
            done < <(grep "^\[" "$file" 2>/dev/null | tail -5)
        fi
    done | sort -t'|' -k2 -r | head -$limit
}

# ダッシュボード描画
draw_dashboard() {
    local wt_name=$(get_worktree_name "$SPEC_DIR")
    local timestamp=$(date "+%H:%M:%S")
    local overall=$(calc_overall_progress)
    local width=64

    clear

    # ヘッダー
    printf "${C_BG_BLUE}${C_WHITE}${C_BOLD}"
    printf "  🎯 Vibe Dashboard"
    printf "%*s" $((width - 33)) "[$wt_name] $timestamp  "
    printf "${C_RESET}\n"

    # 区切り線
    printf "${C_DIM}"
    repeat_char '═' "$width"
    printf "${C_RESET}\n"

    # 全体進捗
    printf "\n  ${C_BOLD}📊 Overall Progress${C_RESET}  "
    progress_bar $overall 30
    printf " ${C_BOLD}%3d%%${C_RESET}\n\n" $overall

    # 区切り線
    printf "${C_DIM}"
    repeat_char '─' "$width"
    printf "${C_RESET}\n"

    # Worker テーブルヘッダー
    printf "  ${C_BOLD}%-12s %-8s %-24s %s${C_RESET}\n" "Worker" "Status" "Progress" "Latest"
    printf "${C_DIM}"
    repeat_char '─' "$width"
    printf "${C_RESET}\n"

    # 各Worker
    for worker in frontend backend test debug; do
        local file="$SPEC_DIR/${worker}.md"
        local icon=$(get_worker_icon "$worker")
        local color=$(get_worker_color "$worker")
        local status=$(parse_worker_status "$file")
        local progress=$(parse_worker_progress "$file")
        local status_icon=$(get_status_icon "$status")
        local message=$(get_latest_message "$file")

        # ファイルが存在する場合のみ表示
        if [[ -f "$file" ]] || [[ "$status" != "waiting" ]]; then
            printf "  ${color}$icon %-10s${C_RESET}" "$worker"
            printf " $status_icon  "
            progress_bar $progress 12
            printf " ${C_DIM}%s${C_RESET}\n" "$message"
        fi
    done

    # アクティビティログ
    printf "\n${C_DIM}"
    repeat_char '─' "$width"
    printf "${C_RESET}\n"
    printf "  ${C_BOLD}📝 Recent Activity${C_RESET}\n"
    printf "${C_DIM}"
    repeat_char '─' "$width"
    printf "${C_RESET}\n"

    local activities=$(get_recent_activities 6)
    if [[ -n "$activities" ]]; then
        while IFS='|' read -r worker line; do
            local color=$(get_worker_color "$worker")
            local time=$(echo "$line" | grep -o '^\[[^]]*\]' || echo "[--:--]")
            local msg=$(echo "$line" | sed 's/^\[[^]]*\] //')
            printf "  ${C_DIM}%s${C_RESET} ${color}%-10s${C_RESET} %s\n" "$time" "$worker:" "${msg:0:42}"
        done <<< "$activities"
    else
        printf "  ${C_DIM}No activity yet...${C_RESET}\n"
    fi

    # フッター
    printf "\n${C_DIM}"
    repeat_char '═' "$width"
    printf "${C_RESET}\n"
    printf "  ${C_DIM}[q]${C_RESET} Quit  ${C_DIM}[r]${C_RESET} Refresh  ${C_DIM}[w]${C_RESET} Worktree  ${C_DIM}[d]${C_RESET} Detail\n"
}

# メイン
main() {
    # .specディレクトリがなければ作成
    [[ ! -d "$SPEC_DIR" ]] && mkdir -p "$SPEC_DIR"

    # 初期パスを共有ファイルに書き込み
    update_spec_path

    # 非カノニカルモードに設定
    stty -echo -icanon time 0 min 0 2>/dev/null || true

    # 終了時にクリーンアップ
    trap cleanup INT TERM EXIT

    while true; do
        draw_dashboard

        # タイムアウト付きでキー入力を待つ（より堅牢な方法）
        if read -rsn1 -t "$REFRESH_INTERVAL" key 2>/dev/null; then
            case "$key" in
                q|Q)
                    stty echo icanon 2>/dev/null
                    clear
                    exit 0
                    ;;
                r|R)
                    # 即座にリフレッシュ
                    continue
                    ;;
                d|D)
                    stty echo icanon 2>/dev/null
                    clear
                    local script_dir="$(dirname "$0")"
                    "$script_dir/plan-viewer.sh" "$SPEC_DIR"
                    stty -echo -icanon time 0 min 0 2>/dev/null || true
                    ;;
                w|W)
                    stty echo icanon 2>/dev/null
                    clear
                    local selected=$(show_worktrees)
                    if [[ -n "$selected" ]]; then
                        local target_spec="$(echo "$selected" | cut -f2)"
                        # シンボリックリンクを切り替え
                        switch_spec_symlink "$target_spec"
                        # SPEC_DIRはgit rootの.specを指す（シンボリックリンク経由）
                        SPEC_DIR="$(get_git_root)/.spec"
                        update_spec_path  # plan-watcherに通知
                    fi
                    stty -echo -icanon time 0 min 0 2>/dev/null || true
                    ;;
            esac
        fi
        # タイムアウトまたはキー処理後、自動的に次の描画へ
    done
}

main
