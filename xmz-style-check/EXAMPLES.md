# xmz-style-check 代码示例索引

本文档提供 `references/check-guide.md` 中所有代码示例的快速索引。

---

## 示例分类

### 基础示例

| 示例 | 场景 | 问题类型 | 位置 |
|------|------|---------|------|
| 示例 1 | 检查单个文件 | 通用 | check-guide.md:79 |
| 示例 2 | 检查代码片段 | 类型注解 + 推导式 | check-guide.md:85 |

### 命名规范

| 示例 | 场景 | 检查项 | 问题数 |
|------|------|--------|--------|
| 示例 3 | 命名规范检查 | 类名、常量、函数名、变量名 | 4 |

**示例代码**：
```python
class user_service:  # ❌ Critical: 应为 UserService
    MAX_retry_count = 3  # ❌ Critical: 应为 MAX_RETRY_COUNT
    
    def getUserData(self):  # ⚠️ Warning: 应为 get_user_data
        UserName = "test"  # ⚠️ Warning: 应为 user_name
```

---

### 短守卫单行化

| 示例 | 场景 | 检查项 | 问题数 |
|------|------|--------|--------|
| 示例 4 | 短守卫单行化 | 空值检查、API 初始化、continue | 5 |

**核心规则**：单行总长度 ≤ 120 字符的短守卫必须写成单行。

**常见场景**：

#### 场景 1：空值检查后返回
```python
# ❌ 错误
if data is None:
    return []

# ✅ 正确
if data is None: return []
```

#### 场景 2：API 未初始化检查
```python
# ❌ 错误
if self._api is None:
    return

# ✅ 正确
if self._api is None: return
```

#### 场景 3：空列表检查
```python
# ❌ 错误
if not data:
    return []

# ✅ 正确
if not data: return []
```

#### 场景 4：条件满足时 continue
```python
# ❌ 错误
if not item.strip():
    continue
if item.startswith("#"):
    continue

# ✅ 正确
if not item.strip(): continue
if item.startswith("#"): continue
```

---

### 长表达式提取

| 示例 | 场景 | 检查项 | 问题数 |
|------|------|--------|--------|
| 示例 5 | 长表达式提取 | XPath、正则、SQL | 3 |

**核心规则**：单行 > 100 字符或嵌套层数 > 2 的表达式必须提取为语义变量。

**常见场景**：

#### 场景 1：长 XPath 表达式（155 字符）
```python
# ❌ 错误：主逻辑被淹没
name = card.xpath('.//div[contains(@class, "item-name") and not(contains(@class, "alias")) and @data-valid="true"]/text()').get('')

# ✅ 正确：提取后语义清晰
name_xpath = './/div[contains(@class, "item-name") and not(contains(@class, "alias")) and @data-valid="true"]/text()'
name = card.xpath(name_xpath).get('')
```

#### 场景 2：长正则表达式（123 字符）
```python
# ❌ 错误
pattern = r'(?P<year>\d{4})-(?P<month>\d{2})-(?P<day>\d{2})\s+(?P<hour>\d{2}):(?P<minute>\d{2}):(?P<second>\d{2})'

# ✅ 正确
datetime_pattern = r'(?P<year>\d{4})-(?P<month>\d{2})-(?P<day>\d{2})\s+(?P<hour>\d{2}):(?P<minute>\d{2}):(?P<second>\d{2})'
```

#### 场景 3：长 SQL 查询（210 字符）
```python
# ❌ 错误：单行过长
result = db.execute("SELECT u.id, u.name, u.email, p.title, p.created_at FROM users u LEFT JOIN posts p ON u.id = p.user_id WHERE u.status = 'active' AND p.published = true ORDER BY p.created_at DESC")

# ✅ 正确：提取为多行字符串
query = """
    SELECT u.id, u.name, u.email, p.title, p.created_at 
    FROM users u 
    LEFT JOIN posts p ON u.id = p.user_id 
    WHERE u.status = 'active' AND p.published = true 
    ORDER BY p.created_at DESC
"""
result = db.execute(query)
```

---

### 长推导式改为显式循环

