---
name: xmz-style-check
description: Python 代码风格规范与检查。编辑/创建/重构 Python 代码时自动应用（短守卫单行、Sphinx docstring、严格类型注解）。触发检查：检查代码风格、检查风格、风格检查、style check、代码规范吗、review 代码、代码质量。
---

# xmz Python 代码风格规范与检查

## 快速自检清单

编辑 Python 代码时，优先检查以下项：

- [ ] **类型注解完整**：可选参数 `X | None = None`，返回值必须标注
- [ ] **Docstring 规范**：简化 Sphinx（`:param`/`:return:`/`:raises:`），禁 Google/NumPy 与 `:rtype:`；多行简述后**必须空行**；类型交签名注解不写进 docstring；含 `raise` 写 `:raises:`；简单函数可不写
- [ ] **短守卫单行**：`if not x: return` 不换行
- [ ] **长表达式提取**：XPath/正则/SQL 先提取为语义变量
- [ ] **中文注释**：解释 Why 不解释 What
- [ ] **长转换显式化**：复杂逻辑改用 `for` 循环，不强行推导式
- [ ] **无类型逃逸**：无 `Any`、无裸 `# type: ignore`

---

## 职责说明

本 skill 同时承担两种角色：

### 角色 1：风格规范定义（自动应用）

编辑 Python 代码时自动应用本规范。若项目已有更强的局部风格或用户给出更具体要求，以局部风格和用户要求优先。

### 角色 2：风格检查工具（主动触发）

用户明确要求检查代码风格时触发，生成详细的检查报告，指出问题位置和修复建议。不自动修改代码。

**触发检查的关键词**：
- "检查代码风格"、"检查风格"、"风格检查"、"style check"
- "这代码规范吗"、"帮我看看代码风格"、"代码写得对不对"
- "符合规范吗"、"review 代码"、"代码质量"

---

## 一、核心原则

**正确性 > 性能 > 水平紧凑度 > 传统可读性**

这个优先级反映了实际开发中的权衡：代码首先要正确，然后要快，接着追求紧凑（减少垂直滚动），最后才考虑传统的"每行不超过 80 字符"等规则。现代宽屏显示器让水平空间变得充裕，垂直空间反而更宝贵。

## 二、排版密度

**核心理念**：保持逻辑上下文的连贯性。短代码单行化减少噪音，长代码通过提取变量提升可读性。

### 短代码不换行（强制规则）

**量化标准**：单行总长度 ≤ 120 字符的简单守卫、返回、追加、continue 必须写成单行，不得换行。

简单守卫、过滤、追加、返回等逻辑优先压缩为单行。**为什么**：这些逻辑通常是"边界条件"或"快速路径"，单行化让主逻辑更突出。

```python
# ✅ 推荐：边界条件一目了然
if not records: return []
if self._api is None: return
if _is_valid_record(record): records.append(record)
if not chunk or chunk in ("LIST OF ITEMS", "- END -"): continue

# ❌ 禁止：强制换行打散逻辑流
if not records:
    return []

if self._api is None:
    return
```

**适用场景**：
- 空值检查后直接返回：`if not x: return` / `if x is None: return`
- 条件判断后 continue：`if condition: continue`
- 条件判断后 break：`if condition: break`
- 简单条件赋值/追加：`if condition: list.append(item)`

**不适用场景**（必须换行）**：
- 单行超过 120 字符
- if 块内有多条语句
- 包含复杂表达式或函数调用

### 长代码不硬压缩

表达式过长、嵌套过深、链式调用难以扫描时，先提取中间变量，再执行主逻辑。**为什么**：强行压缩会牺牲可读性和可调试性。

### 注释独立成行

使用中文解释意图和原因，不重复代码动作。**为什么**：注释应该回答"为什么这样做"，而不是"做了什么"（代码本身已经说明了）。

## 三、命名规范

| 类型 | 风格 | 示例 |
|------|------|------|
| 变量 | `snake_case` | `user_records`, `total_price` |
| 函数 | `snake_case` | `calculate_metrics`, `filter_active_items` |
| 类 | `PascalCase` | `DataProcessor`, `EventAnalyzer` |
| 私有方法 | `_underscore_prefix` | `_task_wrapper`, `_update_response` |
| 常量 | `UPPER_SNAKE_CASE` | `MAX_RETRY_COUNT` |

常量上方保留一行中文注释，说明用途和关键约束；不要使用装饰性分隔线。

```python
# 请求超时时间：避免单个外部接口阻塞整个批次
REQUEST_TIMEOUT = 15
```

