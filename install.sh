#!/bin/bash
# Terminal Setting インストールスクリプト

set -e

echo "=== Terminal Setting Installer ==="
echo ""

# 必要なツールの確認
echo "必要なツールを確認中..."
MISSING_TOOLS=()

command -v zellij >/dev/null 2>&1 || MISSING_TOOLS+=("zellij")
command -v tmux >/dev/null 2>&1 || MISSING_TOOLS+=("tmux")
command -v yazi >/dev/null 2>&1 || MISSING_TOOLS+=("yazi")
command -v nvim >/dev/null 2>&1 || MISSING_TOOLS+=("neovim")
command -v bat >/dev/null 2>&1 || MISSING_TOOLS+=("bat")
command -v glow >/dev/null 2>&1 || MISSING_TOOLS+=("glow")
command -v lazygit >/dev/null 2>&1 || MISSING_TOOLS+=("lazygit")
command -v delta >/dev/null 2>&1 || MISSING_TOOLS+=("git-delta")
command -v fzf >/dev/null 2>&1 || MISSING_TOOLS+=("fzf")
command -v rg >/dev/null 2>&1 || MISSING_TOOLS+=("ripgrep")
command -v fd >/dev/null 2>&1 || MISSING_TOOLS+=("fd")

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
mkdir -p ~/.config/tmux/scripts
mkdir -p ~/.local/bin
mkdir -p ~/.config/yazi/plugins
mkdir -p ~/.codex/skills/reviewer
mkdir -p ~/.codex/skills/tmux-reviewer
mkdir -p ~/.config/ghostty
mkdir -p ~/.config/nvim
mkdir -p ~/.config/lazygit

# ファイルコピー
echo "設定ファイルをコピー中..."

