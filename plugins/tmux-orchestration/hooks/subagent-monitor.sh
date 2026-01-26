#!/bin/bash
# Subagent Monitor - サブエージェントの起動・完了を記録
#
# Claude Code の SubagentStart/SubagentStop hook から呼び出される
# .spec/agents.json にステータスを記録し、vibe-dashboard.sh と連携

set -euo pipefail

# JSONをstdinから受け取り
input=$(cat)

# 必要な値を抽出
event=$(echo "$input" | jq -r '.hook_event_name // empty')
agent_id=$(echo "$input" | jq -r '.agent_id // empty')
agent_type=$(echo "$input" | jq -r '.agent_type // empty')
session_id=$(echo "$input" | jq -r '.session_id // empty')
cwd=$(echo "$input" | jq -r '.cwd // empty')
timestamp=$(date '+%H:%M:%S')

# agent_type から worker 名を抽出（例: tmux-orchestration:frontend-worker -> frontend）
worker_name=""
case "$agent_type" in
    *frontend*) worker_name="frontend" ;;
    *backend*) worker_name="backend" ;;
    *test*) worker_name="test" ;;
    *debug*) worker_name="debug" ;;
    *) worker_name="$agent_type" ;;
esac

# .spec ディレクトリを特定
spec_dir=""
if [[ -n "$cwd" ]]; then
    # git root から .spec を探す
    git_root=$(cd "$cwd" && git rev-parse --show-toplevel 2>/dev/null || echo "$cwd")
    spec_dir="$git_root/.spec"
fi

# .spec が見つからない場合は終了
if [[ -z "$spec_dir" ]]; then
    echo '{"continue": true}'
    exit 0
fi

# ディレクトリ作成
mkdir -p "$spec_dir"

status_file="$spec_dir/agents.json"

# 既存の agents.json を読み込み（なければ空オブジェクト）
if [[ -f "$status_file" ]]; then
    current_json=$(cat "$status_file")
else
    current_json="{}"
fi

case "$event" in
    "SubagentStart")
        # 起動を記録
        new_json=$(echo "$current_json" | jq \
            --arg worker "$worker_name" \
            --arg id "$agent_id" \
            --arg type "$agent_type" \
            --arg time "$timestamp" \
            --arg session "$session_id" \
            '.[$worker] = {
                id: $id,
                type: $type,
                status: "active",
                started: $time,
                session: $session
            }')
        echo "$new_json" > "$status_file"
        ;;

    "SubagentStop")
        # 完了を記録（agent_id で検索して更新）
        new_json=$(echo "$current_json" | jq \
            --arg id "$agent_id" \
            --arg time "$timestamp" \
            'to_entries | map(
                if .value.id == $id then
                    .value.status = "done" |
                    .value.finished = $time
                else
                    .
                end
            ) | from_entries')
        echo "$new_json" > "$status_file"
        ;;
esac

# 正常終了（処理を継続）
echo '{"continue": true}'
exit 0
