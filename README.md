# Terminal Setting

Ghostty + Zellij/tmux + Yazi を使った IDE 風ターミナル設定

**2つの環境を提供:**
- `ide` - Zellij版（モダンなUI、初心者向け）
- `idet` - tmux版（セッション間通信、上級者向け）

## Neovim 設定 (VSCode風 + LSP)

Vim知識不要で使えるVSCode風エディタ + LSP定義ジャンプ:

### 基本操作
| キー | 動作 |
|------|------|
| クリック | カーソル移動 |
| 文字入力 | そのまま入力（自動でInsertモード） |
| ドラッグ | テキスト選択 |
| Ctrl+S | 保存 |
| Ctrl+Z | 元に戻す |
| Ctrl+Shift+Z | やり直し |
| Ctrl+A | 全選択 |
| Ctrl+C/V | コピー/ペースト |
| Shift+矢印 | 選択 |
| ? | ヘルプ表示 |
| Esc×2 | 終了（未保存確認あり） |

### LSP定義ジャンプ
| キー | 動作 |
|------|------|
| **ダブルクリック** | 定義をフローティングでプレビュー (Peek) |
| **Ctrl+D** | 定義に直接ジャンプ |
| Enter (プレビュー内) | ファイルを開く |
| Esc (プレビュー内) | プレビューを閉じる |

### Git差分表示
| キー | 動作 |
|------|------|
| **Ctrl+G** | diffview.nvimでGit差分ビューを開く |
| q / Esc | 差分ビューを閉じる |

### Language Server インストール

```bash
# TypeScript/JavaScript
npm install -g typescript-language-server typescript

# Python
pip install pyright

# Go
go install golang.org/x/tools/gopls@latest

# Rust
rustup component add rust-analyzer

# Lua
brew install lua-language-server
```

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
│  Code  │  Git  │  Diff  │  Impl  │              (タブバー) │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│   Yazi (ビルトインプレビュー付き)                               │
│   ファイル一覧 │ 詳細 │ プレビュー（画像/SVG/テキスト）           │
│                                                                │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│   Terminal (auto cd sync)                                      │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

## 機能

- **IDE風レイアウト**: 上部にYazi（ビルトインプレビュー付き）、下部にターミナル
- **画像プレビュー**: 画像/SVG/PDFなどをYazi内で自動プレビュー（chafa使用）
- **Markdownプレビュー**: glowによるMarkdownレンダリング（キャッシュ付きカスタムプラグイン）
- **フローティング編集**: Enter/`e`でNeovim、`g`でlazygitをフローティングペインで起動
- **ディレクトリ同期**: Yaziでディレクトリ移動すると、ターミナルも自動で追従
- **AI並列開発**: ImplタブでClaude Orchestrator + Codex Reviewerによる開発
- **Vibe Coding**: Claude Code planモードと連携した「見守る」開発スタイル

## タブ構成

| タブ | 内容 |
|------|------|
| Code | Yazi（ビルトインプレビュー） + Terminal |
| Git | lazygit（delta でシンタックスハイライト付きdiff） |
| Diff | mainとの差分表示 + worktree切り替え |
| Impl | Claude Orchestrator + Codex Reviewer |

## Diff タブ（Git差分ビューア）

mainブランチとの差分をfzf + deltaで表示。worktree切り替えも可能。

```
┌─ Files ───────────────┬─ Preview (delta) ────────────────────┐
│ [wt] branch ← main    │                                      │
│                       │ @@ -10,5 +10,8 @@                    │
│ src/app.ts           │ - const old = "value";               │
│ src/utils.ts         │ + const new = "updated";             │
│ package.json         │                                      │
└───────────────────────┴──────────────────────────────────────┘
```

### 操作

| キー | 動作 |
|------|------|
| `↑/↓` | ファイル選択 |
| `Enter` | diff全画面表示 |
| `Tab` | worktree一覧へ切り替え |
| `Esc` | 終了 |
| `Ctrl+R` | リロード |

## Impl タブ（AI並列開発）

```
┌──────────────────────────┬─────────────┐
│                          │             │
│       orchestrator       │   reviewer  │
│        (Claude)          │   (Codex)   │
│                          │             │
├─────────────┬────────────┴─────────────┤
│  [trigger]  │  [restart]               │
└─────────────┴──────────────────────────┘
```

