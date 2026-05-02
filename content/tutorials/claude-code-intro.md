---
date: '2026-04-28T19:11:38+08:00'
draft: false
title: 'Claude Code 入门指南：从零开始'
description: 'Claude Code 是什么？它能做什么？如何安装和配置？一篇真正够用的入门指南'
tags: ['claude-code', '入门', '教程']
categories: ['教程']
---

## 什么是 Claude Code？

Claude Code 是 Anthropic 推出的**命令行 AI 助手**。它的核心定位不是"代码编辑器里的补全插件"，而是一个能直接操作你电脑文件系统、执行终端命令、读写代码的**智能协作者**。

和 Cursor、GitHub Copilot 最大的区别在于：**Claude Code 是 Agent 型的**。它不只是给你建议，而是可以直接：
- 读取你的项目文件，理解整体结构
- 执行 `git`、`npm`、`python` 等命令
- 批量修改多个文件
- 运行测试验证修改是否正确

简单来说：Cursor 是"更聪明的代码编辑器"，Claude Code 是"会写代码的实习生"。

## 安装前的准备

### 系统要求

| 项目 | 要求 |
|------|------|
| 操作系统 | macOS 12+ / Windows 10+ / Linux |
| Node.js | 18.0+（Windows/Linux 需要）|
| 内存 | 建议 8GB+ |
| 网络 | 能访问 Anthropic API 或使用 CC-Switch 代理 |

### 你需要准备什么

1. **Anthropic 账号**：访问 [console.anthropic.com](https://console.anthropic.com) 注册，获取 API Key
2. **命令行基础**：会打开终端、输入命令、切换目录即可
3. **一个实际项目**：Claude Code 需要在一个文件夹里工作，空文件夹它帮不上忙

## 安装步骤

### macOS（推荐）

```bash
# 通过 Homebrew 一键安装
brew install claude-code

# 验证安装
claude --version
# 应输出类似: claude 1.0.25
```

### Windows

```powershell
# 需要先有 Node.js 18+
# 通过 npm 安装
npm install -g @anthropic-ai/claude-code

# 验证
claude --version
```

### Linux

```bash
npm install -g @anthropic-ai/claude-code
claude --version
```

## 首次启动与登录

在你的项目目录下打开终端：

```bash
cd ~/your-project
claude
```

第一次运行会显示一个登录链接，按以下步骤操作：

1. 终端会显示一个 URL，复制到浏览器打开
2. 用 Anthropic 账号登录
3. 浏览器会提示授权成功，回到终端
4. 看到 `>` 提示符，说明登录完成

**关键概念：Working Directory**

Claude Code 启动时所在文件夹就是它的"工作区"。它只能看到这个文件夹里的内容，以及你明确授权的操作。不要在你的家目录 `~` 直接启动——权限范围太大。

## 第一次对话：跟着做

登录成功后，建议先做一次完整对话，熟悉流程。

**场景**：你想了解当前项目的结构。

```
> 帮我看看这个项目是什么技术栈，目录结构如何？
```

Claude 会：
1. 读取 `package.json`、`README.md` 等关键文件（自动执行 Read 工具）
2. 分析目录结构（自动执行 Bash 工具列出文件）
3. 给你一份结构化的分析报告

你会看到类似输出：

```
我分析了你的项目结构：

- 这是一个 React + TypeScript 项目（基于 package.json）
- 使用 Vite 作为构建工具
- 主要目录：
  - src/ — 源代码
  - src/components/ — 组件目录（12个组件）
  - src/pages/ — 页面目录（3个页面）
- 测试覆盖率：60%
```

**注意**：Claude 执行每个操作前都会询问你是否允许。你可以输入 `y` 确认，或 `n` 拒绝。

## 配置模型（国内用户必看）

Claude Code 默认连接 Anthropic 官方 API。如果你在国内遇到连接问题，强烈推荐配置 CC-Switch：

```bash
# 安装 CC-Switch
npm install -g cc-switch

# 查看支持的模型
cc-switch list

# 配置 Kimi（火山引擎）
cc-switch use kimi

# 配置完成后，重新启动 Claude Code
claude
```

配置后，Claude Code 的所有请求都会通过国内模型转发，速度快且稳定。

详细配置见：[CC-Switch 配置指南](/tutorials/cc-switch-setup/)

## 核心概念速览

### 1. 上下文（Context）

Claude Code 不是全知全能的。它只能看到：
- 你当前的工作目录
- 你通过 `@文件名` 明确引用的文件
- 对话历史中提到的内容

**最佳实践**：
- 讨论具体代码时，用 `@文件名` 引用
- 讨论架构时，让 Claude 先读取关键配置文件
- 长对话后用 `/compact` 压缩上下文，避免"失忆"

### 2. 工具使用（Tool Use）

Claude Code 不是直接操作你的电脑，而是通过一套受控的"工具"：

| 工具 | 作用 | 是否需要确认 |
|------|------|-------------|
| Read | 读取文件 | 否 |
| Edit | 修改文件 | 是 |
| Bash | 执行命令 | 是（危险命令）|
| Write | 创建文件 | 是 |

你可以在 `settings.json` 中配置哪些工具不需要确认。

### 3. 配置文件

全局配置位于 `~/.claude/settings.json`：

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Bash(git *)",
      "Bash(npm *)",
      "Bash(ls *)",
      "Bash(pwd)"
    ],
    "deny": [
      "Bash(rm -rf /)",
      "Bash(sudo *)"
    ]
  }
}
```

项目级配置放在项目根目录的 `.claude/settings.json`，会覆盖全局配置。

## 常用命令速查

| 命令 | 作用 | 使用场景 |
|------|------|---------|
| `/plan` | 复杂任务规划 | 大型重构前让 Claude 先出方案 |
| `/compact` | 压缩对话历史 | 对话超过20轮，Claude开始"失忆"时 |
| `/clear` | 清空屏幕和上下文 | 想换个话题重新开始 |
| `/cost` | 查看 token 消耗 | 关注使用成本时 |
| `/help` | 显示所有命令 | 忘了某个命令时 |
| `exit` 或 `Ctrl+D` | 退出 Claude Code | 工作完成后 |

## 常见新手问题

**Q: Claude 说找不到文件**
A: 检查你是否在正确的目录启动了 Claude Code。用 `pwd` 确认当前路径。

**Q: 命令执行被拒绝**
A: 检查 `~/.claude/settings.json` 中的权限配置。Bash 命令需要明确匹配白名单规则。

**Q: Claude 的修改我不满意**
A: 直接说"撤销刚才的修改"或 "回退到上一步"。Claude 会尽量恢复。更保险的做法是：在让 Claude 改代码前，确保你的修改已 `git commit`。

**Q: 连接超时/模型响应慢**
A: 配置 CC-Switch 切换到国内模型。见上面的配置章节。

**Q: 担心 Claude 误删文件**
A: 默认配置下，所有删除操作都需要你确认。更安全的做法是：在重要项目里，先 `git commit` 再让 Claude 操作，随时可以 `git checkout` 回退。

## 下一步

掌握了基础操作后，建议按这个顺序深入：

1. [配置 CC-Switch 接入国内模型](/tutorials/cc-switch-setup/) — 解决网络问题
2. [Claude Code 高效使用技巧](/tutorials/claude-code-tips/) — 提升日常效率
3. [Claude Code Settings 完全指南](/tutorials/claude-code-settings/) — 深度定制权限和工作流

---

*最后更新：2026-05-03 | 如果发现内容过时或有误，欢迎在 [GitHub](https://github.com/xiaocself) 提出 Issue*
