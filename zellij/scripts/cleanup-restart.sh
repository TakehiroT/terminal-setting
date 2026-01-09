#!/bin/bash
# worktreeのクリーンアップとclaude/codex再起動
# exitを送信するとwhile loopで自動再起動

set -e

echo "=== クリーンアップ＆再起動 ==="

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

# orchestratorへ/exitを送信
zellij action move-focus left
zellij action move-focus up
sleep 0.2
zellij action write-chars '/exit'
zellij action write 13
echo "  -> orchestrator: /exit"
sleep 0.5

# reviewerへ/exitを送信
zellij action move-focus right
sleep 0.2
zellij action write-chars '/exit'
zellij action write 13
echo "  -> reviewer: /exit"

echo ""
echo "=== 完了（自動再起動します）==="
