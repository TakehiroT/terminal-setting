#!/bin/bash
# Terminal Setting インストールスクリプト

set -e

echo "=== Terminal Setting Installer ==="
echo ""

# 必要なツールの確認
echo "必要なツールを確認中..."
MISSING_TOOLS=()

command -v zellij >/dev/null 2>&1 || MISSING_TOOLS+=("zellij")
command -v yazi >/dev/null 2>&1 || MISSING_TOOLS+=("yazi")
command -v nvim >/dev/null 2>&1 || MISSING_TOOLS+=("neovim")
command -v bat >/dev/null 2>&1 || MISSING_TOOLS+=("bat")
command -v glow >/dev/null 2>&1 || MISSING_TOOLS+=("glow")
command -v lazygit >/dev/null 2>&1 || MISSING_TOOLS+=("lazygit")

if [ ${#MISSING_TOOLS[@]} -ne 0 ]; then
    echo "以下のツールがインストールされていません:"
    printf '  - %s\n' "${MISSING_TOOLS[@]}"
    echo ""
    echo "Homebrew でインストール:"
    echo "  brew install ${MISSING_TOOLS[*]}"
    echo ""
    read -p "続行しますか? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# ディレクトリ作成
echo "ディレクトリを作成中..."
mkdir -p ~/.config/zellij/layouts
mkdir -p ~/.config/zellij/scripts
mkdir -p ~/.config/yazi/plugins/zellij-nav.yazi
mkdir -p ~/.claude/skills/orchestrator
mkdir -p ~/.claude/skills/worker
mkdir -p ~/.codex/skills/reviewer

# ファイルコピー
echo "設定ファイルをコピー中..."

# Zellij
cp zellij/layouts/ide.kdl ~/.config/zellij/layouts/
cp zellij/scripts/claude-orchestrator.sh ~/.config/zellij/scripts/
chmod +x ~/.config/zellij/scripts/claude-orchestrator.sh

# Yazi
cp yazi/yazi.toml ~/.config/yazi/
cp yazi/keymap.toml ~/.config/yazi/
cp yazi/init.lua ~/.config/yazi/
cp yazi/plugins/zellij-nav.yazi/main.lua ~/.config/yazi/plugins/zellij-nav.yazi/

# Claude skills
cp claude/skills/orchestrator/SKILL.md ~/.claude/skills/orchestrator/
cp claude/skills/worker/SKILL.md ~/.claude/skills/worker/

# Codex skills
cp codex/skills/reviewer/SKILL.md ~/.codex/skills/reviewer/

echo ""
echo "=== インストール完了 ==="
echo ""
echo "以下のエイリアスを ~/.bashrc または ~/.zshrc に追加してください:"
echo ""
echo '# Zellij IDE mode'
echo 'alias ide="zellij --layout ide"'
echo 'alias zj="zellij"'
echo 'alias zja="zellij attach"'
echo 'alias zjls="zellij list-sessions"'
echo 'alias zjkill="zellij delete-all-sessions -f"'
echo ''
echo '# Yazi'
echo 'alias y="yazi"'
echo ""
echo "その後、'source ~/.bashrc' を実行し、'ide' で起動してください。"
echo ""
echo "=== AIスキル ==="
echo "Claude: ~/.claude/skills/ に orchestrator, worker スキルをインストール済み"
echo "Codex: ~/.codex/skills/ に reviewer スキルをインストール済み"
echo ""
echo "ImplタブでAI並列開発を開始するには、'ide' で起動後 Alt+3 でImplタブへ移動してください。"
