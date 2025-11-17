#!/bin/bash

#################################################################################
# Diagram Skills - Uninstallation Script (Linux/macOS)
# Version: 1.1.0
# Date: 2025-11-17
#
# このスクリプトは以下を実行します：
# 1. diagram-skillsのみを安全に削除
# 2. 他のSkillsには影響を与えない
# 3. 削除前に確認プロンプト表示
#################################################################################

set -e  # エラーで停止

# カラー出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 絵文字
CHECK_MARK="✅"
CROSS_MARK="❌"
WARNING="⚠️"
TRASH="🗑️"

# ログファイル
LOG_FILE="uninstall.log"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# 設定
CLAUDE_SKILLS_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
FORCE=false
SILENT=false

#################################################################################
# 関数定義
#################################################################################

# ログ出力
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# 情報メッセージ
info() {
    if [ "$SILENT" = false ]; then
        echo -e "${BLUE}ℹ️  $1${NC}"
    fi
    log "INFO: $1"
}

# 成功メッセージ
success() {
    if [ "$SILENT" = false ]; then
        echo -e "${GREEN}${CHECK_MARK} $1${NC}"
    fi
    log "SUCCESS: $1"
}

# 警告メッセージ
warning() {
    if [ "$SILENT" = false ]; then
        echo -e "${YELLOW}${WARNING} $1${NC}"
    fi
    log "WARNING: $1"
}

# エラーメッセージ
error() {
    echo -e "${RED}${CROSS_MARK} エラー: $1${NC}" >&2
    log "ERROR: $1"
}

# バナー表示
show_banner() {
    if [ "$SILENT" = false ]; then
        echo ""
        echo "╔═══════════════════════════════════════════════════════════╗"
        echo "║                                                           ║"
        echo "║      ${TRASH} Diagram Skills アンインストーラー ${TRASH}              ║"
        echo "║                                                           ║"
        echo "║  Draw.io & Mermaid 図生成 Claude Skills                  ║"
        echo "║  Version: 1.1.0                                           ║"
        echo "║                                                           ║"
        echo "╚═══════════════════════════════════════════════════════════╝"
        echo ""
    fi
}

# 確認プロンプト
confirm() {
    if [ "$FORCE" = true ]; then
        return 0
    fi
    
    echo ""
    echo -e "${YELLOW}${WARNING} 以下のSkillsを削除します:${NC}"
    echo ""
    
    if [ -d "$CLAUDE_SKILLS_DIR/drawio-diagram-generator" ]; then
        echo "  - drawio-diagram-generator"
    fi
    
    if [ -d "$CLAUDE_SKILLS_DIR/mermaid-diagram-generator" ]; then
        echo "  - mermaid-diagram-generator"
    fi
    
    echo ""
    read -p "本当に削除しますか？ (y/N): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        info "アンインストールをキャンセルしました"
        exit 0
    fi
}

# Skillsの存在確認
check_skills() {
    info "インストール状況を確認中..."
    
    local found=false
    
    if [ -d "$CLAUDE_SKILLS_DIR/drawio-diagram-generator" ]; then
        success "drawio-diagram-generator: インストール済み"
        found=true
    else
        info "drawio-diagram-generator: 未インストール"
    fi
    
    if [ -d "$CLAUDE_SKILLS_DIR/mermaid-diagram-generator" ]; then
        success "mermaid-diagram-generator: インストール済み"
        found=true
    fi
    
    if [ "$found" = false ]; then
        warning "diagram-skillsはインストールされていません"
        exit 0
    fi
}

# Skillsの削除
uninstall_skills() {
    info "Skillsを削除中..."
    
    local removed=0
    
    # Draw.io Skill
    if [ -d "$CLAUDE_SKILLS_DIR/drawio-diagram-generator" ]; then
        rm -rf "$CLAUDE_SKILLS_DIR/drawio-diagram-generator"
        success "drawio-diagram-generator: 削除完了"
        removed=$((removed + 1))
    fi
    
    # Mermaid Skill
    if [ -d "$CLAUDE_SKILLS_DIR/mermaid-diagram-generator" ]; then
        rm -rf "$CLAUDE_SKILLS_DIR/mermaid-diagram-generator"
        success "mermaid-diagram-generator: 削除完了"
        removed=$((removed + 1))
    fi
    
    if [ $removed -eq 0 ]; then
        warning "削除するSkillsが見つかりませんでした"
    else
        success "合計 $removed 個のSkillsを削除しました"
    fi
}

