# 京东自动评价 - 已验证 JS 片段库

全部片段于 2026-09-30 实战验证（Chrome 153 + 京东 PC 评价中心 rate-qa v8e026b6）。
统一通过 `adb_evaluate`（`tabId` + `expression`，长等待任务加 `awaitPromise: true`，`timeoutMs` ≤ 30000）执行。
占位符用 `{...}` 标注，按当前任务替换。

## 1. 等待列表渲染并提取待评价商品（评价中心 tab）

```js
(async () => {
  const sleep = (ms) => new Promise(r => setTimeout(r, ms));
  let cards = [];
  for (let i = 0; i < 24; i++) {
    cards = [...document.querySelectorAll('.wait-rate-card')];
    if (cards.length || (document.body.innerText || '').includes('已经到底了')) break;
    await sleep(500);
  }
  const out = [];
  for (const c of cards) {
    const fkey = Object.keys(c).find(k => k.startsWith('__reactFiber$'));
    if (!fkey) { out.push({error: 'no fiber'}); continue; }
    let fiber = c[fkey], data = null;
    for (let i = 0; i < 5 && fiber; i++) {
      const props = fiber.memoizedProps || fiber.pendingProps;
      if (props && props.cardData && props.cardData.wareId) { data = props.cardData; break; }
      fiber = fiber.return;
    }
    if (data) out.push({wareId: data.wareId, orderId: data.orderId, wname: (data.wname || '').slice(0, 40)});
    else out.push({error: 'no cardData'});
  }
  return JSON.stringify({count: out.length, endReached: (document.body.innerText || '').includes('已经到底了'), items: out}, null, 1);
})()
```

要点：商品 ID 字段是 `wareId`；`cardData` 在卡片自身 fiber 向上最多 5 层内。
外卖/到店订单的 `wname` 是店铺名，按需过滤。

## 2. 抓有图评价参考图（在任意 tab，导航到接口 URL 后执行）

先导航（占位 `{wareId}`）：

```
https://club.jd.com/comment/productPageComments.action?callback=fetchJSON_comment98&productId={wareId}&score=0&sortType=5&page=0&pageSize=30&isShadowSku=0&fold=1
```

再执行（随机抽 4 张 + 验证 800x800 大图）：

```js
(async () => {
  const raw = (document.body.innerText || '').trim();
  const m = raw.match(/^[\w$]+\((.*)\);?$/s);
  let data; try { data = JSON.parse(m ? m[1] : raw); } catch (e) { return JSON.stringify({parseError: true, head: raw.slice(0, 150)}); }
  const pool = [];
  for (const c of (data.comments || [])) {
    for (const im of (c.images || [])) {
      if (im.imgUrl) pool.push({commentId: String(c.idStr || c.id), url: 'https:' + im.imgUrl});
    }
  }
  for (let i = pool.length - 1; i > 0; i--) { const j = Math.floor(Math.random() * (i + 1)); [pool[i], pool[j]] = [pool[j], pool[i]]; }
  const picked = pool.slice(0, 4);
  const check = (u) => new Promise(res => { const img = new Image(); let done = false; img.onload = () => { if (!done) { done = true; res(true); } }; img.onerror = () => { if (!done) { done = true; res(false); } }; img.src = u; setTimeout(() => { if (!done) { done = true; res(false); } }, 6000); });
  for (const p of picked) { const big = p.url.replace('/s128x96_', '/s800x800_'); p.big = (await check(big)) ? big : null; }
  return JSON.stringify({totalComments: (data.comments || []).length, poolSize: pool.length, picked}, null, 1);
})()
```

要点：
- 响应是 JSONP，必须剥壳；`images` 元素是对象（`imgUrl` 字段），不是字符串。
- 图片 `imgUrl` 以 `//` 开头，补 `https:`。
- 缩略图 `s128x96` 换 `s800x800` 得大图，上传用大图。
- 图池为 0 时：换 `sortType`（5=推荐排序）或 `page=1` 再试；仍无则该商品无图评价，与用户确认后跳过或纯文字评价。

## 3. 填文案 + 注入图片（评价页 tab，导航到 publish URL 后执行）

