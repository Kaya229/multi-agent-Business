#!/bin/bash
# 🏢 multi-agent-Business 出陣スクリプト（ビジネス版）
# Daily Deployment Script for Business Multi-Agent System
#
# 使用方法:
#   ./shutsujin_departure.sh           # 全エージェント起動（通常）
#   ./shutsujin_departure.sh -s        # セットアップのみ（Claude起動なし）
#   ./shutsujin_departure.sh -h        # ヘルプ表示

set -e

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 言語設定を読み取り（デフォルト: ja）
LANG_SETTING="ja"
if [ -f "./config/settings.yaml" ]; then
    LANG_SETTING=$(grep "^language:" ./config/settings.yaml 2>/dev/null | awk '{print $2}' || echo "ja")
fi

# シェル設定を読み取り（デフォルト: bash）
SHELL_SETTING="bash"
if [ -f "./config/settings.yaml" ]; then
    SHELL_SETTING=$(grep "^shell:" ./config/settings.yaml 2>/dev/null | awk '{print $2}' || echo "bash")
fi

# 色付きログ関数（ビジネス風 + 戦国風）
log_info() {
    echo -e "\033[1;33m【報告】\033[0m $1"
}

log_success() {
    echo -e "\033[1;32m【完了】\033[0m $1"
}

log_war() {
    echo -e "\033[1;31m【実行】\033[0m $1"
}

# ═══════════════════════════════════════════════════════════════════════════════
# プロンプト生成関数（bash/zsh対応）
# ═══════════════════════════════════════════════════════════════════════════════
generate_prompt() {
    local label="$1"
    local color="$2"
    local shell_type="$3"

    if [ "$shell_type" == "zsh" ]; then
        echo "(%F{${color}}%B${label}%b%f) %F{green}%B%~%b%f%# "
    else
        local color_code
        case "$color" in
            red)     color_code="1;31" ;;
            green)   color_code="1;32" ;;
            yellow)  color_code="1;33" ;;
            blue)    color_code="1;34" ;;
            magenta) color_code="1;35" ;;
            cyan)    color_code="1;36" ;;
            *)       color_code="1;37" ;;
        esac
        echo "(\[\033[${color_code}m\]${label}\[\033[0m\]) \[\033[1;32m\]\w\[\033[0m\]\$ "
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# ログ設定関数
# ═══════════════════════════════════════════════════════════════════════════════
setup_logging() {
    local target="$1"
    local agent_name="$2"
    local timestamp=$(date "+%Y%m%d_%H%M%S")
    local log_file="./logs/${timestamp}_${agent_name}.log"

    # logsディレクトリが存在することを確認
    [ -d "./logs" ] || mkdir -p "./logs"

    # pipe-paneで出力をファイルに保存（追記モード）
    tmux pipe-pane -t "$target" "cat >> $log_file"

    log_info "  📝 ログ記録開始: $agent_name -> $log_file"
}

# ═══════════════════════════════════════════════════════════════════════════════
# オプション解析
# ═══════════════════════════════════════════════════════════════════════════════
SETUP_ONLY=false
OPEN_TERMINAL=false
SHELL_OVERRIDE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--setup-only)
            SETUP_ONLY=true
            shift
            ;;
        -t|--terminal)
            OPEN_TERMINAL=true
            shift
            ;;
        -shell|--shell)
            if [[ -n "$2" && "$2" != -* ]]; then
                SHELL_OVERRIDE="$2"
                shift 2
            else
                echo "エラー: -shell オプションには bash または zsh を指定してください"
                exit 1
            fi
            ;;
        -h|--help)
            echo ""
            echo "🏢 multi-agent-Business 出陣スクリプト"
            echo ""
            echo "使用方法: ./shutsujin_departure.sh [オプション]"
            echo ""
            echo "オプション:"
            echo "  -s, --setup-only    tmuxセッションのセットアップのみ（Claude起動なし）"
            echo "  -t, --terminal      Windows Terminal で新しいタブを開く"
            echo "  -shell, --shell SH  シェルを指定（bash または zsh）"
            echo "  -h, --help          このヘルプを表示"
            echo ""
            echo "10体構成:"
            echo "  [司令塔層] Orchestrator, Strategy Consultant, Product Owner"
            echo "  [技術層]   Tech Lead, Frontend, Backend, DB/Infra, UI/UX"
            echo "  [品質層]   QA Reviewer, Archivist"
            echo ""
            exit 0
            ;;
        *)
            echo "不明なオプション: $1"
            exit 1
            ;;
    esac
