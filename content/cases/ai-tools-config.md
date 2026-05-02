---
date: '2026-04-28T19:11:38+08:00'
draft: false
title: '实战：Claude Code + OpenClaw + 微信机器人完整搭建'
description: '从零开始搭建 AI 微信机器人的完整流程记录，包含 6 次踩坑、真实成本数据和最终优化方案'
tags: ['claude-code', 'openclaw', '微信机器人', '实战']
categories: ['案例']
---

## 项目背景

**需求**：每天工作中有大量重复性咨询（工资查询、流程确认、数据核对），希望用 AI 自动回复，释放人力。

**约束条件**：
- 必须用手机就能交互（员工不一定有电脑）
- 成本不能太高（团队预算有限）
- 部署要简单（没有专职运维）
- 响应速度要快（等 10 秒以上就没人用了）

**最终方案**：微信机器人 + OpenClaw 网关 + Claude Code（Kimi 模型）

## 整体架构

```
用户微信消息
    ↓
微信机器人插件（OpenClaw WeChat Plugin）
    ↓
OpenClaw 网关（本地运行）
    ↓
Claude Code → Kimi 模型推理
    ↓
返回结果 → 微信回复
```

**为什么选这套方案**：
- 微信：用户零学习成本，所有人都有
- OpenClaw：开源免费，插件生态成熟
- Claude Code：指令遵循能力强，适合处理结构化任务
- Kimi：国内速度快，价格便宜

## 实施时间线

| 阶段 | 耗时 | 主要工作 |
|------|------|---------|
| 方案调研 | 2 小时 | 对比了 5 种方案，最终选定 OpenClaw |
| 环境搭建 | 1.5 小时 | 安装 Node.js、配置 API Key |
| 网关配置 | 2 小时 | 踩坑 3 次才配通（见下文） |
| 微信绑定 | 1 小时 | 扫码登录 + 测试消息收发 |
| 指令调优 | 3 小时 | 让 AI 回复符合业务规范 |
| **总计** | **约 9.5 小时** | 分两天完成 |

## 详细实施步骤

### Step 1：安装 Claude Code

参考 [入门指南](/tutorials/claude-code-intro/)，macOS 用户直接：

```bash
brew install claude-code
claude --version
```

**注意**：Windows 用户建议用 WSL2，原生 Windows 的终端交互体验较差。

### Step 2：配置 CC-Switch（接入 Kimi）

```bash
npm install -g cc-switch

# 配置环境变量（添加到 ~/.zshrc）
export ANTHROPIC_BASE_URL="https://ark.cn-beijing.volces.com/api/coding"
export ANTHROPIC_AUTH_TOKEN="sk-xxxxxxxx"
export ANTHROPIC_MODEL="Kimi-K2.5"

source ~/.zshrc
```

验证配置：

```bash
claude
# 进入后输入：你是谁？
# 正确回复应包含 "Kimi"，而非 "Claude"
```

### Step 3：安装 OpenClaw

```bash
npm install -g openclaw

# 验证
openclaw --version
# 输出：openclaw 0.x.x
```

### Step 4：配置 OpenClaw 网关

创建配置文件 `~/.openclaw/openclaw.json`：

```json
{
  "gateway": {
    "mode": "local",
    "port": 18789,
    "auth": {
      "mode": "token",
      "token": "自定义一个复杂令牌"
    }
  },
  "models": {
    "mode": "merge",
    "providers": {
      "volcengine": {
        "baseUrl": "https://ark.cn-beijing.volces.com/api/coding",
        "apiKey": "你的火山引擎 API Key",
        "api": "anthropic-messages",
        "models": [
          {
            "id": "Kimi-K2.5",
            "name": "Kimi-K2.5"
          }
        ]
      }
    }
  },
  "plugins": {
    "entries": {
      "openclaw-weixin": {
        "enabled": true,
        "config": {
          "autoAcceptFriend": false,
          "replyInterval": 1000
        }
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

**配置要点**：
- `port` 不要和系统其他服务冲突（可用 `lsof -i:18789` 检查）
- `token` 要足够复杂，这是网关的安全密钥
- `replyInterval` 控制回复间隔，防止触发微信风控

### Step 5：安装微信插件并绑定

```bash
# 安装插件
openclaw plugin install @tencent-weixin/openclaw-weixin

