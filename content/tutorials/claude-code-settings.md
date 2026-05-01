---
date: '2026-05-01T22:00:00+08:00'
draft: false
title: 'Claude Code Settings 完全指南'
description: '系统讲解 settings.json 的完整配置体系：三级配置加载机制、权限控制、环境变量、模型选择，以及可直接使用的项目模板'
tags: ['Claude Code', 'settings.json', '配置指南', '最佳实践']
categories: ['tutorials']
showToc: true
---

## 前言

Claude Code 的强大不仅在于它的 AI 能力，更在于它**高度可配置**的体系。通过 `settings.json`，你可以：

- 控制 Claude 能执行哪些操作（权限管理）
- 配置环境变量和 API 密钥
- 选择默认使用的模型
- 设置 Hooks 实现自动化

但官方文档对配置体系的讲解比较分散，很多用户在使用时一头雾水。

这篇文章将**系统性地讲解** Claude Code 的配置体系，从基础概念到实战模板，让你彻底掌握 `settings.json` 的用法。

---

## 第一部分：三级配置体系

Claude Code 的配置不是单一的，而是**三级叠加**的结构：

```
┌─────────────────────────────────────────────────────────┐
│  Level 1: 系统级配置                                      │
│  ~/.claude/settings.json                                 │
│  ↓ 影响所有项目                                          │
├─────────────────────────────────────────────────────────┤
│  Level 2: 项目级配置                                      │
│  /project/.claude/settings.json                          │
│  ↓ 只影响当前项目，覆盖系统级配置                          │
├─────────────────────────────────────────────────────────┤
│  Level 3: 环境变量和 CLI 参数                              │
│  CLAUDE_* 环境变量 或 `claude --flag`                     │
│  ↓ 最高优先级，覆盖所有配置文件                           │
└─────────────────────────────────────────────────────────┘
```

### 1.1 系统级配置（全局）

**位置**：`~/.claude/settings.json`

**作用范围**：所有使用 Claude Code 的项目

**适用场景**：
- 你个人的默认偏好设置
- 全局 Hooks（如所有项目都需要的操作日志）
- 常用 API 密钥的默认配置

**示例**：

```json
{
  "env": {
    "EDITOR": "code --wait",
    "CLAUDE_DEFAULT_MODEL": "claude-opus-4-7"
  },
  "hooks": {
    "pre_tool_use": [
      {
        "command": "echo \"[$(date)] {tool_name}\" >> ~/.claude/activity.log",
        "when": "always"
      }
    ]
  }
}
```

### 1.2 项目级配置（局部）

**位置**：`/your-project/.claude/settings.json`

**作用范围**：只在当前项目生效

**适用场景**：
- 项目特定的 API 密钥
- 项目特定的权限控制（如禁用某些操作）
- 覆盖全局配置的个性化设置

**示例**：

```json
{
  "env": {
    "OPENAI_API_KEY": "sk-proj-xxx",
    "DEPLOY_TARGET": "production"
  },
  "permissions": {
    "allow": [{"tool": "Bash", "command": "npm run build"}],
    "deny": [{"tool": "Bash", "command": "rm -rf /"}]
  }
}
```

### 1.3 环境变量和 CLI 参数（最高优先级）

**设置方式**：
- 环境变量：`export CLAUDE_MODEL=claude-opus-4-7`
- CLI 参数：`claude --model claude-opus-4-7`

**作用范围**：当前会话

**适用场景**：
- 临时覆盖配置进行测试
- 脚本中动态指定参数
- CI/CD 流水线中的特殊配置

**常见环境变量**：

| 变量名 | 说明 | 示例 |
|--------|------|------|
| `CLAUDE_MODEL` | 默认使用的模型 | `claude-opus-4-7` |
| `CLAUDE_API_KEY` | Anthropic API Key | `sk-ant-...` |
| `CLAUDE_DEBUG` | 开启调试模式 | `1` |
| `CLAUDE_WORKSPACE` | 指定工作区 | `/path/to/project` |

**CLI 参数列表**：

