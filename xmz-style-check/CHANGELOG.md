# xmz-style-check 更新日志

## [2.2.0] - 2026-07-08

### 背景

本次重构由一次 docstring 判定矛盾触发：同一 `_fetch_html` docstring 被判"符合"与"不符"两个相反结论。RED 基线测试（2 个子代理并行检查同一测试段）采集到 5 个失败样本，核心证据为 **F2**——两个子代理对"简述后是否要空行"给出相反结论，其中一个把规则完全反向理解（把违规当合规、合规当违规）。根因是 SKILL.md 第七节模板"空格（空格必须存在）"这一占位行表意歧义。

### RED 失败样本

| 编号 | 类型 | 证据 |
|------|------|------|
| F1 | 漏判 | 两个子代理都没报简述后无空行 |
| F2 | 矛盾判定 | A 判"有空行合规"，B 判"有空行违规"（规则反向理解） |
| F3 | 漏判 | 都没报 `:raises:` 缺失 |
| F4 | 漏判 | 都没判简单函数是否需要 docstring |
| F5 | 漏判 | 类/模块级 docstring 规则未触达 |

### 修改

#### 1. SKILL.md 第七节重写（SKILL.md）

- 删除歧义占位行"空格（空格必须存在）"，改为段落必要性表，逐项显式化触发条件
- 新增"字段细则"：空行不可省、`:param` 顺序、`:return:` 省略条件、`:raises:` 触发条件、类型不进 docstring
- 新增"类与模块级 docstring"规则
- 新增正反例对照（无空行 / Google Style / 合规三例）
- 细化自检清单 Docstring 项为带子判定的速查条

#### 2. check-guide.md docstring 检查补强（check-guide.md）

- 检查范围第 2 项展开为五子项（风格/结构/字段完整性/类型/适用范围），消除"只查风格类型"的漏判根因
- Critical 增：`:rtype:`/`:Example:` 等完整 Sphinx 指令
- Warning 增 4 条：简述后缺空行、含 raise 缺 `:raises:`、`:param` 顺序不一致、docstring 写类型信息
- Info 增：简单函数过度文档
- 新增示例 9：Docstring 结构检查（含合规对照样本）

#### 3. EXAMPLES.md 索引同步（EXAMPLES.md）

- 新增"Docstring 结构"分类（场景 1 空行、场景 2 `:raises:`）
- 按问题类型查找表增 Docstring 行

### 验证

REFACTOR 阶段重跑 RED-1 测试段，确认 F1-F5 全部被识别且无矛盾判定。

---

## [2.1.0] - 2026-06-15

### 新增

#### 1. 量化标准（check-guide.md）

补充了具体的量化阈值，避免主观判断：

| 检查项 | 量化标准 |
|--------|---------|
| 短守卫 | 单行总长度 ≤ 120 字符 |
| 长表达式 | 单行 > 100 字符 或 嵌套层数 > 2 |
| 长推导式 | 单行 > 80 字符 且包含海象运算符或多重条件 |
| 复杂条件 | 逻辑运算符 > 2 个 |
| 嵌套深度 | 缩进层数 > 4 |

#### 2. 命名规范检查（check-guide.md）

新增第 6 个检查维度：命名规范

**Critical 级别**：
- 类名未使用 PascalCase
- 常量未使用 UPPER_SNAKE_CASE

**Warning 级别**：
- 函数名/变量名未使用 snake_case
- 私有方法未使用 `_` 前缀

#### 3. 误报抑制机制（check-guide.md）

提供了规则抑制语法：

```python
# xmz-style-check: disable=short-guard-newline
if very_long_condition:
    return complex_value

# xmz-style-check: disable=naming-convention
getUserData = external_library.getUserData  # 外部库的命名风格
```

**支持的抑制规则**：
- `short-guard-newline`：短守卫换行
- `long-expression`：长表达式未提取
- `long-comprehension`：长推导式
- `naming-convention`：命名规范
- `english-comment`：英文注释
- `docstring-format`：Docstring 格式

#### 4. Python 版本兼容性说明（check-guide.md）

