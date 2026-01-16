#!/bin/bash
# zellij版: worktreeクリーンアップとclaude/codex再起動
# 使用方法: cleanup-restart.sh [session-name]
# tmuxと同様にセッション名を引数で受け取る

set -e

SESSION_NAME="${1:-}"

echo "=== クリーンアップ＆再起動 ==="

# セッション指定がある場合は環境変数を設定
if [[ -n "$SESSION_NAME" ]]; then
    export ZELLIJ_SESSION_NAME="$SESSION_NAME"
fi

# 現在のディレクトリがworktreeかどうか確認
WORKTREE_INFO=$(git rev-parse --show-toplevel 2>/dev/null)
MAIN_WORKTREE=$(git worktree list 2>/dev/null | head -1 | awk '{print $1}')

if [[ -z "$WORKTREE_INFO" ]]; then
    echo "警告: gitリポジトリではありません"
elif [[ "$WORKTREE_INFO" == "$MAIN_WORKTREE" ]]; then
    # メインリポジトリにいる場合
    BRANCH=$(git branch --show-current 2>/dev/null || echo "")
    if [[ "$BRANCH" == "main" || "$BRANCH" == "master" ]]; then
        echo "既にmainブランチです"
    elif [[ -n "$BRANCH" ]]; then
        echo "ブランチ検出: $BRANCH"
        echo "mainブランチに切り替え中..."
        git checkout main
        echo "ブランチ削除中..."
        git branch -D "$BRANCH" 2>/dev/null || echo "ブランチ削除をスキップ"
        echo "クリーンアップ完了"
    fi
else
    # worktreeにいる場合
    BRANCH=$(git branch --show-current 2>/dev/null || echo "")
    echo "worktree検出: $WORKTREE_INFO"
    echo "ブランチ: $BRANCH"
    echo "メインリポジトリに移動中..."
    cd "$MAIN_WORKTREE"
    echo "worktree削除中..."
    git worktree remove "$WORKTREE_INFO" --force 2>/dev/null || echo "worktree削除をスキップ"
    echo "ブランチ削除中..."
    git branch -D "$BRANCH" 2>/dev/null || echo "ブランチ削除をスキップ"
    echo "クリーンアップ完了"
fi

echo ""
echo "claude/codexを再起動中..."

# Implタブに移動（タブ名で絶対指定）
zellij action go-to-tab-name "Impl"
sleep 0.2

# orchestratorペインへ移動（左）
zellij action move-focus left
sleep 0.2

# orchestratorへ/exitを送信
zellij action write-chars '/exit'
zellij action write 13
echo "  -> orchestrator: /exit"
sleep 0.5

# reviewerへ移動（右へ）
zellij action move-focus right
sleep 0.2

# reviewerへ/exitを送信
zellij action write-chars '/exit'
zellij action write 13
echo "  -> reviewer: /exit"

echo ""
echo "=== 完了（自動再起動します）==="