done

if [ -n "$SHELL_OVERRIDE" ]; then
    SHELL_SETTING="$SHELL_OVERRIDE"
fi

# ═══════════════════════════════════════════════════════════════════════════════
# 出陣バナー表示
# ═══════════════════════════════════════════════════════════════════════════════
show_battle_cry() {
    clear
    echo ""
    echo -e "\033[1;34m╔══════════════════════════════════════════════════════════════════════════════════╗\033[0m"
    echo -e "\033[1;34m║\033[0m  \033[1;37m🏢 MULTI-AGENT BUSINESS SYSTEM\033[0m                                                  \033[1;34m║\033[0m"
    echo -e "\033[1;34m║\033[0m  \033[1;33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m  \033[1;34m║\033[0m"
    echo -e "\033[1;34m║\033[0m  \033[1;36m10体のAIエージェントが並列稼働するビジネス開発システム\033[0m                      \033[1;34m║\033[0m"
    echo -e "\033[1;34m╚══════════════════════════════════════════════════════════════════════════════════╝\033[0m"
    echo ""
    echo -e "\033[1;35m  【 組織構成 】\033[0m"
    echo ""
    echo -e "  \033[1;33m┌─────────────────────────────────────────────────────────────────────────────┐\033[0m"
    echo -e "  \033[1;33m│\033[0m  \033[1;31m司令塔・戦略層\033[0m                                                            \033[1;33m│\033[0m"
    echo -e "  \033[1;33m│\033[0m    👑 Orchestrator     📊 Strategy Consultant     📋 Product Owner       \033[1;33m│\033[0m"
    echo -e "  \033[1;33m├─────────────────────────────────────────────────────────────────────────────┤\033[0m"
    echo -e "  \033[1;33m│\033[0m  \033[1;34m技術・実装層\033[0m                                                              \033[1;33m│\033[0m"
    echo -e "  \033[1;33m│\033[0m    🔧 Tech Lead    💻 Frontend    🖥️ Backend    🗄️ DB/Infra    🎨 UI/UX    \033[1;33m│\033[0m"
    echo -e "  \033[1;33m├─────────────────────────────────────────────────────────────────────────────┤\033[0m"
    echo -e "  \033[1;33m│\033[0m  \033[1;32m品質・保存層\033[0m                                                              \033[1;33m│\033[0m"
    echo -e "  \033[1;33m│\033[0m    🔍 QA Reviewer                          📚 Archivist                  \033[1;33m│\033[0m"
    echo -e "  \033[1;33m└─────────────────────────────────────────────────────────────────────────────┘\033[0m"
    echo ""
}

show_battle_cry

echo -e "  \033[1;33m天下布武！陣立てを開始いたす\033[0m (Setting up the battlefield)"
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 1: 既存セッションクリーンアップ
# ═══════════════════════════════════════════════════════════════════════════════
log_info "🧹 既存の陣を撤収中..."
tmux kill-session -t multiagent 2>/dev/null && log_info "  └─ multiagent陣、撤収完了" || log_info "  └─ multiagent陣は存在せず"
tmux kill-session -t multiagent 2>/dev/null && log_info "  └─ multiagent陣、撤収完了" || log_info "  └─ multiagent陣は存在せず"
tmux kill-session -t shogun 2>/dev/null && log_info "  └─ shogun本陣、撤収完了" || log_info "  └─ shogun本陣は存在せず"

# 番犬の撤収
pkill -f "watchdog.sh" && log_info "  └─ 番犬(watchdog.sh)、撤収完了" || true

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 1.5: 前回記録のバックアップ
# ═══════════════════════════════════════════════════════════════════════════════
BACKUP_DIR="./logs/backup_$(date '+%Y%m%d_%H%M%S')"
NEED_BACKUP=false

if [ -f "./dashboard.md" ]; then
    if grep -q "cmd_" "./dashboard.md" 2>/dev/null; then
        NEED_BACKUP=true
    fi
fi

if [ "$NEED_BACKUP" = true ]; then
    mkdir -p "$BACKUP_DIR" || true
    cp "./dashboard.md" "$BACKUP_DIR/" 2>/dev/null || true
    cp -r "./queue/reports" "$BACKUP_DIR/" 2>/dev/null || true
    cp -r "./queue/tasks" "$BACKUP_DIR/" 2>/dev/null || true
    log_info "📦 前回の記録をバックアップ: $BACKUP_DIR"
