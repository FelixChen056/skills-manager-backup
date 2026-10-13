---
name: jd-auto-review
description: 京东(JD)待评价商品自动评价流水线：抓取评价中心待评价列表、提取 orderId/skuId、从商品评价接口收集有图评价参考图、按品类生成不重复的好评文案、自动填表上传图片并提交评价。当用户提到"京东评价/好评/晒图评价/待评价/评价中心/批量评价/做评价任务/赚京豆"时使用本技能；只要任务涉及京东订单的商品评价（查看、起草或提交），即使没有明说"自动"，也应使用本技能。
---

# 京东待评价商品自动评价

通过 AntiDebug Breaker MCP（extension transport，控制用户主浏览器）驱动京东 PC 评价中心，完成"查列表 → 取参考图 → 填表 → 提交"全流程。所有选择器与接口均于 2026-09 实战验证（8 单连续提交全部成功），但京东前端可能改版：任一步选择器失效时，按 `references/js-snippets.md` 末尾的"失效重定位法"重新探测，不要凭旧记忆硬编。

## 工具链与目标（先读，每次执行均适用）

- **配套技能**：执行本 skill 时**先调用 `antidebug-breaker-skills`**，结合 **AntiDebug Breaker MCP** 完成浏览器控制——即用户典型指令"请使用 antidebug-breaker-skills，结合 AntiDebug Breaker MCP，检测网页 https://comment.m.jd.com/pc-static/center"所确立的分工。评价中心若出现反调试干扰（持续刷新、强制跳转、清空内容），按该技能的反调试收尾规范定位绕过，不在本 skill 内另搞一套。
- **唯一浏览器通道**：所有页面操作（导航、evaluate、网络取证、截图）一律走 **AntiDebug Breaker MCP** 的 `adb_*` 工具（extension transport，控制用户主浏览器，端口 19876）。**不要**改用 Playwright/Puppeteer/Selenium 或 chrome-devtools 另起实例——会丢失登录态，也不符合用户浏览器使用约定。
- **目标页面（强调）**：京东 PC 评价中心固定为 **`https://comment.m.jd.com/pc-static/center`**（待评价列表所在页）。评价表单页为其同域路由 `https://comment.m.jd.com/pc-static/publish?orderId=…&skuId=…&commentType=1`（构造方法见下文，不要去 `item.jd.com` 商品页绕路）。

## 前置条件

- AntiDebug Breaker 扩展已装、MCP 已连接（extension transport，端口 19876；健康检查 CONNECTION_CLOSED 多为误报）。
- 评价是**真实账户的外向操作**：提交前确认用户已授权要评哪些单（"先做第一个"之类分批指令按批次执行）。

## 流程总览

1. **连接触发 + 登录状态检查**：`adb_capabilities` + `adb_list_pages`（找已开的 `comment.m.jd.com/pc-static/center` tab；没有就 `adb_navigate action=new` 开一个）。随后立刻做**登录状态检查**（脚本见 `references/js-snippets.md` 第 8 节）：顶部导航应显示用户昵称，页面无"你好，请登录 / 登录/注册"引导；京东自动弹出的 `login2025` 登录框同样视为未登录。未登录则**停止并报告，不要代为登录**（凭证在用户手里，代输密码/短信属越权），告知用户"请在浏览器手动登录京东后说继续"。
2. **抓待评价商品列表（含外卖订单排除）**：等 `.wait-rate-card` 渲染，从 React fiber 的 `cardData` prop 提取每单的 `wareId` / `orderId` / `wname`。提取后**默认剔除外卖/到店订单**，只处理实物商品评价。判定规则（满足任一即疑似外卖）：
   - `wname` 形如"品牌-门店"（含 `-` 且以 `店` 结尾，如"正新鸡排-江晖路店"）；
   - 条目无评价激励文案（京豆/券）且商品图为店铺样式。
   疑似条目跳过不评，但在结果中列出告知用户排除了哪些；仅当用户明确要求包含外卖时才评价。过滤片段见 js-snippets 第 8 节末尾。京东服务端也可能自行移除外卖订单（刷新后消失），以当前列表为准。
