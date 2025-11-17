@echo off
chcp 65001 >nul 2>&1
setlocal enabledelayedexpansion

REM #################################################################################
REM Diagram Skills - Installation Script (Windows)
REM Version: 1.1.0
REM Date: 2025-11-17
REM
REM このスクリプトは以下を実行します：
REM 1. 既存Skillsのバックアップ作成
REM 2. diagram-skillsのインストール
REM 3. インストールの検証
REM 4. エラー時のロールバック
REM #################################################################################

REM 設定
set "CLAUDE_SKILLS_DIR=%USERPROFILE%\.claude\skills"
set "TIMESTAMP=%DATE:~0,4%%DATE:~5,2%%DATE:~8,2%_%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%"
set "TIMESTAMP=%TIMESTAMP: =0%"
set "BACKUP_DIR=%USERPROFILE%\.claude\skills_backup_%TIMESTAMP%"
set "SCRIPT_DIR=%~dp0"
set "LOG_FILE=install.log"
set "SILENT=0"
set "DEBUG=0"

REM 引数解析
:parse_args
if "%~1"=="" goto :start_install
if /I "%~1"=="/SILENT" set "SILENT=1"
if /I "%~1"=="/DEBUG" set "DEBUG=1"
if /I "%~1"=="/?" goto :show_usage
if /I "%~1"=="/HELP" goto :show_usage
shift
goto :parse_args

:show_usage
echo.
echo 使用方法: %~nx0 [OPTIONS]
echo.
echo オプション:
echo   /SILENT    サイレントモード（対話なし）
echo   /DEBUG     デバッグモード（詳細ログ）
echo   /?         このヘルプを表示
echo.
echo 例:
echo   %~nx0              通常インストール
echo   %~nx0 /SILENT      サイレントインストール
echo   %~nx0 /DEBUG       デバッグモード
echo.
exit /b 0

:start_install
REM ログファイル初期化
echo === Diagram Skills Installation Log === > "%LOG_FILE%"
echo Timestamp: %DATE% %TIME% >> "%LOG_FILE%"
echo OS: Windows >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

REM バナー表示
if "%SILENT%"=="0" (
    echo.
    echo ===============================================================
    echo.
    echo          Diagram Skills インストーラー
    echo.
    echo   Draw.io ^& Mermaid 図生成 Claude Skills
    echo   Version: 1.1.0
    echo.
    echo ===============================================================
    echo.
)

REM 前提条件チェック
call :log "INFO: 前提条件をチェック中..."
if "%SILENT%"=="0" echo [INFO] 前提条件をチェック中...

REM Claude Codeがインストールされているか
where claude >nul 2>&1
if errorlevel 1 (
    call :error "Claude Codeが見つかりません"
    call :error "https://claude.ai/code からインストールしてください"
    exit /b 1
)
call :success "Claude Code: インストール済み"

REM ディレクトリ存在チェック
if not exist "%SCRIPT_DIR%drawio-diagram-generator" (
    call :error "drawio-diagram-generator ディレクトリが見つかりません"
    exit /b 1
)

if not exist "%SCRIPT_DIR%mermaid-diagram-generator" (
    call :error "mermaid-diagram-generator ディレクトリが見つかりません"
    exit /b 1
)
call :success "Skillsディレクトリ: 確認済み"

REM Skillsディレクトリの作成
call :log "INFO: Skillsディレクトリを準備中..."
if "%SILENT%"=="0" echo [INFO] Skillsディレクトリを準備中...

if not exist "%CLAUDE_SKILLS_DIR%" (
    mkdir "%CLAUDE_SKILLS_DIR%" 2>>"%LOG_FILE%"
    if errorlevel 1 (
        call :error "Skillsディレクトリの作成に失敗"
        exit /b 1
    )
    call :success "Skillsディレクトリを作成: %CLAUDE_SKILLS_DIR%"
) else (
    call :debug "Skillsディレクトリは既に存在: %CLAUDE_SKILLS_DIR%"
)

