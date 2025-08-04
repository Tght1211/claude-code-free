@echo off
setlocal enabledelayedexpansion

REM Claude Code Router 安装配置脚本 Windows版本
REM 版本: 1.0.0

REM 启用ANSI颜色支持
call :EnableANSI

REM Claude Code 风格颜色定义 (ANSI转义序列)
set "RED=[38;5;203m"
set "GREEN=[38;5;120m"
set "YELLOW=[38;5;221m"
set "BLUE=[38;5;75m"
set "PURPLE=[38;5;147m"
set "CYAN=[38;5;87m"
set "ORANGE=[38;5;215m"
set "GRAY=[38;5;245m"
set "WHITE=[38;5;255m"
set "BOLD=[1m"
set "DIM=[2m"
set "UNDERLINE=[4m"
set "NC=[0m"

REM 全局变量
set "SKIP_CONFIG=false"
set "MODA_API_KEY="

REM 检查命令行参数
if "%1"=="--help" goto :ShowHelp
if "%1"=="-h" goto :ShowHelp
if "%1"=="update" goto :UpdateMode
if "%1"=="" goto :FullInstallMode

echo %RED%  ❌ 未知参数: %1%NC%
echo.
goto :ShowHelp

:ShowHelp
cls
echo %BOLD%%BLUE%
echo    ╭─────────────────────────────────────────────────────────╮
echo    │                                                         │
echo    │    🤖 Claude Code Router 安装配置脚本 v1.0.0            │
echo    │                                                         │
echo    ╰─────────────────────────────────────────────────────────╯
echo %NC%
echo.
echo %BOLD%%WHITE%📋 用法:%NC%
echo %CYAN%  claude-code-free.bat%NC%          %GRAY%# 完整安装和配置%NC%
echo %CYAN%  claude-code-free.bat update%NC%   %GRAY%# 仅更新软件包%NC%
echo %CYAN%  claude-code-free.bat --help%NC%   %GRAY%# 显示帮助信息%NC%
echo.
echo %BOLD%%WHITE%🚀 完整安装流程:%NC%
echo   %GREEN%1.%NC% %WHITE%检查 Node.js 版本%NC% %GRAY%(需要 20+)%NC%
echo   %GREEN%2.%NC% %WHITE%检查/安装 Claude Code%NC%
echo   %GREEN%3.%NC% %WHITE%检查/安装 Claude Code Router%NC%
echo   %GREEN%4.%NC% %WHITE%配置魔搭 API%NC% %GRAY%(可选)%NC%
echo   %GREEN%5.%NC% %WHITE%创建配置文件%NC% %GRAY%(可选)%NC%
echo   %GREEN%6.%NC% %WHITE%重启服务%NC%
echo   %GREEN%7.%NC% %WHITE%推荐 MCP 插件%NC% %GRAY%(可选)%NC%
echo.
echo %BOLD%%YELLOW%💡 提示:%NC%
echo   %GRAY%•%NC% update 模式只会更新软件包，不会修改配置
echo   %GRAY%•%NC% 安装过程中遇到问题可随时按 Ctrl+C 退出
echo.
goto :EOF

:EnableANSI
REM 启用Windows 10/11的ANSI颜色支持
reg add HKEY_CURRENT_USER\Console /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1
goto :EOF

:PrintSuccess
echo %BOLD%%GREEN%  ✅ %~1%NC%
goto :EOF

:PrintError
echo %BOLD%%RED%  ❌ %~1%NC%
goto :EOF

:PrintWarning
echo %BOLD%%YELLOW%  ⚠️  %~1%NC%
goto :EOF

:PrintInfo
echo %BOLD%%BLUE%  ℹ️  %~1%NC%
goto :EOF

:PrintStep
echo %BOLD%%PURPLE%  🔄 步骤 %~1: %WHITE%%~2%NC%
goto :EOF

:PrintHeader
echo.
echo %BOLD%%BLUE%  ╭─────────────────────────────────────────────────────────╮%NC%
set "title=%~1                                                       "
echo %BOLD%%BLUE%  │  !title:~0,55!│%NC%
echo %BOLD%%BLUE%  ╰─────────────────────────────────────────────────────────╯%NC%
echo.
goto :EOF

