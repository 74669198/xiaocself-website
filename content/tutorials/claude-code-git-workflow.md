---
date: '2026-05-02T10:00:00+08:00'
draft: false
title: 'Claude Code Git 工作流最佳实践'
description: '用 Claude Code 管理 Git 分支、提交、代码审查和冲突解决的完整工作流，让你的版本控制从手动挡升级到自动挡'
tags: ['Claude Code', 'Git', '工作流', '代码审查']
categories: ['tutorials']
showToc: true
---

## 前言

大多数人用 Claude Code 写代码，但还是手动 `git add` + `git commit` + 写提交信息。这就像买了自动驾驶汽车，却非要自己握方向盘。

Claude Code 对 Git 的支持远比你想的深——它不只是帮你写代码，还能帮你管理**整个版本控制流程**。

这篇文章分享我日常使用的 Git 工作流，从分支策略到冲突解决，全部由 Claude Code 辅助完成。

---

## 第一部分：分支策略

### Feature Branch 工作流

我最常用的是 Feature Branch 模式：

```
main ──────────────────────────────────●───●───●
       \                             /       \
        └── feature/add-login ──●──●┘         └── feature/add-dashboard ──●──●┘
```

Claude Code 可以一键完成分支创建和切换：

```bash
# 直接告诉 Claude 你要做什么
> 帮我创建一个 feature/add-login 分支，从 main 切出来

# Claude 执行：
git checkout main
git pull origin main
git checkout -b feature/add-login
```

### 什么时候该开新分支

| 场景 | 分支命名 | 示例 |
|------|----------|------|
| 新功能 | `feature/功能名` | `feature/user-auth` |
| 修 Bug | `fix/问题描述` | `fix/login-timeout` |
| 重构 | `refactor/模块名` | `refactor/api-layer` |
| 实验 | `experiment/想法` | `experiment/rust-rewrite` |

**小技巧**：直接对 Claude 说"我要修登录超时的 bug"，它会自动帮你创建 `fix/login-timeout` 分支。

---

## 第二部分：提交信息规范化

### Conventional Commits

Claude Code 生成的提交信息默认遵循 Conventional Commits 规范：

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**常见 type：**

| type | 用途 | 示例 |
|------|------|------|
| feat | 新功能 | `feat(auth): add JWT token refresh` |
| fix | 修 bug | `fix(api): handle null response from upstream` |
| docs | 文档 | `docs: update README installation steps` |
| refactor | 重构 | `refactor(utils): extract date formatter` |
| test | 测试 | `test(auth): add login flow integration tests` |
| chore | 杂项 | `chore: upgrade dependencies` |

### 让 Claude 写提交信息

当你完成一段工作后，直接说：

```
> 帮我提交当前的修改
```

Claude 会自动：
1. 运行 `git diff` 查看所有变更
2. 分析变更内容
3. 生成符合规范的提交信息
4. 执行 `git add` + `git commit`

**实际效果**：你改了 5 个文件，Claude 会生成这样的提交：

```
feat(dashboard): add real-time data refresh and chart tooltips

- Implement WebSocket connection for live data
- Add tooltip component for chart interactions
- Update dashboard layout with responsive grid
- Add loading skeleton for initial data fetch
```

### 拆分提交

有时候一个改动涉及多个关注点，Claude 可以帮你拆分：

```
> 我改了登录功能和相关的测试，帮我拆成两个提交
```

Claude 会分别 `git add` 相关文件，生成两个独立提交。

---

## 第三部分：代码审查

### 用 Claude 做 Pre-review

提交 PR 前，让 Claude 先审查一遍：

```
> 审查一下我当前的改动，看看有没有问题
```

Claude 会检查：
- 潜在的 bug 和边界情况
- 安全问题（SQL 注入、XSS 等）
- 代码风格和一致性
- 遗漏的错误处理
- 性能问题

### 审查 PR 评论

收到 PR 评论后，可以让 Claude 帮你处理：

