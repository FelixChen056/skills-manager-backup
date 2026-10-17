---
name: rqdata-cli
description: Use when 查询中国金融数据——A股/港股/指数/基金/期货/期权/宏观/交易日历的行情、财务、成分股、持仓、净值等;或处理 rqdata CLI 调用问题——payload 参数、order_book_id 代码后缀(.XSHE/.XSHG/.XHKG)、NDJSON 输出、--schema 自省、HTTP 403 权限、当日数据缺失等。
---

# rqdata CLI — 中国金融数据查询

## 概述

rqdata 是米筐 RQData 的命令行封装(Go 单文件二进制),覆盖 7 大数据域 69 个命令,统一 `--payload` JSON 输入、NDJSON/JSON/CSV 输出,适合 Agent 直接调用。**禁止**为这些数据抓网页或调未验证接口。

核心原则:**参数不确定时用 `--schema` 自省,不凭记忆猜**;**命令清单以本地自省为准**(GitHub 文档滞后于本地版本)。

## 调用约定

```powershell
rqdata <group> [subgroup] <command> --payload '{...}'              # 默认 NDJSON
rqdata stock cn price --payload '{"order_book_ids":["000001.XSHE"],"start_date":"2026-10-08","end_date":"2026-10-14","fields":["close"]}' --format json
```

| Flag | 说明 |
|---|---|
| `--payload` | JSON 参数串,数据命令必填 |
| `--format` | `ndjson`(默认,每行一对象)/ `json` / `csv` |
| `--fields` | 逗号分隔,限制输出字段(结果瘦身首选) |
| `--schema` | 打印该命令参数定义(JSON) |

## 命令速查(细节见 references/commands.md)

| 域 | 命令数 | 覆盖 |
|---|---|---|
| `stock cn` | 22 | 行情/财务 PIT/业绩/研报/股东/行业/北向/融资融券/停牌/ST |
| `stock hk` | 9 | 港股行情/财务/股本/行业/分红 |
| `index` | 5 | 指数列表/行情/成分股/权重 |
| `fund` | 7 | 净值/持仓/指标/经理/分红 |
| `futures` | 7 | 合约/行情/主力合约/主力行情/基差 |
| `options` | 8 | 合约/行情/Greeks/指标/主力月份 |
| `macro` | 9 | 因子列表/CPI/PPI/GDP/PMI/利率/货币/准备金 |
| `calendar` | 3 | 交易日列表/前一/后一交易日 |

## 格式约定(高频错误点)

**标识符后缀**:

| 品种 | 带后缀? | 示例 |
|---|---|---|
| A股 / 指数 / ETF / 港股 | **带** | `000001.XSHE`(深)、`600000.XSHG`(沪)、`000300.XSHG`(指数)、`00700.XHKG`(港) |
| 期货 / 期权 / 场外基金代码 | **不带** | `IF2406`、`510300` |

**日期**:`YYYY-MM-DD`;**季度**(financial 命令):`YYYYQn` 如 `2024Q3`;**到期月份**(options):`YYMM` 如 `2503`。

**输出**:NDJSON 中数值是**字符串**(`"close":"11.78"`),下游计算前必须转数值;字段按字母序排列。

## 自省流程(按顺序)

1. `rqdata <group> --help` — 组内完整命令树。**schema list 有盲区**:`macro indicators`(宏观因子名列表)只在这里可见
2. `rqdata schema list` — 全部数据命令清单
3. `rqdata <完整命令> --schema` — 该命令每个参数的类型/必填/默认值

## 认证与权限

凭证按优先级自动加载:`RQDATAC_CONF`/`RQDATAC2_CONF` 环境变量 → `RQDATA_USERNAME`+`RQDATA_PASSWORD` → Keyring → `~/.rqdata/credentials` → 交互输入。token 过期自动刷新,无需干预。`rqdata auth status` 查状态(JSON)。

**HTTP 403 `Not permit to run api xxx` = 当前账号未开通该 API 权限**(本机 license 账号对整个 macro 域 econ.* 均无权限)。这是确定性错误:**不要重试**,直接如实报告需要换有权限的账号。

## 陷阱清单

| 陷阱 | 正确做法 |
|---|---|
| 当日行情返回 null | 交易日当天数据可能尚未入库;用 `calendar prev` 取最近可得交易日再查,不代表代码错误 |
| 单复数:`index constituents` 用 `order_book_id`(单数) | 见 references/commands.md 参数表,不确定就 `--schema` |
| macro `factors` 必填 | 取值来自 `rqdata macro indicators` 的 `indicator` 字段(中文全名),不要编造 |
| financial 用 `start_quarter`/`end_quarter` | 不是 `start_date`/`end_date` |
| `factor` 因子名(stock 财务指标/一致预期) | CLI 无法完整自省;查米筐因子文档后先单股小范围试跑 |
| 大结果集 | 先 `--fields` 限字段、小日期范围试跑,成功后再扩大 |

## 完整命令索引

69 个命令的用途与必填参数表:[references/commands.md](references/commands.md)
