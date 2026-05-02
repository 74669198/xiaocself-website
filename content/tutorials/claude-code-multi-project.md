---
date: '2026-05-02T10:30:00+08:00'
draft: false
title: 'Claude Code 多项目管理实战'
description: '同时管理多个项目不混乱的完整方法：项目级配置、工作区切换、上下文隔离、会话管理最佳实践'
tags: ['Claude Code', '多项目', '工作区', '效率']
categories: ['tutorials']
showToc: true
---

## 前言

如果你同时维护 3 个以上项目，一定遇到过这些问题：

- 在 A 项目里让 Claude 改代码，它改到了 B 项目的文件
- 切项目时忘了切上下文，Claude 还在用上一个项目的配置
- 两个项目依赖不同版本的库，Claude 搞混了

这篇文章分享我日常管理多项目的完整方法，核心思路是：**物理隔离 + 配置隔离 + 上下文隔离**。

---

## 第一部分：项目级配置隔离

### settings.json 三级覆盖

Claude Code 的配置是**三级叠加**的：

```
~/.claude/settings.json          ← 全局配置（影响所有项目）
/project/.claude/settings.json   ← 项目配置（覆盖全局）
/project/.claude/settings.local.json  ← 本地配置（不入 Git）
```

### 给每个项目定制规则

**项目 A：前端项目**

```json
// /project-a/.claude/settings.json
{
  "permissions": {
    "allow": [
      "Bash(npm run *)",
      "Bash(npx *)",
      "Read",
      "Edit"
    ]
  },
  "env": {
    "NODE_ENV": "development"
  }
}
```

**项目 B：Python 后端**

```json
// /project-b/.claude/settings.json
{
  "permissions": {
    "allow": [
      "Bash(python *)",
      "Bash(pytest *)",
      "Bash(pip *)",
      "Read",
      "Edit"
    ]
  },
  "env": {
    "PYTHONPATH": "/project-b/src"
  }
}
```

这样 Claude 在不同项目里会自动加载对应的权限和环境变量。

### 用 settings.local.json 存敏感信息

```json
// /project/.claude/settings.local.json（加入 .gitignore）
{
  "env": {
    "DATABASE_URL": "postgresql://user:pass@localhost:5432/mydb",
    "API_KEY": "sk-xxx"
  }
}
```

`.local.json` 不会被提交到 Git，适合放密钥和本地路径。

---

## 第二部分：工作区切换

### 方法一：终端目录切换（最简单）

```bash
# 项目 A
cd ~/projects/frontend-app
claude

# 项目 B（新开终端窗口）
cd ~/projects/backend-api
claude
```

Claude Code 自动识别当前目录，加载对应的 `.claude/settings.json`。

**建议**：每个项目开一个独立的终端窗口/Tab，避免频繁切换。

### 方法二：git worktree 隔离

当你在同一个项目的不同分支间频繁切换时：

```bash
# 主工作区
cd ~/projects/my-app        # main 分支

# 创建 worktree 做新功能
git worktree add ~/projects/my-app-feature feature/new-ui

# 现在有两个独立目录
# ~/projects/my-app        → main
# ~/projects/my-app-feature → feature/new-ui
```

每个 worktree 可以独立运行 Claude Code，互不干扰。

### 方法三：tmux 多窗口

用 tmux 管理多个项目会话：

```bash
# 窗口 1：前端项目
tmux new-window -n frontend
cd ~/projects/frontend && claude

# 窗口 2：后端项目
tmux new-window -n backend
cd ~/projects/backend && claude

# 窗口 3：运维脚本
tmux new-window -n ops
cd ~/projects/ops-scripts && claude
```

快捷键 `Ctrl+B + 数字` 快速切换。

---

## 第三部分：上下文隔离

### 问题：上下文污染

Claude Code 的上下文窗口有限。如果你在同一个会话里讨论多个项目，会发生：

```
你：帮我改一下 A 项目的登录逻辑
Claude：好的...（改了）

你：现在看看 B 项目的数据库查询
Claude：我注意到 B 项目的登录页面...（还在想 A 项目）
```

### 解决方案

