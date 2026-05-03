---
date: '2026-04-28T20:30:00+08:00'
draft: false
title: 'Hugo 建站速查表：常用命令与配置'
description: '整理 Hugo 静态网站生成器的常用命令、目录结构和配置技巧，方便快速查阅'
tags: ['hugo', '建站', '工具']
categories: ['工具']
---

用 Hugo 建站时总要翻文档？这份速查表整理了最常用的命令、目录结构和配置片段，收藏备用。

## 常用命令

```bash
# 新建站点
hugo new site myblog
cd myblog
git init

# 添加主题
git submodule add https://github.com/adityatelange/hugo-PaperMod.git themes/PaperMod
# 或者手动下载到 themes/ 目录

# 新建文章
hugo new content posts/hello.md

# 本地预览
hugo server -D

# 构建（生成 public/ 目录）
hugo --minify
```

## 目录结构

```
.
├── archetypes/      # 文章模板
├── assets/          # 需要处理的资源（SCSS、JS）
├── content/         # 网站内容
├── data/            # 数据文件（JSON/YAML/TOML）
├── layouts/         # HTML 模板
├── static/          # 静态文件（直接复制到输出）
├── themes/          # 主题
└── hugo.toml        # 站点配置
```

## 文章 Front Matter 模板

```yaml
---
date: '2026-04-28T12:00:00+08:00'
draft: false
title: '文章标题'
description: '文章描述，用于 SEO'
tags: ['标签1', '标签2']
categories: ['分类']
---
```

## 部署到 Cloudflare Pages

1. 代码推送到 GitHub
2. Cloudflare Pages 关联仓库
3. 构建命令：`hugo --minify`
4. 输出目录：`public`
5. 环境变量：`HUGO_VERSION=0.160.1`

---

*持续更新中，欢迎收藏备用。*
