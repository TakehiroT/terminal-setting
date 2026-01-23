---
name: orchestrator
description: tmux Implタブでオーケストレーターとして動作し、Task toolでサブエージェント（frontend-worker, backend-worker, test-worker）を並列起動してタスクを管理する。使用タイミング: (1) 複数のWorkerを並列で動かす実装タスク (2) フロントエンド・バックエンド・テストを同時進行する開発 (3) 「オーケストレーター」「並列開発」「タスク管理」などのリクエスト時
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Task
---

# Orchestrator (tmux版)

Task toolでサブエージェントを並列起動し、レビュー→PR作成のフローを管理する。

## 絶対に守るべきルール

1. **worktree移動必須**: `git gtr new`後、必ず`cd .branches/<feature>`で移動
2. **レビュー必須**: 実装完了後、必ずレビューを実行。スキップ禁止
3. **直接マージ禁止**: `git merge`禁止。必ず`gh pr create`でPR作成
4. **承認前PR禁止**: レビュー承認（Approve）前にPRを作成しない

## ペインレイアウト

```
┌─────────────────┬──────────┐
│  orchestrator   │ reviewer │
│   (Impl.1)      │ (Impl.2) │
└─────────────────┴──────────┘
tmux send-keys -t ide:Impl.1  # claude
tmux send-keys -t ide:Impl.2  # codex
```

## サブエージェント

| subagent_type | 用途 |
|---------------|------|
| `frontend-worker` | UI/UX、コンポーネント、スタイリング |
| `backend-worker` | API、ビジネスロジック、データベース |
| `test-worker` | ユニットテスト、統合テスト、E2E |
| `debugger` | UIデバッグ、パフォーマンス分析、ライブラリ調査 |

## ワークフロー

### 1. 準備

```bash
# feature名を決定し、worktree作成
git gtr new <feature>

# 重要: worktreeに移動
cd .branches/<feature>

# planディレクトリを作成
mkdir -p .spec
```

**注意**:
- worktree作成後、必ず`.branches/<feature>/`に移動すること
- **planファイルは必ずワークツリー配下（`.spec/`）に作成する**
- `Shift+Tab`でplanモードに切り替えて計画を作成可能

### planモード設定（必須）

worktree配下にplanファイルを作成するため、worktree移動後に以下を確認:

```bash
# .claude/settings.json がなければ作成
cat > .claude/settings.json << 'EOF'
{
  "plansDirectory": "./.spec"
}
EOF
```

または、Claude Codeの起動時にカレントディレクトリがworktreeであれば、planモードで作成されるファイルは自動的にworktree配下の`.spec/`に保存される。

**重要**: planファイルは絶対にリポジトリルートや`~/.claude/`に作成しないこと。必ずworktree配下に作成する。

### 2. サブエージェント並列起動

**3つのTask toolを1つのメッセージで同時に呼び出す**。

プロンプトテンプレート: [references/prompts.md](references/prompts.md)

基本構造:
```
## 作業ディレクトリ
.branches/<feature>
## タスク
<具体的な実装内容>
## 対象ファイル
<担当ファイルを明記（競合回避）>
## 完了条件
<何をもって完了とするか>
```

### 3. コミット

```bash
cd .branches/<feature> && git add . && git commit -m "feat(<feature>): 実装完了"
```

### 4. レビュー依頼（必須）

tmux send-keysでcodexペインにメッセージを送信:

```bash
# セッション名は idet で起動した場合 "ide"
# Codexは Escape → Enter で送信（間にsleepを入れる）
tmux send-keys -t ide:Impl.2 -l 'tmux-reviewer skillを使って /review .branches/<feature>/ を行なってください' && sleep 0.1 && tmux send-keys -t ide:Impl.2 Escape && sleep 0.1 && tmux send-keys -t ide:Impl.2 Enter
```

**注意**: レビュワーペインでは `tmux-reviewer` スキルを使って `/review` を実行する。

`.branches/<feature>/.spec/review.md`を確認し、指摘があれば該当Workerで修正→再レビュー。

### 5. PR作成（承認後のみ）

```bash
cd .branches/<feature>
git push -u origin feature/<feature>
gh pr create --base main --head feature/<feature> --title "feat(<feature>): <説明>" --body "レビュー済み: .branches/<feature>/.spec/review.md"
```

PR URLをユーザーに報告。

### 6. クリーンアップ（PRマージ後）

```bash
git checkout main && git pull && git gtr rm <feature>
```

## ディレクトリ構造

```
.branches/<feature>/           # worktree（全Worker共通）
.branches/<feature>/.spec/     # 進捗・レビュー結果（worktreeごと）
  ├── frontend.md              # Frontend進捗
  ├── backend.md               # Backend進捗
  ├── test.md                  # Test進捗
  └── review.md                # レビュー結果
```

## gtrコマンド

```bash
git gtr new <name>   # worktree作成
git gtr rm <name>    # worktree削除
git gtr list         # 一覧表示
```

## tmux send-keys クイックリファレンス

```bash
# claudeペインにメッセージ送信（Enter で送信）
tmux send-keys -t ide:Impl.1 'メッセージ' Enter

# codex（レビュワー）ペインにメッセージ送信（Escape → Enter で送信、間にsleepを入れる）
tmux send-keys -t ide:Impl.2 -l 'メッセージ' && sleep 0.1 && tmux send-keys -t ide:Impl.2 Escape && sleep 0.1 && tmux send-keys -t ide:Impl.2 Enter

# セッション名がカスタムの場合
tmux send-keys -t <session>:Impl.1 'メッセージ' Enter
tmux send-keys -t <session>:Impl.2 -l 'メッセージ' && sleep 0.1 && tmux send-keys -t <session>:Impl.2 Escape && sleep 0.1 && tmux send-keys -t <session>:Impl.2 Enter
```

**注意**: Codexは `Escape` → `Enter` で送信。間に `sleep 0.1` を入れないと改行になる場合がある。`-l` オプションでリテラル送信。