REM バックアップ作成
call :log "INFO: 既存Skillsのバックアップを作成中..."
if "%SILENT%"=="0" echo [INFO] 既存Skillsのバックアップを作成中...

mkdir "%BACKUP_DIR%" 2>>"%LOG_FILE%"
set "BACKUP_COUNT=0"

if exist "%CLAUDE_SKILLS_DIR%\drawio-diagram-generator" (
    xcopy "%CLAUDE_SKILLS_DIR%\drawio-diagram-generator" "%BACKUP_DIR%\drawio-diagram-generator\" /E /I /Q /Y >>"%LOG_FILE%" 2>&1
    set /a BACKUP_COUNT+=1
    call :debug "バックアップ: drawio-diagram-generator"
)

if exist "%CLAUDE_SKILLS_DIR%\mermaid-diagram-generator" (
    xcopy "%CLAUDE_SKILLS_DIR%\mermaid-diagram-generator" "%BACKUP_DIR%\mermaid-diagram-generator\" /E /I /Q /Y >>"%LOG_FILE%" 2>&1
    set /a BACKUP_COUNT+=1
    call :debug "バックアップ: mermaid-diagram-generator"
)

if !BACKUP_COUNT! GTR 0 (
    call :success "バックアップ完了: !BACKUP_COUNT! 個のSkills"
    call :success "バックアップ先: %BACKUP_DIR%"
) else (
    if "%SILENT%"=="0" echo [INFO] バックアップ対象なし（新規インストール）
    call :log "INFO: バックアップ対象なし（新規インストール）"
)

REM Skillsのインストール
call :log "INFO: Skillsをインストール中..."
if "%SILENT%"=="0" echo [INFO] Skillsをインストール中...

REM Draw.io Skill
if "%SILENT%"=="0" echo   [+] drawio-diagram-generator をインストール中...
xcopy "%SCRIPT_DIR%drawio-diagram-generator" "%CLAUDE_SKILLS_DIR%\drawio-diagram-generator\" /E /I /Q /Y >>"%LOG_FILE%" 2>&1
if errorlevel 1 (
    call :error "drawio-diagram-generator のインストールに失敗"
    goto :rollback
)
call :success "  drawio-diagram-generator: インストール完了"

REM Mermaid Skill
if "%SILENT%"=="0" echo   [+] mermaid-diagram-generator をインストール中...
xcopy "%SCRIPT_DIR%mermaid-diagram-generator" "%CLAUDE_SKILLS_DIR%\mermaid-diagram-generator\" /E /I /Q /Y >>"%LOG_FILE%" 2>&1
if errorlevel 1 (
    call :error "mermaid-diagram-generator のインストールに失敗"
    goto :rollback
)
call :success "  mermaid-diagram-generator: インストール完了"

REM インストール検証
call :log "INFO: インストールを検証中..."
if "%SILENT%"=="0" echo [INFO] インストールを検証中...

set "ERRORS=0"

REM Draw.io Skillの検証
if not exist "%CLAUDE_SKILLS_DIR%\drawio-diagram-generator\SKILL.md" (
    call :error "drawio-diagram-generator\SKILL.md が見つかりません"
    set /a ERRORS+=1
) else (
    call :debug "検証OK: drawio-diagram-generator\SKILL.md"
)

if not exist "%CLAUDE_SKILLS_DIR%\drawio-diagram-generator\styles.json" (
    call :error "drawio-diagram-generator\styles.json が見つかりません"
    set /a ERRORS+=1
) else (
    call :debug "検証OK: drawio-diagram-generator\styles.json"
)

REM Mermaid Skillの検証
if not exist "%CLAUDE_SKILLS_DIR%\mermaid-diagram-generator\SKILL.md" (
    call :error "mermaid-diagram-generator\SKILL.md が見つかりません"
    set /a ERRORS+=1
) else (
    call :debug "検証OK: mermaid-diagram-generator\SKILL.md"
)

