# 风格检查功能详细指南

本文档仅在用户主动触发"检查代码风格"时使用。

## 检查范围

本工具检查以下维度：

1. **排版密度**：短守卫是否换行、长表达式是否提取
2. **Docstring**：风格（简化 Sphinx，禁 Google/NumPy/`:rtype:`）、结构（多行简述后必须空行、`:param` 顺序与签名一致）、字段完整性（含 `raise` 是否写 `:raises:`）、类型不进 docstring、适用范围（简单函数是否过度文档）
3. **类型注解**：是否完整、是否能通过 Pyrefly
4. **注释质量**：是否中文、是否解释 Why
5. **性能模式**：是否存在低效循环
6. **命名规范**：变量/函数/类/常量命名是否符合规范

## 量化标准

为了避免主观判断，以下是具体的量化阈值：

| 检查项 | 量化标准 | 示例 |
|--------|---------|------|
| **短守卫** | 单行总长度 ≤ 120 字符 | `if not x: return` |
| **长表达式** | 单行 > 100 字符 或 嵌套层数 > 2 | XPath/正则/SQL 需提取 |
| **长推导式** | 单行 > 80 字符 且包含海象运算符或多重条件 | 改用显式 `for` 循环 |
| **复杂条件** | 逻辑运算符 > 2 个 | 提取为布尔变量 |
| **嵌套深度** | 缩进层数 > 4 | 提取函数或提前返回 |

## 问题分级

### Critical（必须修复）

- 可选参数缺少类型注解
- 使用无差别 `# type: ignore`
- 使用 `Any` 绕过类型检查
- Docstring 使用 Google/NumPy 格式，或 `:rtype:`/`:Example:` 等完整 Sphinx 指令
- 类名未使用 PascalCase
- 常量未使用 UPPER_SNAKE_CASE

### Warning（建议修复）

- 长表达式未提取变量（> 100 字符或嵌套 > 2 层）
- 长转换使用推导式（> 80 字符且包含海象运算符）
- 短守卫强制换行（≤ 120 字符仍换行）
- 英文注释
- 函数名/变量名未使用 snake_case
- 私有方法未使用 `_` 前缀
- 使用 `==` 比较 None（应使用 `is`）
- Docstring 简述后缺空行（多行 docstring，简述与 `:param` 间无空行）
- 含 `raise` 的函数缺 `:raises:`
- Docstring `:param` 顺序与函数签名不一致
- Docstring 字段写了类型信息（类型应交签名注解）

### Info（可选优化）

- 可以使用三元运算符简化
- 可以使用海象运算符
- 可以使用字典合并简化
- 嵌套深度 > 4，可提取函数
- 简单/显而易见函数写了 docstring（过度文档，可省略）

## 报告格式

风格检查报告按以下格式生成：

```markdown
# Python 代码风格检查报告

## 文件：<文件路径>

### ❌ Critical（必须修复）

**问题 1：可选参数缺少类型注解**
- 位置：第 15 行
- 当前代码：`def find_user(user_id: str, fields=None):`
- 问题说明：可选参数省略了类型注解，Pyrefly 会误判为 `fields: None`
- 修复建议：`def find_user(user_id: str, fields: list[str] | None = None):`

**问题 2：类名未使用 PascalCase**
- 位置：第 20 行
- 当前代码：`class user_service:`
- 问题说明：类名应使用 PascalCase
- 修复建议：`class UserService:`

### ⚠️ Warning（建议修复）

**问题 3：长表达式未提取变量**
- 位置：第 23 行
- 当前代码：`name = card.xpath('.//div[contains(@class, "item-name") and not(contains(@class, "alias"))]/text()').get('')`
- 问题说明：XPath 表达式超过 100 字符，降低代码可读性
- 修复建议：
  ```python
  name_xpath = './/div[contains(@class, "item-name") and not(contains(@class, "alias"))]/text()'
  name = card.xpath(name_xpath).get('')
  ```

**问题 4：短守卫强制换行**
- 位置：第 30-31 行
- 当前代码：
  ```python
  if not records:
      return []
  ```
- 问题说明：单行总长度 ≤ 120 字符的短守卫应写成单行
- 修复建议：`if not records: return []`

**问题 5：函数名未使用 snake_case**
- 位置：第 35 行
- 当前代码：`def getUserData():`
- 问题说明：函数名应使用 snake_case
- 修复建议：`def get_user_data():`

### ℹ️ Info（可选优化）

**问题 6：可以使用三元运算符简化**
- 位置：第 40-43 行
- 当前代码：
  ```python
  if name_cn:
      display_name = name_cn
  else:
      display_name = name_en
  ```
- 修复建议：`display_name = name_cn if name_cn else name_en`

---

## 总结
- Critical: 2 个（必须修复）
- Warning: 3 个（建议修复）
- Info: 1 个（可选优化）

## 修复优先级建议

1. **Critical（必须修复）**：
   - 阻塞 PR 合并
   - 修复后必须重新运行 Pyrefly
   - 典型修复时间：5-15 分钟

2. **Warning（建议修复）**：
   - 不阻塞 PR 合并，但应在下次重构时修复
   - 累计超过 10 个 Warning 时应停止新增功能，优先清理
   - 典型修复时间：10-30 分钟

3. **Info（可选优化）**：
   - 可在代码审查时讨论
   - 优先修复高频代码路径的 Info 问题
   - 典型修复时间：5-10 分钟
```

