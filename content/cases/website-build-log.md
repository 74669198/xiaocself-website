---
date: '2026-04-29T20:00:00+08:00'
draft: false
title: '本站建设实录：从 0 到上线，Claude Code 全程辅助'
description: '记录小c的自我修养网站从零搭建到上线的完整过程，包含技术选型、踩坑记录和心得总结'
tags: ['claude-code', 'hugo', '建站', '实战']
categories: ['案例']
cover:
  image: '/images/build-log-cover.png'
  alt: '网站建设实录'
---

## 项目背景

我一直想有个地方记录自己和 Claude Code 的故事。不是发在朋友圈那种碎片，而是成体系的、能帮到别人的内容。

目标很明确：
- **快**：不想折腾服务器、数据库、后端
- **好看**：深色主题、有个性、不模板化
- **可维护**：更新文章像写 Markdown 一样简单
- **免费**：域名是唯一的成本

## 技术选型

### 为什么选 Hugo + PaperMod？

静态网站生成器对比了一圈：

| 方案 | 优点 | 缺点 | 结论 |
|------|------|------|------|
| Hexo | 中文文档多 | 主题老旧 | ❌ |
| Jekyll | GitHub Pages 原生支持 | 慢 | ❌ |
| Next.js | 功能强大 | 太重了 | ❌ |
| **Hugo** | **极速构建**、主题丰富 | 学习曲线略陡 | ✅ |

Hugo 构建 1000 篇文章只要 1 秒，这速度对我这种经常改来改去的人太友好了。

主题选了 PaperMod，因为它：
- 支持暗色模式
- 搜索、归档、标签页齐全
- 自定义空间足够大

### 部署方案

| 方案 | 优点 | 缺点 |
|------|------|------|
| GitHub Pages | 免费、简单 | 国内访问慢 |
| Vercel | 快、自动化 | 免费版有流量限制 |
| **Cloudflare Pages** | **全球 CDN**、免费 SSL、Git 集成 | 根域名验证有点坑 |

Cloudflare Pages 的国内访问速度比 GitHub Pages 好太多，而且免费 SSL 和全球 CDN 是标配。

## 搭建过程

### 第一阶段：基础搭建（1 小时）

用 Claude Code 帮忙初始化项目：

```bash
# 新建站点
hugo new site xiaocself
cd xiaocself

# 添加主题
git init
git submodule add https://github.com/adityatelange/hugo-PaperMod themes/PaperMod

# 配置 hugo.toml
```

Claude Code 帮我把 `hugo.toml` 配好了，包括：
- 中文语言和时区
- 菜单导航（首页、教程、案例、工具、关于）
- PaperMod 主题参数（搜索、暗色模式、社交图标）

### 第二阶段：内容填充（2 小时）

先写了 4 篇种子文章：
1. 《Claude Code 入门指南》
2. 《CC-Switch 配置指南》
3. 《AI 微信机器人搭建实录》
4. 《Hugo 建站速查表》

Claude Code 负责：
- 根据我的口述整理成 Markdown
- 检查 frontmatter 格式
- 自动推送到 GitHub

我负责：
- 确定文章结构和核心观点
- 补充真实踩坑经历
- 最终审校

### 第三阶段：主题定制（3 小时）

PaperMod 默认主题有点"小气"——720px 宽度、小字体、紧间距。我想要一个**大气、前卫、有科技感**的首页。

Claude Code 帮我重写了 `home_info.html` 和 `custom.css`，最终效果包括：

- **全屏 Hero 区域**：渐变文字、浮动光球动画、发光按钮
- **统计卡片**：文章数、案例数、工具数
- **精选内容 masonry 布局**：大图卡片 + 三张小卡片
- **分类导航**： emoji 图标 + 渐变背景
- **学习路径时间线**：4 个阶段，从入门到进阶
- **CTA 区域**：底部行动号召

关键 CSS 技巧：

```css
/* 浮动光球 */
.hero-bg::before {
  content: '';
  position: absolute;
  width: 600px; height: 600px;
  background: radial-gradient(circle, rgba(139,92,246,0.15), transparent 70%);
  animation: float 8s ease-in-out infinite;
}

/* 玻璃拟态卡片 */
.featured-card {
  background: rgba(30, 30, 40, 0.6);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(255,255,255,0.05);
}
```

### 第四阶段：部署上线（4 小时，全在踩坑）

理论上部署最简单：Git push → Cloudflare Pages 自动构建 → 完成。

实际上遇到的坑：

#### 坑 1：Git Submodule 导致构建失败

错误：`fatal: No url found for submodule path 'themes/PaperMod' in .gitmodules`

原因：`.gitmodules` 文件丢失或损坏。

解决：删除 `themes/PaperMod/.git`，把主题文件直接提交到仓库，force push。

#### 坑 2：分类页面 404

访问 `/tutorials/` 返回 404。

原因：`_index.md` 里写了 `draft = true`。

解决：改成 `draft = false`，YAML 格式。

#### 坑 3：根域名绑定 525/522 错误

这是踩得最深的坑。

Cloudflare Pages 要求根域名验证必须有 CNAME 记录，但 DNS 协议本身不允许根域名配置 CNAME。Pages 自动验证一直报 `CNAME record not set`。

尝试过的方案：
- ❌ 手动加 CNAME → DNS 规范不允许
- ❌ 加 A 记录指向 Pages IP → Pages 验证逻辑不认 A 记录
- ❌ 开启 Cloudflare 代理 → 525 SSL 握手失败（Pages 后端没有该域名的证书）
- ✅ **www 子域名绑定成功** → CNAME 验证通过，SSL 自动颁发

**最终方案**：
- 主力地址用 `https://www.xiaocself.top`
- 根域名等后续能进 Cloudflare Dashboard 后手动添加跳转规则

#### 坑 4：DNS 传播极慢

`.top` 域名从阿里云 DNS 切换到 Cloudflare NS，等了 1.5 小时才生效。`.top` 后缀的 DNS 缓存确实比 `.com` 慢不少。

## 最终架构

```
本地写作 (Markdown) 
  → Git push 
  → GitHub 
  → Cloudflare Pages (自动构建) 
  → 全球 CDN 
  → 用户浏览器
```

**成本**：
- Hugo：免费
- PaperMod 主题：免费
- GitHub：免费
- Cloudflare Pages：免费
- 域名 `xiaocself.top`：¥29/年

**总计：29 元/年**

## 心得总结

### 1. Claude Code 在建站中的角色

它不是一个"一键生成网站"的工具，而是一个**超级协作者**：
- 你描述需求，它生成代码
- 你指出问题，它调整细节
- 你确认方向，它执行繁琐操作

最重要的不是它写了多少代码，而是**它让你敢想敢试**——因为改起来太快了。

### 2. 设计比技术更重要

技术层面（Hugo + Cloudflare Pages）半天就能跑通。但首页设计了 4 个版本才满意：
- v1：PaperMod 默认 → 太普通
- v2：加了渐变背景 → 有点土
- v3：调整了布局和间距 → 好一些
- v4：Hero 区域 + 玻璃拟态 + 动画 → 就是它了

好设计是迭代出来的，Claude Code 让迭代成本趋近于零。

### 3. 内容才是核心

网站再好看，没有内容就是空壳。目前 4 篇文章远远不够，目标是 20 篇。接下来的重点是：
- Hooks 配置实战
- 项目管理自动化
- 更多真实案例

## 写在最后

这个网站本身就是最好的案例——证明 Claude Code 不只是写代码的工具，它能帮你完成从创意到上线的全流程。

如果你也想搭一个类似的网站，欢迎在评论区交流，我可以分享完整的配置模板。