补充了特性的最低版本要求：

| 特性 | 最低版本 |
|------|---------|
| 联合类型 `X \| None` | Python 3.10 |
| 字典合并 `\|` / `\|=` | Python 3.9 |
| 海象运算符 `:=` | Python 3.8 |

提供了向后兼容建议（`from __future__ import annotations`）。

#### 5. 修复优先级建议（check-guide.md）

补充了每个级别的修复指导：

| 级别 | 是否阻塞 PR | 典型修复时间 | 清理阈值 |
|------|-----------|-------------|---------|
| Critical | ✅ 阻塞 | 5-15 分钟 | 立即修复 |
| Warning | ❌ 不阻塞 | 10-30 分钟 | 累计 > 10 个时优先清理 |
| Info | ❌ 不阻塞 | 5-10 分钟 | 高频代码路径优先 |

#### 6. 使用示例扩充（check-guide.md）

新增示例 3：命名规范检查，展示类名、常量、函数名、变量名的检查结果。

新增示例 4：短守卫单行化，展示多种短守卫场景的检查和修复：
- 空值检查后返回：`if data is None: return []`
- API 未初始化检查：`if self._api is None: return`
- 空列表检查：`if not data: return []`
- 条件满足时 continue：`if not item.strip(): continue`

新增示例 5：长表达式提取，展示 XPath、正则、SQL 的提取：
- 长 XPath：155 字符，提取为 `name_xpath` 变量
- 长正则：123 字符，提取为 `datetime_pattern` 变量
- 长 SQL：210 字符，提取为多行字符串

新增示例 6：长推导式改为显式循环：
- 推导式包含海象运算符 + 多重条件（168 字符）
- 推导式包含复杂表达式（161 字符）
- 修复后代码展示完整的显式循环结构

新增示例 7：类型注解完整性：
- 可选参数缺少类型注解（`fields=None` → `fields: list[str] | None = None`）
- 函数缺少返回值类型注解

新增示例 8：综合场景，展示一个包含 11 个问题的真实代码：
- 2 个 Critical（类名、类型注解）
- 7 个 Warning（函数名、英文注释、短守卫、长表达式、长推导式）
- 1 个 Info（海象运算符优化）
- 修复后代码展示完整的规范代码

### 修改

#### 1. 问题分级扩充（check-guide.md）

**Critical 级别**：
- 新增：类名未使用 PascalCase
- 新增：常量未使用 UPPER_SNAKE_CASE

**Warning 级别**：
- 新增：函数名/变量名未使用 snake_case
- 新增：私有方法未使用 `_` 前缀
- 新增：使用 `==` 比较 None（应使用 `is`）
- 补充量化标准：长表达式（> 100 字符或嵌套 > 2 层）
- 补充量化标准：长推导式（> 80 字符且包含海象运算符）
- 补充量化标准：短守卫（≤ 120 字符仍换行）

**Info 级别**：
- 新增：嵌套深度 > 4，可提取函数

#### 2. 报告格式优化（check-guide.md）

- 补充了命名规范问题的示例
- 补充了长表达式问题的完整修复建议（带代码块）
- 补充了短守卫问题的修复建议
- 添加了修复优先级建议章节

### 修复

#### 1. SKILL.md description 精简（SKILL.md）

**修复前**（280+ 字符）：
```yaml
description: Python 代码风格规范与检查工具。当编辑、创建、重构、审查任何 Python 代码时自动应用本规范（短守卫单行、中文注释、严格类型注解、长表达式提取、Sphinx Docstring）。当用户说【检查代码风格/检查风格/风格检查/style check/这代码规范吗/帮我看看代码风格/代码写得对不对/符合规范吗/review 代码/代码质量】或任何涉及 Python 代码质量、可读性、类型安全、注释规范的问题时，都应该使用本 skill 生成详细检查报告。即使用户没有明确提到"风格"或"检查"，只要涉及 Python 代码改进、优化、规范化，都应优先使用本 skill。
```

