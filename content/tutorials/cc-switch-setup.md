---
date: '2026-04-28T19:11:38+08:00'
draft: false
title: 'CC-Switch 配置指南：接入 Kimi/GLM 等国内模型'
description: 'Claude Code 国内网络不稳定？CC-Switch 让你无缝切换 Kimi、GLM 等国内模型，速度提升 5 倍+'
tags: ['claude-code', 'cc-switch', 'kimi', '配置']
categories: ['教程']
---

## 为什么需要 CC-Switch？

Claude Code 默认直连 Anthropic 官方 API。在国内使用时，你可能会遇到：

| 问题 | 表现 | 频率 |
|------|------|------|
| 连接超时 | 输入指令后卡 30 秒无响应 | 高频 |
| 响应慢 | 简单问题也要等 5-10 秒 | 高频 |
| 请求失败 | 报错 "Connection reset by peer" | 中频 |
| 夜间不可用 | 晚 8 点后基本连不上 | 中频 |

**CC-Switch 的原理**：它在 Claude Code 和模型之间加了一层代理，把请求转发到国内模型服务商（火山引擎、智谱 AI 等）。由于服务器在国内，延迟从 200ms+ 降到 50ms 以内。

## 准备工作

### 你必须已有

1. **Claude Code 已安装并能运行**（不会装先看 [入门指南](/tutorials/claude-code-intro/)）
2. **一个国内模型平台的账号和 API Key**

### 支持的模型平台