```
> PR 里有人评论说这个函数应该加缓存，帮我改一下
```

### 使用 /review 命令

Claude Code 内置了代码审查能力：

```
> /review
```

这会对当前分支相对于 main 的所有改动进行系统审查。

---

## 第四部分：冲突解决

合并冲突是 Git 最让人头疼的部分，但 Claude Code 处理得很好。

### 场景：合并 main 到 feature 分支

```
> 帮我把 main 的最新改动合并到我的分支
```

Claude 执行流程：
1. `git fetch origin main`
2. `git merge origin/main`
3. 如果有冲突 → 分析双方意图 → 自动解决 → 标记为已解决
4. `git commit` 完成合并

### 冲突解决策略

Claude 面对冲突时的判断逻辑：

| 冲突类型 | 策略 | 示例 |
|----------|------|------|
| 一方改动，一方未动 | 保留改动方 | main 改了函数名，你没动 → 用新名字 |
| 双方都改了同一行 | 合并双方意图 | 你加了参数校验，main 改了变量名 → 用新名字 + 校验 |
| 一方删除一方修改 | 询问你 | 你删了函数，main 修改了它 → 需要你决定 |

**重要**：遇到不确定的冲突，Claude 会**停下来问你**，而不是盲目合并。这是安全设计。

---

## 第五部分：回滚操作

### 撤销最近一次提交

```
> 我刚才的提交有问题，帮我撤销但保留改动
```

Claude 执行：`git reset --soft HEAD~1`

### 回到特定版本

```
> 帮我回到昨天下午的状态
```

Claude 会先 `git log --oneline` 列出最近的提交，让你确认后执行 `git reset --soft <hash>`。

### 撤销某个文件的改动

```
> 把 config.json 恢复到上次提交的状态
```

Claude 执行：`git checkout HEAD -- config.json`

**安全机制**：Claude 默认使用 `--soft` 而非 `--hard`，避免丢失未提交的工作。

---

## 第六部分：完整工作流演示

下面是一个完整的 feature 开发流程：

```
# 1. 开始新功能
> 从 main 创建 feature/export-pdf 分支

# 2. 编写代码
> 帮我实现 PDF 导出功能，支持表格和图表

# 3. 提交
> 提交当前修改

# 4. 审查
> 审查一下我的改动

# 5. 修复审查发现的问题
> 刚才审查说错误处理不够，帮我补上

# 6. 再次提交
> 提交修复

# 7. 合并 main
> 把 main 合并进来，确保没有冲突

# 8. 推送并创建 PR
> 推送分支并创建 PR，标题"feat: PDF 导出功能"
```

全程你只需要**用自然语言描述意图**，Claude Code 处理所有 Git 操作。

---

## 常见问题

### Q: Claude 会不会误操作？

Claude Code 遵循"安全第一"原则：
- 不主动 `push --force`
- 不主动 `reset --hard`
- 涉及不可逆操作会先问你
- 提交前会展示 `git diff` 供确认

### Q: 提交信息不够准确怎么办？

你可以直接修正：

```
> 重新写提交信息，重点提一下我优化了查询性能
```

Claude 会用 `git commit --amend` 修改最后一次提交（注意：只在尚未 push 时使用）。

### Q: 多人协作时需要注意什么？

1. 频繁 `git pull` 保持同步
2. 提交前让 Claude 审查
3. PR 描述写清楚改动意图
4. 合并前让 Claude 检查冲突

---

## 总结

| 操作 | 传统方式 | Claude Code 方式 |
|------|----------|------------------|
| 创建分支 | 手动敲命令 | 自然语言描述 |
| 写提交信息 | 纠结措辞 | 自动分析 diff 生成 |
| 代码审查 | 自己检查 | AI 系统审查 |
| 解决冲突 | 手动编辑 <<< >>> | 自动合并 + 不确定时询问 |
| 回滚 | 查文档找命令 | 自然语言描述意图 |

核心思想：**你负责决定做什么，Claude 负责怎么做**。