| 示例 | 场景 | 检查项 | 问题数 |
|------|------|--------|--------|
| 示例 6 | 长推导式改为显式循环 | 海象运算符 + 多重条件 | 2 |

**核心规则**：单行 > 80 字符且包含海象运算符或多重条件的推导式应改为显式 `for` 循环。

**常见场景**：

#### 场景 1：推导式包含海象运算符 + 多重条件（168 字符）
```python
# ❌ 错误：一行包含太多逻辑
items = [item for text in raw_list if (item := text.strip()) and len(item) > 5 and not item.startswith("#") and item not in ["skip", "ignore"]]

# ✅ 正确：显式循环，每步逻辑独立
items = []
for text in raw_list:
    if not (item := text.strip()): continue
    if len(item) <= 5: continue
    if item.startswith("#"): continue
    if item in ["skip", "ignore"]: continue
    items.append(item)
```

#### 场景 2：推导式包含复杂表达式（161 字符）
```python
# ❌ 错误
valid_users = [{"id": u.id, "name": u.name} for u in users if u.is_active and u.email_verified and not u.is_deleted and u.created_at > cutoff_date]

# ✅ 正确
valid_users = []
for u in users:
    if not u.is_active: continue
    if not u.email_verified: continue
    if u.is_deleted: continue
    if u.created_at <= cutoff_date: continue
    valid_users.append({"id": u.id, "name": u.name})
```

---

### 类型注解完整性

| 示例 | 场景 | 检查项 | 问题数 |
|------|------|--------|--------|
| 示例 7 | 类型注解完整性 | 可选参数、返回值类型 | 4 |

**核心规则**：可选参数使用 `X | None = None`，函数必须标注返回值类型。

```python
# ❌ 错误：缺少类型注解
def find_user(user_id: str, fields=None, include_deleted=False):
    if fields is None:
        fields = []
    return {"id": user_id, "fields": fields}

# ✅ 正确：完整类型注解 + 短守卫单行化
def find_user(user_id: str, fields: list[str] | None = None, include_deleted: bool = False) -> dict[str, Any]:
    if fields is None: fields = []
    return {"id": user_id, "fields": fields}
```

---

### Docstring 结构

| 示例 | 场景 | 检查项 | 问题数 |
|------|------|--------|--------|
| 示例 9 | Docstring 结构检查 | 空行、`:raises:`、适用范围、合规对照 | 6 |

**核心规则**：简化 Sphinx；多行简述后必须空行；含 `raise` 写 `:raises:`；类型不进 docstring；简单函数可不写。

**常见场景**：

#### 场景 1：简述后缺空行
```python
# ❌ 错误：简述后直接 :param
def get_user(user_id: str):
    """获取用户信息。
    :param user_id: 用户ID
    """

# ✅ 正确：简述后空行
def get_user(user_id: str):
    """
    获取用户信息。

    :param user_id: 用户ID
    """
```

#### 场景 2：含 raise 缺 :raises:
```python
# ❌ 错误：有 raise 无 :raises:
def fetch(retry: int):
    """请求。
    :param retry: 重试次数
    """
    if retry < 0: raise ValueError("负数")

# ✅ 正确：补 :raises:
def fetch(retry: int):
    """
    请求。

    :param retry: 重试次数
    :raises ValueError: retry 为负数时
    """
    if retry < 0: raise ValueError("负数")
```

---

### 综合场景

| 示例 | 场景 | 检查项 | 问题数 |
|------|------|--------|--------|
| 示例 8 | 综合场景 | 类名、类型、短守卫、长表达式、推导式 | 11 |

**问题分布**：
- Critical: 2 个（类名、类型注解）
- Warning: 7 个（函数名、英文注释、短守卫、长表达式、长推导式）
- Info: 1 个（海象运算符优化）

**原始代码**：
```python
class user_service:
    def __init__(self):
        self._api = None
    
    def getUserList(self, filter_params=None):
        # Check if API is initialized
        if self._api is None:
            return
        
        if filter_params == None:
            filter_params = {}
        
        users = self._api.query('.//div[@class="user-item" and not(@data-hidden="true") and @data-status="active"]/span[@class="user-name"]/text()')
        
        result = [user.strip() for user in users if user.strip() != "" and len(user.strip()) > 3 and not user.strip().startswith("_")]
        
        return result
```

