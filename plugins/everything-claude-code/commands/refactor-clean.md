---
description: デッドコードを削除しリファクタリングする
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# /refactor-clean - リファクタリング＆クリーンアップコマンド

refactor-cleanerエージェントを使用してデッドコードの削除とリファクタリングを実行します。

## 使用方法

```
/refactor-clean [オプション: 対象ファイルまたはディレクトリ]
```

## 実行内容

### 1. デッドコードの検出

以下のような使用されていないコードを検出します：

- **未使用のインポート**
  ```typescript
  // 削除対象
  import { unusedFunction } from './utils';
  ```

- **未使用の変数・関数**
  ```typescript
  // 削除対象
  const unusedVariable = 'value';
  function unusedFunction() {}
  ```

- **到達不可能なコード**
  ```typescript
  // 削除対象
  return result;
  console.log('This will never execute');
  ```

- **未使用の型定義**
  ```typescript
  // 削除対象
  interface UnusedInterface {
    field: string;
  }
  ```

- **コメントアウトされたコード**
  ```typescript
  // 削除対象
  // function oldImplementation() {
  //   // ...
  // }
  ```

### 2. コードのリファクタリング

コードの品質を向上させる改善を実行：

#### 重複コードの削除
```typescript
// Before: 重複したロジック
function getUserName() {
  return user.firstName + ' ' + user.lastName;
}
function getAuthorName() {
  return author.firstName + ' ' + author.lastName;
}

// After: 共通化
function getFullName(person: { firstName: string; lastName: string }) {
  return `${person.firstName} ${person.lastName}`;
}
```

#### 複雑な条件式の簡略化
```typescript
// Before: 複雑な条件
if (user !== null && user !== undefined && user.age >= 18) {
  // ...
}

// After: シンプルな条件
if (user?.age && user.age >= 18) {
  // ...
}
```

#### マジックナンバーの定数化
```typescript
// Before: マジックナンバー
if (status === 200) {
  // ...
}

// After: 定数化
const HTTP_OK = 200;
if (status === HTTP_OK) {
  // ...
}
```

#### 長い関数の分割
```typescript
// Before: 長い関数
function processUser(data) {
  // 100行のコード...
}

// After: 適切に分割
function validateUser(data) { /* ... */ }
function transformUser(data) { /* ... */ }
function saveUser(data) { /* ... */ }
function processUser(data) {
  validateUser(data);
  const transformed = transformUser(data);
  return saveUser(transformed);
}
```

### 3. コードスタイルの統一

```bash
# フォーマッタの実行
pnpm format

# リンターの実行と自動修正
pnpm lint --fix
```

## refactor-cleanerエージェントの役割

- デッドコードの自動検出
- リファクタリング機会の特定
- 安全な変更の実行
- テストによる動作保証
- コード品質の継続的改善

## 実行手順

### 1. 事前準備

```bash
# 現在の状態をコミット
git add .
git commit -m "refactor前の状態を保存"

# テストが通ることを確認
pnpm test
```

### 2. デッドコード検出

```bash
# TypeScriptの未使用コードチェック
pnpm tsc --noUnusedLocals --noUnusedParameters

# ESLintでの未使用変数チェック
pnpm lint
```

### 3. クリーンアップの実行

refactor-cleanerエージェントが以下を実行：
- 未使用のインポート削除
- 未使用の変数・関数削除
- 到達不可能なコード削除
- コメントアウトされたコード削除

### 4. リファクタリングの実行

安全な順序でリファクタリング：
1. テストの追加（カバレッジ向上）
2. 小さな改善を段階的に実行
3. 各ステップでテスト実行

### 5. 検証

```bash
# ビルドの確認
pnpm build

# テストの実行
pnpm test

# 型チェック
pnpm tsc --noEmit

# リント
pnpm lint
```

## リファクタリングのパターン

### Extract Function（関数の抽出）
```typescript
// Before
function printOwing(invoice) {
  console.log('***********************');
  console.log('**** Customer Owes ****');
  console.log('***********************');
  console.log(`name: ${invoice.customer}`);
  console.log(`amount: ${invoice.amount}`);
}

// After
function printBanner() {
  console.log('***********************');
  console.log('**** Customer Owes ****');
  console.log('***********************');
}

function printDetails(invoice) {
  console.log(`name: ${invoice.customer}`);
  console.log(`amount: ${invoice.amount}`);
}

function printOwing(invoice) {
  printBanner();
  printDetails(invoice);
}
```

### Replace Conditional with Polymorphism（条件分岐の多態性への置換）
```typescript
// Before
function getSpeed(type: string) {
  switch (type) {
    case 'car': return 100;
    case 'bike': return 50;
    case 'train': return 200;
  }
}

// After
interface Vehicle {
  getSpeed(): number;
}

class Car implements Vehicle {
  getSpeed() { return 100; }
}

class Bike implements Vehicle {
  getSpeed() { return 50; }
}

class Train implements Vehicle {
  getSpeed() { return 200; }
}
```

### Introduce Parameter Object（パラメータオブジェクトの導入）
```typescript
// Before
function createUser(name: string, email: string, age: number, address: string) {
  // ...
}

// After
interface UserData {
  name: string;
  email: string;
  age: number;
  address: string;
}

function createUser(userData: UserData) {
  // ...
}
```

## 安全なリファクタリングのルール

### 1. テストファースト
```bash
# リファクタリング前にテストが通ることを確認
pnpm test

# リファクタリング実行
# ...

# リファクタリング後もテストが通ることを確認
pnpm test
```

### 2. 小さな変更を積み重ねる
- 一度に大きな変更をしない
- 各ステップでコミット
- いつでも戻せる状態を保つ

### 3. 動作を変えない
- リファクタリングは構造の改善のみ
- 機能追加や修正は別のタスク

## 使用例

```bash
# プロジェクト全体をクリーンアップ
/refactor-clean

# 特定のディレクトリをクリーンアップ
/refactor-clean src/components

# 特定のファイルをリファクタリング
/refactor-clean src/utils/validation.ts

# デッドコード削除のみ実行
/refactor-clean --dead-code-only
```

## チェックリスト

リファクタリング完了後の確認項目：

- [ ] すべてのテストがパスする
- [ ] ビルドが成功する
- [ ] 型エラーがない
- [ ] リントエラーがない
- [ ] コードカバレッジが低下していない
- [ ] パフォーマンスが悪化していない
- [ ] 既存の機能が正常に動作する

## ツール活用

### 静的解析ツール
```bash
# 複雑度チェック
pnpm eslint --ext .ts,.tsx src/

# 重複コード検出
pnpm jscpd src/
```

### カバレッジ測定
```bash
# テストカバレッジ確認
pnpm test --coverage
```

### 依存関係の可視化
```bash
# 未使用の依存関係検出
pnpm depcheck

# 循環依存の検出
pnpm madge --circular src/
```

## リファクタリングの効果

### コードの保守性向上
- 読みやすく理解しやすいコード
- 変更が容易
- バグの混入リスク低減

### パフォーマンス改善
- 不要なコードの削除
- 効率的なアルゴリズム

### チーム開発の効率化
- 一貫したコードスタイル
- 新規メンバーのオンボーディング容易化