fi

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 2: キューファイルリセット
# ═══════════════════════════════════════════════════════════════════════════════
log_info "📜 前回の記録を破棄中..."

# ディレクトリ作成
[ -d ./queue/reports ] || mkdir -p ./queue/reports
[ -d ./queue/tasks ] || mkdir -p ./queue/tasks
[ -d ./queue/backlog ] || mkdir -p ./queue/backlog
[ -d ./context ] || mkdir -p ./context

# 10体のエージェント用タスクファイルをリセット
AGENTS=("orchestrator" "strategy_consultant" "product_owner" "tech_lead" "frontend" "backend" "db_infra" "ui_ux" "qa_reviewer" "archivist")

for agent in "${AGENTS[@]}"; do
    cat > "./queue/tasks/${agent}.yaml" << EOF
# ${agent} タスクファイル
task:
  task_id: null
  parent_cmd: null
  description: null
  target_path: null
  status: idle
  timestamp: ""
EOF
done

# 報告ファイルリセット
for agent in "${AGENTS[@]}"; do
    cat > "./queue/reports/${agent}_report.yaml" << EOF
worker_id: ${agent}
task_id: null
timestamp: ""
status: idle
result: null
EOF
done

# プロジェクト状態ファイル初期化
cat > ./context/project_state.yaml << 'EOF'
# プロジェクト状態（Archivist管理）
project:
  id: null
  name: null
  phase: Planning  # Planning | Coding | Review

requirements: []
completed_tasks: []
in_progress: []
current_blockers: []

file_structure: {}

last_human_feedback: ""
last_updated: ""
EOF

log_success "✅ キューファイルリセット完了"

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 3: ダッシュボード初期化
# ═══════════════════════════════════════════════════════════════════════════════
log_info "📊 戦況報告板を初期化中..."
TIMESTAMP=$(date "+%Y-%m-%d %H:%M")

cat > ./dashboard.md << EOF
# 📊 戦況報告（Business Multi-Agent System）
最終更新: ${TIMESTAMP}

## 🚨 要対応 - 殿のご判断をお待ちしております
なし

## 🔄 進行中
| 担当 | タスク | 開始時刻 |
|------|--------|----------|

## ✅ 本日の戦果
| 時刻 | 担当 | 任務 | 結果 |
|------|------|------|------|

## 🎯 スキル化候補 - 承認待ち
なし

## ⏸️ 待機中
全エージェント待機中

## 📋 現在のフェーズ
**Planning** - 要件定義フェーズ
EOF

log_success "  └─ ダッシュボード初期化完了 (言語: $LANG_SETTING, シェル: $SHELL_SETTING)"
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 4: tmux の存在確認
# ═══════════════════════════════════════════════════════════════════════════════
if ! command -v tmux &> /dev/null; then
    echo ""
    echo "  ╔════════════════════════════════════════════════════════╗"
    echo "  ║  [ERROR] tmux not found!                              ║"
    echo "  ╠════════════════════════════════════════════════════════╣"
    echo "  ║  Run first_setup.sh first:                            ║"
    echo "  ║     ./first_setup.sh                                  ║"
    echo "  ╚════════════════════════════════════════════════════════╝"
    echo ""
    exit 1
fi

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 5: shogun セッション作成（Orchestrator用）
# ═══════════════════════════════════════════════════════════════════════════════
log_war "👑 Orchestratorの本陣を構築中..."

if ! tmux has-session -t shogun 2>/dev/null; then
    tmux new-session -d -s shogun -n main
fi

ORCHESTRATOR_PROMPT=$(generate_prompt "Orchestrator" "magenta" "$SHELL_SETTING")
tmux send-keys -t shogun:main "cd \"$(pwd)\" && export PS1='${ORCHESTRATOR_PROMPT}' && clear" Enter
tmux select-pane -t shogun:main -P 'bg=#002b36'

# ログ記録開始 (Orchestrator)
setup_logging "shogun:main" "orchestrator"

log_success "  └─ Orchestrator本陣、構築完了"
echo ""

# pane-base-index を取得
PANE_BASE=$(tmux show-options -gv pane-base-index 2>/dev/null || echo 0)

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 5.1: multiagent セッション作成（9ペイン：残り9体）
# ═══════════════════════════════════════════════════════════════════════════════
log_war "⚔️ 9体のエージェント陣を構築中..."

if ! tmux new-session -d -s multiagent -n "agents" 2>/dev/null; then
    echo "  [ERROR] Failed to create tmux session 'multiagent'"
    exit 1
