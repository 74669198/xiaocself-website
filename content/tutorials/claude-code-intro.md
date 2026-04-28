---
date: '2026-04-28T19:11:38+08:00'
draft: false
title: 'Claude Code 入门指南：从零开始'
description: 'Claude Code 是什么？它能做什么？如何安装和配置？一篇入门文讲清楚'
tags: ['claude-code', '入门', '教程']
categories: ['教程']
---

## 什么是 Claude Code？

Claude Code 是 Anthropic 推出的 AI 编程助手，但它不仅仅是写代码的工具。

在我看来，它更像是一个**24小时在线的超级助理**：
- 帮你写文档、做表格
- 帮你分析数据、整理材料
- 帮你配置工具、搭建系统
- 甚至帮你管理项目、复盘经验

## 它能做什么？

### 1. 代码开发
- 写代码、改 Bug、重构项目
- 支持多种语言（Python、JavaScript、Go 等）
- 可以操作文件系统（读写、创建、删除）

### 2. 文档处理
- 写 Markdown、Word、PPT
- 整理会议纪要、工作报告
- 生成标准化文档（报备、申请、方案）

### 3. 数据分析
- 处理 Excel、CSV 数据
- 生成统计图表
- 数据清洗和转换

### 4. 系统配置
- 配置开发环境
- 搭建网站、部署服务
- 管理服务器和数据库

### 5. 项目管理
- 制定计划、分解任务
- 跟踪进度、监控风险
- 复盘总结、知识沉淀

## 如何安装？

### macOS

```bash
# 通过 Homebrew 安装
brew install claude-code

# 验证安装
claude --version
```

### Windows

```powershell
# 通过 npm 安装
npm install -g @anthropic-ai/claude-code
```

### Linux

```bash
# 通过 npm 安装
npm install -g @anthropic-ai/claude-code
```

## 首次配置

### 1. 登录

```bash
claude
```

首次运行会提示登录，按指引完成即可。

### 2. 配置模型（重要）

Claude Code 默认使用 Anthropic 官方模型，国内访问可能不稳定。

**推荐方案：使用 CC-Switch 接入国内模型**

```bash
# 安装 CC-Switch
npm install -g cc-switch

# 配置火山引擎（Kimi 模型）
cc-switch use kimi

# 验证
claude
```

### 3. 配置权限

编辑 `~/.claude/settings.json`：

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Bash(ls *)",
      "Bash(cat *)",
      "Bash(pwd)"
    ]
  }
}
```

## 常用指令

| 指令 | 作用 |
|------|------|
| `/plan` | 复杂任务规划 |
| `/doctor` | 系统健康检查 |
| `/usage` | 查看资源消耗 |
| `/config` | 修改配置 |
| `/compact` | 压缩上下文 |
| `/clear` | 清空屏幕 |

## 下一篇

[《CC-Switch 配置指南：接入 Kimi/GLM 等国内模型》](/tutorials/cc-switch-setup/)

---

*如果这篇文章对你有帮助，欢迎收藏和分享！*