```bash
# 常用参数
claude --model claude-opus-4-7    # 指定模型
claude --no-permissions             # 不加载权限配置
claude --dry-run                    # 试运行模式
claude --verbose                    # 详细输出

# 查看帮助
claude --help
```

### 1.4 配置加载顺序详解

当你在一个项目中运行 `claude` 时，配置是这样加载的：

```
Step 1: 加载 ~/.claude/settings.json（系统级）
        ↓
Step 2: 加载 ./.claude/settings.json（项目级，覆盖系统级）
        ↓
Step 3: 应用环境变量和 CLI 参数（最高优先级）
        ↓
Step 4: 合并后的配置生效
```

**示例场景**：

假设有以下配置：

```json
// ~/.claude/settings.json
{
  "env": {"EDITOR": "code", "MODEL": "claude-haiku-4-5"}
}

// ./my-project/.claude/settings.json
{
  "env": {"MODEL": "claude-opus-4-7"}
}
```

运行命令：`CLAUDE_DEBUG=1 claude`

最终生效的配置：

```json
{
  "env": {
    "EDITOR": "code",           // 来自系统级
    "MODEL": "claude-opus-4-7"  // 项目级覆盖系统级
  },
  "debug": true                  // CLI 参数
}
```

---

## 第二部分：权限控制详解

Claude Code 的权限系统让你能**精确控制** Claude 能执行哪些操作。这在团队协作或处理敏感项目时非常重要。

### 2.1 权限配置结构

```json
{
  "permissions": {
    "allow": [...],    // 允许的操作
    "deny": [...],     // 明确禁止的操作
    "ask": [...]       // 需要确认的操作
  }
}
```

**优先级**：`deny` > `allow` > `ask`

也就是说：
- 如果同时匹配 `deny` 和 `allow`，`deny` 生效
- 如果没有匹配任何规则，默认行为取决于工具类型

### 2.2 工具级别的权限控制

#### 允许/禁止特定工具

```json
{
  "permissions": {
    "allow": [{"tool": "Read"}, {"tool": "Edit"}],
    "deny": [{"tool": "Bash"}]
  }
}
```

**效果**：Claude 可以读取和编辑文件，但不能执行任何 Bash 命令。

#### 允许/禁止特定命令

对于 `Bash` 工具，可以精确到命令级别：

```json
{
  "permissions": {
    "allow": [
      {"tool": "Bash", "command": "npm test"},
      {"tool": "Bash", "command": "git status"},
      {"tool": "Bash", "command": "ls *"}
    ],
    "deny": [
      {"tool": "Bash", "command": "rm -rf /"},
      {"tool": "Bash", "command": "*production*"}
    ]
  }
}
```

**通配符规则**：
- `*` 匹配任意字符
- `ls *` 匹配 `ls -la`、`ls src/` 等
- `*production*` 匹配包含 "production" 的任何命令

### 2.3 需要确认的操作（Ask 模式）

对于敏感操作，可以设置为需要用户确认：

```json
{
  "permissions": {
    "ask": [
      {"tool": "Write", "pattern": "*.config.js"},
      {"tool": "Bash", "command": "git push *"},
      {"tool": "Bash", "command": "*deploy*"}
    ]
  }
}
```

**效果**：当 Claude 尝试执行匹配的操作时，会先询问你是否允许。

### 2.4 文件级别的权限控制

对于 `Read`、`Edit`、`Write` 工具，可以精确到文件路径：

```json
{
  "permissions": {
    "allow": [
      {"tool": "Read", "pattern": "src/**/*"},
      {"tool": "Edit", "pattern": "*.ts"}
    ],
    "deny": [
      {"tool": "Write", "pattern": "*.env*"},
      {"tool": "Edit", "pattern": "node_modules/*"},
      {"tool": "Read", "pattern": ".ssh/*"}
    ]
  }
}
```

**通配符规则**：
- `*` 匹配单个路径段内的任意字符
- `**` 匹配任意层级目录
- `src/**/*` 匹配 `src/` 下的所有文件和子目录
- `*.ts` 匹配所有 TypeScript 文件

