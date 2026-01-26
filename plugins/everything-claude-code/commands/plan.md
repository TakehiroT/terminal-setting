---
description: 実装計画を作成する（Claude Code planモードを活用）
allowed-tools: Read, Glob, Grep, TaskCreate, TaskUpdate, TaskList
---

# /plan - 実装計画作成コマンド

Claude Codeのplanモードを活用して実装計画を作成します。

## 使用方法

```
/plan [機能名または要件]
```

## planモードの活用

このコマンドは Claude Code の planモードと連携します：

1. `Shift+Tab` でplanモードに切り替え
2. 要件を入力して計画を作成
3. 計画は `.spec/` ディレクトリに自動保存
4. Workerは自動的にplanを読み込んで作業開始

## 実行手順

1. **要件の分析**
   - ユーザーからの要件を詳細に分析
   - 対象範囲とスコープの明確化
   - 既存コードベースとの関連性を調査

2. **タスクの分解**
   - 実装を段階的なタスクに分解
   - 各タスクの依存関係を整理
   - 優先順位の設定

3. **計画の自動保存**
   - planモードで作成した計画は `.spec/` に自動保存
   - 技術的な検討事項を文書化
   - 実装アプローチの提案

4. **タスクリストの作成**
   - TaskCreate/TaskUpdateツールで実装タスクを管理
   - 各タスクの状態管理（pending/in_progress/completed）
   - TaskListで進捗を確認

## settings.json の設定

プロジェクトの `.claude/settings.json` に以下を追加：

```json
{
  "plansDirectory": "./.spec"
}
```

## planモードのショートカット

| 操作 | キー |
|------|------|
| planモード切り替え | `Shift+Tab` |
| Extended Thinking切り替え | `Option+T` (macOS) / `Alt+T` |

## 使用例

```bash
# planモードで新機能の実装計画を作成
/plan ユーザー認証機能の追加

# バグ修正の計画を作成
/plan ログイン時のエラーハンドリング改善

# リファクタリング計画を作成
/plan APIレイヤーのリファクタリング
```

## Vibe Coding フロー

```
1. /plan で要件を伝える
2. planモードが計画を作成 → .spec/ に自動保存
3. Worker を起動 → 自動的にplanを読み込み
4. 実装を見守る（Monitorタブで確認）
5. レビュー → PR作成
```
