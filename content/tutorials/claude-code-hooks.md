---
date: '2026-04-29T19:30:00+08:00'
draft: false
title: 'Claude Code Hooks 配置实战：让 AI 自动帮你收尾'
description: '详解 Claude Code 的 Hooks 系统，从自动格式化到自动测试，配置一次受益终生'
tags: ['claude-code', 'hooks', '自动化', '教程']
categories: ['教程']
---

## 为什么需要 Hooks？

用 Claude Code 写代码时，我最烦的一件事是：它帮我改完代码，我还得手动跑一遍格式化、跑一遍测试，确认没问题才能提交。

Hooks 就是来解决这个问题的。**配置好 Hooks，Claude Code 每完成一次文件写入或编辑，就会自动触发你预设的命令。**

打个比方：
- 没有 Hooks = 请了个助理，但整理文档、检查错误还得你自己来
- 有 Hooks = 助理写完直接帮你排版、校对、归档，你只管看结果

## Hooks 能做什么？

Claude Code 支持多种事件触发：

| 事件 | 触发时机 | 常用场景 |
|------|---------|---------|
| `PostToolUse` | 工具执行成功后 | 文件格式化、自动测试、构建验证 |
| `PreToolUse` | 工具执行前 | 命令日志记录、权限检查 |
| `PreCompact` | 会话压缩前 | 保存重要上下文 |
| `Stop` | 会话结束时 | 生成总结、发送通知 |

最常用的是 `PostToolUse`，下面重点讲。

## 实战配置一：自动格式化代码

我用的最多的是 Prettier。每次 Claude 写完 JS/TS/CSS，自动格式化：

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "jq -r '.tool_response.filePath // .tool_input.file_path' | { read -r f; prettier --write \"$f\"; } 2>/dev/null || true"
      }]
    }]
  }
}
```

**效果**：Claude 刚写完一个文件，Prettier 立刻跑一遍，代码风格统一。

如果是 Go 项目，把 `prettier` 换成 `gofmt`：

```json
{
  "type": "command",
  "command": "jq -r '.tool_input.file_path' | { read -r f; gofmt -w \"$f\"; } 2>/dev/null || true"
}
```

## 实战配置二：保存后自动测试

前端项目，文件改动后自动跑相关测试：

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "jq -r '.tool_input.file_path' | grep -E '\.(ts|tsx|js|jsx)$' && npm test -- --run --changed 2>/dev/null || true"
      }]
    }]
  }
}
```

**注意**：如果测试跑很久，Claude 会等待结果。建议用 `--run`（Vitest）或 `--watchAll=false`（Jest）避免挂起。

## 实战配置三：记录所有 Bash 命令

有时候想复盘 Claude 执行了哪些命令，可以配置日志：

```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [{
        "type": "command",
        "command": "jq -r '.tool_input.command' >> ~/.claude/bash-log.txt"
      }]
    }]
  }
}
```

日志文件长这样：

```
2026-04-29 npm install
2026-04-29 hugo server -D
2026-04-29 git push origin main
```

方便以后写"本周 AI 帮我做了什么"的总结。

## 实战配置四：会话结束自动总结

```json
{
  "hooks": {
    "Stop": [{
      "hooks": [{
        "type": "command",
        "command": "echo '{\"systemMessage\": \"本次会话已结束，记得检查修改并提交代码~\"}'"
      }]
    }]
  }
}
```

## 配置文件的存放位置

Claude Code 支持三级配置，优先级由低到高：

| 文件 | 作用范围 | 是否提交 Git |
|------|---------|------------|
| `~/.claude/settings.json` | 全局（所有项目）| 否 |
| `.claude/settings.json` | 当前项目 | ✅ 是 |
| `.claude/settings.local.json` | 当前项目（个人覆盖）| 否 |

**建议**：把 Hooks 放在项目级的 `.claude/settings.json` 里，团队成员共享。个人偏好（比如模型选择）放 `settings.local.json`。

## 调试 Hooks 的技巧

Hooks 配错了不会报错，只会默默不执行。调试方法：

1. **手动测试命令**：把 Hooks 里的命令单独在终端跑一遍，确认能工作
2. **加个哨兵文件**：临时在命令前面加 `echo "hook fired" >> /tmp/hook-test.txt;`，触发后检查文件
3. **看 debug 日志**：启动 Claude Code 时加 `--debug` 参数，能看到 Hooks 执行详情

## 我的 Hooks 配置模板

下面是我日常项目的通用配置，直接复制可用：

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "jq -r '.tool_response.filePath // .tool_input.file_path' | { read -r f; case \"$f\" in *.js|*.ts|*.tsx|*.jsx|*.css|*.json) prettier --write \"$f\" 2>/dev/null ;; *.go) gofmt -w \"$f\" 2>/dev/null ;; esac; } || true"
      }]
    }],
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [{
        "type": "command",
        "command": "jq -r '.tool_input.command' | sed \"s/^/$(date '+%Y-%m-%d %H:%M:%S') /\" >> .claude/bash.log"
      }]
    }]
  }
}
```

## 写在最后

Hooks 是 Claude Code 最容易被低估的功能。很多人用了一个月 Claude Code 都不知道它能自动格式化、自动测试。

花 10 分钟配置好 Hooks，后面每次写代码都能省掉手动收尾的步骤。这就是"配置一次，受益终生"。

如果你有好用的 Hooks 配置，欢迎在评论区分享。
