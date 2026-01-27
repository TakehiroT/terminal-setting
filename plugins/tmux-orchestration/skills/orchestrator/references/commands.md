# tmuxコマンドリファレンス

## レビュー依頼

reviewerペイン（Impl.2）にメッセージを送信してレビューを依頼する。

```bash
# 基本形
S=$(tmux display-message -p '#S') && \
tmux send-keys -t "$S:Impl.2" -l 'tmux-reviewer skillを使って /review .branches/<feature>/ を行なってください' && \
sleep 0.1 && \
tmux send-keys -t "$S:Impl.2" Escape && \
sleep 0.1 && \
tmux send-keys -t "$S:Impl.2" Enter
```

**注意**:
- Codex（レビュワー）は `Escape` → `Enter` で送信
- `-l` オプションでリテラル送信（特殊文字エスケープ回避）
- sleep 0.1は安定性のため（ないと改行になる場合あり）

## ペインレイアウト

```
┌─────────────────┬──────────┐
│  orchestrator   │ reviewer │
│   (Impl.1)      │ (Impl.2) │
└─────────────────┴──────────┘
```

| 対象 | ターゲット |
|------|-----------|
| オーケストレーター | `$S:Impl.1` (`S=$(tmux display-message -p '#S')`) |
| レビュワー | `$S:Impl.2` (`S=$(tmux display-message -p '#S')`) |

## send-keys クイックリファレンス

```bash
# セッション名を取得
S=$(tmux display-message -p '#S')

# claudeペイン（Enter で送信）
tmux send-keys -t "$S:Impl.1" 'メッセージ' Enter

# codexペイン（Escape → Enter で送信）
tmux send-keys -t "$S:Impl.2" -l 'メッセージ' && \
sleep 0.1 && tmux send-keys -t "$S:Impl.2" Escape && \
sleep 0.1 && tmux send-keys -t "$S:Impl.2" Enter
```

## gtrコマンド

```bash
git gtr new <name>   # worktree作成 + ブランチ作成
git gtr rm <name>    # worktree削除 + ブランチ削除
git gtr list         # 一覧表示
```