### 役割分担

- **Orchestrator (Claude)**: 全体の指揮、タスク分割、Task toolでWorker並列実行
- **Reviewer (Codex)**: コードレビュー、品質チェック

### 下部ボタン

| ボタン | 機能 |
|--------|------|
| `trigger` | Enterでスキル送信 (`/orchestrator`) |
| `restart` | Enterでworktree削除 → main移動 → claude/codex再起動 |

### 使い方 (Zellij版)

1. `ide` でZellijを起動
2. `Alt+3` でImplタブへ移動
3. triggerペインでEnterを押してスキルを有効化
4. Orchestratorにタスクを依頼
5. 作業完了後、restartペインでEnterを押してクリーンアップ

## tmux版 Impl タブ

tmux版は `idet` コマンドで起動します。

```
┌──────────────────────────┬─────────────┐
│                          │             │
│       orchestrator       │   reviewer  │
│        (Claude)          │   (Codex)   │
│                          │             │
└──────────────────────────┴─────────────┘
  Alt+m でアクションメニュー表示
```

### アクションメニュー (Alt+m)

| キー | 機能 |
|------|------|
| `a` | Activate Skills - スキル有効化 |
| `r` | Restart - claude/codex再起動 |
| `g` | Go to Git - Gitタブへ移動 |
| `c` | Cleanup & Restart - worktree削除＆再起動 |

### 使い方 (tmux版)

1. `idet` でtmuxを起動
2. `Alt+3` でImplタブへ移動
3. `Alt+m` → `a` でスキルを有効化
4. Orchestratorにタスクを依頼
5. 作業完了後、`Alt+m` → `c` でクリーンアップ

### tmux の利点

- **セッション間通信**: `tmux send-keys` で外部からテキスト送信可能
- **スクリプト連携**: シェルスクリプトからclaude/codexを操作
- **軽量**: Zellijより低リソース

## Vibe Coding（Claude Code planモード連携）

Claude Codeのplanモードを活用した「見守る」開発スタイル。コードを書くのではなく、AIに指示を出して結果を確認するワークフローです。

### セットアップ

プロジェクトの `.claude/settings.json` に以下を追加:

```json
{
  "plansDirectory": "./.spec"
}
```

テンプレートは `templates/settings.json` を参照。

### ワークフロー

```
1. Shift+Tab でplanモードに切り替え
2. 要件を入力 → 計画が .spec/ に自動保存
3. Worker を起動 → 自動的にplanを読み込み
4. 実装を見守る
5. レビュー → PR作成
```

### planモード操作

| 操作 | キー |
|------|------|
| planモード切り替え | `Shift+Tab` |
| Extended Thinking | `Option+T` (macOS) / `Alt+T` |
| Verbose Mode | `Ctrl+O` |

### メリット

- **タスク定義の自動化**: 手動で task.md を書く必要なし
- **コンテキスト共有**: Workerが自動的にplanを読み込む
- **計画の可視化**: `.spec/` ディレクトリで計画を確認可能

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
# コアツール
brew install zellij yazi neovim lazygit git-delta

# Yazi 必須依存（プラグインで使用）
brew install glow    # Markdownプレビュー (glow.yazi)
brew install bat     # テキストプレビュー

# Yazi プレビュー用（オプション - 画像/SVG/動画等）
brew install chafa              # 画像プレビュー
brew install resvg              # SVGプレビュー
brew install ffmpegthumbnailer  # 動画サムネイル
brew install unar p7zip         # アーカイブプレビュー

# Yazi 検索用（必須 - fg.yaziプラグインで使用）
brew install fzf ripgrep fd

