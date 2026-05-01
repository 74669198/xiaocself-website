# 小c的自我修养 — 内容扩充计划

**当前状态**: 7 篇 / **目标**: 20 篇 / **缺口**: 13 篇

## 已有内容（7 篇）

| # | 标题 | 分类 |
|---|------|------|
| 1 | Claude Code 入门指南：从零开始 | 教程 |
| 2 | CC-Switch 配置指南：接入 Kimi/GLM 等国内模型 | 教程 |
| 3 | Claude Code Hooks 配置实战 | 教程 |
| 4 | Claude Code 高效使用技巧 | 教程 |
| 5 | 实战：Claude Code + OpenClaw + 微信机器人完整搭建 | 案例 |
| 6 | 本站建设实录：从 0 到上线 | 案例 |
| 7 | Hugo 建站速查表 | 工具 |

---

## 待完成 Issues（13 篇）

### 教程类（4 篇）

#### Issue #1: 教程 — Claude Code Settings 完全指南
**Objective:** 系统讲解 settings.json 的完整配置项，包括权限、环境变量、模型选择、Attribution
**Acceptance Criteria:**
- [ ] 解释三级配置文件的加载顺序和覆盖规则
- [ ] 列出 permissions.allow/deny/ask 的语法和常见配置
- [ ] 展示 env、model、attribution 等常用配置项
- [ ] 提供一个通用项目模板
**Effort:** M
**Files:** `content/tutorials/claude-code-settings.md`
**Depends on:** None

#### Issue #2: 教程 — Claude Code Git 工作流最佳实践
**Objective:** 讲解如何用 Claude Code 高效管理 Git 分支、提交、PR
**Acceptance Criteria:**
- [ ] 分支策略：feature → main 的工作流
- [ ] 如何生成规范的提交信息
- [ ] 如何用 Claude 做代码审查（requesting-code-review skill）
- [ ] 冲突解决和回滚操作
**Effort:** M
**Files:** `content/tutorials/claude-code-git-workflow.md`
**Depends on:** None

#### Issue #3: 教程 — Claude Code 多项目管理实战
**Objective:** 讲解如何用 Claude Code 同时管理多个项目，避免上下文混乱
**Acceptance Criteria:**
- [ ] 项目级 settings.json 配置
- [ ] 工作区切换技巧
- [ ] 用 git worktree 隔离不同分支
- [ ] 会话管理和 /compact 的最佳实践
**Effort:** S
**Files:** `content/tutorials/claude-code-multi-project.md`
**Depends on:** None

#### Issue #4: 教程 — SEO 优化完全指南（ Hugo 站点）
**Objective:** 为 Hugo 静态站配置完整的 SEO 基础设施
**Acceptance Criteria:**
- [ ] 配置 sitemap.xml 和 robots.txt
- [ ] 完善每篇文章的 meta 标签（title, description, og:image）
- [ ] 添加结构化数据（JSON-LD）
- [ ] 配置 Google Search Console 和 Bing Webmaster
**Effort:** M
**Files:** `content/tutorials/hugo-seo-guide.md`, 可能需要修改 `hugo.toml`
**Depends on:** None

### 案例类（5 篇）

#### Issue #5: 案例 — 运营报备系统自动化搭建实录
**Objective:** 记录用 Claude Code 搭建人员管理、工资核算、费用审批系统的完整过程
**Acceptance Criteria:**
- [ ] 项目背景和需求分析
- [ ] 技术选型和架构设计
- [ ] 核心功能实现过程（Claude 辅助）
- [ ] 踩坑记录和解决方案
- [ ] 最终效果和效率提升数据
**Effort:** L
**Files:** `content/cases/ops-report-system.md`
**Depends on:** None

#### Issue #6: 案例 — 本站从 7 篇到 20 篇的内容运营实录
**Objective:** 记录网站内容扩充的完整过程，包括选题、写作、发布的流水线
**Acceptance Criteria:**
- [ ] 选题策略：如何确定写什么
- [ ] 写作流水线：Claude 辅助写作的效率提升
- [ ] SEO 和流量数据追踪
- [ ] 用户反馈和内容迭代
**Effort:** M
**Files:** `content/cases/content-growth-log.md`
**Depends on:** Issue #4 (SEO 基础先搭好)

