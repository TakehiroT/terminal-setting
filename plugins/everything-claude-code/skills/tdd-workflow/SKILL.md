# TDD Workflow Skill

テスト駆動開発（TDD）のワークフローガイド。

## Red-Green-Refactor サイクル

### 1. Red（失敗するテストを書く）

```typescript
// まず失敗するテストを書く
describe('calculateTotal', () => {
  it('should calculate total with tax', () => {
    const result = calculateTotal(100, 0.1);
    expect(result).toBe(110);
  });
});
```

**ポイント**:
- テストは明確で具体的に
- 1つのテストは1つの振る舞いを検証
- エッジケースも考慮

### 2. Green（テストを通す最小限のコード）

```typescript
// テストを通す最小限の実装
function calculateTotal(price: number, taxRate: number): number {
  return price * (1 + taxRate);
}
```

**ポイント**:
- 完璧を目指さない
- テストが通ることだけに集中
- ハードコードでも構わない

### 3. Refactor（コードを改善）

```typescript
// リファクタリング
const TAX_PRECISION = 2;

function calculateTotal(price: number, taxRate: number): number {
  const total = price * (1 + taxRate);
  return Math.round(total * 10 ** TAX_PRECISION) / 10 ** TAX_PRECISION;
}
```

**ポイント**:
- テストが通る状態を維持
- 重複を排除
- 命名を改善
- 可読性を向上

## テスト設計原則

### FIRST 原則

- **Fast**: 高速に実行できる
- **Isolated**: 他のテストに依存しない
- **Repeatable**: 何度実行しても同じ結果
- **Self-validating**: 成功/失敗が明確
- **Timely**: コードより先に書く

### AAA パターン

```typescript
it('should do something', () => {
  // Arrange（準備）
  const input = createTestData();

  // Act（実行）
  const result = functionUnderTest(input);

  // Assert（検証）
  expect(result).toEqual(expectedOutput);
});
```

## カバレッジ目標

| 種類 | 目標 |
|------|------|
| Statement | 80% |
| Branch | 75% |
| Function | 80% |
| Line | 80% |

## モック戦略

### 外部依存のモック

```typescript
// 外部APIのモック
vi.mock('./api', () => ({
  fetchUser: vi.fn().mockResolvedValue({ id: 1, name: 'Test' })
}));
```

### 時間のモック

```typescript
beforeEach(() => {
  vi.useFakeTimers();
  vi.setSystemTime(new Date('2024-01-01'));
});

afterEach(() => {
  vi.useRealTimers();
});
```

## コマンド

```bash
# テスト実行
pnpm test

# ウォッチモード
pnpm test --watch

# カバレッジ
pnpm test --coverage

# 特定ファイル
pnpm test path/to/file.test.ts
```
