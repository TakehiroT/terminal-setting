#!/bin/bash
# tmux版: 下部ボタンメニュー
# シンプルなselectメニュー

SESSION_NAME="${1:-ide}"

PS3=""
options=("🚀Activate" "🔄Restart" "📋Git" "🧹Cleanup" "❌Close")

while true; do
    # 1行で横並び表示
    printf '\r  [1]🚀Activate [2]🔄Restart [3]📋Git [4]🧹Cleanup [5]❌Close  '
    read -n 1 -s choice

    case "$choice" in
        1)
            ~/terminal-setting/tmux/scripts/activate-skills.sh "$SESSION_NAME"
            sleep 1
            ;;
        2)
            tmux send-keys -t "$SESSION_NAME:Impl.1" '/exit' Enter
            tmux send-keys -t "$SESSION_NAME:Impl.2" '/exit' Enter
            echo "再起動シグナル送信完了"
            sleep 1
            ;;
        3)
            tmux select-window -t "$SESSION_NAME:Git"
            ;;
        4)
            ~/terminal-setting/tmux/scripts/cleanup-restart.sh "$SESSION_NAME"
            sleep 2
            ;;
        5)
            exit 0
            ;;
    esac
done