:PrintDivider
echo %GRAY%  ─────────────────────────────────────────────────────────%NC%
goto :EOF

:DisplayMCPPlugin
setlocal
set "mcp_name=%~1"
set "index=%~2"
set "var_name=mcps_%mcp_name%"

REM 处理变量名中的连字符
set "var_name=%var_name:-=_%"

REM 获取插件信息
call set "mcp_info=%%%var_name%%%"

REM 分割描述和包名
for /f "tokens=1,2 delims=|" %%a in ("%mcp_info%") do (
    set "description=%%a"
    set "package=%%b"
)

echo %index%. %GREEN%%mcp_name%%NC% - %description%
endlocal
goto :EOF

:InstallSingleMCP
set "mcp_name=%~1"
set "counter_var=%~2"
set "var_name=mcps_%mcp_name%"

REM 处理变量名中的连字符
set "var_name=%var_name:-=_%"

REM 获取插件信息
call set "mcp_info=%%%var_name%%%"

REM 分割描述和包名
for /f "tokens=1,2 delims=|" %%a in ("%mcp_info%") do (
    set "description=%%a"
    set "package=%%b"
)

call :PrintInfo "安装 %mcp_name%..."
claude mcp add "%mcp_name%" -- %package%
if not errorlevel 1 (
    call :PrintSuccess "%mcp_name% 安装成功"
    call set /a %counter_var%+=1
) else (
    call :PrintError "%mcp_name% 安装失败"
)
echo.
goto :EOF

:CommandExists
where "%~1" >nul 2>&1
goto :EOF

:CheckNodeVersion
call :PrintInfo "检查 Node.js 版本..."

call :CommandExists node
if errorlevel 1 (
    call :PrintError "未找到 Node.js！"
    call :PrintError "请安装 Node.js 20 或更高版本"
    call :PrintInfo "推荐从官网下载: https://nodejs.org/"
    exit /b 1
)

for /f "tokens=*" %%i in ('node -v 2^>nul') do set "NODE_VERSION=%%i"
set "NODE_VERSION=!NODE_VERSION:v=!"

for /f "tokens=1 delims=." %%i in ("!NODE_VERSION!") do set "MAJOR_VERSION=%%i"

if !MAJOR_VERSION! lss 20 (
    call :PrintError "Node.js 版本过低: v!NODE_VERSION!"
    call :PrintError "需要 Node.js 20 或更高版本"
    call :PrintInfo "当前版本: v!NODE_VERSION!"
    exit /b 1
)

call :PrintSuccess "Node.js 版本检查通过: v!NODE_VERSION!"
goto :EOF

:InstallClaudeCode
call :PrintHeader "🤖 Claude Code 检查与配置"