**修复后**（120 字符）：
```yaml
description: Python 代码风格规范与检查。编辑/创建/重构 Python 代码时自动应用（短守卫单行、Sphinx docstring、严格类型注解）。触发检查：检查代码风格、检查风格、风格检查、style check、代码规范吗、review 代码、代码质量。
```

**改进**：
- 长度压缩 57%
- 触发词前置到末尾，提高匹配效率
- 移除冗余描述

#### 2. 短守卫规则强化（SKILL.md）

**修复前**：
```markdown
### 短代码不换行

简单守卫、过滤、追加、返回等逻辑优先压缩为单行。
```

**修复后**：
```markdown
### 短代码不换行（强制规则）

**量化标准**：单行总长度 ≤ 120 字符的简单守卫、返回、追加、continue 必须写成单行，不得换行。

# ✅ 推荐
if self._api is None: return
if not records: return []

# ❌ 禁止
if self._api is None:
    return
```

**改进**：
- 添加"强制规则"标识
- 量化标准：≤ 120 字符
- 补充正反示例，明确"禁止"
- 添加适用/不适用场景说明

#### 3. CLAUDE.md 强制规则（~/.claude/CLAUDE.md）

在 5.1 排版密度中添加：

```markdown
- **短守卫单行化（强制）**：单行总长度 ≤ 120 字符的简单守卫（`if not x: return`、`if x is None: return`、`if condition: continue`）必须写成单行，禁止换行。
```

---

## 问题修复记录

### 问题 1：技能未被唤醒

**症状**：用户输入"检查代码风格"时，skill 未被触发

**根本原因**：
- description 过长（280+ 字符），关键触发词被淹没
- 双重角色说明混淆了触发条件

**修复方案**：
- 精简 description 从 280 字符压缩到 120 字符
- 将触发词前置到末尾
- 移除冗余的角色说明

### 问题 2：代码未单行化

**症状**：编辑代码时，短守卫未自动单行化（如 `if self._api is None:\n    return`）

**根本原因**：
1. skill 未被唤醒，规范未应用
2. CLAUDE.md 中短守卫规则不够强制
3. 系统默认行为遵循 PEP 8，倾向换行

**修复方案**：
1. 精简 SKILL.md description，提高唤醒率
2. SKILL.md 中添加"强制规则"标识和量化标准
3. CLAUDE.md 中添加"短守卫单行化（强制）"条目

---

## 文档结构变化

### 新增文件
- `CHANGELOG.md`：本文档

### 修改文件
1. `SKILL.md`：
   - description 精简（280→120 字符）
   - 短守卫规则强化（添加量化标准）

2. `references/check-guide.md`：
   - 新增量化标准章节
   - 新增命名规范检查维度
   - 新增误报抑制机制
   - 新增 Python 版本兼容性说明
   - 新增修复优先级建议
   - 扩充问题分级标准
   - 优化报告格式示例

3. `~/.claude/CLAUDE.md`：
   - 5.1 排版密度添加"短守卫单行化（强制）"

4. `test_fix_validation.md`：
   - 问题诊断记录
   - 修复方案验证清单

---

## 后续优化建议

### 高优先级
1. ✅ 补充 check-guide.md 量化标准（已完成）
2. ✅ 添加命名规范检查（已完成）
3. ✅ 补充误报抑制机制（已完成）

### 中优先级
4. ⏳ 多文件检查示例（检查整个目录）
5. ⏳ CI/CD 集成示例（GitHub Actions）
6. ✅ 版本兼容性提示（已完成）

### 低优先级
7. ⏳ 性能检查规则（O(n²) 复杂度警告）
8. ⏳ 多输出格式（JSON、HTML）
9. ⏳ 团队定制功能（`.xmz-style-check.yaml`）

---

## 兼容性说明

本次更新向后兼容，所有现有功能保持不变。

新增功能：
- 量化标准不影响现有检查逻辑，只是让标准更明确
- 命名规范检查默认启用，可通过 `# xmz-style-check: disable=naming-convention` 抑制
- 误报抑制机制不影响默认行为

---

## 贡献者

- @xmz - 初始版本、问题诊断、修复实现、文档补充

---

## 许可证

与主项目保持一致
