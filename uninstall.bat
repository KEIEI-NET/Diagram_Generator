@echo off
chcp 65001 >nul 2>&1
setlocal enabledelayedexpansion

REM #################################################################################
REM Diagram Skills - Uninstallation Script (Windows)
REM Version: 1.1.0
REM Date: 2025-11-17
REM
REM このスクリプトは以下を実行します：
REM 1. diagram-skillsのみを安全に削除
REM 2. 他のSkillsには影響を与えない
REM 3. 削除前に確認プロンプト表示
REM #################################################################################

REM 設定
set "CLAUDE_SKILLS_DIR=%USERPROFILE%\.claude\skills"
set "LOG_FILE=uninstall.log"
set "FORCE=0"
set "SILENT=0"

REM 引数解析
:parse_args
if "%~1"=="" goto :start_uninstall
if /I "%~1"=="/FORCE" set "FORCE=1"
if /I "%~1"=="/SILENT" (
    set "SILENT=1"
    set "FORCE=1"
)
if /I "%~1"=="/?" goto :show_usage
if /I "%~1"=="/HELP" goto :show_usage
shift
goto :parse_args

:show_usage
echo.
echo 使用方法: %~nx0 [OPTIONS]
echo.
echo オプション:
echo   /FORCE     確認なしで削除
echo   /SILENT    サイレントモード（対話なし）
echo   /?         このヘルプを表示
echo.
echo 例:
echo   %~nx0              通常アンインストール（確認あり）
echo   %~nx0 /FORCE       確認なしアンインストール
echo   %~nx0 /SILENT      サイレントアンインストール
echo.
exit /b 0

:start_uninstall
REM ログファイル初期化
echo === Diagram Skills Uninstallation Log === > "%LOG_FILE%"
echo Timestamp: %DATE% %TIME% >> "%LOG_FILE%"
echo OS: Windows >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

REM バナー表示
if "%SILENT%"=="0" (
    echo.
    echo ===============================================================
    echo.
    echo          Diagram Skills アンインストーラー
    echo.
    echo   Draw.io ^& Mermaid 図生成 Claude Skills
    echo   Version: 1.1.0
    echo.
    echo ===============================================================
    echo.
)

REM インストール状況の確認
call :log "INFO: インストール状況を確認中..."
if "%SILENT%"=="0" echo [INFO] インストール状況を確認中...

set "FOUND=0"

if exist "%CLAUDE_SKILLS_DIR%\drawio-diagram-generator" (
    call :success "drawio-diagram-generator: インストール済み"
    set "FOUND=1"
) else (
    if "%SILENT%"=="0" echo [INFO] drawio-diagram-generator: 未インストール
    call :log "INFO: drawio-diagram-generator: 未インストール"
)

if exist "%CLAUDE_SKILLS_DIR%\mermaid-diagram-generator" (
    call :success "mermaid-diagram-generator: インストール済み"
    set "FOUND=1"
) else (
    if "%SILENT%"=="0" echo [INFO] mermaid-diagram-generator: 未インストール
    call :log "INFO: mermaid-diagram-generator: 未インストール"
)

if "%FOUND%"=="0" (
    call :warning "diagram-skillsはインストールされていません"
    exit /b 0
)

REM 確認プロンプト
if "%FORCE%"=="0" (
    echo.
    echo [WARNING] 以下のSkillsを削除します：
    echo.
    
    if exist "%CLAUDE_SKILLS_DIR%\drawio-diagram-generator" (
        echo   - drawio-diagram-generator
    )
    
    if exist "%CLAUDE_SKILLS_DIR%\mermaid-diagram-generator" (
        echo   - mermaid-diagram-generator
    )
    
    echo.
    set /p CONFIRM="本当に削除しますか？ (Y/N): "
    
    if /I not "!CONFIRM!"=="Y" (
        if "%SILENT%"=="0" echo [INFO] アンインストールをキャンセルしました
        call :log "INFO: アンインストールをキャンセルしました"
        exit /b 0
    )
)

