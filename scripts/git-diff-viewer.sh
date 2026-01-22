#!/bin/bash
# Git Diff Viewer - mainとの差分 + worktree切り替え
# シンプルなfzf単体版

get_main_branch() {
    git rev-parse --verify main >/dev/null 2>&1 && echo "main" && return
    git rev-parse --verify master >/dev/null 2>&1 && echo "master" && return
    git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'
}

show_worktrees() {
    local current=$(git rev-parse --show-toplevel)
    git worktree list | while read -r line; do
        local path=$(echo "$line" | awk '{print $1}')
        local branch=$(echo "$line" | sed 's/.*\[\(.*\)\]/\1/')
        [ "$path" = "$current" ] && echo "▶ $branch	$path" || echo "  $branch	$path"
    done | fzf --ansi --delimiter='\t' --with-nth=1 \
        --layout=reverse --height=100% \
        --border=rounded \
        --preview='p=$(echo {} | cut -f2); cd "$p" && m=$(git rev-parse --verify main 2>/dev/null && echo main || echo master); echo "Branch: $(git branch --show-current)"; echo ""; git diff --stat "$m"...HEAD 2>/dev/null | head -20' \
        --preview-window=right:60%:border-left \
        --header="Worktrees | Enter: select | Esc: quit" \
        --bind='enter:accept'
}

show_files() {
    local main=$(get_main_branch)
    local branch=$(git branch --show-current 2>/dev/null || echo "HEAD")
    local wt=$(basename "$(pwd)")
    local files=$(git diff --name-only "$main"...HEAD 2>/dev/null)

    if [ -z "$files" ]; then
        # 差分なし: worktree選択へ
        echo "NO_DIFF"
        return
    fi

    echo "$files" | fzf --ansi --layout=reverse --height=100% \
        --border=rounded \
        --preview="git diff $main...HEAD -- {} | delta --paging=never --width=\$((FZF_PREVIEW_COLUMNS - 4))" \
        --preview-window=right:65%:border-left \
        --header="[$wt] $branch ← $main | Tab: worktrees | Enter: view | Esc: quit" \
        --bind="enter:execute(git diff $main...HEAD --color=always -- {} | delta | less -R)" \
        --expect=tab
}

# メイン
[ ! -d .git ] && [ -z "$(git rev-parse --git-dir 2>/dev/null)" ] && echo "Not a git repo" && exit 1

while true; do
    result=$(show_files)
    key=$(echo "$result" | head -1)

    # 差分なしならworktree選択へ
    if [ "$result" = "NO_DIFF" ]; then
        selected=$(show_worktrees)
        if [ -n "$selected" ]; then
            new_path="$(echo "$selected" | cut -f2)"
            new_branch="$(echo "$selected" | cut -f1 | sed 's/^[▶ ]*//')"
            clear
            echo "Switching to $new_branch..."
            cd "$new_path" 2>/dev/null
            sleep 0.3
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
            new_path="$(echo "$selected" | cut -f2)"
            new_branch="$(echo "$selected" | cut -f1 | sed 's/^[▶ ]*//')"
            clear
            echo "Switching to $new_branch..."
            cd "$new_path" 2>/dev/null
            sleep 0.3
        fi
    fi
done