| 平台 | 推荐模型 | 注册地址 | 新用户优惠 |
|------|---------|---------|-----------|
| 火山引擎 | Kimi-K2.5 | [console.volcengine.com](https://console.volcengine.com) | 50 万 token 免费额度 |
| 智谱 AI | GLM-4 | [open.bigmodel.cn](https://open.bigmodel.cn) | 100 万 token 免费额度 |
| 阿里云 | 通义千问 | [dashscope.aliyun.com](https://dashscope.aliyun.com) | 100 万 token 免费额度 |

**推荐选择火山引擎 Kimi**：速度快、价格便宜、兼容性好。

## 第一步：获取 API Key

以火山引擎为例：

1. 注册/登录 [火山引擎](https://console.volcengine.com)
2. 进入「火山方舟」→「在线推理」
3. 创建接入点，选择 `Kimi-K2.5` 模型
4. 在「API Key 管理」中创建 Key，复制保存

**注意**：Key 只显示一次，务必保存到密码管理器或安全的地方。

## 第二步：安装 CC-Switch

```bash
# 全局安装
npm install -g cc-switch

# 验证安装
cc-switch --version
# 应输出: cc-switch x.x.x
```

如果安装失败，检查 Node.js 版本：

```bash
node --version
# 需要 v18.0.0 或更高
```

## 第三步：配置环境变量

CC-Switch 通过环境变量告诉 Claude Code 把请求发到哪里。

### 配置 Kimi（推荐）

```bash
# 编辑你的 shell 配置文件
nano ~/.zshrc  # macOS/Linux
# 或 notepad $PROFILE  # Windows PowerShell
```

添加以下内容：

```bash
# CC-Switch 配置 - 火山引擎 Kimi
export ANTHROPIC_BASE_URL="https://ark.cn-beijing.volces.com/api/coding"
export ANTHROPIC_AUTH_TOKEN="sk-你的API-Key"
export ANTHROPIC_MODEL="Kimi-K2.5"
```

保存后应用配置：

```bash
source ~/.zshrc
```

### 配置 GLM（备选）

```bash
export ANTHROPIC_BASE_URL="https://open.bigmodel.cn/api/paas/v4"
export ANTHROPIC_AUTH_TOKEN="你的GLM-API-Key"
export ANTHROPIC_MODEL="GLM-4"
```

## 第四步：验证配置

```bash
# 启动 Claude Code
claude
```

进入对话后，输入：

```
> 你是谁？
```

如果配置正确，你会看到类似回复：

```
我是 Kimi，由月之暗面（Moonshot AI）开发的人工智能助手...
```

**注意**：如果仍然显示 "I am Claude, created by Anthropic"，说明配置未生效，请看下面的排错。

## 第五步：使用 CC-Switch 快捷切换

配置好环境变量后，你可以用 `cc-switch` 命令快速切换模型：

```bash
# 查看所有可用配置
cc-switch list

# 切换到 Kimi
cc-switch use kimi

# 切换到 GLM
cc-switch use glm

# 切回官方 Claude
cc-switch use anthropic

# 查看当前使用的模型
cc-switch current
```

**原理**：`cc-switch use` 本质上是修改你的 shell 环境变量，不需要重启 Claude Code，但需要新开一个终端窗口生效。

## 常见问题排错

### 问题 1：启动 Claude Code 时提示 "API Key 无效"

**排查步骤**：

1. 检查 Key 是否复制完整（不要有多余空格或换行）
2. 确认 Key 有对应模型的调用权限（火山引擎需要给 Key 绑定接入点）
3. 检查环境变量是否正确加载：
   ```bash
   echo $ANTHROPIC_AUTH_TOKEN
   # 应该输出你的 Key
   ```

### 问题 2：配置后 Claude 仍回答 "I am Claude"

**原因**：Claude Code 缓存了之前的连接配置。

**解决**：

```bash
# 退出 Claude Code
exit

# 清除环境变量缓存
unset ANTHROPIC_BASE_URL
unset ANTHROPIC_AUTH_TOKEN
unset ANTHROPIC_MODEL

# 重新加载配置
source ~/.zshrc

# 重新启动
claude
```

### 问题 3：响应还是很慢

1. **检查网络**：ping 一下火山引擎域名
   ```bash
   ping ark.cn-beijing.volces.com
   ```
2. **切换地区节点**：火山引擎支持多个地区，在控制台切换离你最近的
3. **检查是否走代理**：如果你开了 VPN/代理，可能反而绕远了。国内模型不需要代理。

### 问题 4：某些功能失效（如图片理解）

国内模型对 Claude Code 的某些高级功能支持不完整：

| 功能 | Kimi 支持 | GLM 支持 | 官方 Claude |
|------|----------|---------|------------|
| 文本对话 | ✅ | ✅ | ✅ |
| 代码生成 | ✅ | ✅ | ✅ |
| 文件读取 | ✅ | ✅ | ✅ |
| 图片理解 | ⚠️ 部分 | ⚠️ 部分 | ✅ |
| 长文本（200K）| ✅ | ⚠️ | ✅ |

如果需要图片理解功能，建议临时切回官方：

```bash
cc-switch use anthropic
# 用完再切回来
cc-switch use kimi
```

## 进阶：项目级隔离配置

如果你在不同项目想用不同模型，可以在项目根目录创建 `.claude/settings.json`：

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://ark.cn-beijing.volces.com/api/coding",
    "ANTHROPIC_AUTH_TOKEN": "sk-项目专用Key",
    "ANTHROPIC_MODEL": "Kimi-K2.5"
  }
}
```

在这个项目里启动 `claude`，会自动使用项目级配置，不影响其他项目。

## 费用参考

以 Kimi-K2.5 为例（2026 年 5 月价格）：

| 场景 | Token 消耗 | 单次成本 |
|------|-----------|---------|
| 简单问答 | 1K-2K | ~￥0.003 |
| 代码重构（小文件）| 5K-10K | ~￥0.015 |
| 代码重构（多文件）| 20K-50K | ~￥0.08 |
| 复杂项目分析 | 50K-100K | ~￥0.15 |

**新用户免费额度通常够用 1-2 个月**，之后按量付费，轻度使用每月约 ￥5-20。

## 总结

配置 CC-Switch 后，Claude Code 的使用体验会有质变：

- ⚡ 响应速度从 5-10 秒降到 1-2 秒
- 🌐 不再担心网络波动
- 💰 成本比官方 API 低 30-50%

花 10 分钟配置好，后续几个月都省心。

---

**下一步**：配置好后，建议阅读 [Claude Code 高效使用技巧](/tutorials/claude-code-tips/)，掌握让效率再翻倍的 10 个技巧。

*最后更新：2026-05-03 | 价格和接口信息可能变动，请以各平台官方文档为准*
