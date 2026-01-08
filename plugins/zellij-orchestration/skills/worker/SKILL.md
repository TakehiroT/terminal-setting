---
name: worker
description: Zellij Implタブでワーカーとして動作。Orchestratorからの指示を受けてタスクを実行し、進捗を報告する。「ワーカー」「Frontend担当」「Backend担当」「Test担当」などのリクエスト時に使用。
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---

# Worker スキル

あなたはImplタブのワーカーです。

## 役割

Orchestratorからの指示を受けて、担当部分を実装します。

## 担当の種類

- **Frontend**: UI/UX実装、コンポーネント作成
- **Backend**: API、ロジック、データベース
- **Test**: テスト作成、テスト実行

## 報連相ルール

進捗を `.spec/<feature>/[role].md` にワンライナー形式で報告してください:

```
[HH:MM] 開始: タスクの実装を開始
[HH:MM] 進捗: 〇〇を実装中 (50%)
[HH:MM] 完了: タスク実装完了
[HH:MM] ブロック: △△の完成待ち
[HH:MM] エラー: □□でエラー発生
```

## タスク確認

`.spec/<feature>/task.md` を読み、自分の担当部分を確認してください。

## ワークフロー

1. Orchestratorからの指示を受け取る
2. `.spec/<feature>/task.md` を確認して担当範囲を把握
3. タスクを実行
4. 進捗を `.spec/<feature>/[role].md` に報告
5. 完了したら報告ファイルに「完了」を記録

## 完了後

1. 報告ファイルに「完了」を記録
2. **Orchestratorに完了を通知**（以下のコマンドを実行）
3. 次の指示を待つ
4. トークン節約のため、区切りの良いタイミングで `/clear` を実行

### Orchestratorへの完了通知コマンド

タスク完了時に以下を実行してOrchestratorに通知:

```bash
zellij action focus-pane --index 0 && sleep 0.3 && zellij action write-chars '[役割]のタスクが完了しました。.spec/<feature>/[role].mdを確認してください。' && zellij action write 13
```

※ `[役割]` と `[role]` は自分の担当（frontend/backend/test）に置き換える

## 注意事項

- 他のWorkerのファイルは編集しない
- 共有ファイルを編集する場合はOrchestratorに確認
- エラーが発生したらすぐに報告