REM Skillsの削除
call :log "INFO: Skillsを削除中..."
if "%SILENT%"=="0" echo [INFO] Skillsを削除中...

set "REMOVED=0"

REM Draw.io Skill
if exist "%CLAUDE_SKILLS_DIR%\drawio-diagram-generator" (
    rmdir /s /q "%CLAUDE_SKILLS_DIR%\drawio-diagram-generator" 2>>"%LOG_FILE%"
    if errorlevel 1 (
        call :error "drawio-diagram-generator の削除に失敗"
        exit /b 1
    )
    call :success "drawio-diagram-generator: 削除完了"
    set /a REMOVED+=1
)

REM Mermaid Skill
if exist "%CLAUDE_SKILLS_DIR%\mermaid-diagram-generator" (
    rmdir /s /q "%CLAUDE_SKILLS_DIR%\mermaid-diagram-generator" 2>>"%LOG_FILE%"
    if errorlevel 1 (
        call :error "mermaid-diagram-generator の削除に失敗"
        exit /b 1
    )
    call :success "mermaid-diagram-generator: 削除完了"
    set /a REMOVED+=1
)

if !REMOVED! EQU 0 (
    call :warning "削除するSkillsが見つかりませんでした"
) else (
    call :success "合計 !REMOVED! 個のSkillsを削除しました"
)

REM 削除の検証
call :log "INFO: 削除を検証中..."
if "%SILENT%"=="0" echo [INFO] 削除を検証中...

set "ERRORS=0"

if exist "%CLAUDE_SKILLS_DIR%\drawio-diagram-generator" (
    call :error "drawio-diagram-generator がまだ存在します"
    set /a ERRORS+=1
)

if exist "%CLAUDE_SKILLS_DIR%\mermaid-diagram-generator" (
    call :error "mermaid-diagram-generator がまだ存在します"
    set /a ERRORS+=1
)

if !ERRORS! EQU 0 (
    call :success "検証完了: 全てのSkillsが正常に削除されました"
) else (
    call :error "検証失敗: !ERRORS! 個のエラー"
    exit /b 1
)

REM 他のSkillsの確認
call :log "INFO: 他のSkillsの状態を確認中..."
if "%SILENT%"=="0" echo [INFO] 他のSkillsの状態を確認中...

if exist "%CLAUDE_SKILLS_DIR%" (
    set "OTHER_SKILLS=0"
    
    for /d %%D in ("%CLAUDE_SKILLS_DIR%\*") do (
        set "DIRNAME=%%~nxD"
        if not "!DIRNAME!"=="drawio-diagram-generator" (
            if not "!DIRNAME!"=="mermaid-diagram-generator" (
                set /a OTHER_SKILLS+=1
            )
        )
    )
    
    if !OTHER_SKILLS! GTR 0 (
        call :success "他の !OTHER_SKILLS! 個のSkillsは影響を受けませんでした"
    ) else (
        if "%SILENT%"=="0" echo [INFO] 他のSkillsはインストールされていません
        call :log "INFO: 他のSkillsはインストールされていません"
    )
) else (
    if "%SILENT%"=="0" echo [INFO] Skillsディレクトリが存在しません
    call :log "INFO: Skillsディレクトリが存在しません"
)

REM 完了メッセージ
call :log "SUCCESS: Uninstallation completed successfully"
if "%SILENT%"=="0" (
    echo.
    echo ===============================================================
    echo.
    echo          [OK] アンインストール完了！
    echo.
    echo ===============================================================
    echo.
    echo diagram-skillsは正常に削除されました。
    echo.
    echo 次のコマンドで確認してください：
    echo.
    echo   ^> claude skills list
    echo.
    echo 再インストールする場合：
    echo.
    echo   ^> install.bat
    echo.
)

exit /b 0

REM #################################################################################
REM サブルーチン
REM #################################################################################

:log
echo [%DATE% %TIME%] %~1 >> "%LOG_FILE%"
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