## 四、长表达式处理

**核心理念**：主逻辑应该描述"做什么"，而不是"怎么做"。长表达式把实现细节混入主流程，增加认知负担。

长 XPath、长正则、长 SQL、长 URL、长链式调用和长条件判断先提取为语义变量。变量名应说明表达式用途，避免让主逻辑被细节淹没。

**Before（❌ 主逻辑被淹没）**：
```python
def parse_user_card(card):
    name = card.xpath('.//div[contains(@class, "item-name") and not(contains(@class, "alias"))]/text()').get('')
    return {"name": name}
```

**After（✅ 主逻辑清晰）**：
```python
def parse_user_card(card):
    # XPath 表达式提取后，主逻辑变成"提取姓名字段"
    name_xpath = './/div[contains(@class, "item-name") and not(contains(@class, "alias"))]/text()'
    name = card.xpath(name_xpath).get('')
    return {"name": name}
```

## 五、长转换不用推导式

**核心理念**：列表推导式适合短过滤，但一旦表达式很长、包含海象运算符、需要多步清洗或调试，显式 `for` 循环更清晰、更易调试。

**为什么不强行推导式**：
1. **可调试性**：推导式无法在中间步骤打断点
2. **可读性**：多个条件挤在一行难以扫描
3. **可维护性**：后续添加逻辑需要拆解推导式

**Before（❌ 强行推导式）**：
```python
# 一行代码包含：循环、海象、多个条件、字符串处理
items = [item for text in raw_list if (item := text.strip()) and len(item) > 5 and not item.startswith("#")]
```

**After（✅ 显式循环）**：
```python
items = []
for text in raw_list:
    # 每步逻辑独立，易于调试和修改
    if not (item := text.strip()): continue
    if len(item) <= 5: continue
    if item.startswith("#"): continue
    items.append(item)
```

**完整示例（XPath + 多步清洗）**：
```python
items = []
item_xpath = './/div[contains(@class, "detail-left")]//span[contains(@class, "detail-item")]/text()'
item_text_list = card.xpath(item_xpath).getall()
for text in item_text_list:
    if not (item_text := text.strip()): continue
    items.append(item_text)
```

## 六、表达式习惯

- 优先使用 `f-string`，不用 `%` 或 `.format()`。
- 简单二选一赋值使用三元运算符。
- 清洗、判空、复用同一临时结果时使用海象运算符 `:=`。
- 合并或补充字典时优先使用 `|` / `|=`，避免多次 `update()` 打散上下文。

```python
display_name = name_cn if name_cn else name_en
if not (clean_text := raw_text.strip()): return None
record |= {"source": source_name, "status": "ok"}
logging.info(f"{tag}处理完成，数量: {len(records)}")
```

## 七、文档注释

**核心原则**：docstring 管"接口语义"（做什么、参数/返回含义），类型注解管"数据形状"，行内注释管"意图"（为什么）。三者职责分离，docstring 不重复类型信息。

### 适用范围（先判断要不要写）

只给**复杂函数、公共函数、非显而易见的函数**写 docstring。简单私有方法（如 `_clear()`、`close()`）、一眼可懂的 getter 可不写，避免文档噪音。

### 风格（强制）

使用**简化 Sphinx 风格**，字段仅限 `:param` / `:return:` / `:raises:`。**禁止** Google Style（`Args:`/`Returns:`）与 NumPy Style（`Parameters`/`-------`）。**禁止** `:rtype:`、`:Example:` 等完整 Sphinx 指令——类型交给签名注解。

### 结构（强制，逐项判定）

多行 docstring 按以下顺序，**简述与字段之间必须空一行**（PEP 257，不可省略）：

```python
def parse_records(html: str) -> list[dict[str, str]]:
    """
    一句话简述函数作用。

    :param html: 原始 HTML 文本
    :return: 结构化记录列表
    """
```

| 段落 | 是否必须 | 说明 |
|---|---|---|
| 首行简述 | 必须 | 动词开头，一句话 |
| **空行** | 多行时必须 | 简述与字段间，漏写判 Warning |
| 详细描述 | 可选 | 仅复杂逻辑写，位于空行后、字段前 |
| `:param x:` | 按需 | 每个参数一行，顺序与签名一致 |
| `:return:` | 有返回值才写 | 返回 None 的函数可省略 |
| `:raises X:` | 含 raise 才写 | 记录可能抛出的异常类型与触发条件 |

### 字段细则

