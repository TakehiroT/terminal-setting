#!/bin/bash
# zellij版: アクションメニュー (Alt+m で呼び出し)
# tmuxのdisplay-menuと同等の機能を提供

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# メニュー項目
options=(
    "Activate Skills"
    "Restart Claude/Codex"
    "Go to Git"
    "Cleanup & Restart"
)

# fzfでメニュー表示
selected=$(printf '%s\n' "${options[@]}" | fzf --height=10 --reverse --border --header=" Actions " --prompt="")

# 選択がなければ終了
[ -z "$selected" ] && exit 0

# フローティングペインを非表示にする（バックグラウンドペインにフォーカスが移る）
zellij action toggle-floating-panes
sleep 0.2

# アクションを実行（この時点でフォーカスは通常ペインにある）
case "$selected" in
    "Activate Skills")
        "$SCRIPT_DIR/activate-skills.sh"
        ;;
    "Restart Claude/Codex")
        # Implタブに移動
        zellij action go-to-tab-name "Impl"
        sleep 0.2

        # orchestratorペインへ移動（左）
        zellij action move-focus left
        sleep 0.2

        # /exitを送信
        zellij action write-chars '/exit'
        zellij action write 13
        sleep 0.3

        # reviewerへ移動（右）
        zellij action move-focus right
        sleep 0.2

        # /exitを送信
        zellij action write-chars '/exit'
        zellij action write 13
        ;;
    "Go to Git")
        zellij action go-to-tab-name "Git"
        ;;
    "Cleanup & Restart")
        "$SCRIPT_DIR/cleanup-restart.sh"
        ;;
esac

# フローティングペインを再表示して閉じる
zellij action toggle-floating-panes
sleep 0.1
zellij action close-pane