# Zellij
cp zellij/config.kdl ~/.config/zellij/
cp zellij/layouts/ide.kdl ~/.config/zellij/layouts/
cp zellij/scripts/activate-skills.sh ~/.config/zellij/scripts/
cp zellij/scripts/cleanup-restart.sh ~/.config/zellij/scripts/
cp zellij/scripts/menu.sh ~/.config/zellij/scripts/
chmod +x ~/.config/zellij/scripts/*.sh

# tmux
cp tmux/tmux.conf ~/.tmux.conf
cp tmux/scripts/*.sh ~/.config/tmux/scripts/
chmod +x ~/.config/tmux/scripts/*.sh
# idet コマンドをパスに追加
ln -sf ~/.config/tmux/scripts/ide.sh ~/.local/bin/idet

# Yazi
cp yazi/yazi.toml ~/.config/yazi/
cp yazi/keymap.toml ~/.config/yazi/
cp yazi/init.lua ~/.config/yazi/
cp -r yazi/plugins/* ~/.config/yazi/plugins/

# 外部プラグイン
# git.yazi（Gitステータス表示）
if [ ! -d ~/.config/yazi/plugins/git.yazi ]; then
    echo "git.yazi プラグインをインストール中..."
    TEMP_DIR=$(mktemp -d)
    git clone --depth 1 https://github.com/yazi-rs/plugins.git "$TEMP_DIR"
    mv "$TEMP_DIR/git.yazi" ~/.config/yazi/plugins/
    rm -rf "$TEMP_DIR"
fi

# fg.yazi（fzf+rg全文検索）
if [ ! -d ~/.config/yazi/plugins/fg.yazi ]; then
    echo "fg.yazi プラグインをインストール中..."
    git clone --depth 1 https://github.com/DreamMaoMao/fg.yazi.git \
        ~/.config/yazi/plugins/fg.yazi
fi

# Codex config & skills
cp codex/config.json ~/.codex/
cp codex/skills/reviewer/SKILL.md ~/.codex/skills/reviewer/
cp codex/skills/tmux-reviewer/SKILL.md ~/.codex/skills/tmux-reviewer/

# Claude Code rules (グローバル設定)
echo "Claude Code rules をインストール中..."
mkdir -p ~/.claude/rules
for file in rules/*.md; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        cp "$file" ~/.claude/rules/terminal-setting-"$filename"
    fi
done

# Ghostty（既存設定がある場合はスキップ）
if [ ! -f ~/.config/ghostty/config ]; then
    cp ghostty/config ~/.config/ghostty/
else
    echo "Ghostty: 既存設定を維持（上書きスキップ）"
fi

# Neovim (VSCode-like config with LSP)
echo "Neovim設定をインストール中..."
if [ -d ~/.config/nvim ] && [ -f ~/.config/nvim/init.lua ]; then
    # 既存設定がこのリポジトリのものでなければバックアップ
    if ! grep -q "terminal-setting Neovim Config" ~/.config/nvim/init.lua 2>/dev/null; then
        BACKUP_DIR=~/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)
        echo "既存のNeovim設定をバックアップ: $BACKUP_DIR"
        mv ~/.config/nvim "$BACKUP_DIR"
        mkdir -p ~/.config/nvim
    fi
fi
# 古いpackディレクトリがあれば削除（lazy.nvimに移行）
if [ -d ~/.config/nvim/pack ]; then
    echo "古いプラグインディレクトリを削除中..."
    rm -rf ~/.config/nvim/pack
fi
cp nvim/init.lua ~/.config/nvim/
echo "初回起動時にlazy.nvimが自動でプラグインをインストールします"

# lazygit (delta でシンタックスハイライト付きdiff)
echo "lazygit設定をインストール中..."
cp lazygit/config.yml ~/.config/lazygit/

# Git Diff Viewer (mainとの差分 + worktree切り替え)
echo "Git Diff Viewerをインストール中..."
cp scripts/git-diff-viewer.sh ~/.local/bin/git-diff-viewer
chmod +x ~/.local/bin/git-diff-viewer

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
echo '# tmux (idetは~/.local/bin/にインストール済み)'
echo 'export PATH="$HOME/.local/bin:$PATH"'
echo 'alias tma="tmux attach"'
echo 'alias tmls="tmux list-sessions"'
echo 'alias tmkill="tmux kill-server"'
echo ''
echo '# Yazi'
echo 'alias y="yazi"'
echo ""
echo "その後、'source ~/.bashrc' を実行してください。"
echo ""
echo "=== Neovim 設定 ==="
echo "VSCodeライクな編集 + LSP定義ジャンプ:"
echo "  - Ctrl+S: 保存, Ctrl+Z: 元に戻す"
echo "  - Ctrl+C/V: コピー/ペースト"
echo "  - Shift+矢印: 選択"
echo "  - ダブルクリック: 定義をプレビュー (Peek)"
echo "  - Ctrl+D: 定義にジャンプ"
echo "  - ?: ヘルプ表示"
echo "  - Esc×2: 終了（未保存確認あり）"
echo ""
echo "=== Language Server (LSP) ==="
echo "定義ジャンプを使うには Language Server が必要です:"
echo "  npm install -g typescript-language-server typescript  # TypeScript/JS"
echo "  pip install pyright                                    # Python"
echo "  go install golang.org/x/tools/gopls@latest            # Go"
echo "  rustup component add rust-analyzer                    # Rust"
echo "  brew install lua-language-server                      # Lua"
echo ""
echo "=== 起動方法 ==="
echo "  ide   : Zellij版IDE環境"
echo "  idet  : tmux版IDE環境"
echo ""
echo "=== Claude Code プラグイン ==="
echo "Claude Code 内で以下を実行してスキルをインストール:"
echo "  /plugin marketplace add TakehiroT/terminal-setting"
echo ""
echo "  # Zellij版"
echo "  /plugin install zellij-orchestration@terminal-setting"
echo ""
echo "  # tmux版"
echo "  /plugin install tmux-orchestration@terminal-setting"
echo ""
echo "含まれるスキル: orchestrator (両方同じスキル名)"
echo ""
echo "=== Vibe Coding (planモード連携) ==="
echo "各プロジェクトの .claude/settings.json に以下を追加:"
echo '  {"plansDirectory": "./.spec"}'
echo ""
echo "または templates/settings.json をコピー:"
echo "  cp $(pwd)/templates/settings.json <your-project>/.claude/settings.json"
echo ""
echo "=== Codex スキル ==="
echo "Codex: ~/.codex/skills/ にスキルをインストール済み"
echo "  - reviewer      : Zellij版レビュアー"
echo "  - tmux-reviewer : tmux版レビュアー"
echo ""
echo "=== Implタブの使い方 (Zellij: ide) ==="
echo "1. 'ide' で起動"
echo "2. Alt+3 でImplタブへ移動"
echo "3. triggerペインでEnterを押してスキル有効化"
echo "4. Orchestratorにタスクを依頼"
echo "5. 作業完了後、restartペインでEnterを押してクリーンアップ"
echo ""
echo "=== Implタブの使い方 (tmux: idet) ==="
echo "1. 'idet' で起動"
echo "2. Alt+3 でImplタブへ移動"
echo "3. Alt+m でアクションメニューを表示:"
echo "   a: Activate Skills - スキル有効化"
echo "   r: Restart - claude/codex再起動"
echo "   g: Go to Git - Gitタブへ移動"
echo "   c: Cleanup & Restart - worktree削除＆再起動"
echo "4. 外部からテキスト送信 (tmux send-keys):"
echo "   tmux send-keys -t ide:Impl.1 'メッセージ'"
echo "   tmux send-keys -t ide:Impl.1 Enter"
echo ""

# gtr (Git Worktree Runner) のインストール確認
echo "=== Git Worktree Runner (推奨) ==="
if command -v git-gtr >/dev/null 2>&1 || [ -f "$HOME/.local/bin/git-gtr" ]; then
    echo "gtr: インストール済み"
else
    echo "gtrは複数のClaudeが同じファイルを編集するコンフリクトを防ぎます。"
    echo ""
    read -p "gtr (Git Worktree Runner) をインストールしますか? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "gtrをインストール中..."
        TEMP_DIR=$(mktemp -d)
        git clone https://github.com/coderabbitai/git-worktree-runner.git "$TEMP_DIR/git-worktree-runner"
        cd "$TEMP_DIR/git-worktree-runner"
        ./install.sh
        cd -
        rm -rf "$TEMP_DIR"
        echo ""
        echo "gtrの使い方:"
        echo "  git gtr new frontend    # ワークツリー作成"
        echo "  git gtr ai frontend     # ワークツリーでClaude起動"
        echo "  git gtr list            # 一覧表示"
        echo "  git gtr rm frontend     # 削除"
    else
        echo "後でインストールする場合:"
        echo "  git clone https://github.com/coderabbitai/git-worktree-runner.git"
        echo "  cd git-worktree-runner && ./install.sh"
    fi
fi
echo ""
echo "セットアップ完了！"
