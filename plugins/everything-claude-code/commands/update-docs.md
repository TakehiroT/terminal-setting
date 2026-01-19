---
description: ドキュメントを更新する
allowed-tools: Read, Write, Edit, Glob, Grep
---

# /update-docs - ドキュメント更新コマンド

doc-updaterエージェントを使用してプロジェクトのドキュメントを更新します。

## 使用方法

```
/update-docs [オプション: 更新対象のドキュメント]
```

## 更新対象のドキュメント

### 1. README.md
プロジェクトの概要とクイックスタート

```markdown
# プロジェクト名

## 概要
プロジェクトの簡潔な説明

## 機能
- 主要機能1
- 主要機能2

## セットアップ
\`\`\`bash
pnpm install
pnpm dev
\`\`\`

## 使用方法
基本的な使用例

## ドキュメント
詳細なドキュメントへのリンク
```

### 2. API ドキュメント
エンドポイントやメソッドの仕様

```markdown
# API Reference

## GET /api/users
ユーザー一覧を取得

### リクエスト
\`\`\`
GET /api/users?page=1&limit=10
\`\`\`

### レスポンス
\`\`\`json
{
  "users": [...],
  "total": 100
}
\`\`\`
```

### 3. 開発ガイド
開発環境の構築手順

```markdown
# 開発ガイド

## 必要な環境
- Node.js 20+
- pnpm 9+

## セットアップ
1. 依存関係のインストール
2. 環境変数の設定
3. データベースの初期化

## 開発フロー
- ブランチ戦略
- コミット規約
- レビュープロセス
```

### 4. アーキテクチャドキュメント
システム設計と構成

```markdown
# アーキテクチャ

## システム構成
- フロントエンド: React + TypeScript
- バックエンド: Node.js + Express
- データベース: PostgreSQL

## ディレクトリ構造
\`\`\`
src/
├── components/    # UIコンポーネント
├── pages/         # ページコンポーネント
├── api/           # APIルート
└── utils/         # ユーティリティ
\`\`\`
```

### 5. CHANGELOG.md
バージョンごとの変更履歴

```markdown
# Changelog

## [1.2.0] - 2024-01-15
### Added
- 新機能X

### Changed
- 既存機能Yの改善

### Fixed
- バグZの修正
```

## doc-updaterエージェントの役割

- コードベースの変更を検出
- 影響を受けるドキュメントを特定
- ドキュメントの整合性チェック
- 適切な更新内容の提案
- ドキュメントの自動生成（可能な場合）

## 実行手順

### 1. 更新が必要なドキュメントの特定

エージェントは以下をチェック：
- 最近のコード変更
- 新規追加されたファイル
- 削除されたファイル
- APIの変更
- 設定ファイルの変更

### 2. 現在のドキュメントの確認

```bash
# ドキュメントファイルの一覧
docs/
├── README.md
├── api/
│   ├── authentication.md
│   └── endpoints.md
├── guides/
│   ├── getting-started.md
│   └── deployment.md
└── architecture/
    └── system-design.md
```

### 3. ドキュメントの更新

エージェントが以下を実行：
- 古い情報の更新
- 新しい機能の追加
- 削除された機能の情報削除
- コード例の更新
- リンク切れの修正

### 4. 検証

更新後のチェック：
- マークダウンの構文チェック
- リンクの有効性確認
- コードブロックの動作確認

## ドキュメントの種類別ガイドライン

### README.md

**必須項目**
- プロジェクト名と説明
- インストール方法
- 基本的な使用方法
- ライセンス情報

**推奨項目**
- バッジ（ビルド状態、カバレッジなど）
- スクリーンショット
- 貢献ガイドライン
- 関連リンク

### API ドキュメント

**記載内容**
- エンドポイントのパス
- HTTPメソッド
- リクエストパラメータ
- レスポンス形式
- エラーコード
- 認証方法
- 使用例

**フォーマット**
```markdown
## POST /api/login

ユーザーログイン

### リクエスト
| パラメータ | 型 | 必須 | 説明 |
|----------|-----|------|------|
| email    | string | ✓ | メールアドレス |
| password | string | ✓ | パスワード |

### レスポンス
\`\`\`json
{
  "token": "eyJhbGc...",
  "user": { ... }
}
\`\`\`

### エラー
- `400` - 入力値エラー
- `401` - 認証失敗
```