- **空行不可省**：简述后直接接 `:param`（无空行）判 Warning。这是最易漏判项。
- **`:param` 顺序**：与函数签名参数顺序一致。
- **`:return:` 省略条件**：返回 None 可省；有返回值必须写。
- **`:raises:` 触发条件**：函数体含 `raise` 时写 `:raises ExceptionType: 触发条件`。
- **类型不进 docstring**：`:param x: int, 计数` 是反模式，类型交给注解。

### 类与模块级 docstring

类 docstring、模块 docstring 同样适用简化 Sphinx。模块级 docstring 简述文件用途，单行即可。

### 正反例对照

```python
# ❌ 简述后无空行（最常见违规，漏判高发）
def get_user(user_id):
    """获取用户信息。
    :param user_id: 用户ID
    """

# ❌ Google Style
def get_user(user_id):
    """获取用户。
    Args:
        user_id: 用户ID
    """

# ✅ 空行 + Sphinx 字段 + 签名注解 + :raises:
def get_user(user_id: str) -> dict | None:
    """
    获取用户信息。

    :param user_id: 用户ID
    :return: 用户字典，不存在返回 None
    :raises UserNotFound: 用户不存在时抛出
    """
```

## 八、类型注解与 Pyrefly

**核心理念**：类型注解保证代码安全性和可维护性。完整的类型信息让 Pyrefly 能在编辑时发现潜在 bug，而不是等到运行时才崩溃。

### 必须提供类型注解

所有新增或修改的 Python 代码必须能通过 Pyrefly 类型引擎检测。函数参数和返回值必须提供类型注解。

### 可选参数的正确写法

可选参数使用 `X | None = None`，禁止省略注解写成 `X = None`。

**为什么**：省略类型写成 `X = None` 会让 Pyrefly 误判为 `X: None`（永远是 None），而非 `X: SomeType | None`。

```python
# ❌ 错误：类型检查器会认为 fields 永远是 None
def find_user(user_id: str, fields=None):
    ...

# ✅ 正确：明确表示 fields 可以是 list[str] 或 None
def find_user(user_id: str, fields: list[str] | None = None):
    ...
```

### 避免类型逃逸

- 避免使用 `Any`；如果类型确实无法确定，用 `object` 或添加 `# type: ignore[<具体规则>]` 并注明原因
- `# type: ignore` 必须指定具体规则号（如 `type: ignore[arg-type]`），禁止无差别 `# type: ignore`
- 第三方库类型存根有误时允许使用行内抑制，但必须附上注释说明原因

```python
def find_record(record_id: str, fields: list[str] | None = None) -> dict[str, str] | None:
    """按 ID 查找记录。"""
    ...

# 第三方库 typeshed 缺失，Pyrefly 无法推断返回类型
result = third_party_lib.parse(raw)  # type: ignore[no-untyped-call]
```

## 九、异步并发模式

异步批处理优先使用 `asyncio.gather(..., return_exceptions=True)` 配合 `asyncio.Semaphore` 控制并发。异常统一收集和记录，不让单个失败任务中断整个批次。

```python
async def fetch_all(urls: list[str], semaphore: asyncio.Semaphore) -> list[dict]:
    async def _task_wrapper(url: str) -> dict:
        async with semaphore:
            async with aiohttp.ClientSession() as session:
                async with session.get(url) as resp:
                    return await resp.json()

    tasks = [_task_wrapper(url) for url in urls]
    results = await asyncio.gather(*tasks, return_exceptions=True)
    for result in results:
        if isinstance(result, Exception): logging.error(f"并发任务失败: {result}")
    return [result for result in results if not isinstance(result, Exception)]
```

## 十、禁止事项

| 禁止 | 替代方案 |
|------|----------|
| 为短守卫语句强制换多行 | `if condition: return value` |
| 在很长表达式里强行写推导式 | 拆变量 + 显式 `for` |
| 让长 XPath/正则/SQL 内联在主逻辑中 | 提取为语义变量 |
| 英文注释解释业务意图 | 中文注释 |
| 为单次使用场景创建抽象 | 直接实现最小逻辑 |
| 使用无差别 `# type: ignore` | 指定具体规则号并注释原因 |
| 可选参数省略注解写成 `X = None` | 使用 `X \| None = None` |
| 使用 `Any` 绕过类型检查 | 使用 `object` 或补充精确类型 |

---

## 十一、风格检查功能

当用户主动触发"检查代码风格"时，阅读 `references/check-guide.md` 获取：

- 检查范围和问题分级（Critical / Warning / Info）
- 报告格式规范
- 使用示例和注意事项

**核心流程**：读取代码 → 逐维度检查 → 生成分级报告 → 提供修复建议
