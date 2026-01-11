#!/bin/bash
# スキル送信スクリプト
# Enterで実行後、orchestratorにスキルを送信

echo "=== スキル送信 ==="

# orchestratorへ
zellij action move-focus left
zellij action move-focus up
sleep 0.3
zellij action write-chars '/zellij-orchestration:orchestrator'
zellij action write 13
echo "  -> orchestrator: /zellij-orchestration:orchestrator"

echo ""
echo "=== 完了 ==="
