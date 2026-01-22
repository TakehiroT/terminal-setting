#!/bin/bash
# plan-viewer.sh - planモード出力をリアルタイム監視・表示
#
# 使い方:
#   ./plan-viewer.sh [plans_dir]
#
# 引数:
#   plans_dir - planファイルのディレクトリ (デフォルト: ./.spec)

PLANS_DIR="${1:-./.spec}"
REFRESH_INTERVAL=2

# 色定義
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

show_header() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  Plan Viewer - Watching: ${PLANS_DIR}${NC}"
    echo -e "${CYAN}  Press Ctrl+C to exit${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

find_latest_plan() {
    # .md ファイルを更新日時順で取得（最新が先頭）
    # plan*.md または task*.md を対象
    find "$PLANS_DIR" -maxdepth 2 -type f \( -name "*.md" \) 2>/dev/null | \
        xargs ls -t 2>/dev/null | \
        head -1
}

display_plan() {
    local file="$1"

    clear
    show_header

    if [[ -z "$file" ]]; then
        echo ""
        echo -e "${YELLOW}  Waiting for plan files in ${PLANS_DIR}...${NC}"
        echo ""
        echo "  planモードで計画を作成すると、ここに表示されます"
        echo "  Shift+Tab でplanモードに切り替え"
        return
    fi

    local filename=$(basename "$file")
    local modified=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$file" 2>/dev/null || stat -c "%y" "$file" 2>/dev/null | cut -d'.' -f1)

    echo ""
    echo -e "${GREEN}  Latest: ${filename}${NC}"
    echo -e "${GREEN}  Modified: ${modified}${NC}"
    echo -e "${CYAN}──────────────────────────────────────────────────────────${NC}"
    echo ""

    # glowがあればMarkdownをレンダリング、なければcatで表示
    if command -v glow &> /dev/null; then
        glow -s dark "$file" 2>/dev/null || cat "$file"
    else
        cat "$file"
    fi
}

main() {
    # ディレクトリが存在しない場合は作成
    mkdir -p "$PLANS_DIR"

    local last_file=""
    local last_mtime=""

    while true; do
        local latest=$(find_latest_plan)
        local current_mtime=""

        if [[ -n "$latest" ]]; then
            current_mtime=$(stat -f "%m" "$latest" 2>/dev/null || stat -c "%Y" "$latest" 2>/dev/null)
        fi

        # ファイルが変わったか、更新されたら再表示
        if [[ "$latest" != "$last_file" ]] || [[ "$current_mtime" != "$last_mtime" ]]; then
            display_plan "$latest"
            last_file="$latest"
            last_mtime="$current_mtime"
        fi

        sleep "$REFRESH_INTERVAL"
    done
}

# Ctrl+C でクリーンに終了
trap 'echo -e "\n${NC}Exiting..."; exit 0' INT

main