### 2.5 权限配置最佳实践

#### 团队协作模板

```json
{
  "permissions": {
    "allow": [
      {"tool": "Read"},
      {"tool": "Edit", "pattern": "src/**/*"},
      {"tool": "Write", "pattern": "src/**/*"},
      {"tool": "Bash", "command": "npm *"},
      {"tool": "Bash", "command": "yarn *"},
      {"tool": "Bash", "command": "git status"},
      {"tool": "Bash", "command": "git log *"},
      {"tool": "Bash", "command": "git diff *"}
    ],
    "deny": [
      {"tool": "Bash", "command": "git push *"},
      {"tool": "Bash", "command": "git checkout *"},
      {"tool": "Bash", "command": "git reset *"},
      {"tool": "Bash", "command": "git rebase *"},
      {"tool": "Write", "pattern": ".env*"},
      {"tool": "Edit", "pattern": "package-lock.json"},
      {"tool": "Edit", "pattern": "yarn.lock"}
    ],
    "ask": [
      {"tool": "Bash", "command": "git commit *"},
      {"tool": "Bash", "command": "git add *"}
    ]
  }
}
```

#### 敏感项目模板

```json
{
  "permissions": {
    "allow": [
      {"tool": "Read", "pattern": "public/*"},
      {"tool": "Read", "pattern": "docs/*"}
    ],
    "deny": [
      {"tool": "Read", "pattern": "secret/*"},
      {"tool": "Read", "pattern": "config/*"},
      {"tool": "Read", "pattern": ".env*"},
      {"tool": "Bash"}
    ],
    "ask": [
      {"tool": "Edit"},
      {"tool": "Write"}
    ]
  }
}
```

---

## 第三部分：常用配置项详解

### 3.1 环境变量配置

在 `settings.json` 中可以通过 `env` 字段设置环境变量：

```json
{
  "env": {
    "EDITOR": "code --wait",
    "NODE_ENV": "development",
    "OPENAI_API_KEY": "sk-...",
    "ANTHROPIC_API_KEY": "sk-ant-..."
  }
}
```

**常见环境变量**：

| 变量名 | 用途 | 示例值 |
|--------|------|--------|
| `EDITOR` | 默认编辑器 | `code --wait`, `vim` |
| `CLAUDE_MODEL` | 默认模型 | `claude-opus-4-7` |
| `NODE_ENV` | Node 环境 | `development`, `production` |
| `OPENAI_API_KEY` | OpenAI API 密钥 | `sk-...` |
| `ANTHROPIC_API_KEY` | Anthropic API 密钥 | `sk-ant-...` |
| `AWS_ACCESS_KEY_ID` | AWS 访问密钥 | `AKIA...` |
| `GOOGLE_API_KEY` | Google API 密钥 | `AIza...` |

### 3.2 模型配置

通过 `model` 字段可以指定 Claude Code 默认使用的模型：

```json
{
  "model": "claude-opus-4-7"
}
```

**可用模型**（截至 2026年5月）：

| 模型名 | 特点 | 适用场景 |
|--------|------|----------|
| `claude-opus-4-7` | 最强能力，价格最高 | 复杂任务、架构设计 |
| `claude-sonnet-4-6` | 能力均衡，速度较快 | 日常开发、代码审查 |
| `claude-haiku-4-5` | 最快响应，价格最低 | 简单问答、快速编辑 |

**推荐配置**：

```json
{
  "model": "claude-sonnet-4-6",
  "env": {
    "CLAUDE_FAST_MODE": "true"
  }
}
```

### 3.3 Attribution 配置

Attribution 用于设置代码归属信息，当你让 Claude 生成代码时，这些信息会被嵌入：

```json
{
  "attribution": {
    "name": "小c",
    "email": "xiaoc@example.com",
    "url": "https://xiaocself.top"
  }
}
```

**用途**：
- 生成的代码文件中包含作者信息
- 在团队协作中标识代码来源
- 开源项目中自动填充 LICENSE 信息