call :CommandExists claude
if not errorlevel 1 (
    for /f "tokens=*" %%i in ('claude -v 2^>nul ^| findstr /r "."') do set "CURRENT_VERSION=%%i" & goto :FoundVersion
    set "CURRENT_VERSION=未知版本"
    :FoundVersion
    
    echo %BOLD%%GREEN%  ✅ 检测到已安装的 Claude Code%NC%
    echo %GRAY%     当前版本: !CURRENT_VERSION!%NC%
    echo.
    
    echo %BOLD%%BLUE%  🔄 是否要更新到最新版本？%NC%
    echo %GRAY%       (输入 %BOLD%%GREEN%y%NC%%GRAY%/%BOLD%%GREEN%yes%NC%%GRAY% 更新，按 Enter 跳过)%NC%
    echo.
    echo %BOLD%%BLUE%  ┌ %NC%
    set /p "update_claude="
    echo %GRAY%  └ ──────────────────────────────────────────────%NC%
    
    if /i "!update_claude!"=="y" goto :UpdateClaude
    if /i "!update_claude!"=="yes" goto :UpdateClaude
    if /i "!update_claude!"=="是" goto :UpdateClaude
    
    echo.
    call :PrintInfo "保持当前版本，跳过更新"
    goto :VerifyClaude
    
    :UpdateClaude
    echo.
    call :PrintInfo "更新 Claude Code..."
    
    npm install -g @anthropic-ai/claude-code
    if errorlevel 1 (
        call :PrintError "Claude Code 更新失败"
        exit /b 1
    )
    
    for /f "tokens=*" %%i in ('claude -v 2^>nul ^| findstr /r "."') do set "NEW_VERSION=%%i" & goto :NewVersionFound
    set "NEW_VERSION=未知版本"
    :NewVersionFound
    
    call :PrintSuccess "Claude Code 更新成功"
    echo %BOLD%%YELLOW%  📈 版本变化: %GRAY%!CURRENT_VERSION!%NC% %BOLD%%YELLOW%→%NC% %BOLD%%GREEN%!NEW_VERSION!%NC%
) else (
    echo %BOLD%%YELLOW%  ℹ️  未检测到 Claude Code，准备安装...%NC%
    echo.
    call :PrintInfo "安装 Claude Code..."
    
    npm install -g @anthropic-ai/claude-code
    if errorlevel 1 (
        call :PrintError "Claude Code 安装失败"
        exit /b 1
    )
    
    for /f "tokens=*" %%i in ('claude -v 2^>nul ^| findstr /r "."') do set "INSTALLED_VERSION=%%i" & goto :InstalledVersionFound
    set "INSTALLED_VERSION=未知版本"
    :InstalledVersionFound
    
    call :PrintSuccess "Claude Code 安装成功"
    echo %BOLD%%GREEN%  🎉 已安装版本: !INSTALLED_VERSION!%NC%
)

:VerifyClaude
echo.
call :PrintInfo "验证 Claude Code 安装..."
claude -v >nul 2>&1
if errorlevel 1 (
    call :PrintError "Claude Code 验证失败"
    exit /b 1
)
call :PrintSuccess "Claude Code 验证成功"
goto :EOF

:InstallClaudeCodeRouter
call :PrintHeader "🔄 Claude Code Router 检查与配置"

call :CommandExists ccr
if not errorlevel 1 (
    for /f "tokens=*" %%i in ('ccr -v 2^>nul ^| findstr /r "."') do set "CURRENT_CCR_VERSION=%%i" & goto :FoundCCRVersion
    set "CURRENT_CCR_VERSION=未知版本"
    :FoundCCRVersion
    
    echo %BOLD%%GREEN%  ✅ 检测到已安装的 Claude Code Router%NC%
    echo %GRAY%     当前版本: !CURRENT_CCR_VERSION!%NC%
    echo.
    
    echo %BOLD%%BLUE%  🔄 是否要更新到最新版本？%NC%
    echo %GRAY%       (输入 %BOLD%%GREEN%y%NC%%GRAY%/%BOLD%%GREEN%yes%NC%%GRAY% 更新，按 Enter 跳过)%NC%
    echo.
    echo %BOLD%%BLUE%  ┌ %NC%
    set /p "update_ccr="
    echo %GRAY%  └ ──────────────────────────────────────────────%NC%
    
    if /i "!update_ccr!"=="y" goto :UpdateCCR
    if /i "!update_ccr!"=="yes" goto :UpdateCCR
    if /i "!update_ccr!"=="是" goto :UpdateCCR
    
    echo.
    call :PrintInfo "保持当前版本，跳过更新"
    goto :VerifyCCR
    
    :UpdateCCR
    echo.
    call :PrintInfo "更新 Claude Code Router..."
    
    npm install -g @musistudio/claude-code-router
    if errorlevel 1 (
        call :PrintError "Claude Code Router 更新失败"
        exit /b 1
    )
    
    for /f "tokens=*" %%i in ('ccr -v 2^>nul ^| findstr /r "."') do set "NEW_CCR_VERSION=%%i" & goto :NewCCRVersionFound
    set "NEW_CCR_VERSION=未知版本"
    :NewCCRVersionFound
    
    call :PrintSuccess "Claude Code Router 更新成功"
    echo %BOLD%%YELLOW%  📈 版本变化: %GRAY%!CURRENT_CCR_VERSION!%NC% %BOLD%%YELLOW%→%NC% %BOLD%%GREEN%!NEW_CCR_VERSION!%NC%
) else (
    echo %BOLD%%YELLOW%  ℹ️  未检测到 Claude Code Router，准备安装...%NC%
    echo.
    call :PrintInfo "安装 Claude Code Router..."
    
    npm install -g @musistudio/claude-code-router
    if errorlevel 1 (
        call :PrintError "Claude Code Router 安装失败"
        exit /b 1
    )
    
    for /f "tokens=*" %%i in ('ccr -v 2^>nul ^| findstr /r "."') do set "INSTALLED_CCR_VERSION=%%i" & goto :InstalledCCRVersionFound
    set "INSTALLED_CCR_VERSION=未知版本"
    :InstalledCCRVersionFound
    
    call :PrintSuccess "Claude Code Router 安装成功"
    echo %BOLD%%GREEN%  🎉 已安装版本: !INSTALLED_CCR_VERSION!%NC%
)