**修复后代码**（所有问题已修复）：
```python
class UserService:
    def __init__(self) -> None:
        self._api: Any | None = None
    
    def get_user_list(self, filter_params: dict[str, Any] | None = None) -> list[str]:
        # 检查 API 是否初始化
        if self._api is None: return []
        if filter_params is None: filter_params = {}
        
        # 提取 XPath 表达式，语义化查询逻辑
        user_xpath = './/div[@class="user-item" and not(@data-hidden="true") and @data-status="active"]/span[@class="user-name"]/text()'
        users = self._api.query(user_xpath)
        
        # 显式循环 + 海象运算符
        result = []
        for user in users:
            if not (clean_user := user.strip()): continue
            if len(clean_user) <= 3: continue
            if clean_user.startswith("_"): continue
            result.append(clean_user)
        
        return result
```

---

## 快速查找

### 按问题类型查找

| 问题类型 | 相关示例 |
|---------|---------|
| 短守卫换行 | 示例 4, 7, 8 |
| 长表达式未提取 | 示例 5, 8 |
| 长推导式 | 示例 6, 8 |
| 类型注解缺失 | 示例 2, 7, 8 |
| 命名规范 | 示例 3, 8 |
| 英文注释 | 示例 8 |
| 使用 `==` 比较 None | 示例 2, 8 |
| Docstring 结构（空行/`:raises:`/适用范围） | 示例 9 |

### 按关键词查找

| 关键词 | 示例 |
|--------|------|
| `if self._api is None:` | 示例 4, 8 |
| `if not x: return` | 示例 4 |
| XPath | 示例 5, 8 |
| 正则 | 示例 5 |
| SQL | 示例 5 |
| 推导式 | 示例 2, 6, 8 |
| 海象运算符 | 示例 2, 6, 8 |
| class user_service | 示例 3, 8 |
| getUserData | 示例 3, 8 |

---

## 使用建议

### 学习路径

1. **新手**：先看示例 3（命名规范）和示例 4（短守卫）
2. **进阶**：看示例 5（长表达式）和示例 6（长推导式）
3. **精通**：看示例 8（综合场景）

### 检查流程

1. 先检查 Critical 问题（类型注解、命名规范）
2. 再检查 Warning 问题（短守卫、长表达式）
3. 最后考虑 Info 优化（海象运算符、三元运算符）

### 修复优先级

1. **Critical**：立即修复（5-15 分钟）
2. **Warning**：下次重构时修复（10-30 分钟）
3. **Info**：高频代码路径优先（5-10 分钟）

---

## 常见误区

### 误区 1：盲目单行化

❌ **错误**：单行超过 120 字符仍强制单行
```python
if very_long_condition_that_exceeds_120_characters_and_needs_multiple_checks: return complex_value_that_also_has_a_very_long_name
```

✅ **正确**：超过 120 字符时换行
```python
if very_long_condition_that_exceeds_120_characters_and_needs_multiple_checks:
    return complex_value_that_also_has_a_very_long_name
```

### 误区 2：过度提取

❌ **错误**：简单表达式也提取
```python
name_value = "test"
user_name = name_value
```

✅ **正确**：只提取 > 100 字符的表达式
```python
user_name = "test"
```

### 误区 3：忽略 Critical 问题

❌ **错误**：只修复 Warning/Info，忽略 Critical
```python
class user_service:  # ❌ Critical 未修复
    def get_user_data(self, fields=None):  # ❌ Critical 未修复
        if not fields: return []  # ✅ Warning 已修复
```

✅ **正确**：优先修复 Critical
```python
class UserService:  # ✅ Critical 已修复
    def get_user_data(self, fields: list[str] | None = None) -> list[dict]:  # ✅ Critical 已修复
        if not fields: return []
```

---

## 更新日志

- 2026-06-15: 初始版本，包含 8 个示例
- 2026-07-08: 新增示例 9（Docstring 结构检查），同步 SKILL.md 第七节重构与 check-guide.md 分级补强
