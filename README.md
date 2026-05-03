# 小c的自我修养

> AI 工具实战经验分享 | Claude Code、Kimi、自动化工作流 | 让每个人都能用好 AI

**网站地址**: [www.xiaocself.top](https://www.xiaocself.top)

## 关于本站

这里记录我与 Claude Code 的故事——从入门到精通，从配置到实战。目标是让每个人都能用好 AI 工具，提升10倍效率。

## 技术栈

| 组件 | 选型 |
|------|------|
| 静态生成器 | [Hugo](https://gohugo.io/) |
| 主题 | [PaperMod](https://github.com/adityatelange/hugo-PaperMod)（深度定制） |
| 托管 | [Cloudflare Pages](https://pages.cloudflare.com/) |
| 域名 | 阿里云（NS 转至 Cloudflare） |
| 统计 | Google Analytics 4 |

## 内容结构

```
content/
├── tutorials/   # 教程（9篇）— Claude Code 系统性学习资源
├── cases/       # 案例（7篇）— 真实项目实战记录
├── tools/       # 工具（4篇）— AI 工具配置与使用技巧
└── about/       # 关于（2篇）— 个人故事
```

## 本地运行

```bash
# 克隆仓库
git clone https://github.com/74669198/xiaocself-website.git
cd xiaocself-website

# 初始化主题子模块
git submodule update --init --recursive

# 启动开发服务器
hugo server -D
```

访问 http://localhost:1313

## 部署

推送到 `main` 分支后，Cloudflare Pages 自动构建部署。

构建命令：`hugo --minify`  
输出目录：`public`

## 定制化

- **品牌色**：天空蓝 `#0ea5e9` + 琥珀橙 `#f59e0b`
- **自定义 CSS**：`assets/css/extended/custom.css`
- **自定义布局**：`layouts/partials/`（hero、footer、featured 等6个独立 partial）

## License

内容采用 [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/) 协议。
