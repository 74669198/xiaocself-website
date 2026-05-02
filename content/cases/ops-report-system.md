---
date: '2026-05-02T12:00:00+08:00'
draft: false
title: '运营报备系统自动化搭建实录'
description: '用 Claude Code 从零搭建人员管理、工资核算、费用审批系统的完整过程，包括需求分析、技术选型、核心功能实现和踩坑记录'
tags: ['Claude Code', '自动化', '运营系统', '实战案例']
categories: ['cases']
showToc: true
---

## 项目背景

我负责的运营团队有 30 多人，每月的报备流程是这样的：

1. 员工填写纸质考勤表 → 主管签字 → 人力录入
2. 工资按考勤 + 绩效手动计算 → Excel 核对 → 财务审核
3. 费用报销走纸质单据 → 三级审批 → 财务打款

**每月至少 2 个人全职处理这些事，还经常出错。**

我决定用 Claude Code 搭一套自动化系统，目标：**报备流程从 3 天缩短到 3 小时**。

---

## 第一阶段：需求分析

### 用 Claude 梳理需求

我先把现状描述给 Claude：

```
我们团队30人，每月考勤用纸质表，工资手动算，报销走纸质单。
现在要做一个系统自动化这些流程。帮我梳理需求。
```

Claude 帮我梳理出三大模块：

| 模块 | 核心功能 | 优先级 |
|------|---------|--------|
| 人员管理 | 考勤打卡、请假审批、排班管理 | P0 |
| 工资核算 | 基本工资 + 绩效 + 扣款 + 加班自动计算 | P0 |
| 费用审批 | 线上报销、多级审批、财务审核 | P1 |

### 确定技术方案

```
技术要求：团队只会用浏览器，不要装任何软件。
预算有限，优先用免费方案。
```

Claude 推荐的方案：

- **前端**：Vue 3 + Element Plus（表单组件丰富）
- **后端**：FastAPI + SQLite（轻量、部署简单）
- **部署**：Docker + 内网服务器

我选了这个方案，因为团队熟悉 Python，维护成本低。

---

## 第二阶段：核心功能实现

### 1. 人员管理模块

**考勤打卡**是第一个功能。我对 Claude 说：

```
> 帮我实现一个考勤打卡接口，支持：
> - 每天打卡两次（上班/下班）
> - 自动计算工时
> - 迟到早退标记
> - 数据存 SQLite
```

Claude 生成了完整代码，包括：

- FastAPI 路由和 Pydantic 模型
- SQLite 表结构
- 工时计算逻辑
- 迟到早退判定规则

**关键代码片段**：

```python
# 工时计算逻辑
def calculate_work_hours(check_in: datetime, check_out: datetime) -> dict:
    work_minutes = (check_out - check_in).total_seconds() / 60
    is_late = check_in.time() > time(9, 0)
    is_early = check_out.time() < time(18, 0)

    return {
        "work_hours": round(work_minutes / 60, 2),
        "is_late": is_late,
        "is_early": is_early,
        "overtime_hours": max(0, round((work_minutes - 540) / 60, 2))  # 超过9小时算加班
    }
```

**实际效果**：这个功能从需求到上线只用了 **1 天**。

### 2. 工资核算模块

这是最复杂的部分。我直接把工资规则告诉 Claude：

```
> 工资计算规则：
> - 基本工资：按岗位等级（A/B/C 三档）
> - 绩效工资：月度评分 × 系数
> - 扣款：迟到3次以上每次扣50，事假按日薪扣
> - 加班费：工作日1.5倍，周末2倍
> - 生成工资条，可导出 Excel
```

Claude 帮我实现了：

```python
def calculate_salary(base: float, performance_score: float,
                     late_count: int, leave_days: float,
                     overtime_weekday: float, overtime_weekend: float) -> dict:
    daily_rate = base / 21.75  # 法定月计薪天数

    # 绩效工资
    performance = base * 0.3 * (performance_score / 100)

    # 扣款
    late_deduction = max(0, late_count - 2) * 50
    leave_deduction = leave_days * daily_rate

    # 加班费
    overtime_pay = overtime_weekday * daily_rate / 8 * 1.5 + \
                   overtime_weekend * daily_rate / 8 * 2

    total = base + performance + overtime_pay - late_deduction - leave_deduction

    return {
        "base": base,
        "performance": performance,
        "overtime_pay": round(overtime_pay, 2),
        "late_deduction": late_deduction,
        "leave_deduction": round(leave_deduction, 2),
        "total": round(total, 2)
    }
```

**踩坑**：第一次 Claude 生成的扣款规则是"迟到就扣"，但实际公司规定是"3次以内不扣"。我补充了规则后，Claude 立刻修正了。