### 3.4 Hooks 配置

Hooks 让你可以在特定时机执行自定义操作：

```json
{
  "hooks": {
    "pre_tool_use": [
      {
        "command": "echo \"[$(date)] {tool_name}\" >> ~/.claude/activity.log",
        "when": "always"
      }
    ],
    "post_session_end": [
      {
        "command": "notify-send \"Claude Code\" \"会话已结束\"",
        "when": "always"
      }
    ]
  }
}
```

**Hook 类型**：

| Hook 名 | 触发时机 |
|---------|----------|
| `pre_tool_use` | 每次工具调用前 |
| `post_tool_use` | 每次工具调用后 |
| `pre_session_start` | 会话开始前 |
| `post_session_end` | 会话结束后 |
| `on_error` | 发生错误时 |

---

## 第四部分：完整项目模板

### 4.1 通用项目模板

```json
{
  "name": "my-project",
  "description": "项目级 Claude Code 配置",
  
  "env": {
    "EDITOR": "code --wait",
    "NODE_ENV": "development",
    "PYTHON_ENV": "venv"
  },
  
  "model": "claude-sonnet-4-6",
  
  "attribution": {
    "name": "Your Name",
    "email": "you@example.com"
  },
  
  "permissions": {
    "allow": [
      {"tool": "Read"},
      {"tool": "Edit", "pattern": "src/**/*"},
      {"tool": "Write", "pattern": "src/**/*"},
      {"tool": "Bash", "command": "npm *"},
      {"tool": "Bash", "command": "yarn *"},
      {"tool": "Bash", "command": "git status"},
      {"tool": "Bash", "command": "git log *"},
      {"tool": "Bash", "command": "git diff *"}
    ],
    "deny": [
      {"tool": "Bash", "command": "git push *"},
      {"tool": "Bash", "command": "git checkout *"},
      {"tool": "Bash", "command": "rm -rf /"},
      {"tool": "Write", "pattern": ".env*"}
    ],
    "ask": [
      {"tool": "Bash", "command": "git commit *"}
    ]
  },
  
  "hooks": {
    "pre_tool_use": [
      {
        "command": "echo \"[$(date '+%Y-%m-%d %H:%M:%S')] {tool_name}\" >> .claude/activity.log",
        "when": "always"
      }
    ]
  }
}
```

### 4.2 前端项目专用模板

```json
{
  "name": "frontend-project",
  "env": {
    "EDITOR": "code --wait",
    "NODE_ENV": "development",
    "NEXT_TELEMETRY_DISABLED": "1"
  },
  "model": "claude-sonnet-4-6",
  "permissions": {
    "allow": [
      {"tool": "Read"},
      {"tool": "Edit", "pattern": "{src,app,components,pages,lib}/**/*"},
      {"tool": "Write", "pattern": "{src,app,components,pages,lib}/**/*"},
      {"tool": "Bash", "command": "npm *"},
      {"tool": "Bash", "command": "yarn *"},
      {"tool": "Bash", "command": "pnpm *"},
      {"tool": "Bash", "command": "npx *"},
      {"tool": "Bash", "command": "git status"},
      {"tool": "Bash", "command": "git log *"},
      {"tool": "Bash", "command": "git diff *"}
    ],
    "deny": [
      {"tool": "Bash", "command": "npm publish*"},
      {"tool": "Bash", "command": "git push *"},
      {"tool": "Write", "pattern": ".env*"},
      {"tool": "Write", "pattern": "package-lock.json"},
      {"tool": "Write", "pattern": "yarn.lock"}
    ]
  }
}
```

### 4.3 后端/Python 项目专用模板

