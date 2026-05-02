---
date: '2026-05-02T14:00:00+08:00'
draft: false
title: 'Google AdSense 申请与接入实录'
description: '从准备申请到成功接入 Google AdSense 的完整流程，包括审核注意事项、广告位配置、样式优化和收入追踪'
tags: ['Google AdSense', '网站变现', 'SEO', '收入优化']
categories: ['cases']
showToc: true
---

## 前言

网站写了一段时间，内容有了，流量有了，自然就想：能不能赚点钱？

Google AdSense 是最简单的变现方式——不需要自己找广告主，Google 自动匹配，你只需要放一段代码。

但申请 AdSense 不是提交就过，**审核很严格**。这篇文章记录我从准备到申请到接入的完整过程。

---

## 第一部分：申请前的准备

### AdSense 审核标准

Google 官方没有公开具体标准，但根据社区经验，以下条件基本是必须的：

| 条件 | 要求 | 我的状态 |
|------|------|---------|
| 网站内容 | 原创、有价值 | ✅ 20 篇原创文章 |
| 内容数量 | 至少 15-20 篇 | ✅ |
| 网站年龄 | 至少运行 1 个月 | ⚠️ 刚好 1 个月 |
| 导航结构 | 清晰的菜单和分类 | ✅ |
| 隐私政策 | 必须有 | ❌ 需要添加 |
| 关于页面 | 必须有 | ✅ |
| 联系方式 | 必须有 | ❌ 需要添加 |
| 域名 | 顶级域名 | ✅ xiaocself.top |
| SSL 证书 | HTTPS | ✅ |
| 无违规内容 | 无成人/暴力/侵权 | ✅ |

### 用 Claude 准备缺失项

**1. 隐私政策页面**

```
> 帮我写一个网站隐私政策页面，包含：
> - 信息收集说明（Google Analytics、AdSense）
> - Cookie 使用说明
> - 第三方服务说明
> - 用户权利
> - 联系方式
> 适合 Hugo PaperMod 主题
```

Claude 生成了完整的隐私政策页面，我放在 `content/privacy-policy.md`。

**2. 联系方式页面**

```
> 帮我添加一个联系方式页面
```

**3. 导航更新**

在 `hugo.toml` 中添加新页面到菜单：

```toml
[[menu.main]]
  identifier = 'privacy'
  name = '隐私政策'
  url = '/privacy-policy/'
  weight = 60
```

---

## 第二部分：提交申请

### 申请流程