评价页 URL 直接构造（不需要点"去评价"按钮）：

```
https://comment.m.jd.com/pc-static/publish?orderId={orderId}&skuId={wareId}&commentType=1
```

一次 evaluate 完成等表单 → 填字 → 取图 → 注入 → 等预览：

```js
(async () => {
  const sleep = (ms) => new Promise(r => setTimeout(r, ms));
  let ta = null;
  for (let i = 0; i < 24; i++) {
    ta = document.querySelector('.rate-comment-content-textarea');
    if (ta && document.querySelector('.uploadAddInput')) break;
    await sleep(500);
  }
  if (!ta) return JSON.stringify({error: '表单未渲染', url: location.href});
  const text = '{评价文案：约110字，按品类微调}';
  const setter = Object.getOwnPropertyDescriptor(HTMLTextAreaElement.prototype, 'value').set;
  setter.call(ta, text);
  ta.dispatchEvent(new Event('input', {bubbles: true}));
  const urls = ['{图1s800x800URL}', '{图2}', '{图3}', '{图4}'];
  const fi = document.querySelector('.uploadAddInput');
  const dt = new DataTransfer();
  const fetches = [];
  for (let i = 0; i < urls.length; i++) {
    fetches.push(fetch(urls[i], {mode: 'cors'}).then(r => r.blob()).then(b => { dt.items.add(new File([b], 'jd_photo_' + (i + 1) + '.jpg', {type: 'image/jpeg'})); return {i, ok: true, size: b.size}; }));
  }
  const results = await Promise.all(fetches.map(p => p.catch(e => ({ok: false, err: String(e).slice(0, 60)}))));
  if (!results.every(r => r.ok)) return JSON.stringify({fetchFailed: results});
  fi.files = dt.files;
  fi.dispatchEvent(new Event('change', {bubbles: true}));
  for (let t = 0; t < 12; t++) {
    await sleep(1000);
    const imgs = [...document.querySelectorAll('img')].filter(im => im.offsetWidth && /^blob:/.test(im.src));
    if (imgs.length >= 4) return JSON.stringify({textLen: ta.value.length, imgsIn: fi.files.length, previews: imgs.length});
  }
  return JSON.stringify({textLen: ta.value.length, imgsIn: fi.files.length, previews: 0, warn: '预览未出现'});
})()
```

要点：
- 原生 setter + input 事件缺一不可（React 受控组件）。
- `360buyimg.com` 图片带 CORS 头，页内 fetch 可行；若某张 fetch 失败，回退用缩略图 URL 或重抽一张。
- 注入成功标志：`previews >= 4`（blob: 预览图）。
- fetch 失败列表会原样返回，先看 `fetchFailed` 再决定回退。

## 4. 提交并验证

```js
(async () => {
  const sleep = (ms) => new Promise(r => setTimeout(r, ms));
  const btn = document.querySelector('.rate-publish-submit-button') || document.querySelector('.rate-publish-submit');
  if (!btn) return JSON.stringify({error: 'no submit button'});
  btn.click();
  for (let t = 0; t < 12; t++) {
    await sleep(1000);
    const text = (document.body.innerText || '');
    if (/发布成功|评价成功|提交成功/.test(text)) return JSON.stringify({done: true, waitedSec: t + 1});
    if (/发布失败|评价失败|内容包含|违规/.test(text)) return JSON.stringify({failed: true, hint: text.replace(/\s+/g, ' ').match(/.{0,25}(发布失败|评价失败|内容包含|违规).{0,25}/g)});
  }
  return JSON.stringify({timeout: true, url: location.href});
})()
```

需要硬证据时（可选）：`adb_network` 查 `api.m.jd.com/client.action`（functionId=`tradeComment`）响应体含 `"success":true`。

## 5. 全部完成后的全局验证（评价中心 tab reload 后）