## 使用示例

### 示例 1：检查单个文件

**用户输入**：检查 user_service.py 的代码风格

**输出**：生成完整的风格检查报告，列出所有问题

### 示例 2：检查代码片段

**用户输入**：检查这段代码的风格
```python
def process(data=None):
    if data == None:
        return []
    result = [x for x in data if x.strip() != "" and len(x) > 5 and x not in ["skip", "ignore"]]
    return result
```

**输出**：
- Critical: 参数缺少类型注解
- Warning: 使用 `==` 比较 None，应使用 `is`
- Warning: 长列表推导式应改为显式 for 循环（单行超过 80 字符且包含多重条件）
- Info: 可以使用海象运算符简化

### 示例 3：命名规范检查

**用户输入**：检查这段代码的风格
```python
class user_service:
    MAX_retry_count = 3
    
    def getUserData(self):
        UserName = "test"
        return UserName
```

**输出**：
- Critical: 类名未使用 PascalCase（`user_service` → `UserService`）
- Critical: 常量未使用 UPPER_SNAKE_CASE（`MAX_retry_count` → `MAX_RETRY_COUNT`）
- Warning: 函数名未使用 snake_case（`getUserData` → `get_user_data`）
- Warning: 变量名未使用 snake_case（`UserName` → `user_name`）

### 示例 4：短守卫单行化

**用户输入**：检查这段代码的风格
```python
def process_data(data: list[str] | None = None) -> list[str]:
    # 场景 1：空值检查后返回
    if data is None:
        return []
    
    # 场景 2：API 未初始化检查
    if self._api is None:
        return
    
    # 场景 3：空列表检查
    if not data:
        return []
    
    # 场景 4：条件满足时 continue
    results = []
    for item in data:
        if not item.strip():
            continue
        if item.startswith("#"):
            continue
        results.append(item)
    
    return results
```

**输出**：
- Warning: 短守卫强制换行（第 3-4 行，单行 25 字符 ≤ 120，应单行化）
- Warning: 短守卫强制换行（第 7-8 行，单行 29 字符 ≤ 120，应单行化）
- Warning: 短守卫强制换行（第 11-12 行，单行 21 字符 ≤ 120，应单行化）
- Warning: 短守卫强制换行（第 17-18 行，单行 29 字符 ≤ 120，应单行化）
- Warning: 短守卫强制换行（第 19-20 行，单行 33 字符 ≤ 120，应单行化）

**修复后代码**：
```python
def process_data(data: list[str] | None = None) -> list[str]:
    if data is None: return []
    if self._api is None: return
    if not data: return []
    
    results = []
    for item in data:
        if not item.strip(): continue
        if item.startswith("#"): continue
        results.append(item)
    
    return results
```

### 示例 5：长表达式提取

**用户输入**：检查这段代码的风格
```python
def parse_user_card(card):
    # 场景 1：长 XPath 表达式
    name = card.xpath('.//div[contains(@class, "item-name") and not(contains(@class, "alias")) and @data-valid="true"]/text()').get('')
    
    # 场景 2：长正则表达式
    pattern = r'(?P<year>\d{4})-(?P<month>\d{2})-(?P<day>\d{2})\s+(?P<hour>\d{2}):(?P<minute>\d{2}):(?P<second>\d{2})'
    
    # 场景 3：长 SQL 查询
    result = db.execute("SELECT u.id, u.name, u.email, p.title, p.created_at FROM users u LEFT JOIN posts p ON u.id = p.user_id WHERE u.status = 'active' AND p.published = true ORDER BY p.created_at DESC")
    
    return {"name": name}
```

**输出**：
- Warning: 长表达式未提取变量（第 3 行，单行 155 字符 > 100）
- Warning: 长表达式未提取变量（第 6 行，单行 123 字符 > 100）
- Warning: 长表达式未提取变量（第 9 行，单行 210 字符 > 100）