1. 访问 [Google AdSense](https://www.google.com/adsense/)
2. 用 Google 账号登录
3. 输入网站地址
4. 填写付款信息（需要真实姓名和地址）
5. 获取广告代码，放到网站
6. 等待审核

### 审核周期

| 阶段 | 时间 | 说明 |
|------|------|------|
| 初审 | 1-3 天 | 检查网站基本资质 |
 | 放置代码 | 你操作 | 把广告代码加到网站 |
| 终审 | 1-4 周 | Google 爬虫检查网站内容 |

### 常见被拒原因

| 原因 | 解决方案 |
|------|---------|
| 内容太少 | 至少 15-20 篇高质量原创内容 |
| 内容抄袭 | 必须原创，不能翻译或洗稿 |
| 导航不清 | 确保有清晰的菜单和分类 |
| 缺少隐私政策 | 添加隐私政策页面 |
| 网站太新 | 至少运行 1 个月 |
| 有违规内容 | 移除成人/暴力/侵权内容 |
| 广告位太多 | 审核期间不要放其他广告 |

---

## 第三部分：接入广告代码

### 在 Hugo 中添加 AdSense

**方法一：全局 head 注入**

在 `layouts/partials/extend-head.html` 中添加：

```html
<!-- Google AdSense -->
<script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-XXXXXXXXXXXXXXXX"
     crossorigin="anonymous"></script>
```

**方法二：用 Hugo Shortcode 灵活放置**

创建 `layouts/shortcodes/adsense.html`：

```html
<ins class="adsbygoogle"
     style="display:block"
     data-ad-client="ca-pub-XXXXXXXXXXXXXXXX"
     data-ad-slot="XXXXXXXXXX"
     data-ad-format="auto"
     data-full-width-responsive="true"></ins>
<script>(adsbygoogle = window.adsbygoogle || []).push({});</script>
```

在文章中用 `{{</* adsense */>}}` 插入广告。

### 广告位策略

| 位置 | 效果 | 注意事项 |
|------|------|---------|
| 文章顶部 | CTR 最高 | 不要太大，影响阅读 |
| 文章中间 | 平衡 | 长文章（>1500字）放一个 |
| 文章底部 | CTR 较低 | 适合放相关内容广告 |
| 侧边栏 | 稳定 | 适合桌面端 |

**我的配置**：
- 文章顶部：1 个自适应广告
- 文章中间（>2000 字时）：1 个广告
- 文章底部：1 个广告

```html
<!-- 文章顶部广告 -->
{{ if and (not .Params.noads) (gt .WordCount 500) }}
<div class="ad-container ad-top">
  {{ partial "adsense-top.html" . }}
</div>
{{ end }}
```

---

## 第四部分：样式优化

### 广告与内容的融合

广告太突兀会影响用户体验，我用 CSS 做了简单的样式调整：

```css
/* 广告容器 */
.ad-container {
  margin: 2rem 0;
  padding: 0.5rem;
  border-radius: 8px;
}

.ad-top {
  margin-bottom: 1.5rem;
}

.ad-mid {
  border-top: 1px solid var(--border);
  border-bottom: 1px solid var(--border);
  padding: 1rem 0.5rem;
}

/* 广告标签 */
.ad-label {
  font-size: 0.75rem;
  color: var(--secondary);
  text-align: center;
  margin-bottom: 0.5rem;
}
```

### 自动广告 vs 手动广告

| 类型 | 优点 | 缺点 |
|------|------|------|
| 自动广告 | 省事、Google 自动优化位置 | 位置不可控 |
| 手动广告 | 位置可控、体验更好 | 需要手动配置 |

**我的建议**：初期用自动广告，等有数据后再切换到手动广告精细优化。

---

## 第五部分：收入追踪

### AdSense 报告

AdSense 后台提供丰富的报告：

| 指标 | 说明 | 优化方向 |
|------|------|---------|
| Page RPM | 每千次展示收入 | 提高内容质量 |
| CTR | 点击率 | 优化广告位置 |
| CPC | 单次点击收入 | 选择高价值关键词 |
| 估算收入 | 实际收入 | 综合优化 |

### 用 Claude 分析收入数据

```
> 这是这个月的 AdSense 报告数据，帮我分析：
> - 哪些页面收入最高
> - 点击率趋势
> - 有什么优化建议
```

### 收入预期

**真实数据参考**（小流量站点）：

| 流量级别 | 月收入 | RPM |
|----------|--------|-----|
| 100 PV/天 | $1-5 | $1-5 |
| 1000 PV/天 | $10-50 | $2-8 |
| 10000 PV/天 | $100-500 | $3-10 |

**重要**：AdSense 不是暴利工具，小站月收入可能只够买杯咖啡。但它是被动的，写好内容就能持续赚。

---

## 第六部分：合规注意事项

### 必须遵守的规则

1. **不要自己点广告**——Google 会检测，直接封号
2. **不要诱导点击**——"请点击广告支持我们"这种话不能有
3. **不要放太多广告**——页面广告面积不超过内容面积
4. **不要修改广告代码**——只能用 Google 提供的代码
5. **不要在空白页放广告**——必须有实质内容

### 隐私合规

```html
<!-- 在隐私政策中说明 Cookie 使用 -->
<p>本站使用 Google AdSense 展示广告。AdSense 可能使用 Cookie
   来提供基于兴趣的广告。您可以访问
   <a href="https://www.google.com/settings/ads">Google 广告设置</a>
   来个性化广告偏好。</p>
```

---

## 常见问题

### Q: 审核被拒怎么办？

1. 仔细阅读拒绝邮件中的原因
2. 针对性修复问题
3. 等待至少 1 周后重新申请
4. 不要频繁申请，会被标记

### Q: 多久能看到收入？

- 审核通过后，广告开始展示
- 达到 $10 会验证地址（邮寄 PIN 码）
- 达到 $100 才能提现
- 小站可能需要 6-12 个月才能第一次提现

### Q: AdSense 和 SEO 冲突吗？

不冲突，但广告太多会降低用户体验，间接影响 SEO。建议：
- 广告面积 < 内容面积
- 首屏不要全是广告
- 移动端少放广告

---

## 总结

AdSense 接入本身不难，难的是**前置条件**——你首先得有一个内容充实、结构清晰的网站。

关键时间线：

| 阶段 | 时间 | 动作 |
|------|------|------|
| 准备期 | 1-2 个月 | 写内容、完善网站结构 |
| 申请期 | 1-4 周 | 提交申请、等待审核 |
| 接入期 | 1 天 | 添加广告代码 |
| 优化期 | 持续 | 调整广告位置和样式 |

AdSense 是网站变现的第一步，不是最后一步。等流量起来后，可以考虑赞助、付费内容、联盟营销等更高收入的模式。