:VerifyCCR
echo.
call :PrintInfo "验证 Claude Code Router 安装..."
ccr -v >nul 2>&1
if errorlevel 1 (
    call :PrintError "Claude Code Router 验证失败"
    exit /b 1
)
call :PrintSuccess "Claude Code Router 验证成功"
goto :EOF

:GetModaKey
call :PrintHeader "🔑 配置魔搭 API (可选)"

echo %BOLD%%WHITE%  魔搭 API 能让您免费使用Qwen3-coder%NC%
echo.
echo %YELLOW%  📍 如果还没有 API Key，可以访问:%NC%
echo %UNDERLINE%%CYAN%     https://modelscope.cn/my/myaccesstoken%NC%
echo %GRAY%     注册并绑定阿里云账号后获取key%NC%
echo.
echo %GRAY%  • 输入 API Key 将自动配置魔搭服务%NC%
echo %GRAY%  • 直接按 Enter 跳过，后续手动配置%NC%
echo.
call :PrintDivider
echo.

echo %BOLD%%BLUE%  🔐 请输入您的魔搭 API Key (可选):%NC%
echo %GRAY%       (直接按 Enter 跳过)%NC%
echo.
echo %BOLD%%BLUE%  ┌ %NC%
set /p "MODA_API_KEY="
echo %GRAY%  └ ╰───────────────────────────────────────────────%NC%

if "!MODA_API_KEY!"=="" (
    echo.
    call :PrintInfo "跳过 API Key 配置，后续可手动配置"
    set "SKIP_CONFIG=true"
    goto :EOF
)

call :StrLen "!MODA_API_KEY!" len
if !len! lss 10 (
    echo.
    call :PrintWarning "API Key 长度过短，跳过配置"
    set "SKIP_CONFIG=true"
    goto :EOF
)

echo.
set "last4=!MODA_API_KEY:~-4!"
call :PrintSuccess "API Key 已安全获取 ••••••!last4!"
set "SKIP_CONFIG=false"
goto :EOF

:StrLen
setlocal enabledelayedexpansion
set "str=%~1"
set "len=0"
:loop
if defined str (
    set "str=!str:~1!"
    set /a len+=1
    goto loop
)
endlocal & set "%~2=%len%"
goto :EOF

:CreateConfigFile
if "!SKIP_CONFIG!"=="true" (
    call :PrintInfo "跳过配置文件创建，可后续手动配置"
    goto :EOF
)

call :PrintHeader "📁 创建配置文件"

set "CONFIG_DIR=%USERPROFILE%\.claude-code-router"
set "CONFIG_FILE=!CONFIG_DIR!\config.json"

