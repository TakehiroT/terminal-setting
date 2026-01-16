#!/bin/bash
# zellij版: スキル送信スクリプト
# 使用方法: activate-skills.sh [session-name]
# tmuxと同様にセッション名を引数で受け取る

SESSION_NAME="${1:-}"

echo "=== スキル送信 ==="

# セッション指定がある場合は環境変数を設定
if [[ -n "$SESSION_NAME" ]]; then
    export ZELLIJ_SESSION_NAME="$SESSION_NAME"
fi

# Implタブに移動（タブ名で絶対指定）
zellij action go-to-tab-name "Impl"
sleep 0.2

# orchestratorペインへ移動（左）
zellij action move-focus left
sleep 0.2

# スキルを送信
zellij action write-chars '/zellij-orchestration:orchestrator'
zellij action write 13
echo "  -> orchestrator: /zellij-orchestration:orchestrator"

echo ""
echo "=== 完了 ==="
