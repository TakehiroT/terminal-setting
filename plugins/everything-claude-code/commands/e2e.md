---
description: E2Eテストを実行する
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# /e2e - E2Eテスト実行コマンド

e2e-runnerエージェントを使用してEnd-to-Endテストを実行します。

## 使用方法

```
/e2e [オプション: テストシナリオの説明]
```

## E2Eテストとは

エンドツーエンドテストは、アプリケーション全体を通したユーザーの操作をシミュレートし、実際の使用シナリオをテストします。

### テスト対象
- ユーザーインターフェース
- APIエンドポイント
- データベース操作
- 外部サービス連携
- ユーザーフロー全体

## 実行手順

### 1. テスト環境の準備

```bash
# テスト用データベースのセットアップ
pnpm db:test:setup

# 開発サーバーの起動（バックグラウンド）
pnpm dev &

# E2Eテストの依存関係を確認
pnpm playwright install  # Playwrightの場合
```

### 2. テストシナリオの作成

```typescript
// tests/e2e/user-registration.spec.ts
import { test, expect } from '@playwright/test';

test('ユーザー登録フロー', async ({ page }) => {
  // 1. ランディングページにアクセス
  await page.goto('/');

  // 2. 登録ボタンをクリック
  await page.click('text=新規登録');

  // 3. フォームに入力
  await page.fill('input[name="email"]', 'test@example.com');
  await page.fill('input[name="password"]', 'SecurePass123');

  // 4. 送信
  await page.click('button[type="submit"]');

  // 5. 成功メッセージを確認
  await expect(page.locator('text=登録完了')).toBeVisible();
});
```

### 3. テストの実行

```bash
# 全テストを実行
pnpm test:e2e

# 特定のテストファイルを実行
pnpm test:e2e user-registration

# ヘッドレスモードで実行
pnpm test:e2e --headless

# UIモードで実行（デバッグ用）
pnpm test:e2e --ui

# 特定のブラウザで実行
pnpm test:e2e --project=chromium
```

### 4. 結果の確認と修正

```bash
# テストレポートを開く
pnpm playwright show-report

# スクリーンショットやトレースを確認
# test-results/ ディレクトリを確認
```

## e2e-runnerエージェントの役割

- テストシナリオの設計
- テストコードの生成
- テストの実行と監視
- エラーの分析とデバッグ
- テスト結果のレポート生成
- テストの改善提案

## テストシナリオの種類

### 1. ハッピーパス
最も一般的な正常系のユーザーフロー
```typescript
test('正常なログインフロー', async ({ page }) => {
  // 正常な認証情報でログイン成功
});
```

### 2. エラーハンドリング
異常系やエラーケース
```typescript
test('不正な認証情報でのログイン失敗', async ({ page }) => {
  // エラーメッセージの表示を確認
});
```

### 3. エッジケース
境界値や特殊なケース
```typescript
test('最大文字数での入力', async ({ page }) => {
  // 長い文字列での動作確認
});
```

### 4. 統合シナリオ
複数の機能を横断するフロー
```typescript
test('商品購入から配送までの一連のフロー', async ({ page }) => {
  // 複数画面を遷移するテスト
});
```

## ベストプラクティス

### テストの独立性
```typescript
// 各テストは独立して実行可能にする
test.beforeEach(async ({ page }) => {
  // テストごとに初期状態をセットアップ
  await setupTestData();
});

test.afterEach(async () => {
  // テスト後のクリーンアップ
  await cleanupTestData();
});
```

### 待機の適切な使用
```typescript
// ❌ 避けるべき: 固定時間の待機
await page.waitForTimeout(3000);

// ✅ 推奨: 条件付き待機
await page.waitForSelector('.success-message');
await page.waitForLoadState('networkidle');
```

### セレクタの安定性
```typescript
// ❌ 避けるべき: 不安定なセレクタ
await page.click('.btn-primary:nth-child(3)');

// ✅ 推奨: data属性やアクセシビリティ属性
await page.click('[data-testid="submit-button"]');
await page.click('button[aria-label="送信"]');
```

### Page Object Pattern
```typescript
// pages/LoginPage.ts
export class LoginPage {
  constructor(private page: Page) {}

  async login(email: string, password: string) {
    await this.page.fill('[name="email"]', email);
    await this.page.fill('[name="password"]', password);
    await this.page.click('[data-testid="login-button"]');
  }
}

// テストで使用
test('ログイン', async ({ page }) => {
  const loginPage = new LoginPage(page);
  await loginPage.login('user@example.com', 'password');
});
```

## デバッグ方法

### 1. スクリーンショットの取得
```typescript
await page.screenshot({ path: 'debug.png' });
```

### 2. トレースの記録
```typescript
test('デバッグ用', async ({ page }) => {
  await page.context().tracing.start({ screenshots: true, snapshots: true });
  // テスト実行
  await page.context().tracing.stop({ path: 'trace.zip' });
});
```

### 3. ステップ実行
```bash
# デバッグモードで実行
pnpm test:e2e --debug
```

### 4. コンソールログの確認
```typescript
page.on('console', msg => console.log('PAGE LOG:', msg.text()));
```

## 使用例

```bash
# 全E2Eテストを実行
/e2e

# ユーザー登録フローをテスト
/e2e ユーザー登録機能のE2Eテスト

# チェックアウトフローをテスト
/e2e 商品購入から決済完了までのフロー

# ログイン・ログアウトをテスト
/e2e 認証フローの動作確認
```

## テスト結果の解釈

### 成功
```
✓ user-registration.spec.ts:5:1 › ユーザー登録フロー (1.2s)
```
- すべてのアサーションがパス
- 期待通りの動作を確認

### 失敗
```
✗ user-registration.spec.ts:5:1 › ユーザー登録フロー (0.8s)
  Error: expect(locator).toBeVisible()
  Expected element to be visible, but it was not found
```
- アサーション失敗の原因を確認
- スクリーンショットやトレースで状況を把握

## CI/CD統合

```yaml
# .github/workflows/e2e.yml
name: E2E Tests

on: [push, pull_request]

jobs:
  e2e:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - run: pnpm install
      - run: pnpm test:e2e
```

## パフォーマンス考慮

- 並列実行でテスト時間を短縮
- 重要なフローに絞ってテスト
- モックを活用して外部依存を削減
- テストデータの効率的な管理
