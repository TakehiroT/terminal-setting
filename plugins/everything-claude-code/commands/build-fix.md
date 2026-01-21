---
description: ビルドエラーを修正する
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# /build-fix - ビルドエラー修正コマンド

build-error-resolverエージェントを使用してビルドエラーを解決します。

## 使用方法

```
/build-fix [オプション: エラー内容の説明]
```

## 実行手順

### 1. エラーの検出

```bash
# ビルドを実行してエラーを確認
pnpm build  # または npm run build, yarn build など
```

build-error-resolverは以下のエラーを検出・解決します：
- TypeScriptの型エラー
- ESLintの静的解析エラー
- モジュール解決エラー
- 依存関係の問題
- ビルド設定の問題

### 2. エラーの分析

エージェントは以下を実行します：
- エラーメッセージの解析
- エラーの原因特定
- 関連ファイルの調査
- 影響範囲の確認

### 3. 修正の実行

エラータイプに応じた修正：

#### 型エラー
- 型定義の修正
- 型アサーションの追加
- 型定義ファイルの作成

#### モジュールエラー
- インポートパスの修正
- モジュール解決設定の調整
- 欠落している依存関係のインストール

#### 設定エラー
- tsconfig.json の修正
- ビルド設定の調整
- パス設定の修正

### 4. 検証

```bash
# 修正後に再ビルド
pnpm build

# 型チェックのみ実行
pnpm tsc --noEmit

# リントチェック
pnpm lint
```

## build-error-resolverエージェントの役割

- ビルドエラーの自動検出
- エラーメッセージの解析と原因特定
- 適切な修正方法の選択と実行
- 修正後の検証
- 再発防止のための提案

## エラータイプ別の対応

### 型エラー (Type Errors)
```typescript
// Before: TS2339: Property 'foo' does not exist on type 'Bar'
const value = obj.foo;

// After: 型定義の追加または修正
interface Bar {
  foo: string;
}
const value = (obj as Bar).foo;
```

### インポートエラー (Import Errors)
```typescript
// Before: Cannot find module './utils'
import { helper } from './utils';

// After: パスの修正
import { helper } from './utils/helper';
```

### 依存関係エラー (Dependency Errors)
```bash
# Before: Module not found: Can't resolve 'lodash'

# After: 依存関係のインストール
pnpm add lodash
pnpm add -D @types/lodash
```

## 段階的な修正アプローチ

1. **クリティカルエラーから対応**
   - ビルドを完全に止めているエラーを優先

2. **型エラーの解決**
   - 型の不整合を修正
   - 型定義の追加

3. **警告の解決**
   - ESLint警告の修正
   - 非推奨APIの置き換え

4. **最適化**
   - 不要なコードの削除
   - パフォーマンス改善

## 使用例

```bash
# 一般的なビルドエラー修正
/build-fix

# 特定のエラーについて修正
/build-fix 型エラー: Property 'id' does not exist on type 'User'

# ビルド後に自動で修正
pnpm build && /build-fix
```

## 修正後のチェックリスト

- [ ] ビルドが成功する
- [ ] 型チェックがパスする
- [ ] リントエラーがゼロになる
- [ ] 既存のテストが通る
- [ ] 修正による副作用がないか確認

## トラブルシューティング

### エラーが解決しない場合

1. **キャッシュのクリア**
   ```bash
   pnpm clean  # または rm -rf node_modules .next dist
   pnpm install
   ```

2. **依存関係の再インストール**
   ```bash
   rm -rf node_modules pnpm-lock.yaml
   pnpm install
   ```

3. **型定義の更新**
   ```bash
   pnpm update @types/*
   ```

## 予防策

- 定期的な `pnpm build` の実行
- コミット前のビルドチェック
- CI/CDでのビルド検証
- 型チェックの強化（strict mode）