#### Issue #7: 案例 — 微信机器人：从搭建到日常运维
**Objective:** 深入记录微信机器人的长期运维经验，不仅是搭建
**Acceptance Criteria:**
- [ ] 搭建过程简要回顾
- [ ] 日常运维：监控、日志、异常处理
- [ ] 功能迭代：如何添加新指令
- [ ] 封号风险和规避策略
**Effort:** M
**Files:** `content/cases/wechat-bot-ops.md`
**Depends on:** None

#### Issue #8: 案例 — 数据分析实战：用 Claude Code 处理 Excel/CSV
**Objective:** 展示用 Claude Code + Python 做数据分析的完整流程
**Acceptance Criteria:**
- [ ] 数据清洗：处理脏数据、缺失值
- [ ] 数据可视化：生成图表
- [ ] 自动化报表：定时生成并发送
- [ ] 实际业务场景（比如工资数据分析）
**Effort:** M
**Files:** `content/cases/data-analysis-claude.md`
**Depends on:** None

#### Issue #9: 案例 — Google AdSense 申请与接入实录
**Objective:** 记录从申请到接入 AdSense 的完整流程
**Acceptance Criteria:**
- [ ] AdSense 申请条件和准备
- [ ] 网站内容审核注意事项
- [ ] 广告位配置和样式调整
- [ ] 收入数据追踪和优化
**Effort:** L
**Files:** `content/cases/adsense-setup.md`
**Depends on:** Issue #4 (网站需要先有一定内容和 SEO)

### 工具类（3 篇）

#### Issue #10: 工具 — Claude Code 快捷键大全
**Objective:** 整理 Claude Code CLI 的所有快捷键和隐藏操作
**Acceptance Criteria:**
- [ ] 列出所有 / 命令及其用途
- [ ] 终端快捷键（Ctrl+L、上下箭头等）
- [ ] 文件引用技巧（@、Tab 补全）
- [ ] 多行输入和代码块粘贴技巧
**Effort:** S
**Files:** `content/tools/claude-shortcuts.md`
**Depends on:** None

#### Issue #11: 工具 — Claude Code MCP 配置指南
**Objective:** 讲解 MCP（Model Context Protocol）的概念和配置方法
**Acceptance Criteria:**
- [ ] 什么是 MCP，为什么要用
- [ ] 常用 MCP Server 推荐（文件系统、浏览器、数据库）
- [ ] 配置步骤和常见问题
- [ ] 国内网络环境下的替代方案
**Effort:** M
**Files:** `content/tools/claude-mcp-guide.md`
**Depends on:** None

#### Issue #12: 工具 — AI 工具对比：Claude Code vs Cursor vs GitHub Copilot
**Objective:** 横向对比三大 AI 编程工具，帮助读者选择
**Acceptance Criteria:**
- [ ] 功能对比表（代码补全、Agent 模式、终端集成等）
- [ ] 适用场景分析
- [ ] 价格和性价比
- [ ] 个人主观推荐和使用建议
**Effort:** M
**Files:** `content/tools/ai-tools-compare.md`
**Depends on:** None

### 关于类（1 篇）

#### Issue #13: 关于 — 我的 Claude Code 故事：从怀疑到离不开
**Objective:** 写一篇个人叙事文章，增强网站人情味和信任感
**Acceptance Criteria:**
- [ ] 第一次接触 Claude Code 的经历
- [ ] 早期遇到的困难和怀疑
- [ ] 某个"顿悟时刻"：什么场景让我彻底信任它
- [ ] 现在每天的工作流和依赖程度
- [ ] 给新手的真诚建议
**Effort:** M
**Files:** `content/about/my-claude-story.md`
**Depends on:** None

---

## 里程碑规划

| 里程碑 | 目标 | 时间 |
|--------|------|------|
| Milestone 1: 基础设施 | 完成 Issue #4 (SEO) + Issue #10 (快捷键) | 1 周内 |
| Milestone 2: 教程补完 | 完成 Issue #1~#3 (Settings/Git/多项目) | 2 周内 |
| Milestone 3: 案例爆发 | 完成 Issue #5~#8 (运营/内容/机器人/数据分析) | 3 周内 |
| Milestone 4: 商业化 | 完成 Issue #9 (AdSense) + Issue #11~#13 | 4 周内 |
