# Worker向けプロンプトテンプレート

## 基本構造

```
## 作業ディレクトリ
.branches/<feature>

## タスク
<具体的な実装内容>

## 対象ファイル
<担当ファイルを明記>

## 完了条件
<何をもって完了とするか>
```

## Frontend Worker

### 新規コンポーネント作成

```
## 作業ディレクトリ
.branches/<feature>

## タスク
<ComponentName>コンポーネントを作成する
- 機能: <機能説明>
- Props: <props定義>
- 状態管理: <state説明>

## 対象ファイル
- src/components/<ComponentName>/index.tsx
- src/components/<ComponentName>/styles.ts（必要な場合）

## 完了条件
- コンポーネントが正しくレンダリングされる
- 型エラーがない
```

### 既存UI修正

```
## 作業ディレクトリ
.branches/<feature>

## タスク
<対象ページ/コンポーネント>を修正する
- 現状: <現在の動作>
- 期待: <修正後の動作>

## 対象ファイル
- src/pages/<file>.tsx
- src/components/<file>.tsx

## 完了条件
- 修正が正しく動作する
- 既存機能に影響がない
```

## Backend Worker

### API エンドポイント追加

```
## 作業ディレクトリ
.branches/<feature>

## タスク
<endpoint>エンドポイントを追加する
- メソッド: GET/POST/PUT/DELETE
- リクエスト: <body/params>
- レスポンス: <response形式>

## 対象ファイル
- src/api/<resource>.ts
- src/services/<service>.ts
- src/types/<types>.ts（必要な場合）

## 完了条件
- エンドポイントが正しく動作する
- エラーハンドリングが実装されている
```

### ビジネスロジック実装

```
## 作業ディレクトリ
.branches/<feature>

## タスク
<機能名>のビジネスロジックを実装する
- 入力: <入力データ>
- 処理: <処理内容>
- 出力: <出力データ>

## 対象ファイル
- src/services/<service>.ts
- src/utils/<utility>.ts（必要な場合）

## 完了条件
- ロジックが正しく動作する
- エッジケースが考慮されている
```

## Test Worker

### ユニットテスト作成

```
## 作業ディレクトリ
.branches/<feature>

## タスク
<対象モジュール>のユニットテストを作成する
- テスト対象: <関数/クラス名>
- カバレッジ: 主要なパスとエッジケース

## 対象ファイル
- tests/unit/<module>.test.ts
- __tests__/<module>.test.ts

## 完了条件
- 全テストがパスする
- 主要なケースがカバーされている
```

### 統合テスト作成

```
## 作業ディレクトリ
.branches/<feature>

## タスク
<機能名>の統合テストを作成する
- テスト範囲: <API/フロー>
- シナリオ: <テストシナリオ>

## 対象ファイル
- tests/integration/<feature>.test.ts

## 完了条件
- E2Eフローが正しく動作する
- エラーケースがテストされている
```

## Debugger

### UI動作確認

```
## 作業ディレクトリ
.branches/<feature>

## タスク
<対象ページ/機能>のUI動作を確認する
- 確認URL: <URL>
- 確認項目: <操作手順>

## 使用ツール
- Chrome DevTools MCP

## 完了条件
- スクリーンショットを撮影
- コンソールエラーがないことを確認
- 期待通りの動作を確認
```

### ライブラリ調査

```
## 作業ディレクトリ
.branches/<feature>

## タスク
<ライブラリ名>の使用方法を調査する
- 調査目的: <目的>
- 確認したい機能: <機能>

## 使用ツール
- Context7 MCP

## 完了条件
- 最新の推奨実装パターンを取得
- 実装例を報告
```

### パフォーマンス分析

```
## 作業ディレクトリ
.branches/<feature>

## タスク
<対象ページ>のパフォーマンスを分析する
- 分析URL: <URL>
- 注目点: <パフォーマンス指標>

## 使用ツール
- Chrome DevTools MCP (performance_start_trace)

## 完了条件
- パフォーマンストレースを取得
- ボトルネックを特定
- 改善提案を作成
```

## 修正対応

### レビュー指摘対応

```
## 作業ディレクトリ
.branches/<feature>

## タスク
レビュー指摘を修正する

## 修正内容
1. <指摘1>: <対応方法>
2. <指摘2>: <対応方法>

## 対象ファイル
- <修正対象ファイル1>
- <修正対象ファイル2>

## 完了条件
- 全ての指摘が対応されている
- 新たな問題が発生していない
```
