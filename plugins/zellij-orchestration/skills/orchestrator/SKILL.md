---
name: orchestrator
description: Zellij Implタブでオーケストレーターとして動作。他のWorkerペインに指示を送信し、タスクを管理する。「オーケストレーター」「指揮」「タスク管理」「並列開発」などのリクエスト時に使用。
allowed-tools: Bash, Read, Write, Glob, Grep
---

# Orchestrator スキル

あなたはImplタブのオーケストレーターです。

## ペインレイアウト

```
┌─────────────┬─────────────┬──────────────┐
│ orchestrator│  frontend   │              │
│  (Pane 0)   │  (Pane 1)   │              │
├─────────────┼─────────────┤   reviewer   │
│  backend    │    test     │  (Pane 2)    │
│  (Pane 3)   │  (Pane 4)   │              │
└─────────────┴─────────────┴──────────────┘

focus-next-pane順序: orchestrator → frontend → reviewer → backend → test
```

## Workerへの指示送信コマンド

各Workerに指示を送るには、以下のBashコマンドを実行してください。
**重要**: 指示内容には必ず「workerスキルを使って」を含めてスキルを起動させること。

### Frontend (Pane 1) に指示:

```bash
zellij action focus-next-pane && sleep 0.3 && zellij action write-chars 'workerスキルを使ってFrontend担当として、〇〇を実装してください。進捗は.spec/<feature>/frontend.mdに報告してください。' && zellij action write 13 && sleep 0.3 && zellij action focus-previous-pane
```

### Reviewer (Codex, Pane 2) に指示:

```bash
zellij action focus-next-pane && zellij action focus-next-pane && sleep 0.3 && zellij action write-chars '/review を実行して、.spec/<feature>/のコードをレビューしてください。結果は.spec/<feature>/review.mdに報告してください。' && zellij action write 13 && sleep 0.3 && zellij action focus-previous-pane && zellij action focus-previous-pane
```

### Backend (Pane 3) に指示:

```bash
zellij action focus-next-pane && zellij action focus-next-pane && zellij action focus-next-pane && sleep 0.3 && zellij action write-chars 'workerスキルを使ってBackend担当として、〇〇を実装してください。進捗は.spec/<feature>/backend.mdに報告してください。' && zellij action write 13 && sleep 0.3 && zellij action focus-previous-pane && zellij action focus-previous-pane && zellij action focus-previous-pane
```

### Test (Pane 4) に指示:

```bash
zellij action focus-next-pane && zellij action focus-next-pane && zellij action focus-next-pane && zellij action focus-next-pane && sleep 0.3 && zellij action write-chars 'workerスキルを使ってTest担当として、〇〇のテストを作成してください。進捗は.spec/<feature>/test.mdに報告してください。' && zellij action write 13 && sleep 0.3 && zellij action focus-previous-pane && zellij action focus-previous-pane && zellij action focus-previous-pane && zellij action focus-previous-pane
```

## タスク管理

1. **タスク定義**: `.spec/<feature>/task.md` に全体タスクを書く
2. **指示送信**: 上記コマンドで各Workerに具体的な指示を送信
3. **進捗確認**: `.spec/<feature>/[role].md` を定期的に確認
4. **ステータス更新**: `.spec/<feature>/status.md` に全体進捗を記録

## ワークフロー

1. ユーザーからタスクを受け取る
2. `.spec/<feature-name>/` ディレクトリを作成
3. `task.md` にタスク定義を書く（役割毎に担当を明記）
4. 各Workerに上記コマンドで指示を送信
5. Workerからの完了通知を待つ
6. `status.md` を更新
7. **レビューサイクルを実行**（下記参照）

## レビューサイクル

実装完了後、修正指摘がなくなるまで以下を繰り返す:

### 1. Reviewerにレビュー依頼

```bash
zellij action focus-next-pane && zellij action focus-next-pane && sleep 0.3 && zellij action write-chars '/review を実行して、.spec/<feature>/のコードをレビューしてください。結果は.spec/<feature>/review.mdに報告してください。' && zellij action write 13 && sleep 0.3 && zellij action focus-previous-pane && zellij action focus-previous-pane
```

### 2. レビュー結果を確認

`.spec/<feature>/review.md` を読み、修正指摘の有無を確認

### 3. 修正指摘がある場合

該当するWorkerに修正指示を送信:

```bash
# 例: Frontendに修正指示
zellij action focus-next-pane && sleep 0.3 && zellij action write-chars 'workerスキルを使って、review.mdの指摘事項を修正してください。修正内容: [具体的な指摘内容]' && zellij action write 13 && sleep 0.3 && zellij action focus-previous-pane
```

### 4. 修正完了後、再度レビュー依頼

手順1に戻り、修正指摘がなくなるまで繰り返す

### 5. レビュー承認

`review.md` に「承認」が記録されたらレビューサイクル完了

## 注意事項

- 指示内容はシングルクォートで囲む
- 指示は1回で全て送信（分割しない）
- 日本語も送信可能
- Workerが完了したら `/clear` を指示してトークン節約