if exist "!CONFIG_FILE!" (
    echo %BOLD%%YELLOW%  ⚠️  检测到现有配置文件:%NC%
    echo %GRAY%     !CONFIG_FILE!%NC%
    echo.
    echo %BOLD%%BLUE%  🤔 是否要覆盖现有配置？%NC%
    echo %GRAY%       (输入 %BOLD%%GREEN%y%NC%%GRAY%/%BOLD%%GREEN%yes%NC%%GRAY% 覆盖，按 Enter 取消)%NC%
    echo.
    echo %BOLD%%BLUE%  ┌ %NC%
    set /p "overwrite_config="
    echo %GRAY%  └ ╰───────────────────────────────────────────────%NC%
    
    if /i not "!overwrite_config!"=="y" if /i not "!overwrite_config!"=="yes" if /i not "!overwrite_config!"=="是" (
        echo.
        call :PrintInfo "取消覆盖，保留现有配置文件"
        goto :EOF
    )
    
    echo.
    call :PrintWarning "将覆盖现有配置文件"
) else (
    echo %BOLD%%BLUE%  🤔 是否创建魔搭配置文件？%NC%
    echo %GRAY%       (输入 %BOLD%%GREEN%y%NC%%GRAY%/%BOLD%%GREEN%yes%NC%%GRAY% 确认，按 Enter 跳过)%NC%
    echo.
    echo %BOLD%%BLUE%  ┌ %NC%
    set /p "create_config="
    echo %GRAY%  └ ╰───────────────────────────────────────────────%NC%
    
    if /i not "!create_config!"=="y" if /i not "!create_config!"=="yes" if /i not "!create_config!"=="是" (
        echo.
        call :PrintInfo "跳过配置文件创建"
        goto :EOF
    )
)

echo.
call :PrintInfo "创建配置文件..."

if not exist "!CONFIG_DIR!" mkdir "!CONFIG_DIR!"

(
echo {
echo     "LOG": false,
echo     "CLAUDE_PATH": "",
echo     "HOST": "127.0.0.1",
echo     "PORT": 3456,
echo     "APIKEY": "",
echo     "transformers": [
echo 
echo     ],
echo     "Providers": [
echo         {
echo             "name": "moda",
echo             "api_base_url": "https://api-inference.modelscope.cn/v1/chat/completions",
echo             "api_key": "!MODA_API_KEY!",
echo             "models": [
echo                 "Qwen/Qwen3-Coder-480B-A35B-Instruct",
echo                 "Qwen/Qwen3-235B-A22B-Thinking-2507",
echo                 "Qwen/Qwen3-Coder-30B-A3B-Instruct"
echo             ],
echo             "transformer": {
echo                 "use": [
echo                     [
echo                         "maxtoken",
echo                         {
echo                             "max_tokens": 65535
echo                         }
echo                     ],
echo                     "enhancetool"
echo                 ],
echo                 "Qwen/Qwen3-235B-A22B-Thinking-2507": {
echo                     "use": [
echo                         "reasoning"
echo                     ]
echo                 }
echo             }
echo         }
echo     ],
echo     "Router": {
echo         "default": "moda,Qwen/Qwen3-Coder-480B-A35B-Instruct",
echo         "background": "moda,Qwen/Qwen3-Coder-30B-A3B-Instruct",
echo         "think": "moda,Qwen/Qwen3-235B-A22B-Thinking-2507",
echo         "longContext": "moda,Qwen/Qwen3-Coder-480B-A35B-Instruct",
echo         "webSearch": "moda,Qwen/Qwen3-Coder-30B-A3B-Instruct"
echo     }
echo }
) > "!CONFIG_FILE!"

call :PrintSuccess "配置文件已创建: !CONFIG_FILE!"
echo %BOLD%%YELLOW%  💡 提示: 后续可使用 %CYAN%ccr ui%NC%%BOLD%%YELLOW% 命令进行可视化配置%NC%
goto :EOF

:RestartService
call :PrintInfo "重启 Claude Code Router..."

ccr restart
if errorlevel 1 (
    call :PrintWarning "重启可能失败，但这通常是正常的（如果是首次安装）"
) else (
    call :PrintSuccess "Claude Code Router 重启成功"
)
goto :EOF

:ShowTutorial
echo.
echo %GREEN%🎉 安装配置完成！%NC%
echo.
echo %BLUE%使用教程:%NC%
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo %YELLOW%基础命令:%NC%
echo   ccr code    - 启动 Claude Code
echo   ccr ui      - 访问 UI 界面配置第三方 API
echo   ccr restart - 重启服务（修改配置后需要执行）
echo   ccr stop    - 停止服务
echo   ccr status  - 查看服务状态
echo.
echo %YELLOW%配置文件位置:%NC%
echo   %USERPROFILE%\.claude-code-router\config.json
echo.
echo %YELLOW%重要提示:%NC%
echo   • 每次修改配置后记得执行 'ccr restart'
echo   • 如需修改 API Key，请编辑配置文件后重启
echo   • UI 界面地址: http://127.0.0.1:3456
echo.
echo %GREEN%开始使用吧！%NC%
goto :EOF

