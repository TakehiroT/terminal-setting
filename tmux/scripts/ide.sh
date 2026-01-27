#!/bin/bash
# tmux IDE環境起動スクリプト
# 使用方法: idet [session-name]  (省略時は ide-1, ide-2... で自動採番)

if [ -n "$1" ]; then
    SESSION_NAME="$1"
    # 明示的に指定された場合、既存セッションがあればアタッチ
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        exec tmux attach-session -t "$SESSION_NAME"
    fi
else
    # 自動採番: ide-1, ide-2, ... で空き番号を探す
    N=1
    while tmux has-session -t "ide-${N}" 2>/dev/null; do
        N=$((N + 1))
    done
    SESSION_NAME="ide-${N}"
fi

# === Window 1: Code (yazi + terminal) ===
tmux new-session -d -s "$SESSION_NAME" -n "Code"
tmux select-pane -t "$SESSION_NAME:Code.1" -T "files"
tmux split-window -t "$SESSION_NAME:Code" -v -l 30%
tmux select-pane -t "$SESSION_NAME:Code.2" -T "term"
tmux select-pane -t "$SESSION_NAME:Code.1"

# === Window 2: Git (lazygit) ===
tmux new-window -t "$SESSION_NAME" -n "Git"
tmux select-pane -t "$SESSION_NAME:Git.1" -T "lazygit"
tmux send-keys -t "$SESSION_NAME:Git" "lazygit" Enter

# === Window 3: Diff (mainとの差分 + worktree切り替え) ===
tmux new-window -t "$SESSION_NAME" -n "Diff"
tmux select-pane -t "$SESSION_NAME:Diff.1" -T "diff-viewer"
tmux send-keys -t "$SESSION_NAME:Diff" "~/.local/bin/git-diff-viewer" Enter

# === Window 4: Impl (claude + codex) ===
tmux new-window -t "$SESSION_NAME" -n "Impl"
tmux select-pane -t "$SESSION_NAME:Impl.1" -T "orchestrator"
tmux send-keys -t "$SESSION_NAME:Impl" 'while true; do claude --dangerously-skip-permissions; echo "再起動中..."; sleep 1; done' Enter

tmux split-window -t "$SESSION_NAME:Impl" -h -l 30%
tmux select-pane -t "$SESSION_NAME:Impl.2" -T "reviewer"
tmux send-keys -t "$SESSION_NAME:Impl.2" 'while true; do codex; echo "再起動中..."; sleep 1; done' Enter

# === Window 5: Monitor (Worker進捗 + Plan表示) ===
tmux new-window -t "$SESSION_NAME" -n "Monitor"
tmux select-pane -t "$SESSION_NAME:Monitor.1" -T "vibe-dashboard"
tmux send-keys -t "$SESSION_NAME:Monitor" '~/.config/tmux/scripts/vibe-dashboard.sh ./.spec' Enter

tmux split-window -t "$SESSION_NAME:Monitor" -h -l 40%
tmux select-pane -t "$SESSION_NAME:Monitor.2" -T "plan-view"
tmux send-keys -t "$SESSION_NAME:Monitor.2" '~/.config/tmux/scripts/plan-watcher.sh ./.spec' Enter
tmux select-pane -t "$SESSION_NAME:Monitor.1"

# 最初のウィンドウ(Code)を選択
tmux select-window -t "$SESSION_NAME:Code"
tmux select-pane -t "$SESSION_NAME:Code.1"

# アタッチ完了後にyaziを起動するhookを設定
tmux set-hook -t "$SESSION_NAME" client-attached "send-keys -t $SESSION_NAME:Code.1 'yazi' Enter ; set-hook -u -t $SESSION_NAME client-attached"

# アタッチ
exec tmux attach-session -t "$SESSION_NAME"
