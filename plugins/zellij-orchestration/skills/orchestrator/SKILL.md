---
name: orchestrator
description: Zellij Implタブでオーケストレーターとして動作し、Task toolでサブエージェント（frontend-worker, backend-worker, test-worker）を並列起動してタスクを管理する。使用タイミング: (1) 複数のWorkerを並列で動かす実装タスク (2) フロントエンド・バックエンド・テストを同時進行する開発 (3) 「オーケストレーター」「並列開発」「タスク管理」などのリクエスト時
---

# Orchestrator

Task toolでサブエージェントを並列起動し、レビュー→PR作成のフローを管理する。

## 絶対に守るべきルール

1. **レビュー必須**: 実装完了後、必ずレビューを実行。スキップ禁止
2. **直接マージ禁止**: `git merge`禁止。必ず`gh pr create`でPR作成
3. **承認前PR禁止**: レビュー承認（Approve）前にPRを作成しない

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

## ワークフロー

### 1. 準備

```bash
# feature名を決定し、worktree作成
git gtr new <feature>
# .spec/<feature>/task.md にタスク定義を書く
```

### 2. サブエージェント並列起動

**3つのTask toolを1つのメッセージで同時に呼び出す**:

```
subagent_type: "frontend-worker" / "backend-worker" / "test-worker"
prompt: |
  ## 作業ディレクトリ
  .gtr/<feature>
  ## タスク
  <具体的な実装内容>
  ## 対象ファイル
  <担当ファイルを明記（競合回避）>
```

### 3. コミット

```bash
cd .gtr/<feature> && git add . && git commit -m "feat(<feature>): 実装完了"
```

### 4. レビュー依頼（必須）

```bash
zellij action move-focus right && sleep 0.3 && zellij action write-chars '/review .gtr/<feature>/' && zellij action write 13 && sleep 0.3 && zellij action move-focus left
```

`.spec/<feature>/review.md`を確認し、指摘があれば該当Workerで修正→再レビュー。

### 5. PR作成（承認後のみ）

```bash
cd .gtr/<feature>
git push -u origin gtr/<feature>
gh pr create --base main --head gtr/<feature> --title "feat(<feature>): <説明>" --body "レビュー済み: .spec/<feature>/review.md"
```

PR URLをユーザーに報告。

### 6. クリーンアップ（PRマージ後）

```bash
git checkout main && git pull && git gtr rm <feature>
```

## ディレクトリ構造

```
.gtr/<feature>/    # worktree（全Worker共通）
.spec/<feature>/   # タスク定義・進捗・レビュー結果
```

## gtrコマンド

```bash
git gtr new <name>   # worktree作成
git gtr rm <name>    # worktree削除
git gtr list         # 一覧表示
```