:InstallRecommendedMCPs
echo.
echo %BLUE%═══════════════════════════════════════%NC%
echo %YELLOW%🚀 推荐安装以下 MCP 插件来增强 Claude Code 功能%NC%
echo %BLUE%═══════════════════════════════════════%NC%
echo.

REM MCP 插件列表 (使用普通变量以提升兼容性)
set "mcps_context7=让你的 Claude Code 编码更加准确|npx -y @upstash/context7-mcp"
set "mcps_memory=助力记忆功能|npx -y @modelcontextprotocol/server-memory"
set "mcps_fetch=抓取网页信息|npx -y @kazuph/mcp-fetch"
set "mcps_Playwright=接管你的浏览器自动化|npx -y @playwright/mcp@latest"
set "mcps_sequential_thinking=助力思考分析|npx -y @modelcontextprotocol/server-sequential-thinking"

echo %YELLOW%可用的 MCP 插件:%NC%
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

REM 显示 MCP 插件列表
set count=1
for %%m in (context7 memory fetch Playwright sequential-thinking) do (
    call :DisplayMCPPlugin %%m !count!
    set /a count+=1
)
echo.

echo %BLUE%是否要安装这些推荐的 MCP 插件？ (y/N): %NC%
set /p "install_mcps="

if /i not "!install_mcps!"=="y" if /i not "!install_mcps!"=="yes" if /i not "!install_mcps!"=="是" (
    call :PrintInfo "跳过 MCP 插件安装"
    goto :EOF
)

echo.
call :PrintInfo "开始安装推荐的 MCP 插件..."
echo.

set "success_count=0"
set "total_count=5"

REM 安装每个 MCP 插件
for %%m in (context7 memory fetch Playwright sequential-thinking) do (
    call :InstallSingleMCP %%m success_count
)

echo %BLUE%═══════════════════════════════════════%NC%
if !success_count! equ !total_count! (
    call :PrintSuccess "所有 MCP 插件安装完成！(!success_count!/!total_count!)"
) else if !success_count! gtr 0 (
    call :PrintWarning "部分 MCP 插件安装完成 (!success_count!/!total_count!)"
) else (
    call :PrintError "所有 MCP 插件安装失败"
)

echo.
echo %YELLOW%MCP 使用提示:%NC%
echo   • 已安装的 MCP 插件会自动在 Claude Code 中生效
echo   • 可以使用 'claude mcp list' 查看已安装的插件
echo   • 可以使用 'claude mcp remove ^<name^>' 移除插件
echo   • 更多信息请访问: https://docs.anthropic.com/en/docs/claude-code/mcp
echo.
goto :EOF

:ShowWelcome
cls
echo %BOLD%%BLUE%
echo    ╭─────────────────────────────────────────────────────────╮
echo    │                                                         │
echo    │    🤖 欢迎使用 Claude Code Free 安装配置脚本                │
echo    │                                                         │
echo    │    🚀 一键免费使用Claude Code                             │
echo    │                                                         │
echo    ╰─────────────────────────────────────────────────────────╯
echo %NC%
echo.
echo %GRAY%  作者: Tght  │  版本: v1.0.0  │  2025%NC%
echo.
call :PrintDivider
echo.
goto :EOF

:UpdateMode
call :PrintHeader "🔄 进入更新模式"

echo %BOLD%%WHITE%  检查并更新已安装的软件包，不修改现有配置%NC%
call :PrintDivider
echo.

set "total_steps=3"

call :PrintStep "1/!total_steps!" "检查 Node.js 版本"
call :CheckNodeVersion
if errorlevel 1 exit /b 1
echo.

