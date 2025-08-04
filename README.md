# 🤖 Claude Code Free

<div align="center">

![Claude Code Free](https://img.shields.io/badge/Claude%20Code-Free-blue?style=for-the-badge&logo=anthropic&logoColor=white&labelColor=0051D5)
![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Linux%20%7C%20macOS-green?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-orange?style=for-the-badge)
![Stars](https://img.shields.io/github/stars/your-username/claude-code-free?style=for-the-badge&color=yellow)

**🚀 一键免费使用 Claude Code - 无需 API 费用！**

让每个开发者都能享受 Claude 的强大编程能力

[🔥 立即开始](#-快速开始) · [📖 使用指南](#-使用指南) · [🎯 功能特性](#-功能特性) · [🤝 贡献代码](#-贡献)

</div>

---

## 📋 项目简介

Claude Code Free 是一个**一键安装配置脚本**，让你能够**完全免费**使用 Anthropic 的 Claude Code 编程助手。通过集成魔搭 ModelScope 的免费 API，无需付费即可享受 Claude 级别的代码生成、调试和优化服务。

### 🎯 核心价值

- 🆓 **完全免费** - 无需 Anthropic API 费用
- ⚡ **一键安装** - 自动配置所有依赖和设置  
- 🌍 **跨平台支持** - Windows、Linux、macOS 全覆盖
- 🔧 **开箱即用** - 零配置启动，省心省力
- 🚀 **性能强劲** - 基于 Qwen3-Coder 480B 模型

## 🌟 功能特性

### 💡 智能编程助手
- **代码生成** - 根据需求自动生成高质量代码
- **Bug 修复** - 智能识别并修复代码问题
- **代码优化** - 重构和性能优化建议
- **文档生成** - 自动生成代码注释和文档

### 🔧 便捷工具集成
- **MCP 插件生态** - 支持多种扩展插件
  - 🧠 **context7** - 智能上下文分析
  - 💾 **memory** - 对话记忆功能
  - 🌐 **fetch** - 网页内容抓取
  - 🎭 **Playwright** - 浏览器自动化
  - 🤔 **sequential-thinking** - 逻辑思维分析

### 🎨 用户体验
- **美观界面** - 精心设计的命令行界面
- **进度显示** - 实时安装进度反馈
- **错误处理** - 智能错误诊断和修复建议
- **多语言支持** - 中文友好的交互体验

## 🚀 快速开始

### 📋 系统要求

- **Node.js** 20+ 
- **操作系统**: Windows 10+、Linux、macOS 10.15+
- **网络**: 稳定的互联网连接

### ⬇️ 下载安装

#### 方式一：直接下载（推荐）

<details>
<summary><b>🪟 Windows 用户</b></summary>

```bash
# 下载脚本
curl -o claude-code-free.bat https://raw.githubusercontent.com/your-username/claude-code-free/main/claude-code-free.bat

# 运行安装
claude-code-free.bat
```

</details>

<details>
<summary><b>🐧 Linux / 🍎 macOS 用户</b></summary>

```bash
# 下载脚本
curl -o claude-code-free.sh https://raw.githubusercontent.com/your-username/claude-code-free/main/claude-code-free.sh

# 添加执行权限
chmod +x claude-code-free.sh

# 运行安装
./claude-code-free.sh
```

</details>

#### 方式二：Git 克隆

```bash
git clone https://github.com/your-username/claude-code-free.git
cd claude-code-free

# Windows
claude-code-free.bat

# Linux/macOS  
./claude-code-free.sh
```

### 🎬 安装演示

```
   ╭─────────────────────────────────────────────────────────╮
   │                                                         │
   │    🤖 欢迎使用 Claude Code Free 安装配置脚本                │
   │                                                         │
   │    🚀 一键免费使用Claude Code                             │
   │                                                         │
   ╰─────────────────────────────────────────────────────────╯

  🔄 步骤 1/7: 检查 Node.js 版本
  ✅ Node.js 版本检查通过: v20.10.0
  
  🔄 步骤 2/7: 检查/安装 Claude Code
  ✅ Claude Code 安装成功
  
  🔄 步骤 3/7: 检查/安装 Claude Code Router  
  ✅ Claude Code Router 安装成功
```

## 📖 使用指南

### 🔑 获取魔搭 API Key（可选但推荐）

1. 访问 [ModelScope](https://modelscope.cn/my/myaccesstoken)
2. 注册并绑定阿里云账号
3. 获取免费 API Key
4. 在安装过程中输入 API Key

### 🎮 基础命令

```bash
# 启动 Claude Code
ccr code

# 管理界面（浏览器访问）
ccr ui              # 打开 http://127.0.0.1:3456

# 服务管理
ccr restart         # 重启服务
ccr stop            # 停止服务  
ccr status          # 查看状态
```

### 🔄 更新软件

```bash
# Windows
claude-code-free.bat update

# Linux/macOS
./claude-code-free.sh update
```

### 🧩 MCP 插件管理

```bash
# 查看已安装插件
claude mcp list

# 移除插件
claude mcp remove <plugin-name>

# 手动安装插件
claude mcp add <plugin-name> -- <package-command>
```

## 🎯 高级配置

### 📁 配置文件位置

- **Windows**: `%USERPROFILE%\.claude-code-router\config.json`
- **Linux/macOS**: `~/.claude-code-router/config.json`

### ⚙️ 自定义配置示例

> ccr 的配置，详情可以查看 claude-code-router 开源项目
```json
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
            "api_key": "填入魔搭的key",
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
```

## 🛠️ 故障排除

### 常见问题

<details>
<summary><b>❓ Node.js 版本过低</b></summary>

**解决方案**：
```bash
# 使用 nvm 升级 Node.js
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install 20
nvm use 20
```

</details>

<details>
<summary><b>❓ 网络连接问题</b></summary>

**解决方案**：
- 检查网络连接
- 尝试使用代理
- 切换到移动热点

</details>

<details>
<summary><b>❓ 权限问题</b></summary>

**解决方案**：
```bash
# Linux/macOS
sudo chmod +x claude-code-free.sh

# 或使用 sudo 运行
sudo ./claude-code-free.sh
```

</details>

### 🆘 获取帮助

```bash
# 显示帮助信息
claude-code-free.sh --help  # Linux/macOS
claude-code-free.bat --help  # Windows
```

## 🎪 使用场景

### 👨‍💻 个人开发者
- **学习编程** - 获得实时编程指导
- **项目开发** - 加速开发效率
- **代码审查** - 发现潜在问题

### 👥 团队协作  
- **代码标准化** - 统一编程风格
- **知识分享** - 新人快速上手
- **质量提升** - 减少 Bug 数量

### 🏫 教育场景
- **编程教学** - 辅助教学工具
- **作业辅导** - 学生编程助手
- **技能提升** - 实践项目指导

## 🤝 贡献

我们欢迎所有形式的贡献！

### 🔧 开发贡献

1. **Fork** 本仓库
2. 创建功能分支: `git checkout -b feature/AmazingFeature`
3. 提交更改: `git commit -m 'Add some AmazingFeature'`
4. 推送分支: `git push origin feature/AmazingFeature`
5. 提交 **Pull Request**

### 🐛 问题反馈

- [提交 Bug](https://github.com/your-username/claude-code-free/issues/new?template=bug_report.md)
- [功能建议](https://github.com/your-username/claude-code-free/issues/new?template=feature_request.md)
- [使用问题](https://github.com/your-username/claude-code-free/discussions)



## 🙏 致谢

- **Anthropic** - 提供强大的 Claude AI 技术
- **ModelScope** - 提供免费的 API 服务
- **[Claude Code Router](https://github.com/MusiStudio/claude-code-router)** - 核心路由服务 
- **开源社区** - 提供宝贵的反馈和贡献

## 📞 联系我们

- **作者**: Tght
- **项目主页**: [https://github.com/your-username/claude-code-free](https://github.com/your-username/claude-code-free)
- **问题反馈**: [Issues](https://github.com/your-username/claude-code-free/issues)

---

<div align="center">

**⭐ 如果这个项目对你有帮助，请给我们一个 Star！**

**🔗 分享给更多开发者，让大家都能免费使用 Claude Code！**

[![分享到微博](https://img.shields.io/badge/%E5%88%86%E4%BA%AB%E5%88%B0-%E5%BE%AE%E5%8D%9A-red?style=flat-square&logo=sina-weibo)](https://service.weibo.com/share/share.php?url=https://github.com/your-username/claude-code-free&title=🤖%20Claude%20Code%20Free%20-%20一键免费使用%20Claude%20Code)
[![分享到推特](https://img.shields.io/badge/Share%20on-Twitter-blue?style=flat-square&logo=twitter)](https://twitter.com/intent/tweet?text=🤖%20Claude%20Code%20Free%20-%20One-click%20free%20Claude%20Code%20setup!&url=https://github.com/your-username/claude-code-free)

</div>