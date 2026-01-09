#!/bin/bash
# 2ペインにスキルコマンドを送信
# ペイン順序: trigger → orchestrator → reviewer
echo "スキルを起動中..."
sleep 2

# 1. Orchestrator (next x1 from trigger)
zellij action focus-next-pane && sleep 0.3 && zellij action write-chars '/orchestrator' && zellij action write 13
sleep 0.5

# 2. Reviewer/Codex (next x1)
zellij action focus-next-pane && sleep 0.3 && zellij action write-chars '$reviewer' && zellij action write 13

echo "完了！このペインを閉じてください (Ctrl+p x)"
