# コーディングスタイル

## 基本原則

- **読みやすさ優先**: コードは書く時間より読む時間の方が長い
- **一貫性**: プロジェクト全体で統一されたスタイルを保つ
- **シンプルさ**: 複雑なトリックより明確なコードを選ぶ

## イミュータビリティ

- **`const`を優先**: 変更しない変数は`const`で宣言
- **`let`は必要な時のみ**: 再代入が必要な場合のみ使用
- **`var`は使用禁止**: スコープの問題を避けるため
- **readonly修飾子**: TypeScriptではクラスプロパティに積極的に使用
- **不変データ構造**: `Object.freeze()`、Immer、Immutable.jsを検討

## 制御フロー

- **早期リターンパターン**: ネストを減らすため条件を反転
  ```typescript
  // Good
  if (!user) return null;
  if (!user.isActive) return null;
  return processUser(user);

  // Bad
  if (user) {
    if (user.isActive) {
      return processUser(user);
    }
  }
  return null;
  ```

- **ガード節の活用**: 異常系を先に処理
- **三項演算子は簡潔な場合のみ**: 複雑な条件はif文で

## ファイル・関数サイズ

- **ファイルサイズ**: 300行を目安に分割を検討
- **関数サイズ**: 50行を目安に、1つの関数は1つの責務
- **Single Responsibility Principle**: 1つのモジュール/関数は1つの理由でのみ変更される

## 命名規則

- **変数・関数**: camelCase（例: `userName`, `calculateTotal`）
- **クラス・型**: PascalCase（例: `UserProfile`, `ApiResponse`）
- **定数**: UPPER_SNAKE_CASE（例: `MAX_RETRY_COUNT`）
- **プライベートメソッド**: `_`プレフィックス（例: `_internalMethod`）
- **真偽値**: `is`, `has`, `should` プレフィックス（例: `isActive`, `hasPermission`）
- **説明的な名前**: 略語より明確な名前を優先

## マジックナンバー・文字列の禁止

```typescript
// Bad
if (status === 1) { ... }
setTimeout(callback, 3600000);

// Good
const STATUS_ACTIVE = 1;
const ONE_HOUR_MS = 60 * 60 * 1000;

if (status === STATUS_ACTIVE) { ... }
setTimeout(callback, ONE_HOUR_MS);
```

## コメント

- **コードで表現できることはコメント不要**: 自己説明的なコードを目指す
- **なぜ（Why）を書く**: 何を（What）はコードで分かるため
- **TODOコメント**: 課題は明示する（`// TODO: 〇〇を実装`）
- **複雑なロジック**: アルゴリズムの意図を説明

## インポート順序

1. 標準ライブラリ
2. 外部ライブラリ
3. 内部モジュール（絶対パス）
4. 相対パス

各グループ間は空行で区切る

## エラーハンドリング

- **明示的なエラー処理**: try-catchを適切に使用
- **カスタムエラー**: 独自のエラークラスを定義
- **エラーの伝播**: 適切なレベルでキャッチ

## 型定義

- **any型の禁止**: unknown型またはジェネリクスを使用
- **型アサーションは最小限**: as演算子の乱用を避ける
- **明示的な戻り値の型**: 関数の戻り値型は明記
- **厳格な型チェック**: `strict: true` を設定
