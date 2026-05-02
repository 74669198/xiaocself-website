---
date: '2026-05-02T13:30:00+08:00'
draft: false
title: '数据分析实战：用 Claude Code 处理 Excel/CSV'
description: '用 Claude Code + Python 完成数据清洗、分析、可视化和自动化报表的完整流程，附真实业务场景演示'
tags: ['Claude Code', '数据分析', 'Python', 'Excel', '自动化']
categories: ['cases']
showToc: true
---

## 前言

很多人不知道，Claude Code 其实是个很强的数据分析工具。原因很简单：

1. 它能**直接读写文件**——Excel、CSV、JSON 都行
2. 它能**写 Python 代码**——pandas、matplotlib、openpyxl 随便用
3. 它能**执行脚本**——跑完直接看结果
4. 它能**理解你的意图**——"帮我看看这月工资有没有算错"比写 SQL 简单多了

这篇文章用 3 个真实场景，展示 Claude Code 做数据分析的完整流程。

---

## 场景一：工资数据核对

### 背景

每月财务发来工资表，30 多人的数据，需要核对：
- 基本工资 + 绩效是否正确
- 扣款（迟到、请假）是否合理
- 加班费计算是否准确

以前手动核对要半天，现在 5 分钟。

### Step 1：导入数据

```
> 读取这个月的工资表 salary_may.xlsx，帮我看看数据结构
```

Claude 执行：

```python
import pandas as pd

df = pd.read_excel('salary_may.xlsx')
print(df.info())
print(df.head())
print(df.describe())
```

输出：
```
RangeIndex: 32 entries, 0 to 31
Data columns: 姓名, 部门, 基本工资, 绩效评分, 迟到次数, 请假天数, 加班小时, 实发工资
```

### Step 2：自动核算

```
> 帮我核对实发工资是否正确，规则是：
> - 绩效工资 = 基本工资 × 30% × (绩效评分/100)
> - 迟到扣款：3次以内不扣，超过3次每次50
> - 请假扣款 = 请假天数 × (基本工资/21.75)
> - 加班费 = 加班小时 × (基本工资/21.75/8) × 1.5
> - 实发 = 基本工资 + 绩效工资 + 加班费 - 迟到扣款 - 请假扣款
```

Claude 生成核算代码：

```python
def verify_salary(row):
    base = row['基本工资']
    daily_rate = base / 21.75
    hourly_rate = daily_rate / 8

    performance = base * 0.3 * (row['绩效评分'] / 100)
    late_deduction = max(0, row['迟到次数'] - 2) * 50
    leave_deduction = row['请假天数'] * daily_rate
    overtime = row['加班小时'] * hourly_rate * 1.5

    expected = base + performance + overtime - late_deduction - leave_deduction
    diff = row['实发工资'] - round(expected, 2)

    return round(diff, 2)

df['差异'] = df.apply(verify_salary, axis=1)
errors = df[df['差异'] != 0]
print(f"发现 {len(errors)} 条核算差异")
print(errors[['姓名', '实发工资', '差异']])
```

**结果**：发现 3 条差异，最大一笔多算了 200 元。5 分钟搞定以前半天的活。

---

## 场景二：运营数据分析

### 背景

运营团队有一份月度数据，包含每日访问量、注册量、付费转化等。需要分析趋势和异常。

### Step 1：数据清洗

```
> 读取 ops_data.csv，帮我清洗数据：
> - 处理缺失值
> - 日期格式统一
> - 去掉重复行
> - 异常值标记
```

Claude 生成：

```python
df = pd.read_csv('ops_data.csv')

# 日期格式统一
df['date'] = pd.to_datetime(df['date'])

# 缺失值处理
df['visits'] = df['visits'].fillna(df['visits'].median())
df['signups'] = df['signups'].fillna(0)

# 去重
df = df.drop_duplicates(subset=['date'])

# 异常值标记（3σ 原则）
for col in ['visits', 'signups', 'payments']:
    mean, std = df[col].mean(), df[col].std()
    df[f'{col}_outlier'] = df[col].apply(
        lambda x: True if abs(x - mean) > 3 * std else False
    )

print(f"清洗后数据：{len(df)} 行")
print(f"异常值：{df[[c for c in df.columns if 'outlier' in c]].sum().sum()} 个")
```

### Step 2：趋势分析

```
> 分析这一个月的数据趋势，找出：
> - 访问量最高的日期和原因
> - 转化率变化趋势
> - 周几表现最好
> - 有没有异常波动
```

Claude 生成完整分析：