# 検証
verify_uninstallation() {
    info "削除を検証中..."
    
    local errors=0
    
    if [ -d "$CLAUDE_SKILLS_DIR/drawio-diagram-generator" ]; then
        error "drawio-diagram-generator がまだ存在します"
        errors=$((errors + 1))
    fi
    
    if [ -d "$CLAUDE_SKILLS_DIR/mermaid-diagram-generator" ]; then
        error "mermaid-diagram-generator がまだ存在します"
        errors=$((errors + 1))
    fi
    
    if [ $errors -eq 0 ]; then
        success "検証完了: 全てのSkillsが正常に削除されました"
        return 0
    else
        error "検証失敗: $errors 個のエラー"
        return 1
    fi
}

# 他のSkillsの確認
check_other_skills() {
    info "他のSkillsの状態を確認中..."
    
    if [ ! -d "$CLAUDE_SKILLS_DIR" ]; then
        info "Skillsディレクトリが存在しません"
        return
    fi
    
    local other_skills=0
    
    for dir in "$CLAUDE_SKILLS_DIR"/*; do
        if [ -d "$dir" ]; then
            local basename=$(basename "$dir")
            if [ "$basename" != "drawio-diagram-generator" ] && [ "$basename" != "mermaid-diagram-generator" ]; then
                other_skills=$((other_skills + 1))
            fi
        fi
    done
    
    if [ $other_skills -gt 0 ]; then
        success "他の $other_skills 個のSkillsは影響を受けませんでした"
    else
        info "他のSkillsはインストールされていません"
    fi
}

# 完了メッセージ
show_completion() {
    if [ "$SILENT" = false ]; then
        echo ""
        echo "╔═══════════════════════════════════════════════════════════╗"
        echo "║                                                           ║"
        echo "║          ${CHECK_MARK} アンインストール完了！ ${CHECK_MARK}                   ║"
        echo "║                                                           ║"
        echo "╚═══════════════════════════════════════════════════════════╝"
        echo ""
        echo "diagram-skillsは正常に削除されました。"
        echo ""
        echo "次のコマンドで確認してください："
        echo ""
        echo "  $ claude skills list"
        echo ""
        echo "再インストールする場合："
        echo ""
        echo "  $ ./install.sh"
        echo ""
    fi
}

# 使用方法
show_usage() {
    echo "使用方法: $0 [OPTIONS]"
    echo ""
    echo "オプション:"
    echo "  --force     確認なしで削除"
    echo "  --silent    サイレントモード（対話なし）"
    echo "  --help      このヘルプを表示"
    echo ""
    echo "例:"
    echo "  $0                # 通常アンインストール（確認あり）"
    echo "  $0 --force        # 確認なしアンインストール"
    echo "  $0 --silent       # サイレントアンインストール"
    echo ""
}

#################################################################################
# メイン処理
#################################################################################

main() {
    # 引数解析
    while [[ $# -gt 0 ]]; do
        case $1 in
            --force)
                FORCE=true
                shift
                ;;
            --silent)
                SILENT=true
                FORCE=true  # サイレントモードは強制削除
                shift
                ;;
            --help)
                show_usage
                exit 0
                ;;
            *)
                error "不明なオプション: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # ログファイル初期化
    echo "=== Diagram Skills Uninstallation Log ===" > "$LOG_FILE"
    echo "Timestamp: $(date)" >> "$LOG_FILE"
    echo "OS: $(uname -s)" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
    
    # バナー表示
    show_banner
    
    # アンインストール処理
    check_skills
    confirm
    uninstall_skills
    
    # 検証
    if verify_uninstallation; then
        check_other_skills
        show_completion
        
        log "Uninstallation completed successfully"
        exit 0
    else
        error "アンインストールに失敗しました"
        error "詳細は $LOG_FILE を確認してください"
        exit 1
    fi
}

# スクリプト実行
main "$@"