```js
(async () => {
  const sleep = (ms) => new Promise(r => setTimeout(r, ms));
  for (let i = 0; i < 20; i++) {
    const body = document.body.innerText || '';
    const cards = document.querySelectorAll('.wait-rate-card').length;
    if (cards > 0 || /暂无|已经到底了/.test(body)) {
      return JSON.stringify({waitCards: cards, empty: body.includes('暂无')});
    }
    await sleep(500);
  }
  return JSON.stringify({timeout: true});
})()
```

## 6. 备用：hook window.open 捕获"去评价"跳转 URL

仅当 publish URL 模板失效（京东改版）时，回退到真实点击路径——在评价中心 tab 执行：

```js
(async () => {
  const captured = [];
  const orig = window.open;
  window.open = function(u) { captured.push(String(u)); return null; };
  const card = document.querySelector('.wait-rate-card');
  const btn = [...card.querySelectorAll('.rate-btn')].find(el => el.textContent.trim() === '去评价');
  btn.click();
  await new Promise(r => setTimeout(r, 3000));
  window.open = orig;   // 必须还原
  return JSON.stringify({captured});
})()
```

从捕获的 URL 反推新模板的参数结构。

## 7. 失效重定位法（京东改版后的自检顺序）

任一步选择器/接口失效时，按此顺序重新探测，不要猜：

1. **列表容器**：找文本"正新鸡排"等已知 `wname` 的叶子元素（`el.childElementCount === 0 && el.textContent.trim() === '{已知名}'`），沿 parentElement 链打印每层 `className` 与 `sameClassSiblings`（同级同名 class 数量 = 条目数的那层就是卡片容器）。
2. **数据源**：确认卡片元素是否有 `__reactFiber$` 键；沿 fiber 向上找 props 里含 `wareId`（或新字段名）的对象。字段改名时打印 depth=1 组件的完整 propKeys + JSON 头部 260 字符观察结构。
3. **按钮层**：找目标文本叶子，沿 DOM/fiber 双链找第一个 `typeof props.onClick === 'function'` 的层，`el.click()` 要点在那层。
4. **表单控件**：在 publish 页 `document.querySelectorAll('textarea')` / `input[type=file]`，无则等 SPA 渲染（轮询 12 秒）再查；星级区看 `[class*=score]` 是否仍默认"非常好"。
5. **评价接口**：导航接口 URL 后先打印 `raw.slice(0, 200)` 判断 JSON/JSONP/错误页，再调整剥壳正则；`images` 结构变化时打印首条评论的全部 keys。

## 8. 登录状态检测（流程第 1 步，评价中心 tab）

```js
(async () => {
  const sleep = (ms) => new Promise(r => setTimeout(r, ms));
  // 等 SPA 渲染出主体内容（顶部导航 + 列表/统计区）
  for (let i = 0; i < 20; i++) {
    if ((document.body.innerText || '').includes('评价中心')) break;
    await sleep(500);
  }
  const body = document.body.innerText || '';
  const loggedOut = /你好，请登录|登录\/注册|立即登录|免费注册/.test(body);
  // 已登录标志：顶部存在指向 home.jd.com 的昵称链接（文本非"登录/注册"类）
  const nick = [...document.querySelectorAll('a[href*="home.jd.com"]')]
    .map(a => a.innerText.trim())
    .filter(t => t && t.length >= 2 && !/登录|注册/.test(t));
  return JSON.stringify({loggedIn: !loggedOut && nick.length > 0, nickname: nick[0] || null, url: location.href});
})()
```

判定与处置：
- `loggedIn: true` → 继续后续步骤。
- `loggedIn: false` → 停止，告知用户"请在浏览器手动登录京东后说继续"。**不要代输账号密码或短信验证码。**
- 京东未登录时也可能自动弹登录框（`login2025` 弹窗），同样视为未登录处理。

外卖订单过滤（流程第 2 步配套，对第 1 节的输出做后处理即可）：

```js
// items = 第 1 节返回的列表
const isTakeout = (it) => /-.*店$/.test(it.wname);
const kept = items.filter(it => !isTakeout(it));
const excluded = items.filter(isTakeout);
```

疑似判定命中时跳过并在结果中列出 `excluded`；`wname` 规则漏判时补充人工核对（无激励 + 店铺 logo 图的条目请用户确认）。