```python
# 周几分析
df['weekday'] = df['date'].dt.day_name()
weekday_stats = df.groupby('weekday').agg({
    'visits': 'mean',
    'signups': 'mean',
    'payments': 'mean'
}).round(0)
print("=== 各周几平均表现 ===")
print(weekday_stats.sort_values('visits', ascending=False))

# 转化率趋势
df['signup_rate'] = (df['signups'] / df['visits'] * 100).round(2)
df['payment_rate'] = (df['payments'] / df['signups'] * 100).round(2)

# 最高访问日
best_day = df.loc[df['visits'].idxmax()]
print(f"\n访问量最高：{best_day['date'].date()}，{best_day['visits']} 次")

# 异常波动
outliers = df[df['visits_outlier']]
print(f"\n异常波动日期：{outliers['date'].dt.date.tolist()}")
```

### Step 3：数据可视化

```
> 生成图表：访问量和转化率的双轴折线图，保存为 PNG
```

```python
import matplotlib.pyplot as plt
import matplotlib.dates as mdates

plt.rcParams['font.sans-serif'] = ['Arial Unicode MS']  # macOS 中文
fig, ax1 = plt.subplots(figsize=(14, 6))

ax1.bar(df['date'], df['visits'], color='skyblue', alpha=0.6, label='访问量')
ax1.set_ylabel('访问量', color='skyblue')

ax2 = ax1.twinx()
ax2.plot(df['date'], df['signup_rate'], color='red', marker='o', label='注册率')
ax2.plot(df['date'], df['payment_rate'], color='green', marker='s', label='付费率')
ax2.set_ylabel('转化率 (%)', color='red')

ax1.xaxis.set_major_formatter(mdates.DateFormatter('%m/%d'))
plt.title('月度运营数据趋势')
plt.savefig('ops_trend.png', dpi=150, bbox_inches='tight')
```

---

## 场景三：自动化报表

### 背景

每周需要给领导发一份运营周报，手动汇总数据很费时。

### 用 Claude 生成自动化脚本

```
> 帮我写一个周报自动生成脚本：
> - 读取本周的运营数据 CSV
> - 汇总关键指标（环比变化）
> - 生成 Excel 报表，包含图表
> - 通过邮件发送
```

Claude 生成的核心逻辑：

```python
from openpyxl import Workbook
from openpyxl.chart import BarChart, LineChart
import smtplib
from email.mime.multipart import MIMEMultipart

def generate_weekly_report(csv_path: str, output_path: str):
    df = pd.read_csv(csv_path)
    df['date'] = pd.to_datetime(df['date'])

    # 本周 vs 上周
    this_week = df[df['date'] >= pd.Timestamp.now() - pd.Timedelta(days=7)]
    last_week = df[(df['date'] >= pd.Timestamp.now() - pd.Timedelta(days=14)) &
                   (df['date'] < pd.Timestamp.now() - pd.Timedelta(days=7))]

    metrics = {
        '访问量': (this_week['visits'].sum(), last_week['visits'].sum()),
        '注册数': (this_week['signups'].sum(), last_week['signups'].sum()),
        '付费数': (this_week['payments'].sum(), last_week['payments'].sum()),
    }

    # 生成 Excel
    wb = Workbook()
    ws = wb.active
    ws.title = "周报摘要"

    ws.append(['指标', '本周', '上周', '环比变化'])
    for name, (current, previous) in metrics.items():
        change = (current - previous) / previous * 100 if previous > 0 else 0
        ws.append([name, current, previous, f"{change:+.1f}%"])

    wb.save(output_path)
    return output_path
```

### 定时执行

用 crontab 设置每周一早上 9 点自动生成并发送：

```bash
# 每周一 9:00 生成周报
0 9 * * 1 cd /path/to/project && python weekly_report.py >> logs/report.log 2>&1
```

---

## 效率对比

| 任务 | 传统方式 | Claude Code | 提升 |
|------|---------|-------------|------|
| 工资核对 | 半天手动 | 5 分钟 | 90% |
| 数据清洗 | 1-2 小时 | 10 分钟 | 85% |
| 趋势分析 | 2-3 小时 | 15 分钟 | 90% |
| 图表生成 | 30 分钟 | 5 分钟 | 83% |
| 周报制作 | 1 小时 | 5 分钟（自动化后 0） | 95%+ |

---

## 经验总结

### Claude Code 做数据分析的优势

1. **零门槛**——用自然语言描述需求，不用记 pandas 语法
2. **快速迭代**——改需求只需改一句话，代码自动更新
3. **端到端**——从读取到分析到可视化，一个会话搞定
4. **可复现**——生成的代码可以反复运行，结果一致

### 需要注意的

1. **数据隐私**——敏感数据不要上传到云端，Claude Code 本地执行是安全的
2. **结果验证**——AI 生成的分析结论要人工过一遍，尤其是业务决策
3. **大文件处理**——超过 100MB 的文件，建议先采样或分块
4. **中文编码**——Excel 文件注意编码问题，用 `encoding='utf-8'` 或 `gbk`

数据分析的本质不是写代码，而是**提出正确的问题**。Claude Code 帮你把问题变成答案，你只需要问对问题。
