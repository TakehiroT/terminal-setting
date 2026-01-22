# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## リポジトリ概要

Ghostty + Zellij/tmux + Yazi を使ったIDE風ターミナル設定と、Claude Code用のオーケストレーションプラグインを提供するリポジトリ。

**2つの環境を提供:**
- `ide` - Zellij版（モダンなUI、初心者向け）
- `idet` - tmux版（セッション間通信、上級者向け）

## アーキテクチャ

```
terminal-setting/
├── ghostty/          # ターミナル設定（透明背景、Kanagawa Dragon）
├── zellij/           # Zellijレイアウト・スクリプト
│   ├── layouts/ide.kdl
│   └── scripts/      # activate-skills, cleanup-restart等
├── tmux/             # tmux設定・スクリプト
│   └── scripts/ide.sh, button-menu.sh等
├── yazi/             # ファイラー設定
│   └── plugins/      # zellij-nav, glow, fg.yazi
├── nvim/             # Neovim VSCode風設定 + LSP
├── rules/            # Claude Code用コーディングルール
├── plugins/          # Claude Codeプラグイン（マーケットプレイス）
│   ├── zellij-orchestration/
│   ├── tmux-orchestration/
│   └── everything-claude-code/
└── codex/            # Codex用スキル（reviewer）
```

### プラグイン構造

各プラグインは `.claude-plugin/plugin.json` でメタデータを定義:
- `agents/` - サブエージェント定義（YAML/MD形式）
- `skills/` - スキル定義（SKILL.md）
- `commands/` - スラッシュコマンド

**利用可能なエージェント:**
| エージェント | 役割 |
|------------|------|
| planner | 計画立案 |
| architect | アーキテクチャ設計 |
| tdd-guide | TDD実装 |
| build-error-resolver | ビルドエラー解決 |
| e2e-runner | E2Eテスト |
| refactor-cleaner | リファクタリング・デッドコード削除 |
| doc-updater | ドキュメント更新 |

## 主要コマンド

### インストール

```bash
./install.sh
```

必要なツール:
- コアツール: `brew install zellij tmux yazi neovim lazygit git-delta`
- Yazi依存: `brew install glow bat fzf ripgrep fd`

### IDE起動

```bash
ide     # Zellij版
idet    # tmux版
```

### Claude Codeプラグイン

```bash
# マーケットプレイス追加
/plugin marketplace add TakehiroT/terminal-setting

# プラグインインストール
/plugin install zellij-orchestration@terminal-setting
/plugin install tmux-orchestration@terminal-setting
/plugin install everything-claude-code@terminal-setting
```

## Vibe Coding（planモード連携）

プロジェクトの `.claude/settings.json`:
```json
{"plansDirectory": "./.spec"}
```

ワークフロー: planモード（Shift+Tab）→ 計画作成 → Worker起動 → 実装見守り

## オーケストレーターの使い方

`rules/orchestrator.md` に基づくワークフロー:

1. **要件ヒアリング**: 曖昧な点があれば確認
2. **タスク分解**: TodoWriteで管理
3. **サブエージェント委託**: 適切なエージェントにタスクを委託
4. **品質チェック**: `pnpm check && pnpm test && pnpm build`

## コーディング規約

`rules/` ディレクトリ参照:
- **coding-style.md**: イミュータビリティ、早期リターン、命名規則
- **git-workflow.md**: Conventional Commits、1コミット1変更
- **testing.md**: TDD、FIRST原則、カバレッジ80%目標

### Conventional Commits

```
<type>(<scope>): <subject>
```

Type: feat, fix, refactor, docs, test, chore, style, perf, ci, revert

## 設定ファイルの場所

| 設定 | インストール先 |
|------|--------------|
| Zellij | `~/.config/zellij/` |
| tmux | `~/.tmux.conf`, `~/.config/tmux/scripts/` |
| Yazi | `~/.config/yazi/` |
| Neovim | `~/.config/nvim/init.lua` |
| Ghostty | `~/.config/ghostty/config` |
| Claude rules | `~/.claude/rules/` |
| Codex skills | `~/.codex/skills/` |
