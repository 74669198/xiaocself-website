---
date: '2026-04-28T19:11:38+08:00'
draft: false
title: '实战：Claude Code + OpenClaw + 微信机器人完整搭建'
description: '从零开始搭建 Claude Code + OpenClaw + 微信机器人的完整流程记录'
tags: ['claude-code', 'openclaw', '微信机器人', '实战']
categories: ['案例']
---

## 项目背景

我一直想用 AI 辅助日常工作，但希望能随时随地（尤其是手机上）与 AI 交互。最终目标是：**微信里发消息，AI 秒回**。

经过调研，选择了这套方案：
- **Claude Code**：AI 大脑，处理复杂任务
- **OpenClaw**：网关中间件，连接多个 AI 服务
- **微信机器人**：接收和发送消息

## 整体架构

```
微信消息 → 微信机器人插件 → OpenClaw 网关 → Claude Code (Kimi 模型) → 返回结果 → 微信回复
```

## 实施步骤

### Step 1：安装 Claude Code

见[入门指南](/tutorials/claude-code-intro/)，这里不再赘述。

### Step 2：配置 CC-Switch

使用火山引擎 Kimi 模型，配置环境变量：

```bash
export ANTHROPIC_BASE_URL="https://ark.cn-beijing.volces.com/api/coding"
export ANTHROPIC_AUTH_TOKEN="你的API-Key"
export ANTHROPIC_MODEL="Kimi-K2.5"
```

### Step 3：安装 OpenClaw

```bash
# 通过 npm 安装
npm install -g openclaw

# 验证
openclaw --version
```

### Step 4：配置 OpenClaw

编辑 `~/.openclaw/openclaw.json`：

```json
{
  "gateway": {
    "mode": "local",
    "auth": {
      "mode": "token",
      "token": "你的网关令牌"
    }
  },
  "models": {
    "mode": "merge",
    "providers": {
      "doubaoseed": {
        "baseUrl": "https://ark.cn-beijing.volces.com/api/coding",
        "apiKey": "你的API-Key",
        "api": "anthropic-messages",
        "models": [
          {
            "id": "ark-code-latest",
            "name": "ark-code-latest"
          }
        ]
      }
    }
  },
  "plugins": {
    "entries": {
      "openclaw-weixin": {
        "enabled": true
      }
    }
  },
  "bindings": [
    {
      "agentId": "main",
      "match": {
        "channel": "openclaw-weixin"
      }
    }
  ]
}
```

### Step 5：安装微信插件

```bash
openclaw plugin install @tencent-weixin/openclaw-weixin
```

### Step 6：启动服务

```bash
# 启动 OpenClaw 网关
openclaw gateway start

# 或启动 ClawX 桌面版（推荐，带 GUI）
open /Applications/ClawX.app
```

### Step 7：绑定微信

1. 打开 ClawX 控制界面
2. 进入微信插件设置
3. 扫码登录微信
4. 测试发送消息

## 遇到的问题及解决

### 问题1：网关端口冲突
**现象**：OpenClaw CLI 和 ClawX 同时尝试占用 18789 端口
**解决**：关闭 CLI 网关，只使用 ClawX 内置网关

### 问题2：Kimi 模型不支持图片
**现象**：发送图片后报错 "不支持 image_url"
**解决**：切换到纯文本模型，或暂时不发图片

### 问题3：微信机器人响应慢
**现象**：消息发送后 5-10 秒才回复
**解决**：
- 禁用自改进 Agent 功能
- 缩短会话超时时间
- 优化网络连接

## 最终效果

✅ 微信发送文字消息，AI 3秒内回复  
✅ 支持多轮对话，上下文连贯  
✅ 可以处理复杂任务（写文档、算数据、查资料）  
✅ 手机端随时可用

## 成本分析

| 项目 | 费用 |
|------|------|
| Claude Code | 免费 |
| OpenClaw | 免费 |
| 微信插件 | 免费 |
| Kimi API | 按量计费（约0.01-0.05元/千token）|
| **月均成本** | **约10-30元** |

## 下一步优化

1. 接入更多模型（GPT-4、Claude 3 等）
2. 增加语音输入/输出
3. 开发自定义 Skills（如自动写日报）

---

*如果你有类似需求，欢迎参考这个案例。有问题可以在评论区留言。*
