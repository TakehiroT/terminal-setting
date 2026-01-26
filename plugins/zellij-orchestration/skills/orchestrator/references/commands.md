# Zellijコマンドリファレンス

## レビュー依頼

reviewerペインにメッセージを送信してレビューを依頼する。

```bash
# 基本形
zellij -s "$ZELLIJ_SESSION_NAME" action move-focus right && \
sleep 0.3 && \
zellij -s "$ZELLIJ_SESSION_NAME" action write-chars 'reviewer skillを使って /review .branches/<feature>/ を行なってください' && \
zellij -s "$ZELLIJ_SESSION_NAME" action write 27 && \
sleep 0.1 && \
zellij -s "$ZELLIJ_SESSION_NAME" action write 13 && \
sleep 0.3 && \
zellij -s "$ZELLIJ_SESSION_NAME" action move-focus left
```

**注意**:
- Codex（レビュワー）は `Escape (27)` → `Enter (13)` で送信
- `-s "$ZELLIJ_SESSION_NAME"` は必須（セッション指定）
- sleepは安定性のため

## ペインレイアウト

```
┌─────────────────┬──────────┐
│  orchestrator   │ reviewer │
│    (Pane 0)     │ (Pane 1) │
└─────────────────┴──────────┘
```

| 操作 | コマンド |
|------|----------|
| 右に移動 | `zellij action move-focus right` |
| 左に移動 | `zellij action move-focus left` |
| 文字送信 | `zellij action write-chars 'text'` |
| キーコード送信 | `zellij action write <code>` |

## gtrコマンド

```bash
git gtr new <name>   # worktree作成 + ブランチ作成
git gtr rm <name>    # worktree削除 + ブランチ削除
git gtr list         # 一覧表示
```