```json
{
  "name": "python-project",
  "env": {
    "EDITOR": "code --wait",
    "PYTHON_ENV": "venv",
    "PIP_DISABLE_PIP_VERSION_CHECK": "1"
  },
  "model": "claude-opus-4-7",
  "permissions": {
    "allow": [
      {"tool": "Read"},
      {"tool": "Edit", "pattern": "{src,app,tests,scripts}/**/*"},
      {"tool": "Write", "pattern": "{src,app,tests,scripts}/**/*"},
      {"tool": "Bash", "command": "python *"},
      {"tool": "Bash", "command": "pip *"},
      {"tool": "Bash", "command": "pytest *"},
      {"tool": "Bash", "command": "black *"},
      {"tool": "Bash", "command": "isort *"},
      {"tool": "Bash", "command": "flake8 *"},
      {"tool": "Bash", "command": "mypy *"},
      {"tool": "Bash", "command": "git status"},
      {"tool": "Bash", "command": "git log *"}
    ],
    "deny": [
      {"tool": "Bash", "command": "pip uninstall *"},
      {"tool": "Bash", "command": "python -m pip install *"},
      {"tool": "Bash", "command": "rm -rf /"},
      {"tool": "Bash", "command": "git push *"},
      {"tool": "Write", "pattern": ".env*"},
      {"tool": "Write", "pattern": "requirements.txt"}
    ]
  }
}
```

---

## 第五部分：常见问题与调试

### 5.1 配置不生效怎么办？

**检查清单**：

1. **检查配置文件位置**
   ```bash
   # 系统级
   ls ~/.claude/settings.json
   
   # 项目级
   ls ./.claude/settings.json
   ```

2. **验证 JSON 格式**
   ```bash
   # 使用 jq 检查
   cat ~/.claude/settings.json | jq empty
   
   # 或者 Python
   python3 -m json.tool ~/.claude/settings.json > /dev/null && echo "Valid JSON"
   ```

3. **检查环境变量**
   ```bash
   # 查看当前环境变量
   env | grep CLAUDE
   
   # 检查是否有覆盖
   echo $CLAUDE_MODEL
   ```

4. **重启 Claude Code**
   配置修改后，需要重启会话才能生效。

### 5.2 如何调试权限问题？

**问题**：Claude 说没有权限执行某个操作

**解决方法**：

1. **查看当前生效的权限配置**
   ```bash
   claude --show-config
   ```

2. **临时添加调试权限**
   在项目级配置中添加：
   ```json
   {
     "permissions": {
       "allow": [
         {"tool": "Bash", "command": "*"}
       ]
     }
   }
   ```

3. **使用 CLI 参数绕过权限检查**
   ```bash
   claude --no-permissions
   ```
   ⚠️ 注意：这很危险，只用于调试

### 5.3 常见错误及解决方案

| 错误信息 | 原因 | 解决方案 |
|----------|------|----------|
| `Invalid JSON in settings` | JSON 格式错误 | 使用 JSON 验证工具检查 |
| `Permission denied` | 权限不足 | 检查并修改 permissions 配置 |
| `Unknown tool: xxx` | 工具名拼写错误 | 检查 tool 名称拼写 |
| `Hook execution failed` | Hook 脚本错误 | 检查脚本权限和路径 |
| `Configuration not found` | 配置文件位置错误 | 检查文件路径是否正确 |

---

## 结语

这篇文章从三级配置体系、权限控制、常用配置项，到实战模板，系统地讲解了 Claude Code 的 `settings.json` 配置。

掌握这些知识后，你可以：
- ✅ 为不同项目配置不同的行为
- ✅ 精确控制 Claude 的权限，保障安全
- ✅ 通过 Hooks 实现自动化
- ✅ 团队共享统一的配置规范

建议你现在就开始：
1. 检查你当前的 `~/.claude/settings.json`
2. 选择一个项目，创建 `.claude/settings.json`
3. 从上面的模板开始，逐步调整到你需要的配置

如果你有任何问题，欢迎在评论区交流。

---

**附录：相关资源**

- [Claude Code 官方文档](https://docs.anthropic.com/en/docs/claude-code/overview)
- [Anthropic API 文档](https://docs.anthropic.com/en/api/getting-started)
- [本文配套的 GitHub 模板仓库](https://github.com/xiaocself/claude-code-settings-templates)

---

*最后更新：2026年5月1日*
*作者：[小c](https://xiaocself.top)*
