#!/bin/bash

#################################################################################
# Diagram Skills - Installation Script (Linux/macOS)
# Version: 1.1.0
# Date: 2025-11-17
#
# このスクリプトは以下を実行します：
# 1. 既存Skillsのバックアップ作成
# 2. diagram-skillsのインストール
# 3. インストールの検証
# 4. エラー時のロールバック
#################################################################################

set -e  # エラーで停止

# カラー出力（対応端末のみ）
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 絵文字（Linux/macOSでは使用可能）
CHECK_MARK="✅"
CROSS_MARK="❌"
WARNING="⚠️"
ROCKET="🚀"
FOLDER="📁"
GEAR="⚙️"

# ログファイル
LOG_FILE="install.log"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# 設定
CLAUDE_SKILLS_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
BACKUP_DIR="$HOME/.claude/skills_backup_$TIMESTAMP"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# サイレントモードとデバッグモード
SILENT=false
DEBUG=false

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
        echo -e "${BLUE}${GEAR} $1${NC}"
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

# デバッグメッセージ
debug() {
    if [ "$DEBUG" = true ]; then
        echo -e "${BLUE}[DEBUG] $1${NC}"
        log "DEBUG: $1"
    fi
}

# バナー表示
show_banner() {
    if [ "$SILENT" = false ]; then
        echo ""
        echo "╔═══════════════════════════════════════════════════════════╗"
        echo "║                                                           ║"
        echo "║          ${ROCKET} Diagram Skills インストーラー ${ROCKET}              ║"
        echo "║                                                           ║"
        echo "║  Draw.io & Mermaid 図生成 Claude Skills                  ║"
        echo "║  Version: 1.1.0                                           ║"
        echo "║                                                           ║"
        echo "╚═══════════════════════════════════════════════════════════╝"
        echo ""
    fi
}

# 前提条件チェック
check_prerequisites() {
    info "前提条件をチェック中..."
    
    # Claude Codeがインストールされているか
    if ! command -v claude &> /dev/null; then
        error "Claude Codeが見つかりません"
        error "https://claude.ai/code からインストールしてください"
        exit 1
    fi
    
    success "Claude Code: インストール済み"
    
    # ディレクトリ存在チェック
    if [ ! -d "$SCRIPT_DIR/drawio-diagram-generator" ]; then
        error "drawio-diagram-generator ディレクトリが見つかりません"
        exit 1
    fi
    
    if [ ! -d "$SCRIPT_DIR/mermaid-diagram-generator" ]; then
        error "mermaid-diagram-generator ディレクトリが見つかりません"
        exit 1
    fi
    
    success "Skillsディレクトリ: 確認済み"
}

# Skillsディレクトリの作成
create_skills_directory() {
    info "Skillsディレクトリを準備中..."
    
    if [ ! -d "$CLAUDE_SKILLS_DIR" ]; then
        mkdir -p "$CLAUDE_SKILLS_DIR"
        success "Skillsディレクトリを作成: $CLAUDE_SKILLS_DIR"
    else
        debug "Skillsディレクトリは既に存在: $CLAUDE_SKILLS_DIR"
    fi
}

# バックアップ作成
create_backup() {
    info "既存Skillsのバックアップを作成中..."
    
    # バックアップディレクトリ作成
    mkdir -p "$BACKUP_DIR"
    
    # 既存のdiagram-skillsをバックアップ
    local backup_count=0
    
    if [ -d "$CLAUDE_SKILLS_DIR/drawio-diagram-generator" ]; then
        cp -r "$CLAUDE_SKILLS_DIR/drawio-diagram-generator" "$BACKUP_DIR/"
        backup_count=$((backup_count + 1))
        debug "バックアップ: drawio-diagram-generator"
    fi
    
    if [ -d "$CLAUDE_SKILLS_DIR/mermaid-diagram-generator" ]; then
        cp -r "$CLAUDE_SKILLS_DIR/mermaid-diagram-generator" "$BACKUP_DIR/"
        backup_count=$((backup_count + 1))
        debug "バックアップ: mermaid-diagram-generator"
    fi
    
    if [ $backup_count -gt 0 ]; then
        success "バックアップ完了: $backup_count 個のSkills"
        success "バックアップ先: $BACKUP_DIR"
    else
        info "バックアップ対象なし（新規インストール）"
    fi
}

# Skillsのインストール
install_skills() {
    info "Skillsをインストール中..."
    
    # Draw.io Skill
    info "  ${FOLDER} drawio-diagram-generator をインストール中..."
    cp -r "$SCRIPT_DIR/drawio-diagram-generator" "$CLAUDE_SKILLS_DIR/"
    chmod -R 755 "$CLAUDE_SKILLS_DIR/drawio-diagram-generator"
    success "  drawio-diagram-generator: インストール完了"
    
    # Mermaid Skill
    info "  ${FOLDER} mermaid-diagram-generator をインストール中..."
    cp -r "$SCRIPT_DIR/mermaid-diagram-generator" "$CLAUDE_SKILLS_DIR/"
    chmod -R 755 "$CLAUDE_SKILLS_DIR/mermaid-diagram-generator"
    success "  mermaid-diagram-generator: インストール完了"
}

