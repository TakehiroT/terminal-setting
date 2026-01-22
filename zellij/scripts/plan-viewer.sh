#!/bin/bash
# Plan Viewer - planファイルのインタラクティブビューア
# fzfでファイル選択 + worktree切り替え
#
# キーバインド:
#   Enter - 詳細表示 (glow/less)
#   Tab   - ワークツリー切り替え
#   Esc   - 終了

# Homebrew PATH（Intel/Apple Silicon両対応）
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

PLANS_DIR="${1:-./.spec}"

get_git_root() {
    git rev-parse --show-toplevel 2>/dev/null || pwd
}

get_worktree_name() {
    local dir="$1"
    if [[ "$dir" == *"/.branches/"* ]]; then
        echo "$dir" | sed 's|.*/.branches/||' | cut -d'/' -f1
    else
        echo "main"
    fi
}

show_worktrees() {
    local git_root=$(get_git_root)
    local branches_dir="$git_root/.branches"
    local current_wt=$(get_worktree_name "$PLANS_DIR")

    {
        # メインリポジトリ
        if [[ -d "$git_root/.spec" ]]; then
            [ "$current_wt" = "main" ] && echo "▶ main	$git_root/.spec" || echo "  main	$git_root/.spec"
        fi
        # .branches配下
        if [[ -d "$branches_dir" ]]; then
            for wt in "$branches_dir"/*/; do
                if [[ -d "${wt}.spec" ]]; then
                    local name=$(basename "$wt")
                    [ "$current_wt" = "$name" ] && echo "▶ $name	${wt}.spec" || echo "  $name	${wt}.spec"
                fi
            done
        fi
    } | fzf --ansi --delimiter='\t' --with-nth=1 \
        --layout=reverse --height=100% \
        --border=rounded \
        --preview='p=$(echo {} | cut -f2); f=$(find "$p" -maxdepth 3 -type f -name "*.md" 2>/dev/null | xargs ls -t 2>/dev/null | head -1); [ -n "$f" ] && glow -s dark "$f" || echo "No plan files"' \
        --preview-window=right:60%:border-left:wrap \
        --header="Worktrees | Enter: select | Esc: back" \
        --bind='enter:accept'
}

show_files() {
    local wt_name=$(get_worktree_name "$PLANS_DIR")
    local files=$(find "$PLANS_DIR" -maxdepth 3 -type f -name "*.md" 2>/dev/null)

    if [ -z "$files" ]; then
        echo "NO_FILES"
        return
    fi

    # 更新日時順でソートしてファイルパスのみ出力
    find "$PLANS_DIR" -maxdepth 3 -type f -name "*.md" -print0 2>/dev/null | \
        xargs -0 ls -t 2>/dev/null | \
    fzf --ansi \
        --layout=reverse --height=100% \
        --border=rounded \
        --preview='script -q /dev/null glow -s dark {}' \
        --preview-window=right:65%:border-left:wrap \
        --header="[$wt_name] Plans | Enter: view | Tab: worktrees | Esc: quit" \
        --bind="enter:execute(glow -s dark -p {})" \
        --expect=tab
}

# メイン
[ ! -d "$PLANS_DIR" ] && mkdir -p "$PLANS_DIR"

while true; do
    result=$(show_files)
    key=$(echo "$result" | head -1)

    # ファイルなしならworktree選択へ
    if [ "$result" = "NO_FILES" ]; then
        clear
        echo "No plan files in $PLANS_DIR"
        echo "Switching worktree..."
        sleep 1
        selected=$(show_worktrees)
        if [ -n "$selected" ]; then
            PLANS_DIR="$(echo "$selected" | cut -f2)"
            continue
        else
            exit 0
        fi
    fi

    # Escで終了
    [ -z "$result" ] && exit 0

    # Tabでworktree選択
    if [ "$key" = "tab" ]; then
        selected=$(show_worktrees)
        if [ -n "$selected" ]; then
            PLANS_DIR="$(echo "$selected" | cut -f2)"
        fi
    fi
done