**修复后代码**：
```python
def parse_user_card(card):
    # XPath 表达式提取后，主逻辑变成"提取姓名字段"
    name_xpath = './/div[contains(@class, "item-name") and not(contains(@class, "alias")) and @data-valid="true"]/text()'
    name = card.xpath(name_xpath).get('')
    
    # 正则表达式提取后，语义更清晰
    datetime_pattern = r'(?P<year>\d{4})-(?P<month>\d{2})-(?P<day>\d{2})\s+(?P<hour>\d{2}):(?P<minute>\d{2}):(?P<second>\d{2})'
    
    # SQL 查询提取后，主逻辑更简洁
    query = """
        SELECT u.id, u.name, u.email, p.title, p.created_at 
        FROM users u 
        LEFT JOIN posts p ON u.id = p.user_id 
        WHERE u.status = 'active' AND p.published = true 
        ORDER BY p.created_at DESC
    """
    result = db.execute(query)
    
    return {"name": name}
```

### 示例 6：长推导式改为显式循环

**用户输入**：检查这段代码的风格
```python
def filter_items(raw_list: list[str]) -> list[str]:
    # 场景 1：推导式包含海象运算符 + 多重条件
    items = [item for text in raw_list if (item := text.strip()) and len(item) > 5 and not item.startswith("#") and item not in ["skip", "ignore"]]
    
    # 场景 2：推导式包含复杂表达式
    valid_users = [{"id": u.id, "name": u.name} for u in users if u.is_active and u.email_verified and not u.is_deleted and u.created_at > cutoff_date]
    
    return items
```

**输出**：
- Warning: 长转换使用推导式（第 3 行，单行 168 字符 > 80 且包含海象运算符和多重条件）
- Warning: 长转换使用推导式（第 6 行，单行 161 字符 > 80 且包含多重条件）

**修复后代码**：
```python
def filter_items(raw_list: list[str]) -> list[str]:
    # 显式循环：每步逻辑独立，易于调试和修改
    items = []
    for text in raw_list:
        if not (item := text.strip()): continue
        if len(item) <= 5: continue
        if item.startswith("#"): continue
        if item in ["skip", "ignore"]: continue
        items.append(item)
    
    # 显式循环：复杂过滤条件清晰可读
    valid_users = []
    for u in users:
        if not u.is_active: continue
        if not u.email_verified: continue
        if u.is_deleted: continue
        if u.created_at <= cutoff_date: continue
        valid_users.append({"id": u.id, "name": u.name})
    
    return items
```

### 示例 7：类型注解完整性

**用户输入**：检查这段代码的风格
```python
def find_user(user_id: str, fields=None, include_deleted=False):
    if fields is None:
        fields = []
    return {"id": user_id, "fields": fields}
```

**输出**：
- Critical: 可选参数缺少类型注解（第 1 行，`fields=None` 应为 `fields: list[str] | None = None`）
- Critical: 可选参数缺少类型注解（第 1 行，`include_deleted=False` 应为 `include_deleted: bool = False`）
- Critical: 函数缺少返回值类型注解（应为 `-> dict[str, Any]`）
- Warning: 短守卫强制换行（第 2-3 行）

**修复后代码**：
```python
def find_user(user_id: str, fields: list[str] | None = None, include_deleted: bool = False) -> dict[str, Any]:
    if fields is None: fields = []
    return {"id": user_id, "fields": fields}
```

### 示例 8：综合场景

**用户输入**：检查这段代码的风格
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
        
        # Build query with long XPath
        users = self._api.query('.//div[@class="user-item" and not(@data-hidden="true") and @data-status="active"]/span[@class="user-name"]/text()')
        
        result = [user.strip() for user in users if user.strip() != "" and len(user.strip()) > 3 and not user.strip().startswith("_")]
        
        return result
```

**输出**：

**Critical（必须修复）**：
1. 类名未使用 PascalCase（第 1 行，`user_service` → `UserService`）
2. 可选参数缺少类型注解（第 5 行，`filter_params=None`）
3. 函数缺少返回值类型注解（第 5 行）

**Warning（建议修复）**：
4. 函数名未使用 snake_case（第 5 行，`getUserList` → `get_user_list`）
5. 英文注释（第 6 行，应使用中文）
6. 短守卫强制换行（第 7-8 行）
7. 使用 `==` 比较 None（第 10 行，应使用 `is`）
8. 短守卫强制换行（第 10-11 行）
9. 长表达式未提取变量（第 14 行，XPath 超过 100 字符）
10. 长转换使用推导式（第 16 行，包含多重条件）

**Info（可选优化）**：
11. 可以使用海象运算符简化（第 16 行的 `user.strip()` 重复调用）

**修复后代码**：
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

### 示例 9：Docstring 结构检查

**用户输入**：检查这段代码的 docstring 风格
```python
class UserService:
    """用户服务。"""

    def get_user(self, user_id: str) -> dict | None:
        """获取用户信息。
        :param user_id: 用户ID
        """
        if not self._db: return None
        return self._db.get(user_id)

    async def fetch(self, url: str, retry: int = 3) -> str:
        """请求数据，失败重试。
        :param url: 请求地址
        :param retry: 重试次数
        """
        if retry < 0: raise ValueError("重试次数不能为负")
        return await self._client.get(url)

    def build_query(self, name: str) -> str:
        """
        构建查询。

        :param name: 用户名
        :return: 查询SQL
        """
        return f"SELECT * FROM u WHERE n='{name}'"

    def _reset(self) -> None:
        """重置状态。"""
        self._state = {}