fi

# 3x3グリッド作成
tmux split-window -h -t "multiagent:agents"
tmux split-window -h -t "multiagent:agents"

tmux select-pane -t "multiagent:agents.${PANE_BASE}"
tmux split-window -v
tmux split-window -v

tmux select-pane -t "multiagent:agents.$((PANE_BASE+3))"
tmux split-window -v
tmux split-window -v

tmux select-pane -t "multiagent:agents.$((PANE_BASE+6))"
tmux split-window -v
tmux split-window -v

# 9体のエージェント（Orchestrator以外）
PANE_AGENTS=("Strategy" "ProductOwner" "TechLead" "Frontend" "Backend" "DBInfra" "UIUX" "QA" "Archivist")
PANE_COLORS=("yellow" "cyan" "red" "blue" "blue" "blue" "magenta" "green" "cyan")

for i in {0..8}; do
    p=$((PANE_BASE + i))
    tmux select-pane -t "multiagent:agents.${p}" -T "${PANE_AGENTS[$i]}"
    PROMPT_STR=$(generate_prompt "${PANE_AGENTS[$i]}" "${PANE_COLORS[$i]}" "$SHELL_SETTING")
    tmux send-keys -t "multiagent:agents.${p}" "cd \"$(pwd)\" && export PS1='${PROMPT_STR}' && clear" Enter
    
    # ログ記録開始 (各エージェント)
    setup_logging "multiagent:agents.${p}" "${PANE_AGENTS[$i]}"
done

log_success "  └─ 9体のエージェント陣、構築完了"
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 6: Claude Code 起動
# ═══════════════════════════════════════════════════════════════════════════════
if [ "$SETUP_ONLY" = false ]; then
    if ! command -v claude &> /dev/null; then
        log_info "⚠️  claude コマンドが見つかりません"
        echo "  first_setup.sh を再実行してください"
        exit 1
    fi

    log_war "👑 全軍に Claude Code を召喚中..."

    # モデル設定（ユーザー指定: CEO=Opus, 他=Sonnet）
    # ※ CLIの仕様に合わせてモデル名を指定
    MODEL_CEO="opus"      # ユーザー希望: ClaudeOPS4.5 -> Opus
    MODEL_OTHERS="sonnet" # ユーザー希望: Sonnet4.5 -> Sonnet

    # Orchestrator (CEO)
    tmux send-keys -t shogun:main "MAX_THINKING_TOKENS=0 claude --model ${MODEL_CEO} --dangerously-skip-permissions"
    tmux send-keys -t shogun:main Enter
    log_info "  └─ Orchestrator (Model: ${MODEL_CEO})、召喚完了"

    sleep 1

    # 残り9体 (Others)
    for i in {0..8}; do
        p=$((PANE_BASE + i))
        tmux send-keys -t "multiagent:agents.${p}" "claude --model ${MODEL_OTHERS} --dangerously-skip-permissions"
        tmux send-keys -t "multiagent:agents.${p}" Enter
    done
    log_info "  └─ 9体のエージェント (Model: ${MODEL_OTHERS})、召喚完了"

    log_success "✅ 全軍 Claude Code 起動完了"
    echo ""

    # 指示書読み込み
    log_war "📜 各エージェントに指示書を読み込ませ中..."

    echo "  Claude Code の起動を待機中（最大30秒）..."
    for i in {1..30}; do
        if tmux capture-pane -t shogun:main -p | grep -q "bypass permissions"; then
            echo "  └─ Orchestrator起動確認完了（${i}秒）"
            break
        fi
        sleep 1
    done

    # 指示書の対応表（pane 7 = Chief of Staff）
    INSTRUCTION_FILES=("strategy_consultant" "product_owner" "tech_lead" "frontend_specialist" "backend_specialist" "db_infra_engineer" "ui_ux_designer" "chief_of_staff" "archivist")

    # Orchestrator
    tmux send-keys -t shogun:main "instructions/orchestrator.md を読んで役割を理解せよ。"
    sleep 0.5
    tmux send-keys -t shogun:main Enter

    sleep 2

    # 9体
    for i in {0..8}; do
        p=$((PANE_BASE + i))
        tmux send-keys -t "multiagent:agents.${p}" "instructions/${INSTRUCTION_FILES[$i]}.md を読んで役割を理解せよ。"
        sleep 0.3
        tmux send-keys -t "multiagent:agents.${p}" Enter
        sleep 0.5
    done

    # ═══════════════════════════════════════════════════════════════════════════════
    # STEP 6.5: 番犬(Watchdog)起動
    # ═══════════════════════════════════════════════════════════════════════════════
    log_war "🐕 番犬(Watchdog)を放ち中..."
    chmod +x ./scripts/watchdog.sh
    nohup ./scripts/watchdog.sh > ./logs/watchdog.log 2>&1 &
    log_success "✅ 番犬配備完了 (Log: ./logs/watchdog.log)"
    echo ""

    # ═══════════════════════════════════════════════════════════════════════════════
    # STEP 6.6: Web UI 起動
    # ═══════════════════════════════════════════════════════════════════════════════
    if [ -d "./web-ui" ]; then
        log_war "🌐 司令室Webインターフェースを展開中..."
        if ! tmux list-windows -t shogun 2>/dev/null | grep -q "web-ui"; then
            tmux new-window -t shogun -n "web-ui"
            # 初回ビルドが必要な場合は npm run build などを検討
            # ここでは start を使用 (npm run dev でも可)
            tmux send-keys -t shogun:web-ui "cd ./web-ui && npm run dev" Enter
        fi
        log_success "✅ Web UI 起動: http://localhost:3000"
    fi
    echo ""