# 启动 ClawX 桌面版（带 GUI，比 CLI 更稳定）
open /Applications/ClawX.app
```

在 ClawX 界面中：
1. 进入「插件管理」→ 启用微信插件
2. 点击「扫码登录」→ 用手机微信扫码
3. 登录成功后，测试发送一条消息给自己

### Step 6：配置 AI 回复规则

默认情况下，AI 会回复所有消息。这很危险——你的微信好友发消息，AI 也会自动回复。

**必须配置白名单**：

编辑微信插件配置，添加 `allowedUsers`：

```json
{
  "allowedUsers": [
    "微信号1",
    "微信号2"
  ],
  "defaultReply": "您好，我是AI助手。如需帮助请联系管理员。"
}
```

## 踩坑记录（6次失败才成功）

### 坑 1：网关启动失败，提示端口被占用

**现象**：
```
Error: listen EADDRINUSE: address already in use :::18789
```

**排查**：
```bash
lsof -i:18789
# 发现之前未正常关闭的 openclaw 进程还在运行
```

**解决**：
```bash
killall openclaw
# 或者换端口：把配置里的 18789 改成 18889
```

**教训**：每次调试完用 `Ctrl+C` 正常退出，不要直接关终端。

### 坑 2：Kimi 模型返回乱码

**现象**：AI 回复全是 "����" 乱码，或中英文混杂的无意义内容。

**原因**：火山引擎的 `anthropic-messages` API 对消息格式要求严格，少一个字段就崩溃。

**解决**：升级 openclaw 到最新版（0.3.2+修复了这个问题）。

```bash
npm update -g openclaw
```

### 坑 3：微信消息能发不能收

**现象**：从微信发消息，OpenClaw 日志显示收到，但 AI 没有回复。

**排查过程**：
1. 检查 OpenClaw 日志 → 显示 "message received"
2. 检查 Claude Code 日志 → 显示 "waiting for response"
3. 检查 Kimi API 状态 → 返回 429（请求过多）

**原因**：新注册的火山引擎账号默认有 QPS 限制（每秒 1 次），微信消息并发时触发限流。

**解决**：
- 短期：在 OpenClaw 配置中增加 `replyInterval: 2000`（2秒间隔）
- 长期：在火山引擎控制台申请提升配额

### 坑 4：AI 回复太啰嗦

**现象**：用户问"今天工资发了吗"，AI 回复 300 字，把工资计算逻辑全讲了一遍。

**解决**：在 Claude Code 的 `~/.claude/settings.json` 中添加系统提示：

```json
{
  "env": {
    "CLAUDE_SYSTEM_PROMPT": "你是企业客服助手。回复要求：1. 简洁，不超过50字；2. 不知道的直接说不知道；3. 不要解释原理。"
  }
}
```

### 坑 5：ClawX 自动退出

**现象**：ClawX 运行几小时后突然退出，微信机器人掉线。

**原因**：macOS 的 App Nap 功能会在后台应用闲置时暂停其运行。

**解决**：
```bash
# 对 ClawX 禁用 App Nap
caffeinate -i /Applications/ClawX.app/Contents/MacOS/ClawX
```

或者用 `pm2` 持久化运行 CLI 版本：

```bash
npm install -g pm2
pm2 start openclaw -- gateway start
pm2 save
pm2 startup
```

### 坑 6：API 账单暴涨

**现象**：第二天收到火山引擎账单通知，一晚花了 80 多元。

**原因**：测试阶段忘记限制白名单，AI 回复了一个群聊里的几百条消息。

**解决**：
1. 立即配置 `allowedUsers` 白名单
2. 在火山引擎控制台设置每日消费上限（建议 20 元）
3. 开启用量告警（超过 10 元发邮件通知）

## 最终效果与数据

**运行数据**（上线 30 天）：

| 指标 | 数值 |
|------|------|
| 日均消息量 | 120-150 条 |
| 平均响应时间 | 2.8 秒 |
| 准确率（用户满意度） | 约 85% |
| 需要人工介入的比例 | 约 15% |
| 系统稳定性（无故障运行） | 28/30 天 |

**节省的人力**：
- 之前：1 人专职处理重复咨询（月薪 4000）
- 现在：AI 处理 85%，人工只处理复杂问题（占用 0.2 人）
- **每月节省约 3200 元**

## 真实成本（第一个月）

| 项目 | 费用 | 说明 |
|------|------|------|
| Kimi API | ￥47 | 约 95 万 token |
| OpenClaw | 免费 | 开源工具 |
| ClawX | 免费 | 开源工具 |
| Claude Code | 免费 | 客户端免费 |
| 服务器 | 0 元 | 跑在个人 Mac 上 |
| **首月总计** | **￥47** | 远低于预期 |

第二个月优化后（限制白名单 + 缩短上下文）：**￥23**

## 仍然存在的问题

1. **微信群消息处理不稳定**：微信群消息偶尔收不到，私聊更可靠
2. **多轮上下文消耗大**：长对话的 token 消耗是单轮的 5-8 倍
3. **Claude Code 重启后需重新登录**：每次重启电脑要重新 `claude login`
4. **手机端无法查看 AI 的思考过程**：只能看到最终回复，不知道它怎么想的

## 下一步优化计划

| 优先级 | 优化项 | 预期效果 |
|--------|--------|---------|
| P0 | 接入语音输入/输出 | 方便不识字员工使用 |
| P1 | 开发定制化 Skills | 自动查工资、查考勤 |
| P2 | 接入更多模型备用 | GPT-4 作为 Kimi 的 fallback |
| P3 | 部署到云端服务器 | 不再需要本地 Mac 24 小时开机 |

## 给后来者的建议

1. **先配通再走**：每个组件单独验证，不要一次性全装完再调试
2. **白名单必须配**：否则 API 账单可能失控
3. **设置消费上限**：所有云平台都要设，这是血泪教训
4. **别追求 100% 自动化**：85% 的准确率已经能节省大量人力，剩下的 15% 人工处理更稳妥
5. **做好日志记录**：OpenClaw 和 Claude Code 的日志是排障的唯一线索

---

**项目状态**：已上线运行，稳定服务中  
**维护成本**：每月约 30 元 API 费用 + 偶尔调优 1-2 小时  
**投资回报**：首月即收回成本（节省人力 3200 元 vs 成本 47 元）

*如果你有类似需求，可以参考这个案例。具体配置细节因环境而异，有问题建议查看 OpenClaw 官方文档或社区 Issue。*