# AI ツール（オプション）
# Claude Code: https://claude.ai/download
# Codex: npm install -g @openai/codex
```

### Yazi 依存関係一覧

| ツール | 用途 | 必須 |
|--------|------|------|
| glow | Markdownプレビュー | ✅ |
| bat | テキストプレビュー・シンタックスハイライト | ✅ |
| fzf | ファジー検索UI（fg.yaziプラグイン） | ✅ |
| ripgrep | 全文検索（fg.yaziプラグイン） | ✅ |
| fd | ファイル名検索（fg.yaziプラグイン） | ✅ |
| chafa | 画像プレビュー（PNG, JPG等） | - |
| resvg | SVGプレビュー | - |
| ffmpegthumbnailer | 動画サムネイル | - |
| unar | アーカイブ内容プレビュー | - |
| p7zip | 7zアーカイブ対応 | - |

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
# Ghostty 設定
mkdir -p ~/.config/ghostty
cp ghostty/config ~/.config/ghostty/

# Zellij レイアウト
mkdir -p ~/.config/zellij/layouts
cp zellij/layouts/ide.kdl ~/.config/zellij/layouts/

# Zellij スクリプト
mkdir -p ~/.config/zellij/scripts
cp zellij/scripts/activate-skills.sh ~/.config/zellij/scripts/
chmod +x ~/.config/zellij/scripts/activate-skills.sh

# Yazi 設定
mkdir -p ~/.config/yazi/plugins/zellij-nav.yazi
mkdir -p ~/.config/yazi/plugins/glow.yazi
cp yazi/yazi.toml ~/.config/yazi/
cp yazi/keymap.toml ~/.config/yazi/
cp yazi/init.lua ~/.config/yazi/
cp yazi/plugins/zellij-nav.yazi/main.lua ~/.config/yazi/plugins/zellij-nav.yazi/
cp yazi/plugins/glow.yazi/main.lua ~/.config/yazi/plugins/glow.yazi/

# Codex skills
mkdir -p ~/.codex/skills/reviewer
cp codex/skills/reviewer/SKILL.md ~/.codex/skills/reviewer/

# Claude Code settings テンプレート（プロジェクトごとにコピー）
# cp templates/settings.json <your-project>/.claude/settings.json

# Claude Code skills (プラグインとしてインストール - 後述)
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

### 4. Claude Code プラグインをインストール

このリポジトリはClaude Codeプラグインマーケットプレイスとして機能します。

```bash
# マーケットプレイスを追加
/plugin marketplace add TakehiroT/terminal-setting

# プラグインをインストール (どちらか選択)
/plugin install zellij-orchestration@terminal-setting   # Zellij版
/plugin install tmux-orchestration@terminal-setting     # tmux版
```

**含まれるプラグイン:**
- `zellij-orchestration` - Zellij版オーケストレーター
- `tmux-orchestration` - tmux版オーケストレーター（send-keys対応）

**含まれるスキル:**
- `orchestrator` - タスク分割と進捗管理、Task toolでWorker並列実行

### 5. シェルを再読み込み

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
| `Enter` | Neovim で編集（フローティングペイン） |
| `e` | Neovim で編集（フローティングペイン） |
| `g` | lazygit を起動（フローティングペイン） |
| `gg` | 先頭へ |
| `G` | 末尾へ |
| `Space` | 選択トグル |
| `/` | ファイル名検索 |
| `f` → `g` | **全文検索 (fzf UI)** - VSCode風 |
| `f` → `f` | **ファイル名検索 (fzf UI)** - VSCode風 |
| `.` | 隠しファイル切り替え |
| `y` | コピー |
| `x` | カット |
| `p` | ペースト |
| `d` | ゴミ箱へ |
| `c` | 新規作成 |
| `r` | リネーム |
| `Ctrl+e` | プレビューを下へスクロール |
| `Ctrl+y` | プレビューを上へスクロール |
| `Ctrl+f` | フィルター |
| `q` | 終了 |

**注**: プレビューはYaziのビルトイン機能で自動表示されます（画像/SVG/PDF/Markdown対応）。

### VSCode風 検索 (fg.yazi プラグイン)

`f` → `g` で全文検索すると、fzfのインタラクティブUIが表示されます：

- 入力した文字列を含むファイルがリアルタイムで絞り込み
- プレビューでマッチ行がハイライト表示
- Enterでファイルに移動またはNeovimで開く

### Zellij 操作

| キー | 動作 |
|------|------|
| `Alt+1/2/3/4` | タブ切り替え (Code/Git/Diff/Impl) |
| `Ctrl+p` → `h/j/k/l` | ペイン移動 |
| `Ctrl+p` → `n` | 新規ペイン |
| `Ctrl+p` → `x` | ペインを閉じる |
| `Ctrl+p` → `Tab` | タブ一覧 |

### tmux 操作

| キー | 動作 |
|------|------|
| `Alt+1/2/3/4/5` | タブ切り替え |
| `Ctrl+p` → `矢印/h/j/k/l` | ペイン移動 |
| `Ctrl+p` → `n` | 新規ペイン（下） |
| `Ctrl+p` → `r` | 新規ペイン（右） |
| `Ctrl+p` → `x` | ペインを閉じる |
| `Ctrl+t` → `n` | 新規タブ |
| `Ctrl+n` → `矢印/h/j/k/l` | リサイズ |
| `Ctrl+s` | スクロール/コピーモード |
| `Ctrl+q` | セッション終了 |
| `Alt+m` | アクションメニュー |

### コマンド

```bash
# Zellij
ide       # Zellij IDE モードで起動
zjkill    # 全セッション削除
zjls      # セッション一覧
zja       # セッションにアタッチ

