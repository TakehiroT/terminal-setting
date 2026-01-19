#!/usr/bin/env bash
# フォーマッター自動選択スクリプト
# 優先順位: 環境変数 CLAUDE_FORMATTER > biome.json > .prettierrc > デフォルト(Biome)

set -euo pipefail

# 標準入力から tool_input を取得
input=$(cat)

# file_path を抽出
file_path=$(echo "$input" | jq -r '.tool_input.file_path // ""')

# ファイルパスが空の場合は何もせずに終了
if [ -z "$file_path" ] || [ ! -f "$file_path" ]; then
  echo "$input"
  exit 0
fi

# プロジェクトルートを探索
dir=$(dirname "$file_path")
project_root="$dir"

while [ "$project_root" != "/" ]; do
  if [ -f "$project_root/package.json" ]; then
    break
  fi
  project_root=$(dirname "$project_root")
done

# フォーマッター選択
formatter=""

# 1. 環境変数を最優先
if [ -n "${CLAUDE_FORMATTER:-}" ]; then
  formatter="$CLAUDE_FORMATTER"
  echo "INFO: 環境変数 CLAUDE_FORMATTER=$formatter を使用します" >&2
# 2. biome.json の存在確認
elif [ -f "$project_root/biome.json" ]; then
  formatter="biome"
  echo "INFO: biome.json が見つかりました。Biome を使用します" >&2
# 3. .prettierrc の存在確認
elif [ -f "$project_root/.prettierrc" ] || \
     [ -f "$project_root/.prettierrc.json" ] || \
     [ -f "$project_root/.prettierrc.js" ] || \
     [ -f "$project_root/prettier.config.js" ]; then
  formatter="prettier"
  echo "INFO: Prettier設定ファイルが見つかりました。Prettierを使用します" >&2
# 4. デフォルトは Biome
else
  formatter="biome"
  echo "INFO: デフォルトフォーマッター Biome を使用します" >&2
fi

# フォーマット実行
cd "$project_root"

case "$formatter" in
  biome)
    if command -v biome &> /dev/null; then
      biome format --write "$file_path" 2>&1 | head -10 >&2 || true
    else
      echo "WARNING: biome コマンドが見つかりません。フォーマットをスキップします" >&2
    fi
    ;;
  prettier)
    if command -v prettier &> /dev/null; then
      prettier --write "$file_path" 2>&1 | head -10 >&2 || true
    elif [ -f "$project_root/node_modules/.bin/prettier" ]; then
      "$project_root/node_modules/.bin/prettier" --write "$file_path" 2>&1 | head -10 >&2 || true
    else
      echo "WARNING: prettier コマンドが見つかりません。フォーマットをスキップします" >&2
    fi
    ;;
  *)
    echo "WARNING: 不明なフォーマッター '$formatter' が指定されました" >&2
    ;;
esac

# 元の入力をそのまま出力
echo "$input"
