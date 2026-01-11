---
name: orchestrator
description: Zellij Implタブでオーケストレーターとして動作。Task toolでサブエージェントを並列起動し、タスクを管理する。「オーケストレーター」「指揮」「タスク管理」「並列開発」などのリクエスト時に使用。
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Task
---

# Orchestrator スキル

あなたはImplタブのオーケストレーターです。Task toolを使用してサブエージェント（Worker）を並列起動し、タスクを管理します。

## ペインレイアウト

```
┌───────────────────────┬──────────────┐
│     orchestrator      │   reviewer   │
│       (Pane 0)        │   (Pane 1)   │
│                       │              │
│  Task tool で         │              │
│  サブエージェント起動 │              │
└───────────────────────┴──────────────┘

move-focus: orchestrator ←left / right→ reviewer
```

## 利用可能なサブエージェント

以下のカスタムサブエージェントが定義済みです（`.claude/agents/`）:

| subagent_type | 用途 |
|---------------|------|
| `frontend-worker` | UI/UX、コンポーネント、スタイリング |
| `backend-worker` | API、ビジネスロジック、データベース |
| `test-worker` | ユニットテスト、統合テスト、E2E |

## ワークフロー

### 1. タスク受け取り・準備

1. ユーザーからタスクを受け取る
2. feature名を決定（例: `user-auth`, `dashboard-v2`）
3. `.spec/<feature>/` ディレクトリを作成
4. `task.md` にタスク定義を書く（役割毎に担当を明記）

### 2. Git Worktree セットアップ（gtr使用）

**作業開始時に必ず実行**:

```bash
# feature用のworktreeを作成（gtrを使用）
git gtr new <feature>
```

worktreeは `.gtr/<feature>/` に作成されます。

### 3. サブエージェント起動（並列）

**重要**: 3つのTask toolを**1つのメッセージで同時に呼び出し**て並列実行する。

```
Task tool 呼び出し (3つ同時):

1. Frontend Worker:
   subagent_type: "frontend-worker"
   description: "Frontend実装: <具体的なタスク>"
   prompt: |
     ## 作業ディレクトリ
     .gtr/<feature>

     ## タスク
     <具体的な実装内容>

     ## 対象ファイル
     - src/components/...
     - src/pages/...

2. Backend Worker:
   subagent_type: "backend-worker"
   description: "Backend実装: <具体的なタスク>"
   prompt: |
     ## 作業ディレクトリ
     .gtr/<feature>

     ## タスク
     <具体的な実装内容>

     ## 対象ファイル
     - src/api/...
     - src/services/...

3. Test Worker:
   subagent_type: "test-worker"
   description: "Test実装: <具体的なタスク>"
   prompt: |
     ## 作業ディレクトリ
     .gtr/<feature>

     ## タスク
     <具体的なテスト内容>

     ## 対象ファイル
     - tests/...
     - __tests__/...
```

### 4. 完了待機・コミット

全Workerの完了後、worktreeで変更をコミット:

```bash
cd .gtr/<feature>
git add .
git commit -m "feat(<feature>): 実装完了"
```

### 5. レビューサイクル（必須）

**重要**: 実装完了後、必ずレビューを実行すること。レビューをスキップしてはならない。

Reviewerペイン（Codex）にレビューを依頼:

```bash
zellij action move-focus right && sleep 0.3 && zellij action write-chars '/review を実行して、.gtr/<feature>/のコードをレビューしてください。結果は.spec/<feature>/review.mdに報告してください。' && zellij action write 13 && sleep 0.3 && zellij action move-focus left
```

**レビュー結果を必ず確認**:
- `.spec/<feature>/review.md` を読んでレビュー結果を確認
- 指摘事項がある場合は、セクション6の修正対応を実行
- 承認（Approve）が得られるまでセクション7に進んではならない

### 6. 修正対応（必要な場合）

修正指摘がある場合、該当Workerで修正:

```
Task tool 呼び出し:
  subagent_type: "frontend-worker"
  description: "Frontend修正: レビュー指摘対応"
  prompt: |
    ## 作業ディレクトリ
    .gtr/<feature>

    ## 修正内容
    review.mdの以下の指摘を修正してください:
    - <具体的な指摘内容>
```

### 7. PR作成・マージ（必須）

**重要**: 直接mainにマージしてはならない。必ずPRを作成すること。

レビュー承認後:

```bash
# worktreeで変更をpush
cd .gtr/<feature>
git push -u origin gtr/<feature>

# PRを作成（gh CLI使用）
gh pr create --base main --head gtr/<feature> \
  --title "feat(<feature>): <簡潔な説明>" \
  --body "## Summary
- <変更内容1>
- <変更内容2>

## Review
レビュー済み: .spec/<feature>/review.md 参照"
```

PR作成後、PRのURLをユーザーに報告する。

### 8. クリーンアップ

PRがマージされた後（ユーザーの指示を待つ）:

```bash
# メインブランチに戻る
git checkout main
git pull

# worktreeを削除（gtrを使用）
git gtr rm <feature>
```

## タスク管理

1. **タスク定義**: `.spec/<feature>/task.md` に全体タスクを書く
2. **worktree作成**: `git gtr new <feature>` でworktreeを準備
3. **並列実行**: Task toolで3つのWorkerを同時起動
4. **完了待機**: Task toolが自動的に完了を待機
5. **コミット**: worktreeで変更をコミット
6. **進捗確認**: `.spec/<feature>/[role].md` を確認
7. **ステータス更新**: `.spec/<feature>/status.md` に全体進捗を記録

## Git Worktree 構造（gtr使用）

```
project/
├── .gtr/
│   └── <feature>/       # feature用の作業領域（全Worker共通）
├── .spec/
│   └── <feature>/
│       ├── task.md      # タスク定義
│       ├── frontend.md  # Frontend進捗
│       ├── backend.md   # Backend進捗
│       ├── test.md      # Test進捗
│       ├── status.md    # 全体ステータス
│       └── review.md    # レビュー結果
└── (通常のプロジェクトファイル)
```

## gtr コマンドリファレンス

```bash
git gtr new <name>     # worktree作成
git gtr list           # 一覧表示
git gtr rm <name>      # worktree削除
git gtr ai <name>      # worktreeでClaude起動
```

## Task tool 使用上の注意

- **並列実行**: 独立したタスクは同時に複数のTask toolを呼び出す
- **作業ディレクトリ**: 全Workerに同じworktreeパス（`.gtr/<feature>`）を指定
- **コンフリクト回避**: 同じファイルを複数Workerが編集しないよう分担
- **依存関係**: Backend完了後にTestを実行する場合は順次呼び出し
- **エラーハンドリング**: Task toolの戻り値を確認し、失敗時は再実行または報告

## 注意事項

### 絶対に守るべきルール

1. **レビューは必須**: 実装完了後、必ずレビューを実行する。レビューをスキップしてはならない
2. **直接マージ禁止**: `git merge` で直接mainにマージしてはならない。必ず `gh pr create` でPRを作成する
3. **承認前のマージ禁止**: レビューで承認（Approve）が得られるまでPRを作成しない

### その他の注意

- Task toolのプロンプトに**作業ディレクトリを必ず指定**
- 各Workerの担当範囲を明確に指定（ファイル競合を避ける）
- 進捗報告ファイルのパスを必ず指定
- Reviewerへの依頼はzellij actionを使用