# インストール検証
verify_installation() {
    info "インストールを検証中..."
    
    local errors=0
    
    # Draw.io Skillの検証
    if [ ! -f "$CLAUDE_SKILLS_DIR/drawio-diagram-generator/SKILL.md" ]; then
        error "drawio-diagram-generator/SKILL.md が見つかりません"
        errors=$((errors + 1))
    else
        debug "検証OK: drawio-diagram-generator/SKILL.md"
    fi
    
    if [ ! -f "$CLAUDE_SKILLS_DIR/drawio-diagram-generator/styles.json" ]; then
        error "drawio-diagram-generator/styles.json が見つかりません"
        errors=$((errors + 1))
    else
        debug "検証OK: drawio-diagram-generator/styles.json"
    fi
    
    # Mermaid Skillの検証
    if [ ! -f "$CLAUDE_SKILLS_DIR/mermaid-diagram-generator/SKILL.md" ]; then
        error "mermaid-diagram-generator/SKILL.md が見つかりません"
        errors=$((errors + 1))
    else
        debug "検証OK: mermaid-diagram-generator/SKILL.md"
    fi
    
    if [ ! -f "$CLAUDE_SKILLS_DIR/mermaid-diagram-generator/simplification-rules.md" ]; then
        error "mermaid-diagram-generator/simplification-rules.md が見つかりません"
        errors=$((errors + 1))
    else
        debug "検証OK: mermaid-diagram-generator/simplification-rules.md"
    fi
    
    if [ $errors -eq 0 ]; then
        success "検証完了: 全てのファイルが正常にインストールされました"
        return 0
    else
        error "検証失敗: $errors 個のエラー"
        return 1
    fi
}

# ロールバック
rollback() {
    warning "エラーが発生しました。ロールバック中..."
    
    if [ -d "$BACKUP_DIR" ]; then
        # インストールしたSkillsを削除
        rm -rf "$CLAUDE_SKILLS_DIR/drawio-diagram-generator"
        rm -rf "$CLAUDE_SKILLS_DIR/mermaid-diagram-generator"
        
        # バックアップから復元
        if [ "$(ls -A $BACKUP_DIR)" ]; then
            cp -r "$BACKUP_DIR"/* "$CLAUDE_SKILLS_DIR/"
            success "ロールバック完了: バックアップから復元しました"
        fi
    fi
}

# クリーンアップ
cleanup() {
    debug "クリーンアップ中..."
    
    # 古いバックアップを削除（30日以上前）
    if [ -d "$HOME/.claude" ]; then
        find "$HOME/.claude" -name "skills_backup_*" -type d -mtime +30 -exec rm -rf {} + 2>/dev/null || true
        debug "古いバックアップを削除しました"
    fi
}

# 完了メッセージ
show_completion() {
    if [ "$SILENT" = false ]; then
        echo ""
        echo "╔═══════════════════════════════════════════════════════════╗"
        echo "║                                                           ║"
        echo "║          ${CHECK_MARK} インストール完了！ ${CHECK_MARK}                        ║"
        echo "║                                                           ║"
        echo "╚═══════════════════════════════════════════════════════════╝"
        echo ""
        echo "次のコマンドで確認してください："
        echo ""
        echo "  $ claude skills list"
        echo ""
        echo "期待される出力："
        echo "  - drawio-diagram-generator"
        echo "  - mermaid-diagram-generator"
        echo ""
        echo "使い方："
        echo ""
        echo "  $ claude"
        echo "  > Eコマースシステムのクラス図をDraw.ioで作成してください"
        echo ""
        echo "詳細は README.md を参照してください。"
        echo ""
    fi
}

# 使用方法
show_usage() {
    echo "使用方法: $0 [OPTIONS]"
    echo ""
    echo "オプション:"
    echo "  --silent    サイレントモード（対話なし）"
    echo "  --debug     デバッグモード（詳細ログ）"
    echo "  --help      このヘルプを表示"
    echo ""
    echo "例:"
    echo "  $0                # 通常インストール"
    echo "  $0 --silent       # サイレントインストール"
    echo "  $0 --debug        # デバッグモード"
    echo ""
}

#################################################################################
# メイン処理
#################################################################################

main() {
    # 引数解析
    while [[ $# -gt 0 ]]; do
        case $1 in
            --silent)
                SILENT=true
                shift
                ;;
            --debug)
                DEBUG=true
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
    echo "=== Diagram Skills Installation Log ===" > "$LOG_FILE"
    echo "Timestamp: $(date)" >> "$LOG_FILE"
    echo "OS: $(uname -s)" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
    
    # バナー表示
    show_banner
    
    # エラーハンドリング
    trap 'rollback; exit 1' ERR
    
    # インストール処理
    check_prerequisites
    create_skills_directory
    create_backup
    install_skills
    
    # 検証
    if verify_installation; then
        cleanup
        show_completion
        
        log "Installation completed successfully"
        exit 0
    else
        rollback
        error "インストールに失敗しました"
        error "詳細は $LOG_FILE を確認してください"
        exit 1
    fi
}

# スクリプト実行
main "$@"