**规则一：一个会话只讨论一个项目**

```bash
# 不要这样做
cd ~/project-a
claude
> 先帮我改 A 项目的 bug，然后看看 B 项目的...

# 应该这样做
cd ~/project-a
claude
> 帮我改登录 bug

# 完成后，退出，开新会话
cd ~/project-b
claude
> 帮我优化数据库查询
```

**规则二：用 /clear 清除上下文**

如果必须在同一会话里切换话题：

```
> /clear
> 现在我们讨论 B 项目的数据库查询
```

`/clear` 会清空对话历史，让 Claude 重新开始。

**规则三：用 /compact 压缩上下文**

当对话很长但还没结束时：

```
> /compact
```

Claude 会把之前的对话压缩成摘要，释放上下文空间。

---

## 第四部分：CLAUDE.md 项目文档

每个项目根目录放一个 `CLAUDE.md`，让 Claude 快速了解项目：

```markdown
# 项目 A：电商平台前端

## 技术栈
- Next.js 14 + TypeScript
- Tailwind CSS
- Zustand 状态管理

## 关键目录
- src/app/ — 页面路由
- src/components/ — UI 组件
- src/lib/ — 工具函数

## 开发规范
- 组件用 PascalCase 命名
- API 调用统一走 src/lib/api.ts
- 提交信息用中文
```

```markdown
# 项目 B：用户服务 API

## 技术栈
- FastAPI + Python 3.12
- SQLAlchemy + PostgreSQL
- Redis 缓存

## 关键目录
- app/routers/ — API 路由
- app/models/ — 数据模型
- app/services/ — 业务逻辑

## 开发规范
- 函数名用 snake_case
- 每个 API 都要有对应的测试
- 数据库迁移用 Alembic
```

Claude Code 启动时会自动读取 `CLAUDE.md`，不需要你重复介绍项目。

---

## 第五部分：实际工作流

### 我的日常多项目管理

```
09:00  打开终端，启动 3 个 tmux 窗口
       ├── frontend (Claude Code) → 处理前端需求
       ├── backend  (Claude Code) → 处理 API 需求
       └── ops      (Claude Code) → 检查监控和脚本

09:10  在 frontend 窗口：修复按钮样式 bug
09:30  在 backend 窗口：添加新的 API 端点
10:00  /compact 压缩上下文
10:30  切到 ops 窗口：更新部署脚本

午休   关闭所有 Claude Code 会话

14:00  重新打开，每个项目一个新会话
       ├── 全新的上下文，没有上午的残留
```

### 批量任务处理

当需要同时在多个项目执行相似操作时：

```
# 不要在一个会话里跨项目操作
> 帮我同时更新 A 项目和 B 项目的依赖

# 应该分别处理
# 项目 A 会话
> 更新所有 npm 依赖到最新版

# 项目 B 会话
> 更新所有 pip 依赖到最新版
```

---

## 常见问题

### Q: 同时开多个 Claude Code 会不会卡？

不会。每个 Claude Code 实例是独立进程，不共享上下文。只要你的机器内存够，开几个都没问题。

### Q: 怎么在项目间共享代码片段？

用剪贴板或临时文件：

```bash
# 在项目 A 生成代码
> 把这个工具函数输出到 /tmp/shared-utils.ts

# 在项目 B 引用
> 读取 /tmp/shared-utils.ts，适配到我们的项目里
```

### Q: 上下文用完了怎么办？

1. `/compact` — 压缩当前对话
2. `/clear` — 完全清除，重新开始
3. 退出重开 — 最彻底的方式

---

## 总结

| 隔离维度 | 方法 | 效果 |
|----------|------|------|
| 配置隔离 | 项目级 settings.json | 不同项目不同权限和环境变量 |
| 物理隔离 | 不同终端/tmux 窗口 | Claude 只看到当前项目文件 |
| 上下文隔离 | 一会话一项目 + /clear | 避免跨项目上下文污染 |
| 认知隔离 | CLAUDE.md | Claude 自动了解项目上下文 |

多项目管理的核心就一句话：**每个项目都是独立的宇宙，不要让它们交叉感染**。