fi

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 7: 完了メッセージ
# ═══════════════════════════════════════════════════════════════════════════════
log_info "🔍 陣容を確認中..."
echo ""
echo "  ┌──────────────────────────────────────────────────────────┐"
echo "  │  📺 Tmux陣容 (Sessions)                                  │"
echo "  └──────────────────────────────────────────────────────────┘"
tmux list-sessions | sed 's/^/     /'
echo ""
echo "  ┌──────────────────────────────────────────────────────────┐"
echo "  │  📋 布陣図 (Formation)                                   │"
echo "  └──────────────────────────────────────────────────────────┘"
echo ""
echo "     【shogunセッション】Orchestrator本陣"
echo "     ┌─────────────────────────────┐"
echo "     │  👑 Orchestrator (CEO)     │  ← 総指揮官・ユーザー窓口"
echo "     └─────────────────────────────┘"
echo ""
echo "     【multiagentセッション】9体のエージェント（3x3 = 9ペイン）"
echo "     ┌───────────┬───────────┬───────────┐"
echo "     │ Strategy  │ TechLead  │ DB/Infra  │"
echo "     │  (参謀)   │ (技術統括) │ (インフラ)  │"
echo "     ├───────────┼───────────┼───────────┤"
echo "     │ ProdOwner │ Frontend  │ UI/UX     │"
echo "     │  (PO)     │ (フロント) │ (デザイン) │"
echo "     ├───────────┼───────────┼───────────┤"
echo "     │ Backend   │ QA        │ Archivist │"
echo "     │(バックエンド)│ (品質保証) │ (記録官)  │"
echo "     └───────────┴───────────┴───────────┘"
echo ""

echo ""
echo "  ╔══════════════════════════════════════════════════════════╗"
echo "  ║  🏢 出陣準備完了！Business Multi-Agent System稼働開始！   ║"
echo "  ╚══════════════════════════════════════════════════════════╝"
echo ""

if [ "$SETUP_ONLY" = true ]; then
    echo "  ⚠️  セットアップのみモード: Claude Codeは未起動です"
    echo ""
fi

echo "  次のステップ:"
echo "  ┌──────────────────────────────────────────────────────────┐"
echo "  │  Orchestratorの本陣にアタッチして命令を開始:              │"
echo "  │     tmux attach-session -t shogun                       │"
echo "  │                                                          │"
echo "  │  エージェント陣を確認する:                                │"
echo "  │     tmux attach-session -t multiagent                   │"
echo "  └──────────────────────────────────────────────────────────┘"
echo ""
echo "  ════════════════════════════════════════════════════════════"
echo "   天下布武！勝利を掴め！"
echo "  ════════════════════════════════════════════════════════════"
echo ""

# Windows Terminal タブ展開（オプション）
if [ "$OPEN_TERMINAL" = true ]; then
    log_info "📺 Windows Terminal でタブを展開中..."
    if command -v wt.exe &> /dev/null; then
        wt.exe -w 0 new-tab wsl.exe -e bash -c "tmux attach-session -t shogun" \; new-tab wsl.exe -e bash -c "tmux attach-session -t multiagent"
        log_success "  └─ ターミナルタブ展開完了"
    else
        log_info "  └─ wt.exe が見つかりません"
    fi
fi
