---
date: '2026-04-28T19:11:38+08:00'
draft: false
title: 'CC-Switch 配置指南：接入 Kimi/GLM 等国内模型'
description: '详细步骤教你如何用 CC-Switch 让 Claude Code 使用国内大模型，解决网络问题'
tags: ['claude-code', 'cc-switch', 'kimi', '配置']
categories: ['教程']
---

## 为什么要用 CC-Switch？

Claude Code 默认连接 Anthropic 官方 API，在国内访问可能遇到：
- 网络不稳定
- 响应速度慢
- 偶尔无法连接

**CC-Switch 是解决这个问题的神器**——它让 Claude Code 可以无缝切换到国内大模型（Kimi、GLM、通义千问等），速度快、稳定性高。

## 前置准备

1. **Claude Code 已安装**（见[入门指南](/tutorials/claude-code-intro/)）
2. **有火山引擎/智谱AI/阿里云的 API Key**

## 安装 CC-Switch

```bash
# 全局安装
npm install -g cc-switch

# 验证安装
cc-switch --version
```

## 配置 Kimi 模型（推荐）

### 1. 获取 API Key

登录 [火山引擎](https://console.volcengine.com/) → 创建接入点 → 复制 API Key

### 2. 配置环境变量

```bash
# 添加到 ~/.zshrc 或 ~/.bashrc
export ANTHROPIC_BASE_URL="https://ark.cn-beijing.volces.com/api/coding"
export ANTHROPIC_AUTH_TOKEN="你的API-Key"
export ANTHROPIC_MODEL="Kimi-K2.5"
```

### 3. 应用配置

```bash
source ~/.zshrc

# 验证
claude
```

如果看到 Claude Code 正常启动，并且回复内容来自 Kimi，说明配置成功！

## 配置 GLM 模型（备选）

```bash
# 智谱 AI
export ANTHROPIC_BASE_URL="https://open.bigmodel.cn/api/paas/v4"
export ANTHROPIC_AUTH_TOKEN="你的GLM-API-Key"
export ANTHROPIC_MODEL="GLM-4"
```

## 切换模型

```bash
# 查看可用模型
cc-switch list

# 切换到 Kimi
cc-switch use kimi

# 切换到 GLM
cc-switch use glm

# 切换回官方
cc-switch use anthropic
```

## 常见问题

### Q1: 提示 "API Key 无效"
- 检查 Key 是否复制完整（不要有多余空格）
- 确认 Key 有对应模型的调用权限

### Q2: 提示 "模型不支持"
- 检查 `ANTHROPIC_MODEL` 是否设置正确
- 某些模型不支持图片输入，纯文本任务可忽略

### Q3: 响应很慢
- 检查网络连接
- 尝试切换其他模型或地区节点

## 进阶配置

### 自动切换（根据任务类型）

```json
// ~/.claude/settings.json
{
  "env": {
    "ANTHROPIC_MODEL": "Kimi-K2.5",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "Kimi-K2.5",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "Kimi-K2.5"
  }
}
```

### 多模型备份

配置多个 API Key，当一个失效时自动切换：

```bash
export ANTHROPIC_AUTH_TOKEN="主Key,备用Key1,备用Key2"
```

## 总结

CC-Switch 让 Claude Code 在国内也能流畅使用，是提升效率的关键一步。

配置好后，你就可以享受：
- ⚡ 极速响应
- 🌐 稳定连接
- 💰 更低成本（国内模型通常更便宜）

---

*下一篇：《OpenClaw 配置指南：搭建微信 AI 机器人》*