call :PrintStep "2/!total_steps!" "检查/更新 Claude Code"
call :CommandExists claude
if not errorlevel 1 (
    for /f "tokens=*" %%i in ('claude -v 2^>nul ^| findstr /r "."') do set "CURRENT_VERSION=%%i" & goto :CurrentVersionFound
    set "CURRENT_VERSION=未知版本"
    :CurrentVersionFound
    echo %BOLD%%GREEN%  ✅ 检测到 Claude Code: !CURRENT_VERSION!%NC%
    call :PrintInfo "自动更新 Claude Code..."
    
    npm install -g @anthropic-ai/claude-code
    if errorlevel 1 (
        call :PrintError "Claude Code 更新失败"
    ) else (
        for /f "tokens=*" %%i in ('claude -v 2^>nul ^| findstr /r "."') do set "NEW_VERSION=%%i" & goto :NewVersionFound2
        set "NEW_VERSION=未知版本"
        :NewVersionFound2
        call :PrintSuccess "Claude Code 更新成功"
        echo %BOLD%%YELLOW%  📈 版本变化: %GRAY%!CURRENT_VERSION!%NC% %BOLD%%YELLOW%→%NC% %BOLD%%GREEN%!NEW_VERSION!%NC%
    )
) else (
    call :PrintWarning "未检测到 Claude Code，跳过更新"
)
echo.

call :PrintStep "3/!total_steps!" "检查/更新 Claude Code Router"
call :CommandExists ccr
if not errorlevel 1 (
    for /f "tokens=*" %%i in ('ccr -v 2^>nul ^| findstr /r "."') do set "CURRENT_CCR_VERSION=%%i" & goto :CurrentCCRVersionFound
    set "CURRENT_CCR_VERSION=未知版本"
    :CurrentCCRVersionFound
    echo %BOLD%%GREEN%  ✅ 检测到 Claude Code Router: !CURRENT_CCR_VERSION!%NC%
    call :PrintInfo "自动更新 Claude Code Router..."
    
    npm install -g @musistudio/claude-code-router
    if errorlevel 1 (
        call :PrintError "Claude Code Router 更新失败"
    ) else (
        for /f "tokens=*" %%i in ('ccr -v 2^>nul ^| findstr /r "."') do set "NEW_CCR_VERSION=%%i" & goto :NewCCRVersionFound2
        set "NEW_CCR_VERSION=未知版本"
        :NewCCRVersionFound2
        call :PrintSuccess "Claude Code Router 更新成功"
        echo %BOLD%%YELLOW%  📈 版本变化: %GRAY%!CURRENT_CCR_VERSION!%NC% %BOLD%%YELLOW%→%NC% %BOLD%%GREEN%!NEW_CCR_VERSION!%NC%
    )
) else (
    call :PrintWarning "未检测到 Claude Code Router，跳过更新"
)
echo.

call :PrintSuccess "更新检查完成！"
echo %BOLD%%YELLOW%  💡 提示: 如需重启服务，请执行:%NC% %CYAN%ccr restart%NC%
goto :EOF

:FullInstallMode
call :PrintHeader "🚀 开始完整安装"

set "total_steps=7"

call :PrintStep "1/!total_steps!" "检查 Node.js 版本"
call :CheckNodeVersion
if errorlevel 1 exit /b 1
echo.

call :PrintStep "2/!total_steps!" "检查/安装 Claude Code"
call :InstallClaudeCode
if errorlevel 1 exit /b 1
echo.

call :PrintStep "3/!total_steps!" "检查/安装 Claude Code Router"
call :InstallClaudeCodeRouter
if errorlevel 1 exit /b 1
echo.

call :PrintStep "4/!total_steps!" "配置魔搭 API (可选)"
call :GetModaKey
echo.

call :PrintStep "5/!total_steps!" "创建配置文件 (可选)"
call :CreateConfigFile
echo.

call :PrintStep "6/!total_steps!" "重启服务"
call :RestartService
if errorlevel 1 exit /b 1
echo.

call :PrintStep "7/!total_steps!" "推荐 MCP 插件 (可选)"
call :InstallRecommendedMCPs
echo.

REM 显示使用教程
call :ShowTutorial

echo.
echo %BOLD%%GREEN%  🎉 所有步骤完成！%NC%
goto :EOF

REM 主程序入口
call :ShowWelcome

REM 检查命令行参数并执行相应功能
if "%1"=="update" (
    call :UpdateMode
) else if "%1"=="" (
    call :FullInstallMode
)

pause
endlocal