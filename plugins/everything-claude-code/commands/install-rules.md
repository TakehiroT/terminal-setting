---
description: everything-claude-code の rules をカレントプロジェクトにインストール
allowed-tools: Read, Write, Bash, Glob
---

# /install-rules - Rulesインストールコマンド

everything-claude-codeプラグインのrulesファイルをカレントプロジェクトの `.claude/rules/` ディレクトリにインストールします。

## 使用方法

```
/install-rules [オプション: --overwrite]
```

## 概要

このコマンドは、everything-claude-codeプラグインに含まれるベストプラクティスやコーディング規約を定義したrulesファイルを、現在作業中のプロジェクトにコピーします。

## インストールされるRules

プラグインの `plugins/everything-claude-code/rules/` にある全てのrulesファイルが対象です：

- `agent-orchestrator.md` - エージェントオーケストレーション規約
- `backend.md` - バックエンド開発のガイドライン
- `frontend.md` - フロントエンド開発のガイドライン
- `test.md` - テスト作成のベストプラクティス
- その他のrules

## 実行手順

### 1. プロジェクトのrules状態を確認

```bash
# カレントディレクトリに .claude/rules/ が存在するか確認
ls -la .claude/rules/
```

### 2. プラグインのrulesを取得

```bash
# プラグインのrulesディレクトリを確認
ls -la plugins/everything-claude-code/rules/
```

### 3. rulesのコピー

以下の手順で実行：

1. プロジェクトルートの `.claude/rules/` ディレクトリを確認
2. ディレクトリが存在しない場合は作成
3. プラグインのrulesファイルを1つずつコピー
4. 既存ファイルがある場合の処理：
   - デフォルト: スキップ（上書きしない）
   - `--overwrite` オプション: 上書き

### 4. インストール結果の確認

```bash
# インストールされたrulesを確認
ls -la .claude/rules/

# 各rulesファイルの内容を確認
cat .claude/rules/backend.md
```

## オプション

### --overwrite
既存のrulesファイルを上書きします。

```bash
/install-rules --overwrite
```

**使用場面**
- プラグインのrulesが更新された場合
- 既存のrulesを最新版に置き換えたい場合
- カスタマイズしたrulesを初期状態に戻したい場合

**注意**
既存のカスタマイズ内容は失われます。バックアップを推奨します。

## インストール前のバックアップ

```bash
# 既存のrulesをバックアップ
cp -r .claude/rules .claude/rules.backup.$(date +%Y%m%d-%H%M%S)

# バックアップの確認
ls -la .claude/
```

## 使用例

### 基本的なインストール

```bash
# 初回インストール
/install-rules

# 出力例:
# ✓ .claude/rules/ ディレクトリを作成
# ✓ agent-orchestrator.md をコピー
# ✓ backend.md をコピー
# ✓ frontend.md をコピー
# ✓ test.md をコピー
#
# 4個のrulesファイルをインストールしました。
```

### 既存ファイルがある場合

```bash
# デフォルト（スキップ）
/install-rules

# 出力例:
# - backend.md は既に存在します（スキップ）
# ✓ frontend.md をコピー
# - test.md は既に存在します（スキップ）
#
# 1個のrulesファイルをインストールしました。
# 2個のファイルをスキップしました。
```

### 上書きインストール

```bash
# 全て上書き
/install-rules --overwrite

# 出力例:
# ✓ agent-orchestrator.md を上書き
# ✓ backend.md を上書き
# ✓ frontend.md を上書き
# ✓ test.md を上書き
#
# 4個のrulesファイルを上書きしました。
```

## Rulesのカスタマイズ

インストール後、プロジェクト固有の要件に合わせてrulesをカスタマイズできます：

```bash
# プロジェクト固有のrulesを追加
vim .claude/rules/project-specific.md

# 既存のrulesを編集
vim .claude/rules/backend.md
```

### カスタマイズ例

```markdown
# .claude/rules/backend.md

<!-- 既存の内容 -->

## プロジェクト固有の規約

### データベース操作
- Prismaを使用すること
- トランザクションは必ず使用すること

### エラーハンドリング
- カスタムエラークラスを使用すること
- エラーログは winston で記録すること
```

## Rulesの適用確認

インストールしたrulesが適切に適用されているか確認：

```bash
# Claudeに確認
# 「プロジェクトのrulesを教えてください」と質問
```

Claudeは `.claude/rules/` にあるファイルを自動的に読み込みます。

## トラブルシューティング

### Rulesが適用されない

**原因**
- ファイルパスが間違っている
- ファイル名が正しくない
- ファイルの権限問題

**対処法**
```bash
# パスの確認
pwd
ls -la .claude/rules/

# 権限の確認と修正
chmod 644 .claude/rules/*.md
```

### インストールに失敗する

**原因**
- プラグインディレクトリが存在しない
- 書き込み権限がない

**対処法**
```bash
# プラグインの存在確認
ls -la plugins/everything-claude-code/

# 権限の確認
ls -ld .claude/

# 権限の付与
chmod 755 .claude/
```

### カスタマイズ内容を保持したい

```bash
# バックアップから特定の内容を復元
diff .claude/rules.backup.*/backend.md .claude/rules/backend.md

# 手動でマージ
vim .claude/rules/backend.md
```

## ベストプラクティス

### 1. 定期的な更新

```bash
# プラグイン更新後にrulesも更新
git pull  # プラグインの更新
/install-rules --overwrite  # rulesの更新
```

### 2. プロジェクトごとのカスタマイズ

```bash
# 基本ルールはプラグインから
/install-rules

# プロジェクト固有のルールは追加ファイルで
echo "# プロジェクト固有ルール" > .claude/rules/custom.md
```

### 3. バージョン管理

```gitignore
# .gitignore
# プラグインのrulesはインストール時に取得するため除外
.claude/rules/agent-orchestrator.md
.claude/rules/backend.md
.claude/rules/frontend.md
.claude/rules/test.md

# プロジェクト固有のrulesはコミット
!.claude/rules/custom.md
```

または、すべてをコミット：

```gitignore
# .gitignore には追加しない
# すべてのrulesをバージョン管理
```

## Rules の構成

インストールされるrulesの典型的な構成：

```
.claude/rules/
├── agent-orchestrator.md    # オーケストレーション規約
├── backend.md                # バックエンド規約
├── frontend.md               # フロントエンド規約
├── test.md                   # テスト規約
└── custom.md                 # プロジェクト固有（任意）
```

## まとめ

`/install-rules` コマンドは：
- ✅ プラグインのrulesを簡単にインストール
- ✅ 既存ファイルの保護（デフォルト）
- ✅ 上書きオプションによる更新
- ✅ プロジェクトごとのカスタマイズが可能

プロジェクト開始時にこのコマンドを実行することで、一貫したコーディング規約とベストプラクティスを適用できます。