# tmux
idet      # tmux IDE モードで起動
tmkill    # サーバー終了
tmls      # セッション一覧
tma       # セッションにアタッチ
```

## ファイル構成

```
~/.config/
├── ghostty/
│   └── config                     # Ghostty 設定
│
├── zellij/
│   ├── layouts/
│   │   └── ide.kdl                # Zellij レイアウト定義
│   └── scripts/
│       ├── activate-skills.sh     # スキル送信スクリプト
│       └── cleanup-restart.sh     # クリーンアップ＆再起動スクリプト
│
├── tmux/
│   └── scripts/
│       ├── ide.sh                 # tmux IDE起動スクリプト
│       ├── activate-skills.sh     # スキル送信スクリプト
│       └── cleanup-restart.sh     # クリーンアップ＆再起動スクリプト
│
└── yazi/
    ├── yazi.toml                  # Yazi 基本設定
    ├── keymap.toml                # キーマップ設定
    ├── init.lua                   # 初期化スクリプト
    └── plugins/
        ├── zellij-nav.yazi/       # Zellij/tmux 連携プラグイン
        ├── glow.yazi/             # Markdownプレビュー
        ├── git.yazi/              # Gitステータス (外部: yazi-rs/plugins)
        └── fg.yazi/               # fzf+rg全文検索 (外部: DreamMaoMao/fg.yazi)

├── nvim/
│   └── init.lua                   # Neovim設定 (VSCode風 + LSP)

~/.tmux.conf                       # tmux 設定

~/.local/bin/
├── idet                           # tmux IDE起動コマンド
└── git-diff-viewer                # Git差分ビューア

~/.config/lazygit/
└── config.yml                     # lazygit設定（deltaでシンタックスハイライト）

codex/skills/
├── reviewer/SKILL.md              # Zellij版レビュアースキル
└── tmux-reviewer/SKILL.md         # tmux版レビュアースキル

plugins/                           # Claude Code プラグイン
├── zellij-orchestration/          # Zellij版オーケストレーター
│   ├── .claude-plugin/
│   │   └── plugin.json
│   └── skills/
│       └── orchestrator/SKILL.md
└── tmux-orchestration/            # tmux版オーケストレーター
    ├── .claude-plugin/
    │   └── plugin.json
    └── skills/
        └── orchestrator/SKILL.md
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
ratio = [1, 3, 4]  # [親, 現在, プレビュー] の比率
# [0, 1, 0] で1列表示
# [1, 2, 0] でプレビューなし
```

### Yazi git プラグインの修正

デフォルトの git.yazi プラグインでは、ディレクトリに下層ファイルの変更状態が表示されません。
以下の修正で、サブディレクトリ内のファイルに変更がある場合に親ディレクトリにも変更マークが表示されるようになります。

`~/.config/yazi/plugins/git.yazi/main.lua` の `fetch` 関数内:

```lua
-- 修正前（条件付き）
if job.files[1].cha.is_dir then
    ya.dict_merge(changed, bubble_up(changed))
end

-- 修正後（常に実行）
-- Always bubble up changes from nested files to parent directories
ya.dict_merge(changed, bubble_up(changed))
```

**注意**: `ya pkg upgrade git` でプラグインを更新すると上書きされるため、再度修正が必要です。

## License

MIT