```

**输出**：

**Warning（建议修复）**：
1. `get_user` docstring 简述后缺空行（`获取用户信息。` 后直接 `:param`）
2. `get_user` 有返回值（`dict | None`）但缺 `:return:`
3. `fetch` docstring 简述后缺空行
4. `fetch` 含 `raise ValueError` 但缺 `:raises ValueError:`
5. `fetch` 有返回值（`str`）但缺 `:return:`

**Info（可选优化）**：
6. `_reset` 为简单私有方法，docstring 可省略（过度文档，非违规）

**合规确认**：
- ✅ `build_query` 结构正确（简述后空行 + `:param` + `:return:`）
- ✅ `UserService` 类级 docstring 单行简述，合规

**修复后代码**：
```python
class UserService:
    """用户服务。"""

    def get_user(self, user_id: str) -> dict | None:
        """
        获取用户信息。

        :param user_id: 用户ID
        :return: 用户字典，不存在返回 None
        """
        if not self._db: return None
        return self._db.get(user_id)

    async def fetch(self, url: str, retry: int = 3) -> str:
        """
        请求数据，失败重试。

        :param url: 请求地址
        :param retry: 重试次数
        :return: 响应文本
        :raises ValueError: retry 为负数时抛出
        """
        if retry < 0: raise ValueError("重试次数不能为负")
        return await self._client.get(url)

    def build_query(self, name: str) -> str:
        """
        构建查询。

        :param name: 用户名
        :return: 查询SQL
        """
        return f"SELECT * FROM u WHERE n='{name}'"

    def _reset(self) -> None:
        self._state = {}
```

## 与其他工具的配合

### 与 code-review 的配合

在 code review 过程中，可以先用 xmz-style-check 做初步风格检查，再进行深度代码审查。

### 建议使用场景

- **开发中检查**：编写代码后主动检查风格
- **重构后验证**：大规模重构后验证代码风格一致性
- **学习规范**：通过检查报告学习和掌握代码风格规范
- **代码审查前**：作为自查工具，提前发现风格问题

## 注意事项

1. **仅检查不修改**：本工具只生成报告，不会自动修改代码
2. **需人工确认**：修复建议仅供参考，最终决策由开发者做出
3. **不替代测试**：风格检查不能替代功能测试和类型检查
4. **优先级判断**：Critical 问题应优先修复，Info 级别可根据实际情况选择

## 误报处理

如需抑制某条规则，在代码中添加注释：

```python
# xmz-style-check: disable=short-guard-newline
if very_long_condition_that_exceeds_120_characters_and_needs_multiple_checks:
    return complex_value_that_also_has_a_very_long_name

# xmz-style-check: disable=long-expression
name = card.xpath('.//div[contains(@class, "item-name") and not(contains(@class, "alias"))]/text()').get('')

# xmz-style-check: disable=naming-convention
getUserData = external_library.getUserData  # 外部库的命名风格
```

**抑制规则列表**：
- `short-guard-newline`：短守卫换行
- `long-expression`：长表达式未提取
- `long-comprehension`：长推导式
- `naming-convention`：命名规范
- `english-comment`：英文注释
- `docstring-format`：Docstring 格式

## Python 版本要求

本规范使用的特性及最低版本要求：

| 特性 | 最低版本 | 示例 |
|------|---------|------|
| 联合类型 `X \| None` | Python 3.10 | `def f(x: str \| None = None):` |
| 字典合并 `\|` / `\|=` | Python 3.9 | `dict1 \| dict2` |
| 海象运算符 `:=` | Python 3.8 | `if (x := func()):` |

**兼容性建议**：
- 如需支持 Python 3.8-3.9，在文件开头添加：
  ```python
  from __future__ import annotations
  ```
- 如需支持 Python 3.7 及以下，请使用传统类型注解：
  ```python
  from typing import Optional
  def f(x: Optional[str] = None):
  ```