3. **取参考图**（每商品 4 张）：导航到 `club.jd.com` 评价接口，筛"有图评价"，从图池随机抽 4 张并验证 800x800 大图可加载。
4. **填表**：导航到 `publish?orderId=…&skuId=…&commentType=1`，写 ~110 字文案 + 注入 4 张图。
5. **提交验证**：点发布，确认"发布成功"；全部完成后刷新评价中心核对列表清空。

逐步的可复制 JS 表达式（含占位符）全部在 `references/js-snippets.md`，按其中编号取用，不要自己重写——那些片段包含了 React 受控组件、JSONP 剥壳、CORS 图片注入等已踩过坑的细节。

## 关键经验（失败换来的，别绕开）

- **商品 ID 叫 `wareId` 不是 `skuId`**：卡片数据在 fiber `memoizedProps.cardData` 里，搜 `skuId` 会扑空。
- **"去评价"按钮的 `window.open` 会被弹窗拦截器拦截**：合成 `click()` 的 `isTrusted=false`，浏览器拒绝弹窗。无需点击按钮——评价页 URL 可直接构造：`https://comment.m.jd.com/pc-static/publish?orderId={orderId}&skuId={wareId}&commentType=1`，用 `adb_navigate action=new`（注意：action=new 不能带 tabId，返回新 tabId 后复用）。
- **点击元素要点到带 onClick 的层**：`.rate-btn` 自身持有 onClick，点到父层 `.card-right` 无效。判断方法见 js-snippets 的失效重定位法。
- **textarea 是 React 受控组件**：必须用 `HTMLTextAreaElement.prototype` 的原生 value setter + 派发 `input` 事件，直接赋 `ta.value` 不会进 React state。
- **图片上传走 DataTransfer**：`fetch` 京东 CDN 图（360buyimg.com 带 CORS 头，可行）→ `File` → `DataTransfer` → 赋给 `input.uploadAddInput.files` → 派发 `change`。注入成功的标志是页面出现 4 个 `blob:` 预览图。
- **星级默认即 5 星**：四项（商品评价/快递包装/送货速度/配送员服务）默认"非常好"，无需操作。
- **评价接口是 JSONP**：`club.jd.com/comment/productPageComments.action?callback=…&productId={wareId}&score=0&sortType=5&page=0&pageSize=30`，响应需剥 `fetchJSON_comment98(...)` 壳；`comments[].images` 是**对象数组**（取 `imgUrl` 字段，`//` 开头补 `https:`），不是字符串数组。
- **图片规格可替换**：缩略图 `s128x96_jfs` ↔ 大图 `s800x800_jfs`，上传前先 `Image.onload` 验证大图存在。
- **文案要多样化**：每单按品类微调（包装→品质/使用感→物流→总结的骨架不变、用词不同），完全相同的文案连发有风控风险。~110 字即可（有图评价门槛以上）。
- **成功判据**：提交后轮询 body 出现"发布成功"（1 秒内）；失败词监测"发布失败/内容包含/违规"。需要硬证据时查网络请求 `api.m.jd.com/client.action`（functionId=tradeComment）响应 `success:true`。
- **外卖订单**：默认排除，判定规则见流程第 2 步，不再依赖用户每次提醒。

## 节奏与边界

- 单商品三步：导航 → 填文案+注图（合并一次 evaluate）→ 提交。`timeoutMs` 上限 30000。
- 连续提交间不额外等待（8 连发实测无风控）；若遇验证码/登录失效，立即停下如实报告，不要重试硬闯。
- 提交成功页停留在 tab 上即可，下一单直接 `navigate` 覆盖。全部完成后刷新评价中心验证 `wait-rate-card` 数量为 0。
- 结束时清点：新开的 tab 保留并告知用户、无 hook/断点残留（`window.open` 临时 hook 用后必须还原）。
