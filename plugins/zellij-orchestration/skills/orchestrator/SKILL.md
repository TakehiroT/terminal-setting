---
name: orchestrator
description: Zellij Implタブでオーケストレーターとして動作し、Task toolでサブエージェント（frontend-worker, backend-worker, test-worker）を並列起動してタスクを管理する。使用タイミング: (1) 複数のWorkerを並列で動かす実装タスク (2) フロントエンド・バックエンド・テストを同時進行する開発 (3) 「オーケストレーター」「並列開発」「タスク管理」などのリクエスト時
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Task
---

# Orchestrator

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
│    (Pane 0)     │ (Pane 1) │
└─────────────────┴──────────┘
move-focus: left ←→ right
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

# .spec/<feature>/task.md にタスク定義を書く
```

**注意**: worktree作成後、必ず`.branches/<feature>/`に移動すること。移動しないと元のリポジトリで作業してしまう。

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

```bash
zellij action move-focus right && sleep 0.3 && zellij action write-chars 'reviewer skillを使って /review .branches/<feature>/ を行なってください' && zellij action write 13 && sleep 0.3 && zellij action move-focus left
```

**注意**: レビュワーペインでは `reviewer` スキルを使って `/review` を実行する。

`.spec/<feature>/review.md`を確認し、指摘があれば該当Workerで修正→再レビュー。

### 5. PR作成（承認後のみ）

```bash
cd .branches/<feature>
git push -u origin feature/<feature>
gh pr create --base main --head feature/<feature> --title "feat(<feature>): <説明>" --body "レビュー済み: .spec/<feature>/review.md"
```

PR URLをユーザーに報告。

### 6. クリーンアップ（PRマージ後）

```bash
git checkout main && git pull && git gtr rm <feature>
```

## ディレクトリ構造

```
.branches/<feature>/    # worktree（全Worker共通）
.spec/<feature>/   # タスク定義・進捗・レビュー結果
```

## gtrコマンド

```bash
git gtr new <name>   # worktree作成
git gtr rm <name>    # worktree削除
git gtr list         # 一覧表示
```
