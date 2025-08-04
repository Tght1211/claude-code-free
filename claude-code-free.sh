#!/bin/bash

# Claude Code Router 安装配置脚本
# 版本: 1.0.0

# Apple Design 风格颜色定义
GREEN='\033[38;5;47m'       # Apple 绿色
BLUE='\033[38;5;69m'        # Apple 蓝色
YELLOW='\033[38;5;221m'     # Apple 黄色
RED='\033[38;5;197m'        # Apple 红色
GRAY='\033[38;5;245m'       # Apple 灰色
LIGHT_GRAY='\033[38;5;250m' # 浅灰色
DARK_GRAY='\033[38;5;240m'  # 深灰色
BOLD='\033[1m'              # 粗体
DIM='\033[2m'               # 暗淡
ITALIC='\033[3m'            # 斜体
NC='\033[0m'                # 重置颜色

# 显示帮助信息
show_help() {
    clear
    echo ""
    echo "📋 用法:"
    echo "  ./claude-code-free.sh          # 完整安装和配置"
    echo "  ./claude-code-free.sh update   # 仅更新软件包"
    echo "  ./claude-code-free.sh --help   # 显示帮助信息"
    echo ""
    echo "🚀 完整安装流程:"
    echo "  1. 检查 Node.js 版本 (需要 20+)"
    echo "  2. 检查/安装 Claude Code"
    echo "  3. 检查/安装 Claude Code Router"
    echo "  4. 配置魔搭 API (可选)"
    echo "  5. 创建配置文件 (可选)"
    echo "  6. 重启服务"
    echo "  7. 推荐 MCP 插件 (可选)"
    echo ""
    echo "💡 提示:"
    echo "  • update 模式只会更新软件包，不会修改配置"
    echo "  • 安装过程中遇到问题可随时按 Ctrl+C 退出"
    echo ""
}

# 美化的消息打印函数
print_success() {
    echo -e "${BOLD}${GREEN}  ✅ $1${NC}"
}

print_error() {
    echo -e "${BOLD}${RED}  ❌ $1${NC}"
}

print_warning() {
    echo -e "${BOLD}${YELLOW}  ⚠️  $1${NC}"
}

print_info() {
    echo -e "${BOLD}${BLUE}  ℹ️  $1${NC}"
}

print_step() {
    echo -e "${BOLD}${BLUE}步骤 $1/$2: ${NC}${LIGHT_GRAY}$3${NC}"
}

print_header() {
    echo ""
    echo -e "${BOLD}${BLUE}$1${NC}"
    echo -e "${DIM}${GRAY}――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――${NC}"
    echo ""
}

print_divider() {
    echo -e "${GRAY}  ────────────────────────────────────────────────────────────────────────────────${NC}"
}

print_section_divider() {
    echo -e "${DIM}${GRAY}  ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄${NC}"
}

print_progress() {
    local current=$1
    local total=$2
    
    # 简单的进度指示器
    printf "  🔄 步骤进度: "
    for ((i=1; i<=total; i++)); do
        if [ $i -eq $current ]; then
            printf "● "  # 当前步骤
        elif [ $i -lt $current ]; then
            printf "● "  # 已完成步骤
        else
            printf "○ "  # 未完成步骤
        fi
    done
    printf "(%d/%d)\n" $current $total
}

print_spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    local temp
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 检查 Node.js 版本
check_node_version() {
    print_info "检查 Node.js 版本..."
    
    if ! command_exists node; then
        print_error "未找到 Node.js！"
        print_error "请安装 Node.js 20 或更高版本"
        print_info "推荐使用 nvm 安装: https://github.com/nvm-sh/nvm"
        exit 1
    fi
    
    NODE_VERSION=$(node -v | sed 's/v//')
    MAJOR_VERSION=$(echo $NODE_VERSION | cut -d. -f1)
    
    if [ "$MAJOR_VERSION" -lt 20 ]; then
        print_error "Node.js 版本过低: v$NODE_VERSION"
        print_error "需要 Node.js 20 或更高版本"
        print_info "当前版本: v$NODE_VERSION"
        exit 1
    fi
    
    print_success "Node.js 版本检查通过: v$NODE_VERSION"
}

