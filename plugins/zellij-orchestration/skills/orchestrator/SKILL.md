---
name: orchestrator
description: Zellij Implタブでオーケストレーターとして動作し、Task toolでサブエージェント（frontend-worker, backend-worker, test-worker, debugger）を並列起動してタスクを管理する。使用タイミング: (1) 複数のWorkerを並列で動かす実装タスク (2) フロントエンド・バックエンド・テストを同時進行する開発 (3) 「オーケストレーター」「並列開発」「タスク管理」などのリクエスト時
---

# Orchestrator

Task toolでサブエージェントを並列起動し、worktree → 実装 → レビュー → PR作成のフローを管理する。

## 絶対ルール

1. `git gtr new <feature>` 後、必ず `cd .branches/<feature>` で移動
2. 実装完了後、必ずレビュー実行（スキップ禁止）
3. `git merge` 禁止 → 必ず `gh pr create` でPR作成
4. planファイル名は必ず `plan.md`（タイムスタンプ付き禁止）

## サブエージェント

| subagent_type | 用途 |
|---------------|------|
| `frontend-worker` | UI/UX、コンポーネント |
| `backend-worker` | API、ビジネスロジック |
| `test-worker` | テスト作成・実行 |
| `debugger` | UI確認、ライブラリ調査 |

## ワークフロー

### 1. 準備

```bash
git gtr new <feature>
cd .branches/<feature>
mkdir -p .spec
```

### 2. サブエージェント並列起動

**3つのTask toolを1つのメッセージで同時呼び出し**。
プロンプト例: [references/prompts.md](references/prompts.md)

### 3. コミット

```bash
git add . && git commit -m "feat(<feature>): 実装完了"
```

### 4. レビュー依頼

詳細: [references/commands.md](references/commands.md#レビュー依頼)

```bash
zellij -s "$ZELLIJ_SESSION_NAME" action move-focus right && \
zellij -s "$ZELLIJ_SESSION_NAME" action write-chars 'reviewer skillで /review .branches/<feature>/ を実行' && \
zellij -s "$ZELLIJ_SESSION_NAME" action write 27 && sleep 0.1 && \
zellij -s "$ZELLIJ_SESSION_NAME" action write 13 && \
zellij -s "$ZELLIJ_SESSION_NAME" action move-focus left
```

レビュー結果: `.spec/review.md` → 指摘があれば修正 → 再レビュー

### 5. PR作成（承認後のみ）

```bash
git push -u origin feature/<feature>
gh pr create --base main --head feature/<feature> --title "feat(<feature>): <説明>"
```

### 6. クリーンアップ（PRマージ後）

```bash
git checkout main && git pull && git gtr rm <feature>
```

## ディレクトリ構造

```
.branches/<feature>/.spec/
  ├── plan.md        # 実装計画
  ├── frontend.md    # Frontend進捗
  ├── backend.md     # Backend進捗
  ├── test.md        # Test進捗
  └── review.md      # レビュー結果
```