if not exist "%CLAUDE_SKILLS_DIR%\mermaid-diagram-generator\simplification-rules.md" (
    call :error "mermaid-diagram-generator\simplification-rules.md が見つかりません"
    set /a ERRORS+=1
) else (
    call :debug "検証OK: mermaid-diagram-generator\simplification-rules.md"
)

if !ERRORS! EQU 0 (
    call :success "検証完了: 全てのファイルが正常にインストールされました"
    goto :completion
) else (
    call :error "検証失敗: !ERRORS! 個のエラー"
    goto :rollback
)

:rollback
call :log "WARNING: エラーが発生しました。ロールバック中..."
if "%SILENT%"=="0" echo [WARNING] エラーが発生しました。ロールバック中...

REM インストールしたSkillsを削除
if exist "%CLAUDE_SKILLS_DIR%\drawio-diagram-generator" (
    rmdir /s /q "%CLAUDE_SKILLS_DIR%\drawio-diagram-generator" 2>>"%LOG_FILE%"
)
if exist "%CLAUDE_SKILLS_DIR%\mermaid-diagram-generator" (
    rmdir /s /q "%CLAUDE_SKILLS_DIR%\mermaid-diagram-generator" 2>>"%LOG_FILE%"
)

REM バックアップから復元
if exist "%BACKUP_DIR%\drawio-diagram-generator" (
    xcopy "%BACKUP_DIR%\drawio-diagram-generator" "%CLAUDE_SKILLS_DIR%\drawio-diagram-generator\" /E /I /Q /Y >>"%LOG_FILE%" 2>&1
)
if exist "%BACKUP_DIR%\mermaid-diagram-generator" (
    xcopy "%BACKUP_DIR%\mermaid-diagram-generator" "%CLAUDE_SKILLS_DIR%\mermaid-diagram-generator\" /E /I /Q /Y >>"%LOG_FILE%" 2>&1
)

call :success "ロールバック完了: バックアップから復元しました"
call :error "インストールに失敗しました"
call :error "詳細は %LOG_FILE% を確認してください"
exit /b 1

:completion
REM クリーンアップ（30日以上前の古いバックアップを削除）
call :debug "クリーンアップ中..."
forfiles /P "%USERPROFILE%\.claude" /M "skills_backup_*" /D -30 /C "cmd /c if @isdir==TRUE rmdir /s /q @path" 2>nul

REM 完了メッセージ
call :log "SUCCESS: Installation completed successfully"
if "%SILENT%"=="0" (
    echo.
    echo ===============================================================
    echo.
    echo          [OK] インストール完了！
    echo.
    echo ===============================================================
    echo.
    echo 次のコマンドで確認してください：
    echo.
    echo   ^> claude skills list
    echo.
    echo 期待される出力：
    echo   - drawio-diagram-generator
    echo   - mermaid-diagram-generator
    echo.
    echo 使い方：
    echo.
    echo   ^> claude
    echo   ^> Eコマースシステムのクラス図をDraw.ioで作成してください
    echo.
    echo 詳細は README.md を参照してください。
    echo.
)

exit /b 0

REM #################################################################################
REM サブルーチン
REM #################################################################################

:log
echo [%DATE% %TIME%] %~1 >> "%LOG_FILE%"
exit /b 0

:info
if "%SILENT%"=="0" echo [INFO] %~1
call :log "INFO: %~1"
exit /b 0

:success
if "%SILENT%"=="0" echo [OK] %~1
call :log "SUCCESS: %~1"
exit /b 0

:warning
if "%SILENT%"=="0" echo [WARNING] %~1
call :log "WARNING: %~1"
exit /b 0

:error
echo [ERROR] %~1 1>&2
call :log "ERROR: %~1"
exit /b 0

:debug
if "%DEBUG%"=="1" (
    echo [DEBUG] %~1
    call :log "DEBUG: %~1"
)
exit /b 0