# 检查并安装/更新 Claude Code
install_claude_code() {
    print_header "🤖 Claude Code 检查与配置"
    
    # 先检查是否已安装
    if command_exists claude; then
        # 获取当前版本
        CURRENT_VERSION=$(claude -v 2>/dev/null | head -1 || echo "未知版本")
        echo -e "${BOLD}${GREEN}  ✅ 检测到已安装的 Claude Code${NC}"
        echo -e "${GRAY}     当前版本: $CURRENT_VERSION${NC}"
        echo ""
        
        echo -e "${BOLD}${BLUE}  🔄 是否要更新到最新版本？${NC}"
        echo -e "${GRAY}       (输入 ${BOLD}${GREEN}y${NC}${GRAY}/${BOLD}${GREEN}yes${NC}${GRAY} 更新，按 Enter 跳过)${NC}"
        echo ""
        echo -n -e "${BOLD}${BLUE}  ┌ ${NC}"
        read -r update_claude
        echo -e "${GRAY}  └ ──────────────────────────────────────────────${NC}"
        
        if [[ "$(echo "$update_claude" | tr '[:upper:]' '[:lower:]')" =~ ^(y|yes|是)$ ]]; then
            echo ""
            print_info "更新 Claude Code..."
            
            if npm install -g @anthropic-ai/claude-code; then
                NEW_VERSION=$(claude -v 2>/dev/null | head -1 || echo "未知版本")
                print_success "Claude Code 更新成功"
                echo -e "${BOLD}${YELLOW}  📈 版本变化: ${GRAY}$CURRENT_VERSION${NC} ${BOLD}${YELLOW}→${NC} ${BOLD}${GREEN}$NEW_VERSION${NC}"
            else
                print_error "Claude Code 更新失败"
                exit 1
            fi
        else
            echo ""
            print_info "保持当前版本，跳过更新"
        fi
    else
        echo -e "${BOLD}${YELLOW}  ℹ️  未检测到 Claude Code，准备安装...${NC}"
        echo ""
        print_info "安装 Claude Code..."
        
        if npm install -g @anthropic-ai/claude-code; then
            INSTALLED_VERSION=$(claude -v 2>/dev/null | head -1 || echo "未知版本")
            print_success "Claude Code 安装成功"
            echo -e "${BOLD}${GREEN}  🎉 已安装版本: $INSTALLED_VERSION${NC}"
        else
            print_error "Claude Code 安装失败"
            exit 1
        fi
    fi
    
    # 验证安装
    echo ""
    print_info "验证 Claude Code 安装..."
    if claude -v >/dev/null 2>&1; then
        print_success "Claude Code 验证成功"
    else
        print_error "Claude Code 验证失败"
        exit 1
    fi
}

# 检查并安装/更新 Claude Code Router
install_claude_code_router() {
    print_header "🔄 Claude Code Router 检查与配置"
    
    # 先检查是否已安装
    if command_exists ccr; then
        # 获取当前版本
        CURRENT_CCR_VERSION=$(ccr -v 2>/dev/null | head -1 || echo "未知版本")
        echo -e "${BOLD}${GREEN}  ✅ 检测到已安装的 Claude Code Router${NC}"
        echo -e "${GRAY}     当前版本: $CURRENT_CCR_VERSION${NC}"
        echo ""
        
        echo -e "${BOLD}${BLUE}  🔄 是否要更新到最新版本？${NC}"
        echo -e "${GRAY}       (输入 ${BOLD}${GREEN}y${NC}${GRAY}/${BOLD}${GREEN}yes${NC}${GRAY} 更新，按 Enter 跳过)${NC}"
        echo ""
        echo -n -e "${BOLD}${BLUE}  ┌ ${NC}"
        read -r update_ccr
        echo -e "${GRAY}  └ ──────────────────────────────────────────────${NC}"
        
        if [[ "$(echo "$update_ccr" | tr '[:upper:]' '[:lower:]')" =~ ^(y|yes|是)$ ]]; then
            echo ""
            print_info "更新 Claude Code Router..."
            
            if npm install -g @musistudio/claude-code-router; then
                NEW_CCR_VERSION=$(ccr -v 2>/dev/null | head -1 || echo "未知版本")
                print_success "Claude Code Router 更新成功"
                echo -e "${BOLD}${YELLOW}  📈 版本变化: ${GRAY}$CURRENT_CCR_VERSION${NC} ${BOLD}${YELLOW}→${NC} ${BOLD}${GREEN}$NEW_CCR_VERSION${NC}"
            else
                print_error "Claude Code Router 更新失败"
                exit 1
            fi
        else
            echo ""
            print_info "保持当前版本，跳过更新"
        fi
    else
        echo -e "${BOLD}${YELLOW}  ℹ️  未检测到 Claude Code Router，准备安装...${NC}"
        echo ""
        print_info "安装 Claude Code Router..."
        
        if npm install -g @musistudio/claude-code-router; then
            INSTALLED_CCR_VERSION=$(ccr -v 2>/dev/null | head -1 || echo "未知版本")
            print_success "Claude Code Router 安装成功"
            echo -e "${BOLD}${GREEN}  🎉 已安装版本: $INSTALLED_CCR_VERSION${NC}"
        else
            print_error "Claude Code Router 安装失败"
            exit 1
        fi
    fi
    
    # 验证安装
    echo ""
    print_info "验证 Claude Code Router 安装..."
    if ccr -v >/dev/null 2>&1; then
        print_success "Claude Code Router 验证成功"
    else
        print_error "Claude Code Router 验证失败"
        exit 1
    fi
}

