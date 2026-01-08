# Terminal Setting

Ghostty + Zellij + Yazi を使った IDE 風ターミナル設定

## Ghostty 設定

透明背景・ぼかし効果のモダンなターミナル設定:

```
font-family = "UDEV Gothic 35"
font-size = 13
background-opacity = 0.70
background-blur-radius = 20
theme = "Kanagawa Dragon"
```

主な設定:
- **フォント**: UDEV Gothic 35 (日本語対応等幅フォント)
- **テーマ**: Kanagawa Dragon (落ち着いた配色)
- **透明度**: 70% + ぼかし効果
- **タイトルバー**: タブ形式 (macOS)
- **カーソル**: ブロック (点滅なし)
- **クリップボード**: 選択で自動コピー
- **音声入力対応**: Secure Input 無効化

## スクリーンショット

```
┌────────────────────────────────────────────────────────────────┐
│  Code  │  Git  │  Impl  │                      (タブバー) │
├────────────┬────────────────────────────────────────────────────┤
│            │                                                │
│   Yazi     │              Preview / Editor                  │
│  (Files)   │              (bat / nvim)                      │
│            │                                                │
│  2階層表示  ├────────────────────────────────────────────────────┤
│            │                                                │
│            │              Terminal                          │
│            │              (auto cd sync)                    │
│            │                                                │
└────────────┴────────────────────────────────────────────────────┘
```

## 機能

- **IDE風レイアウト**: 左にファイルツリー、右上にプレビュー/エディタ、右下にターミナル
- **Yazi連携**: ファイル選択でプレビュー、Enterでbat表示、`e`でNeovim
- **ディレクトリ同期**: Yaziでディレクトリ移動すると、ターミナルも自動で追従
- **Markdown対応**: `.md`ファイルはglowで読みやすく表示
- **Git連携**: `g`キーでlazygitを起動
- **AI並列開発**: Implタブで4つのClaude + Codexによるオーケストレーション

## タブ構成

| タブ | 内容 |
|------|------|
| Code | Yazi + Preview + Terminal |
| Git | lazygit |
| Impl | Claude x4 + Codex (オーケストレーション) |

## Impl タブ（AI並列開発）

```
┌─────────────┬─────────────┬──────────────┐
│ orchestrator│  frontend   │              │
│  (Pane 0)   │  (Pane 1)   │              │
├─────────────┼─────────────┤   reviewer   │
│  backend    │    test     │  (Pane 2)    │
│  (Pane 3)   │  (Pane 4)   │              │
├─────────────┴─────────────┴──────────────┤
│ [trigger] Press ENTER to activate skills │
└──────────────────────────────────────────┘
```

### 役割分担

- **Orchestrator**: 全体の指揮、タスク分割、進捗管理
- **Frontend**: UI/UX実装、コンポーネント作成
- **Backend**: API、ロジック、データベース
- **Test**: テスト作成、テスト実行
- **Reviewer (Codex)**: コードレビュー、品質チェック

### 使い方

1. `ide` でZellijを起動
2. `Alt+3` でImplタブへ移動
3. 下部のtriggerペインでEnterを押してスキルを有効化
4. triggerペインを閉じる (Ctrl+p x)
5. Orchestratorにタスクを依頼

## Git Worktree で安全な並列開発（推奨）