### コンポーネントドキュメント

```markdown
# Button コンポーネント

## 概要
汎用的なボタンコンポーネント

## Props
| 名前 | 型 | デフォルト | 説明 |
|------|-----|-----------|------|
| variant | 'primary' \| 'secondary' | 'primary' | ボタンの種類 |
| onClick | () => void | - | クリック時のハンドラ |

## 使用例
\`\`\`tsx
<Button variant="primary" onClick={handleClick}>
  クリック
</Button>
\`\`\`
```

## ベストプラクティス

### 1. 同期を保つ
```bash
# コード変更時にドキュメントも更新
git commit -m "feat: 新機能追加とドキュメント更新"
```

### 2. コード例は実際に動くものを
```markdown
<!-- ❌ 動かないコード例 -->
\`\`\`typescript
const result = doSomething();
\`\`\`

<!-- ✅ 完全なコード例 -->
\`\`\`typescript
import { doSomething } from './utils';

const result = doSomething({
  param1: 'value',
  param2: 42
});
console.log(result);
\`\`\`
```

### 3. スクリーンショットは最新に
- UI変更時は画像も更新
- 日付やバージョンを画像ファイル名に含める

### 4. 検索可能なキーワードを含める
- よくある質問への回答
- エラーメッセージの対処法
- トラブルシューティング

## 自動生成ツールの活用

### TypeDoc（TypeScript）
```bash
# APIドキュメントの自動生成
pnpm typedoc --out docs/api src/
```

### JSDoc（JavaScript）
```javascript
/**
 * ユーザーを作成する
 * @param {Object} userData - ユーザーデータ
 * @param {string} userData.name - ユーザー名
 * @param {string} userData.email - メールアドレス
 * @returns {Promise<User>} 作成されたユーザー
 */
async function createUser(userData) {
  // ...
}
```

### OpenAPI/Swagger
```yaml
# openapi.yaml
paths:
  /api/users:
    get:
      summary: ユーザー一覧取得
      responses:
        '200':
          description: 成功
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/User'
```

## 使用例

```bash
# 全ドキュメントを更新
/update-docs

# README.mdのみ更新
/update-docs README.md

# APIドキュメントを更新
/update-docs docs/api

# 新機能の追加に伴う更新
/update-docs --feature "ユーザー認証機能"

# CHANGELOG.mdに変更履歴を追加
/update-docs CHANGELOG.md --version 1.2.0
```

## ドキュメント品質チェック

### リンク切れチェック
```bash
# マークダウンのリンクチェック
pnpm markdown-link-check docs/**/*.md
```

### スペルチェック
```bash
# スペルミスチェック
pnpm cspell "docs/**/*.md"
```

### マークダウン構文チェック
```bash
# マークダウンのリント
pnpm markdownlint docs/
```

## チェックリスト

ドキュメント更新時の確認項目：

- [ ] コードの変更に対応している
- [ ] コード例が正しく動作する
- [ ] リンクが有効
- [ ] スクリーンショットが最新
- [ ] 誤字脱字がない
- [ ] 構文エラーがない
- [ ] 一貫したスタイル
- [ ] 適切な見出し構造
- [ ] 目次が更新されている（必要な場合）

## ドキュメントの配置

```
project/
├── README.md              # プロジェクトのトップ
├── CHANGELOG.md           # 変更履歴
├── CONTRIBUTING.md        # 貢献ガイドライン
├── docs/                  # 詳細ドキュメント
│   ├── api/              # APIリファレンス
│   ├── guides/           # ガイド・チュートリアル
│   ├── architecture/     # システム設計
│   └── troubleshooting/  # トラブルシューティング
└── .github/
    └── PULL_REQUEST_TEMPLATE.md
```

## 継続的な改善

- ユーザーからのフィードバックを反映
- よくある質問をFAQに追加
- 使用例を充実させる
- バージョンごとの移行ガイド作成
