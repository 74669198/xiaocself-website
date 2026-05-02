---
date: '2026-05-02T11:00:00+08:00'
draft: false
title: 'Claude Code MCP 配置指南'
description: '从零理解 MCP（Model Context Protocol）的概念，掌握常用 MCP Server 的配置方法，以及国内网络环境下的实用方案'
tags: ['Claude Code', 'MCP', '配置指南', 'AI工具']
categories: ['tools']
showToc: true
---

## 前言

MCP 是 2025 年 AI 领域最火的概念之一，但很多人只听过名字，不知道怎么用。简单说：

**MCP 让 Claude Code 长出了手和眼。**

没有 MCP：Claude 只能读写本地文件、执行终端命令。

有了 MCP：Claude 可以操作浏览器、查询数据库、调用第三方 API、访问云端服务——**能力几乎没有上限**。

---

## 第一部分：MCP 是什么

### 一句话解释

MCP（Model Context Protocol）是一个开放协议，定义了 AI 模型如何与外部工具通信。你可以把它理解为"AI 的 USB 接口"：

```
┌──────────────┐     MCP 协议     ┌──────────────┐
│  Claude Code  │ ◄──────────────► │  MCP Server   │
│   (客户端)    │    标准化通信     │  (工具提供方)  │
└──────────────┘                   └──────────────┘
                                         │
                                    ┌────┴────┐
                                    │ 实际能力  │
                                    │ 浏览器    │
                                    │ 数据库    │
                                    │ GitHub   │
                                    │ ...      │
                                    └─────────┘
```

### 核心概念

| 概念 | 类比 | 说明 |
|------|------|------|
| MCP Client | USB 主机 | Claude Code 本身 |
| MCP Server | USB 设备 | 提供具体能力的程序 |
| Tool | 设备功能 | Server 暴露的操作（如"点击网页"） |
| Resource | 设备数据 | Server 提供的数据（如"数据库记录"） |

---

## 第二部分：配置 MCP Server

### 配置位置

MCP Server 配置写在 Claude Code 的 settings 里：

```json
// ~/.claude/settings.json（全局）
// 或 /project/.claude/settings.json（项目级）
{
  "mcpServers": {
    "server-name": {
      "command": "node",
      "args": ["/path/to/server/index.js"],
      "env": {
        "API_KEY": "xxx"
      }
    }
  }
}
```

### 配置字段说明

| 字段 | 必填 | 说明 |
|------|------|------|
| `command` | 是 | 启动 Server 的命令 |
| `args` | 否 | 命令参数 |
| `env` | 否 | 环境变量（放 API Key 等） |

---

## 第三部分：常用 MCP Server 推荐

### 1. Playwright — 浏览器自动化

最实用的 MCP Server，让 Claude 直接操作浏览器：

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@anthropic-ai/mcp-playwright"]
    }
  }
}
```

装好后 Claude 可以：
- 打开网页、点击按钮、填写表单
- 截图对比
- 执行 JavaScript
- 抓取页面内容

### 2. Context7 — 实时文档查询

让 Claude 查询最新的库文档，不再依赖过时的训练数据：

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"]
    }
  }
}
```

用法示例：

```
> 查一下 Next.js 14 的 App Router 怎么配置中间件
```

Claude 会通过 Context7 获取最新的 Next.js 文档来回答。

### 3. Filesystem — 安全文件访问

限制 Claude 只能访问特定目录：

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@anthropic-ai/mcp-filesystem",
        "/home/user/projects",
        "/home/user/documents"
      ]
    }
  }
}
```

### 4. GitHub — 仓库操作

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-github"],
      "env": {
        "GITHUB_TOKEN": "ghp_xxx"
      }
    }
  }
}
```

Claude 可以：创建 Issue、管理 PR、查看 CI 状态。

### 5. Sequential Thinking — 深度推理

让 Claude 在复杂问题上做链式推理：

```json
{
  "mcpServers": {
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-sequential-thinking"]
    }
  }
}
```

---

## 第四部分：国内网络环境配置

### 问题

国内使用 MCP 的主要障碍：
- npm/npx 下载慢或超时
- 部分 Server 依赖的 API 被墙（如 GitHub API）
- 环境变量配置复杂

### 解决方案

#### 1. 配置 npm 镜像

```bash
# 使用淘宝镜像
npm config set registry https://registry.npmmirror.com

# 或在 MCP 配置中指定
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["--registry", "https://registry.npmmirror.com", "@anthropic-ai/mcp-playwright"]
    }
  }
}
```

#### 2. 全局安装代替 npx

npx 每次运行都检查更新，在国内很慢。建议全局安装：

```bash
# 全局安装
npm install -g @anthropic-ai/mcp-playwright

# 配置改为直接调用
{
  "mcpServers": {
    "playwright": {
      "command": "mcp-playwright"
    }
  }
}
```

#### 3. 代理配置

如果有代理，设置环境变量：

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-github"],
      "env": {
        "GITHUB_TOKEN": "ghp_xxx",
        "HTTP_PROXY": "http://127.0.0.1:7890",
        "HTTPS_PROXY": "http://127.0.0.1:7890"
      }
    }
  }
}
```

#### 4. 使用 CC-Switch 接入国内模型

如果你用 CC-Switch 配置了国内模型（见之前的教程），MCP Server 同样可以配合使用。模型负责理解和生成，MCP 负责执行操作，两者互补。

---

## 第五部分：实战——搭建个人 MCP 工具箱

### 我推荐的组合

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-playwright"]
    },
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"]
    },
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-sequential-thinking"]
    },
    "memory": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-memory"]
    }
  }
}
```

这 4 个 Server 覆盖了：
- **Playwright**：浏览器操作（测试、爬虫、自动化）
- **Context7**：实时文档（不再用过时信息）
- **Sequential Thinking**：深度推理（复杂问题分步思考）
- **Memory**：持久记忆（跨会话记住上下文）

### 验证 MCP 是否生效

启动 Claude Code 后输入：

```
> 列出你可用的 MCP 工具
```

Claude 会返回所有已加载的 MCP 工具列表。如果某个 Server 没出现，检查配置和安装。

---

## 常见问题

### Q: MCP Server 启动失败？

检查：
1. Node.js 版本 >= 18
2. `npx` 能否正常运行
3. 网络是否需要代理
4. 环境变量是否配置正确

### Q: MCP 会影响 Claude 的响应速度？

每个 MCP Server 是独立进程，只有在调用时才通信。不使用时零开销。

### Q: 可以自己写 MCP Server 吗？

可以！MCP 是开放协议，Python 和 TypeScript 都有 SDK：

```bash
# 创建 TypeScript MCP Server
npm create @anthropic-ai/mcp-server my-server

# 创建 Python MCP Server
pip install mcp
```

适合把你公司的内部系统（OA、CRM、监控）接入 Claude Code。

---

## 总结

| 阶段 | 动作 | 推荐优先级 |
|------|------|-----------|
| 入门 | 装 Playwright | ⭐⭐⭐⭐⭐ |
| 进阶 | 装 Context7 + Memory | ⭐⭐⭐⭐ |
| 高级 | 装 GitHub + Sequential Thinking | ⭐⭐⭐ |
| 专家 | 自己写 MCP Server | ⭐⭐ |

MCP 让 Claude Code 从"代码助手"升级为"全能助手"。装一个试试，你会回不来的。