### 3. 费用审批模块

```
> 费用报销流程：
> - 员工提交报销单（事由、金额、附件）
> - 主管审批 → 金额>5000 自动转部门经理
> - 财务审核 → 打款
> - 全程有状态追踪
```

Claude 设计了状态机：

```
待提交 → 主管审批中 → (金额>5000?) → 部门经理审批中 → 财务审核中 → 已打款
                                      ↓ 金额≤5000
                                   财务审核中 → 已打款
```

**多级审批逻辑**：

```python
async def submit_approval(expense_id: str, amount: float, approver_chain: list):
    if amount > 5000:
        # 需要3级审批：主管 → 部门经理 → 财务
        chain = ["supervisor", "department_manager", "finance"]
    else:
        # 2级审批：主管 → 财务
        chain = ["supervisor", "finance"]

    for i, role in enumerate(chain):
        await create_approval_task(expense_id, role, order=i+1)
```

---

## 第三阶段：前端开发

前端是团队最直接接触的部分，我要求界面简洁易用：

```
> 用 Vue 3 + Element Plus 做前端，要求：
> - 打卡页面：一个大按钮，点击打卡
> - 工资条：表格展示明细，支持导出
> - 报销单：表单填写 + 图片上传
> - 审批列表：待审批/已审批筛选
```

Claude 生成了完整的 Vue 组件，包括路由、状态管理和 API 对接。

**打卡页面效果**：

```vue
<template>
  <div class="check-in">
    <el-card class="check-card">
      <h2>{{ isCheckIn ? '下班打卡' : '上班打卡' }}</h2>
      <p class="time">{{ currentTime }}</p>
      <el-button type="primary" size="large" @click="handleCheck">
        打卡
      </el-button>
      <p v-if="lastCheck" class="last-record">
        上次打卡：{{ lastCheck }}
      </p>
    </el-card>
  </div>
</template>
```

---

## 第四阶段：部署上线

### Docker 部署

Claude 帮我写了 Docker Compose 配置：

```yaml
version: '3.8'
services:
  backend:
    build: ./backend
    ports:
      - "8000:8000"
    volumes:
      - ./data:/app/data  # SQLite 数据持久化
    restart: always

  frontend:
    build: ./frontend
    ports:
      - "80:80"
    depends_on:
      - backend
    restart: always
```

### 内网部署

```
> 帮我写一个部署脚本，自动拉取代码、构建镜像、启动服务
```

Claude 生成了部署脚本，一条命令完成部署：

```bash
./deploy.sh  # 自动完成 git pull + docker build + docker up
```

---

## 第五阶段：效果和效率提升

### 上线前后对比

| 指标 | 上线前 | 上线后 | 提升 |
|------|--------|--------|------|
| 月度考勤统计 | 3 天 | 10 分钟 | 99% |
| 工资核算 | 2 天 | 30 分钟 | 94% |
| 报销审批周期 | 5-7 天 | 1-2 天 | 71% |
| 人工错误率 | ~5% | ~0.1% | 98% |
| 人力投入 | 2 人全职 | 0.5 人兼职 | 75% |

### 开发过程数据

| 指标 | 数值 |
|------|------|
| 总开发时间 | 2 周 |
| Claude 辅助比例 | ~70% |
| 手动修改代码比例 | ~10% |
| Bug 数量 | 3 个（均为业务规则理解偏差） |

---

## 踩坑记录

### 坑 1：业务规则描述不清

Claude 第一次理解的"迟到扣款"是每次迟到都扣，实际是3次以内不扣。

**教训**：给 Claude 描述业务规则时，要把**边界条件**说清楚。

### 坑 2：并发写入 SQLite

多人同时打卡时出现锁竞争。解决方案：

```python
# 设置 SQLite WAL 模式
conn = sqlite3.connect("data.db")
conn.execute("PRAGMA journal_mode=WAL")
```

### 坑 3：前端附件上传大小限制

Nginx 默认限制 1MB，报销单据的照片经常超限。修改 Nginx 配置：

```nginx
client_max_body_size 20M;
```

---

## 总结

这次项目最大的感受是：**Claude Code 让非专业开发者也能搭建生产级系统**。

关键经验：
1. **需求描述越具体，代码质量越高**——边界条件、异常情况一定要说清楚
2. **分模块递进开发**——不要一次描述整个系统，先做核心功能
3. **测试每个模块**——Claude 生成的代码大概率正确，但业务逻辑必须人工验证
4. **部署环节最需要人工参与**——网络、权限、环境差异 Claude 很难预判

从 3 天到 3 小时的目标，实际达成了。而且系统上线后几乎没有维护成本——这才是自动化的真正价值。
