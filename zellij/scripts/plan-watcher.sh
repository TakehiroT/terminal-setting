#!/bin/bash
# Plan Watcher - plan.mdをリアルタイム表示
# glowで表示し、変更を検知して自動更新
# vibe-dashboard.shとworktree切り替えを連動

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

SPEC_DIR="${1:-./.spec}"
REFRESH_INTERVAL=2

# セッション名またはPWDベースでパスファイルを共有
SESSION_ID="${ZELLIJ_SESSION_NAME:-$(pwd | md5sum 2>/dev/null | cut -c1-8 || echo 'default')}"
SPEC_PATH_FILE="/tmp/vibe-spec-path-${SESSION_ID}"

# 共有ファイルからパスを読み取り
read_spec_path() {
    if [[ -f "$SPEC_PATH_FILE" ]]; then
        cat "$SPEC_PATH_FILE"
    else
        echo "$SPEC_DIR"
    fi
}

find_plan_file() {
    local dir="$1"
    # plan.md または *.plan.md を探す（更新日時が新しい順）
    local plan=$(find -L "$dir" -maxdepth 2 -type f \( -name "plan.md" -o -name "*.plan.md" \) 2>/dev/null | xargs ls -t 2>/dev/null | head -1)
    echo "$plan"
}

show_plan() {
    local plan_file="$1"
    clear

    if [[ -f "$plan_file" ]]; then
        # ヘッダー
        echo -e "\033[1m📋 Plan: $(basename "$plan_file")\033[0m"
        echo -e "\033[2m$(dirname "$plan_file")\033[0m"
        echo ""

        # glow でMarkdown表示
        glow -s dark "$plan_file" 2>/dev/null || cat "$plan_file"
    else
        echo -e "\033[2m"
        echo "  No plan file found in $SPEC_DIR"
        echo ""
        echo "  Plan will appear here when created via:"
        echo "    - Claude Code plan mode (Shift+Tab)"
        echo "    - Manual creation: .spec/plan.md"
        echo -e "\033[0m"
    fi
}

get_file_hash() {
    local file="$1"
    if [[ -f "$file" ]]; then
        md5 -q "$file" 2>/dev/null || md5sum "$file" 2>/dev/null | cut -d' ' -f1
    else
        echo "none"
    fi
}

main() {
    local last_hash=""
    local last_file=""
    local last_spec_dir=""

    while true; do
        # 共有ファイルからパスを読み取り（worktree切り替え連動）
        local current_spec_dir=$(read_spec_path)

        # パスが変わったら強制更新
        if [[ "$current_spec_dir" != "$last_spec_dir" ]]; then
            last_spec_dir="$current_spec_dir"
            last_hash=""  # 強制再描画
        fi

        local plan_file=$(find_plan_file "$current_spec_dir")
        local current_hash=$(get_file_hash "$plan_file")

        # ファイルまたはハッシュが変わったら再表示
        if [[ "$plan_file" != "$last_file" ]] || [[ "$current_hash" != "$last_hash" ]]; then
            show_plan "$plan_file"
            last_file="$plan_file"
            last_hash="$current_hash"
        fi

        sleep $REFRESH_INTERVAL
    done
}

main
