#!/bin/bash
# 🐕 watchdog.sh - エージェントの生存監視を行う番犬
# 指定ディレクトリ（queue/reports）の更新時刻を監視し、
# 一定時間（デフォルト10分）更新がないエージェントを検出して警告する。

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
REPORT_DIR="${ROOT_DIR}/queue/reports"
DASHBOARD_FILE="${ROOT_DIR}/dashboard.md"

# 監視対象エージェント
AGENTS=("orchestrator" "strategy_consultant" "product_owner" "tech_lead" "frontend" "backend" "db_infra" "ui_ux" "qa_reviewer" "archivist")

# タイムアウト時間（秒） - デフォルト600秒（10分）
TIMEOUT_SECONDS=600

# チェック間隔（秒）
CHECK_INTERVAL=60

log_check() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 🐕 番犬巡回中..."
}

log_alert() {
    local agent="$1"
    local last_update="$2"
    echo -e "\033[1;31m[ALERT]\033[0m ${agent} が応答していません（最終更新: ${last_update}）"
    
    # ダッシュボードに警告を追記（重複しないように確認）
    if grep -q "⚠️ ${agent}" "$DASHBOARD_FILE"; then
        return
    fi
    
    # 既存の「🚨 要対応」セクションに追記する簡易ロジック
    if [ -f "$DASHBOARD_FILE" ]; then
         # macOS sed compatible insert
         sed -i '' "/## 🚨 要対応/a\\
- [ ] ⚠️ **${agent}** の応答がありません (Check logs!)" "$DASHBOARD_FILE"
    fi
}

log_start() {
    echo "🐕 Watchdog started across ${#AGENTS[@]} agents."
    echo "   Watching directory: $REPORT_DIR"
    echo "   Timeout threshold: ${TIMEOUT_SECONDS}s"
}

log_start

while true; do
    log_check
    
    CURRENT_TIME=$(date +%s)
    
    for agent in "${AGENTS[@]}"; do
        # レポートファイルのパス
        # エージェント名の揺らぎ（orchestratorのみ _report がない等）を吸収
        if [ "$agent" == "orchestrator" ]; then
            FILE_PATH="${ROOT_DIR}/queue/tasks/${agent}.yaml" # Orchestratorはタスクファイルを見る（例）
            # もしくは reports/orchestrator_report.yaml があるならそちら
            if [ -f "${REPORT_DIR}/${agent}_report.yaml" ]; then
                FILE_PATH="${REPORT_DIR}/${agent}_report.yaml"
            fi
        else
            FILE_PATH="${REPORT_DIR}/${agent}_report.yaml"
        fi

        if [ -f "$FILE_PATH" ]; then
            LAST_MOD=$(stat -f %m "$FILE_PATH")
            DIFF=$((CURRENT_TIME - LAST_MOD))
            
            if [ $DIFF -gt $TIMEOUT_SECONDS ]; then
                LAST_UPDATE_STR=$(date -r "$LAST_MOD" '+%H:%M:%S')
                log_alert "$agent" "$LAST_UPDATE_STR"
            fi
        else
            echo "   [INFO] No report file found for $agent yet."
        fi
    done
    
    sleep $CHECK_INTERVAL
done