複数のClaudeが同じファイルを編集するとコンフリクトが発生します。
[gtr (Git Worktree Runner)](https://github.com/coderabbitai/git-worktree-runner) を使うと、各Claudeに独立した作業ディレクトリを割り当てられます。

### gtr インストール

```bash
# リポジトリをクローン
git clone https://github.com/coderabbitai/git-worktree-runner.git
cd git-worktree-runner

# インストール
./install.sh

# クリーンアップ（オプション）
cd ..
rm -rf git-worktree-runner
```

### gtr 使い方

```bash
# ワークツリー作成
git gtr new frontend
git gtr new backend
git gtr new test

# Claude Codeを起動
git gtr config set gtr.ai.default claude
git gtr ai frontend   # frontendワークツリーでClaude起動
git gtr ai backend    # backendワークツリーでClaude起動

# 一覧表示
git gtr list

# 削除
git gtr rm frontend
```

### メリット

- `.env`ファイルの自動コピー
- 作成後のフック（`npm install`等）
- Claude Code連携組み込み
- チーム設定の共有（`.gtrconfig`）

## 必要なツール

```bash
# Homebrew でインストール
brew install zellij yazi neovim bat glow lazygit fd ripgrep

# AI ツール（オプション）
# Claude Code: https://claude.ai/download
# Codex: npm install -g @openai/codex
```

## インストール

### 1. リポジトリをクローン

```bash
git clone https://github.com/TakehiroT/terminal-setting.git
cd terminal-setting
```

### 2. インストールスクリプトを実行

```bash
chmod +x install.sh
./install.sh
```

またはファイルを手動でコピー:

```bash
# Ghostty 設定 (macOS)
mkdir -p "$HOME/Library/Application Support/com.mitchellh.ghostty"
cp ghostty/config "$HOME/Library/Application Support/com.mitchellh.ghostty/"

# Zellij レイアウト
mkdir -p ~/.config/zellij/layouts
cp zellij/layouts/ide.kdl ~/.config/zellij/layouts/

# Zellij スクリプト
mkdir -p ~/.config/zellij/scripts
cp zellij/scripts/activate-skills.sh ~/.config/zellij/scripts/
chmod +x ~/.config/zellij/scripts/activate-skills.sh

# Yazi 設定
mkdir -p ~/.config/yazi/plugins/zellij-nav.yazi
cp yazi/yazi.toml ~/.config/yazi/
cp yazi/keymap.toml ~/.config/yazi/
cp yazi/init.lua ~/.config/yazi/
cp yazi/plugins/zellij-nav.yazi/main.lua ~/.config/yazi/plugins/zellij-nav.yazi/

# Claude skills
mkdir -p ~/.claude/skills/orchestrator ~/.claude/skills/worker
cp claude/skills/orchestrator/SKILL.md ~/.claude/skills/orchestrator/
cp claude/skills/worker/SKILL.md ~/.claude/skills/worker/

# Codex skills
mkdir -p ~/.codex/skills/reviewer
cp codex/skills/reviewer/SKILL.md ~/.codex/skills/reviewer/
```

### 3. シェルエイリアスを追加

`.bashrc` または `.zshrc` に追加:

```bash
# Zellij IDE mode
alias ide="zellij --layout ide"
alias zj="zellij"
alias zja="zellij attach"
alias zjls="zellij list-sessions"
alias zjkill="zellij delete-all-sessions -f"

# Yazi
alias y="yazi"
```

### 4. シェルを再読み込み

```bash
source ~/.bashrc  # or ~/.zshrc
```

## 使い方

### 起動

```bash
ide
```

### Yazi キーバインド

| キー | 動作 |
|------|------|
| `j/k` | 上下移動 |
| `h` | 親ディレクトリへ |
| `l` | ディレクトリに入る |
| `Enter` | プレビュー (bat/glow) |
| `e` | Neovim で編集 |
| `g` | lazygit を起動 |
| `gg` | 先頭へ |
| `G` | 末尾へ |
| `Space` | 選択トグル |
| `/` | 検索 |
| `.` | 隠しファイル切り替え |
| `y` | コピー |
| `x` | カット |
| `p` | ペースト |
| `d` | ゴミ箱へ |
| `c` | 新規作成 |
| `r` | リネーム |
| `q` | 終了 |

### Zellij 操作

| キー | 動作 |
|------|------|
| `Alt+1/2/3` | タブ切り替え |
| `Ctrl+p` → `h/j/k/l` | ペイン移動 |
| `Ctrl+p` → `n` | 新規ペイン |
| `Ctrl+p` → `x` | ペインを閉じる |
| `Ctrl+p` → `Tab` | タブ一覧 |

### コマンド

```bash
ide       # IDE モードで起動
zjkill    # 全セッション削除
zjls      # セッション一覧
zja       # セッションにアタッチ
```

## ファイル構成

```
~/Library/Application Support/com.mitchellh.ghostty/
└── config                         # Ghostty 設定

~/.config/
├── zellij/
│   ├── layouts/
│   │   └── ide.kdl                # Zellij レイアウト定義
│   └── scripts/
│       └── activate-skills.sh     # スキル有効化スクリプト
└── yazi/
    ├── yazi.toml                  # Yazi 基本設定
    ├── keymap.toml                # キーマップ設定
    ├── init.lua                   # 初期化スクリプト
    └── plugins/
        └── zellij-nav.yazi/
            └── main.lua           # Zellij 連携プラグイン

~/.claude/skills/
├── orchestrator/SKILL.md        # オーケストレータースキル
└── worker/SKILL.md              # ワーカースキル

~/.codex/skills/
└── reviewer/SKILL.md            # レビュアースキル
```

## カスタマイズ

### タブの追加・削除

`~/.config/zellij/layouts/ide.kdl` を編集:

```kdl
tab name="NewTab" {
    pane {
        command "your-command"
    }
}
```

### ペイン比率の変更

`ide.kdl` の `size` パラメータを調整:

```kdl
pane size="30%" name="files"  // ファイルツリーの幅
pane size="60%" name="preview" // プレビューの高さ
```

### Yazi の表示列数

`yazi.toml` の `ratio` を変更:

```toml
[mgr]
ratio = [1, 2, 0]  # [親, 現在, プレビュー] の比率
# [0, 1, 0] で1列表示
# [1, 3, 0] で親を狭く
```

## License

MIT
