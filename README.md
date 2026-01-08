# Terminal Setting

Ghostty + Zellij + Yazi を使った IDE 風ターミナル設定

## スクリーンショット

```
┌────────────────────────────────────────────────────────────────┐
│  Code  │  Git  │  Claude  │  Codex  │            (タブバー) │
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
- **複数タブ**: Code / Git / Claude / Codex タブ

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

または手動でコピー:

```bash
# Zellij レイアウト
mkdir -p ~/.config/zellij/layouts
cp zellij/layouts/ide.kdl ~/.config/zellij/layouts/

# Yazi 設定
mkdir -p ~/.config/yazi/plugins/zellij-nav.yazi
cp yazi/yazi.toml ~/.config/yazi/
cp yazi/keymap.toml ~/.config/yazi/
cp yazi/init.lua ~/.config/yazi/
cp yazi/plugins/zellij-nav.yazi/main.lua ~/.config/yazi/plugins/zellij-nav.yazi/
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
| `Alt+1/2/3/4` | タブ切り替え |
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
~/.config/
├── zellij/
│   └── layouts/
│       └── ide.kdl              # Zellij レイアウト定義
└── yazi/
    ├── yazi.toml                # Yazi 基本設定
    ├── keymap.toml              # キーマップ設定
    ├── init.lua                 # 初期化スクリプト
    └── plugins/
        └── zellij-nav.yazi/
            └── main.lua         # Zellij 連携プラグイン
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
