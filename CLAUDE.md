# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## リポジトリ概要

Ghostty + Zellij/tmux + Yazi を使ったIDE風ターミナル設定と、Claude Code用のオーケストレーションプラグインを提供するリポジトリ。ビルドシステムやパッケージマネージャは使用していない（dotfiles + シェルスクリプト構成）。

**2つのIDE環境:**
- `ide` - Zellij版（モダンUI、KDLレイアウト定義）
- `idet` - tmux版（`tmux send-keys`によるセッション間通信）

## 主要コマンド

```bash
# インストール（全設定ファイルを~/.config/以下にコピー）
./install.sh

# IDE起動
ide     # Zellij版
idet    # tmux版
```

`install.sh`は設定ファイルのコピーとシンボリックリンク作成のみ。`rules/*.md`は`~/.claude/rules/terminal-setting-`プレフィックス付きでインストールされる。

## アーキテクチャ

### 全体構造

5タブ構成のIDE環境（Zellij/tmux共通）:

| タブ | 内容 | キー |
|------|------|------|
| Code | Yazi(70%) + Terminal(30%)、ディレクトリ自動同期 | Alt+1 |
| Git | lazygit（delta付きdiff） | Alt+2 |
| Diff | mainとの差分表示 + worktree切り替え（fzf+delta） | Alt+3 |
| Impl | Claude Orchestrator(70%) + Codex Reviewer(30%) | Alt+4 |
| Monitor | vibe-dashboard + plan-watcher | Alt+5 |

### ディレクトリ構成

```
terminal-setting/
├── ghostty/              # Ghosttyターミナル設定（Kanagawa Dragon, 透明背景）
├── zellij/
│   ├── layouts/ide.kdl   # 5タブレイアウト定義
│   └── scripts/          # activate-skills.sh, vibe-dashboard.sh等
├── tmux/
│   ├── tmux.conf         # tmux設定（→ ~/.tmux.conf）
│   └── scripts/          # ide.sh, button-menu.sh, activate-skills.sh等
├── yazi/
│   ├── plugins/          # zellij-nav.yazi, glow.yazi（自前プラグイン）
│   └── *.toml, init.lua  # Yazi設定
├── nvim/init.lua         # VSCode風Neovim（lazy.nvim + LSP）
├── lazygit/config.yml    # delta統合
├── scripts/              # git-diff-viewer等
├── rules/                # Claude Codeルール（6ファイル）
├── plugins/              # Claude Codeプラグイン（3つ）
│   ├── everything-claude-code/   # 7エージェント + 4スキル + 7コマンド
│   ├── zellij-orchestration/     # Zellij版オーケストレーター
│   └── tmux-orchestration/       # tmux版オーケストレーター
├── codex/skills/         # Codexレビュアースキル
└── templates/            # settings.jsonテンプレート
```

### プラグインアーキテクチャ

各プラグインは `plugins/<name>/.claude-plugin/plugin.json` でメタデータ定義。

```
plugins/<name>/
├── .claude-plugin/plugin.json   # バージョン、説明等
├── agents/                      # サブエージェント定義（Markdown）
├── skills/                      # スキル定義（SKILL.md）
├── commands/                    # スラッシュコマンド
└── hooks/subagent.json          # SubagentStart/Stopフック
```

**3プラグインの役割分担:**

| プラグイン | 役割 | 主要コンテンツ |
|-----------|------|--------------|
| everything-claude-code | 専門エージェント群 | 7エージェント(planner, architect, tdd-guide, build-error-resolver, e2e-runner, refactor-cleaner, doc-updater) |
| zellij-orchestration | Zellij版並列実行 | 4ワーカー(frontend/backend/test-worker, debugger) + orchestratorスキル |
| tmux-orchestration | tmux版並列実行 | 同上（tmux send-keys対応） |

### Vibe Coding フロー

Implタブ(Alt+4)でのAI並列開発ワークフロー:

1. **計画**: Claude Code planモード(Shift+Tab)で`.spec/`に計画保存
2. **実行**: OrchestratorがTask toolで複数Workerを並列起動
3. **監視**: Monitorタブ(Alt+5)のvibe-dashboardでWorker進捗確認
4. **レビュー**: Codex Reviewerがコード品質チェック
5. **完了**: restartペイン(Zellij)またはAlt+m→c(tmux)でクリーンアップ

### スクリプトの注意点

`zellij/scripts/`と`tmux/scripts/`には大規模なシェルスクリプトがある:
- `vibe-dashboard.sh` (14000行超): Worker進捗監視のステートマシン
- `plan-watcher.sh` / `plan-viewer.sh`: `.spec/`ファイル監視・表示

これらは`~/.config/zellij/scripts/`または`~/.config/tmux/scripts/`にインストールされる。

## コーディング規約

`rules/`ディレクトリにClaude Code用ルール6ファイル:
- **orchestrator.md**: PDCAワークフロー、TaskCreate/TaskUpdate管理
- **agents.md**: 7エージェントの選択基準と組み合わせパターン
- **coding-style.md**: const優先、早期リターン、300行/50行目安
- **git-workflow.md**: Conventional Commits (`<type>(<scope>): <subject>`)
- **testing.md**: TDD (Red-Green-Refactor)、カバレッジ80%目標
- **security.md**: 秘密情報管理、入力検証、脆弱性対策

### Conventional Commits

```
<type>(<scope>): <subject>
```

Type: feat, fix, refactor, docs, test, chore, style, perf, ci, revert