# 获取魔搭 API Key (可选)
get_moda_key() {
    print_header "🔑 配置魔搭 API (可选)"
    
    echo -e "${BOLD}${WHITE}  魔搭 API 能让您免费使用Qwen3-coder${NC}"
    echo ""
    echo -e "${YELLOW}  📍 如果还没有 API Key，可以访问:${NC}"
    echo -e "${UNDERLINE}${CYAN}     https://modelscope.cn/my/myaccesstoken${NC}"
    echo -e "${GRAY}     注册并绑定阿里云账号后获取key${NC}"
    echo ""
    echo -e "${GRAY}  • 输入 API Key 将自动配置魔搭服务${NC}"
    echo -e "${GRAY}  • 直接按 Enter 跳过，后续手动配置${NC}"
    echo ""
    print_divider
    echo ""
    
    echo -e "${BOLD}${BLUE}  🔐 请输入您的魔搭 API Key (可选):${NC}"
    echo -e "${GRAY}       (直接按 Enter 跳过)${NC}"
    echo ""
    echo -n -e "${BOLD}${BLUE}  ┌ ${NC}"
    read MODA_API_KEY
    echo ""
    echo -e "${GRAY}  └ ╰───────────────────────────────────────────────${NC}"
    
    if [ -z "$MODA_API_KEY" ]; then
        echo ""
        print_info "跳过 API Key 配置，后续可手动配置"
        SKIP_CONFIG=true
        return 0
    fi
    
    if [[ ${#MODA_API_KEY} -lt 10 ]]; then
        echo ""
        print_warning "API Key 长度过短，跳过配置"
        SKIP_CONFIG=true
        return 0
    fi
    
    echo ""
    print_success "API Key 已安全获取 ••••••${MODA_API_KEY: -4}"
    SKIP_CONFIG=false
}

# 创建配置文件
create_config_file() {
    # 如果跳过配置，则不创建文件
    if [ "$SKIP_CONFIG" = true ]; then
        print_info "跳过配置文件创建，可后续手动配置"
        return 0
    fi
    
    print_header "📁 创建配置文件"
    
    CONFIG_DIR="$HOME/.claude-code-router"
    CONFIG_FILE="$CONFIG_DIR/config.json"
    
    # 检查配置文件是否已存在
    if [ -f "$CONFIG_FILE" ]; then
        echo -e "${BOLD}${YELLOW}  ⚠️  检测到现有配置文件:${NC}"
        echo -e "${GRAY}     $CONFIG_FILE${NC}"
        echo ""
        echo -e "${BOLD}${BLUE}  🤔 是否要覆盖现有配置？${NC}"
        echo -e "${GRAY}       (输入 ${BOLD}${GREEN}y${NC}${GRAY}/${BOLD}${GREEN}yes${NC}${GRAY} 覆盖，按 Enter 取消)${NC}"
        echo ""
        echo -n -e "${BOLD}${BLUE}  ┌ ${NC}"
        read -r overwrite_config
        echo -e "${GRAY}  └ ╰───────────────────────────────────────────────${NC}"
        
        if [[ ! "$(echo "$overwrite_config" | tr '[:upper:]' '[:lower:]')" =~ ^(y|yes|是)$ ]]; then
            echo ""
            print_info "取消覆盖，保留现有配置文件"
            return 0
        fi
        
        echo ""
        print_warning "将覆盖现有配置文件"
    else
        echo -e "${BOLD}${BLUE}  🤔 是否创建魔搭配置文件？${NC}"
        echo -e "${GRAY}       (输入 ${BOLD}${GREEN}y${NC}${GRAY}/${BOLD}${GREEN}yes${NC}${GRAY} 确认，按 Enter 跳过)${NC}"
        echo ""
        echo -n -e "${BOLD}${BLUE}  ┌ ${NC}"
        read -r create_config
        echo -e "${GRAY}  └ ╰───────────────────────────────────────────────${NC}"
        
        if [[ ! "$(echo "$create_config" | tr '[:upper:]' '[:lower:]')" =~ ^(y|yes|是)$ ]]; then
            echo ""
            print_info "跳过配置文件创建"
            return 0
        fi
    fi
    
    echo ""
    print_info "创建配置文件..."
    
    # 创建目录
    mkdir -p "$CONFIG_DIR"
    
    # 创建配置文件内容
    cat > "$CONFIG_FILE" << EOF
{
    "LOG": false,
    "CLAUDE_PATH": "",
    "HOST": "127.0.0.1",
    "PORT": 3456,
    "APIKEY": "",
    "transformers": [

    ],
    "Providers": [
        {
            "name": "moda",
            "api_base_url": "https://api-inference.modelscope.cn/v1/chat/completions",
            "api_key": "$MODA_API_KEY",
            "models": [
                "Qwen/Qwen3-Coder-480B-A35B-Instruct",
                "Qwen/Qwen3-235B-A22B-Thinking-2507",
                "Qwen/Qwen3-Coder-30B-A3B-Instruct"
            ],
            "transformer": {
                "use": [
                    [
                        "maxtoken",
                        {
                            "max_tokens": 65535
                        }
                    ],
                    "enhancetool"
                ],
                "Qwen/Qwen3-235B-A22B-Thinking-2507": {
                    "use": [
                        "reasoning"
                    ]
                }
            }
        }
    ],
    "Router": {
        "default": "moda,Qwen/Qwen3-Coder-480B-A35B-Instruct",
        "background": "moda,Qwen/Qwen3-Coder-30B-A3B-Instruct",
        "think": "moda,Qwen/Qwen3-235B-A22B-Thinking-2507",
        "longContext": "moda,Qwen/Qwen3-Coder-480B-A35B-Instruct",
        "webSearch": "moda,Qwen/Qwen3-Coder-30B-A3B-Instruct"
    }
}
EOF
    
    print_success "配置文件已创建: $CONFIG_FILE"
    echo -e "${BOLD}${YELLOW}  💡 提示: 后续可使用 ${CYAN}ccr ui${NC}${BOLD}${YELLOW} 命令进行可视化配置${NC}"
}

# 重启服务
restart_service() {
    print_info "重启 Claude Code Router..."
    
    if ccr restart; then
        print_success "Claude Code Router 重启成功"
    else
        print_warning "重启可能失败，但这通常是正常的（如果是首次安装）"
    fi
}

# 显示使用教程
show_tutorial() {
    echo ""
    print_header "🎉 安装配置完成！"
    echo ""
    echo -e "${BOLD}${BLUE}使用教程:${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${BOLD}${YELLOW}基础命令:${NC}"
    echo -e "  ${CYAN}ccr code${NC}    - 启动 Claude Code"
    echo -e "  ${CYAN}ccr ui${NC}      - 访问 UI 界面配置第三方 API"
    echo -e "  ${CYAN}ccr restart${NC} - 重启服务（修改配置后需要执行）"
    echo -e "  ${CYAN}ccr stop${NC}    - 停止服务"
    echo -e "  ${CYAN}ccr status${NC}  - 查看服务状态"
    echo ""
    echo -e "${BOLD}${YELLOW}配置文件位置:${NC}"
    echo -e "  ${WHITE}~/.claude-code-router/config.json${NC}"
    echo ""
    echo -e "${BOLD}${YELLOW}重要提示:${NC}"
    echo -e "  • 每次修改配置后记得执行 ${BOLD}${CYAN}'ccr restart'${NC}"
    echo -e "  • 如需修改 API Key，请编辑配置文件后重启"
    echo -e "  • UI 界面地址: ${BOLD}${UNDERLINE}${CYAN}http://127.0.0.1:3456${NC}"
    echo ""
    echo -e "${BOLD}${GREEN}开始使用吧！${NC}"
}

# 安装推荐的 MCP 插件
install_recommended_mcps() {
    echo ""
    print_header "🚀 推荐安装以下 MCP 插件来增强 Claude Code 功能"
    echo ""
    
    # MCP 插件列表 (使用普通变量以提升兼容性)
    mcps_context7="让你的 Claude Code 编码更加准确|npx -y @upstash/context7-mcp"
    mcps_memory="助力记忆功能|npx -y @modelcontextprotocol/server-memory"
    mcps_fetch="抓取网页信息|npx -y @kazuph/mcp-fetch"
    mcps_Playwright="接管你的浏览器自动化|npx -y @playwright/mcp@latest"
    mcps_sequential_thinking="助力思考分析|npx -y @modelcontextprotocol/server-sequential-thinking"
    
    # 显示 MCP 插件列表
    echo -e "${BOLD}${YELLOW}可用的 MCP 插件:${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    local count=1
    for mcp_name in "context7" "memory" "fetch" "Playwright" "sequential-thinking"; do
        # 动态获取变量名 (将 - 替换为 _)
        var_name="mcps_${mcp_name//-/_}"
        mcp_info=$(eval echo \$${var_name})
        IFS='|' read -r description package <<< "$mcp_info"
        echo -e "${count}. ${BOLD}${GREEN}${mcp_name}${NC} - ${WHITE}${description}${NC}"
        ((count++))
    done
    echo ""
    
    # 询问用户是否要安装
    echo -n -e "${BOLD}${BLUE}是否要安装这些推荐的 MCP 插件？ (y/N): ${NC}"
    read -r install_mcps
    
    if [[ ! "$(echo "$install_mcps" | tr '[:upper:]' '[:lower:]')" =~ ^(y|yes|是)$ ]]; then
        print_info "跳过 MCP 插件安装"
        return 0
    fi
    
    echo ""
    print_info "开始安装推荐的 MCP 插件..."
    echo ""
    
    # 安装每个 MCP 插件
    local success_count=0
    local total_count=5
    
    for mcp_name in "context7" "memory" "fetch" "Playwright" "sequential-thinking"; do
        # 动态获取变量名 (将 - 替换为 _)
        var_name="mcps_${mcp_name//-/_}"
        mcp_info=$(eval echo \$${var_name})
        IFS='|' read -r description package <<< "$mcp_info"
        print_info "安装 ${mcp_name}..."
        
        if claude mcp add "$mcp_name" -- $package; then
            print_success "${mcp_name} 安装成功"
            ((success_count++))
        else
            print_error "${mcp_name} 安装失败"
        fi
        echo ""
    done
    
    # 显示安装结果
    print_header "📊 MCP 插件安装结果"
    if [ $success_count -eq $total_count ]; then
        print_success "所有 MCP 插件安装完成！(${success_count}/${total_count})"
    elif [ $success_count -gt 0 ]; then
        print_warning "部分 MCP 插件安装完成 (${success_count}/${total_count})"
    else
        print_error "所有 MCP 插件安装失败"
    fi

    echo ""
    echo -e "${BOLD}${YELLOW}MCP 使用提示:${NC}"
    echo "  • 已安装的 MCP 插件会自动在 Claude Code 中生效"
    echo "  • 可以使用 ${BOLD}${CYAN}'claude mcp list'${NC} 查看已安装的插件"
    echo "  • 可以使用 ${BOLD}${CYAN}'claude mcp remove <name>'${NC} 移除插件"
    echo "  • 更多信息请访问: ${BOLD}${UNDERLINE}${CYAN}https://docs.anthropic.com/en/docs/claude-code/mcp${NC}"
    echo ""
}

# 更新模式
update_mode() {
    print_header "🔄 进入更新模式"
    
    echo -e "${BOLD}${WHITE}  检查并更新已安装的软件包，不修改现有配置${NC}"
    print_divider
    echo ""
    
    local total_steps=3
    
    print_step 1 $total_steps "检查 Node.js 版本"
    check_node_version
    print_progress 1 $total_steps
    echo ""
    
    print_step "2/$total_steps" "检查/更新 Claude Code"
    # 在更新模式下，自动更新而不问用户
    if command_exists claude; then
        CURRENT_VERSION=$(claude -v 2>/dev/null | head -1 || echo "未知版本")
        echo -e "${BOLD}${GREEN}  ✅ 检测到 Claude Code: $CURRENT_VERSION${NC}"
        print_info "自动更新 Claude Code..."
        
        if npm install -g @anthropic-ai/claude-code; then
            NEW_VERSION=$(claude -v 2>/dev/null | head -1 || echo "未知版本")
            print_success "Claude Code 更新成功"
            echo -e "${BOLD}${YELLOW}  📈 版本变化: ${GRAY}$CURRENT_VERSION${NC} ${BOLD}${YELLOW}→${NC} ${BOLD}${GREEN}$NEW_VERSION${NC}"
        else
            print_error "Claude Code 更新失败"
        fi
    else
        print_warning "未检测到 Claude Code，跳过更新"
    fi
    print_progress 2 $total_steps
    echo ""
    
    print_step "3/$total_steps" "检查/更新 Claude Code Router"
    if command_exists ccr; then
        CURRENT_CCR_VERSION=$(ccr -v 2>/dev/null | head -1 || echo "未知版本")
        echo -e "${BOLD}${GREEN}  ✅ 检测到 Claude Code Router: $CURRENT_CCR_VERSION${NC}"
        print_info "自动更新 Claude Code Router..."
        
        if npm install -g @musistudio/claude-code-router; then
            NEW_CCR_VERSION=$(ccr -v 2>/dev/null | head -1 || echo "未知版本")
            print_success "Claude Code Router 更新成功"
            echo -e "${BOLD}${YELLOW}  📈 版本变化: ${GRAY}$CURRENT_CCR_VERSION${NC} ${BOLD}${YELLOW}→${NC} ${BOLD}${GREEN}$NEW_CCR_VERSION${NC}"
        else
            print_error "Claude Code Router 更新失败"
        fi
    else
        print_warning "未检测到 Claude Code Router，跳过更新"
    fi
    print_progress 3 $total_steps
    echo ""
    
    print_success "更新检查完成！"
    echo -e "${BOLD}${YELLOW}  💡 提示: 如需重启服务，请执行:${NC} ${CYAN}ccr restart${NC}"
}

# 完整安装模式
full_install_mode() {
    print_header "🚀 开始完整安装"
    
    local total_steps=7
    
    print_step "1/$total_steps" "检查 Node.js 版本"
    check_node_version
    print_progress 1 $total_steps
    echo ""
    
    print_step 2 $total_steps "检查/安装 Claude Code"
    install_claude_code  
    print_progress 2 $total_steps
    echo ""
    
    print_step 3 $total_steps "检查/安装 Claude Code Router"
    install_claude_code_router
    print_progress 3 $total_steps
    echo ""
    
    print_step 4 $total_steps "配置魔搭 API (可选)"
    get_moda_key
    print_progress 4 $total_steps
    echo ""
    
    print_step 5 $total_steps "创建配置文件 (可选)"
    create_config_file
    print_progress 5 $total_steps
    echo ""
    
    print_step 6 $total_steps "重启服务"
    restart_service
    print_progress 6 $total_steps
    echo ""
    
    print_step 7 $total_steps "推荐 MCP 插件 (可选)"
    install_recommended_mcps
    print_progress 7 $total_steps
    echo ""
    
    # 显示使用教程
    show_tutorial
    
    echo -e "\n${BOLD}${GREEN}  🎉 所有步骤完成！${NC}"
}

# 显示欢迎界面
show_welcome() {
    clear
    echo ""
    echo -e "${BOLD}${BLUE}🤖 Claude Code Free 安装配置脚本${NC}"
    echo -e "${LIGHT_GRAY}🚀 一键免费使用 Claude Code${NC}"
    echo ""
    echo -e "${DIM}${GRAY}版本: v1.0.0  │  作者: Tght  │  2025${NC}"
    echo -e "${DIM}${GRAY}――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――${NC}"
    echo ""
}

# 主函数
main() {
    show_welcome
    
    # 解析命令行参数
    case "${1:-}" in
        --help|-h)
            show_help
            exit 0
            ;;
        update)
            update_mode
            ;;
        "")
            full_install_mode
            ;;
        *)
            print_error "未知参数: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# 运行主函数
main "$@"
