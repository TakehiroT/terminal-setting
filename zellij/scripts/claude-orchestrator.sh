#!/bin/bash
# Orchestratorから全ペインにスキルコマンドを送信
# ペイン順序: orchestrator → frontend → reviewer → backend → test
(
  sleep 20
  # 1. Orchestrator (自分自身)
  zellij action write-chars '/orchestrator' && zellij action write 13
  sleep 3
  # 2. Frontend (next x1)
  zellij action focus-next-pane && sleep 0.3 && zellij action write-chars '/worker' && zellij action write 13
  sleep 0.5
  # 3. Reviewer/Codex (next x1)
  zellij action focus-next-pane && sleep 0.3 && zellij action write-chars '$reviewer' && zellij action write 13
  sleep 0.5
  # 4. Backend (next x1)
  zellij action focus-next-pane && sleep 0.3 && zellij action write-chars '/worker' && zellij action write 13
  sleep 0.5
  # 5. Test (next x1)
  zellij action focus-next-pane && sleep 0.3 && zellij action write-chars '/worker' && zellij action write 13
  sleep 0.3
  # Orchestratorに戻る (next x1)
  zellij action focus-next-pane
) &
exec claude --dangerously-skip-permissions
