#!/bin/bash
# tmux版: スキル送信スクリプト
# 使用方法: activate-skills.sh [session-name]

SESSION_NAME="${1:-ide}"

echo "=== スキル送信 ==="

# orchestratorへ (Impl.1)
tmux send-keys -t "$SESSION_NAME:Impl.1" '/tmux-orchestration:orchestrator'
tmux send-keys -t "$SESSION_NAME:Impl.1" Enter
echo "  -> orchestrator: /tmux-orchestration:orchestrator"

echo ""
echo "=== 完了 ==="
