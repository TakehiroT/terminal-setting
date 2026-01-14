#!/bin/bash
# claude/codexを再起動（/exitを送信）
SESSION_NAME="${1:-ide}"

tmux send-keys -t "$SESSION_NAME:Impl.1" '/exit'
tmux send-keys -t "$SESSION_NAME:Impl.1" Enter
tmux send-keys -t "$SESSION_NAME:Impl.2" '/exit'
tmux send-keys -t "$SESSION_NAME:Impl.2" Enter
