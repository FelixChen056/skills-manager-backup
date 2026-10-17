# rqdata CLI 命令索引(69 个数据命令)

> 基于 rqdata v1.0.5 本地自省核验(2026-10-15),比 GitHub 文档(66 个)多 `stock cn research-reports`、`futures basis`、`futures current-basis`,另有隐藏命令 `macro indicators` 不在 `schema list` 中。
> 必填参数不列出的一律为"无必填"。完整参数以 `rqdata <命令> --schema` 实时自省为准。

## 参数名单复数陷阱(高频错误)

| 命令 | 参数 | 单/复数 |
|---|---|---|
| `index constituents` / `index weights` | `order_book_id` | **单数** |
| `futures dominant` / `options dominant-month` | `underlying_symbol` | **单数** |
| `stock` / `fund` / `futures price` 等多数命令 | `order_book_ids` | 复数 |
| `futures dominant-price` / `options indicators` | `underlying_symbols` | 复数 |

## stock cn — A股(22 个)

| 命令 | 用途 | 必填参数 |
|---|---|---|
| `stock cn list` | 股票列表(可按 type/date 筛选) | 无 |
| `stock cn instruments` | A股基础信息 | `order_book_ids` |
| `stock cn price` | A股行情(日/分钟/tick,默认前复权) | `order_book_ids` |
| `stock cn dividend` | A股分红送股 | `order_book_ids` |
| `stock cn split` | A股拆股合股 | `order_book_ids` |
| `stock cn shares` | A股股本数据 | `order_book_ids` |
| `stock cn ex-factor` | A股复权因子 | `order_book_ids` |
| `stock cn industry` | A股行业分类(默认 citics_2019) | `order_book_ids` |
| `stock cn turnover-rate` | A股换手率(today/week/month/year) | `order_book_ids` |
| `stock cn margin` | A股融资融券(按日期) | 无 |
| `stock cn northbound` | 北向资金持股(可传 `all_connect`) | `order_book_ids` |
| `stock cn financial` | A股财务数据 PIT | `order_book_ids` + `fields` + `start_quarter` + `end_quarter` |
| `stock cn financial-indicator` | A股财务指标(因子) | `order_book_ids` + `factor` |
| `stock cn financial-express` | A股业绩快报 | `order_book_ids` |
| `stock cn forecast` | A股业绩预告 | `order_book_ids` |
| `stock cn consensus` | A股一致预期(因子) | `order_book_ids` + `factor` |
| `stock cn research-reports` | 券商研报 | `order_book_ids` + `fiscal_year` |
| `stock cn shareholder-top10` | 十大股东 | `order_book_ids` |
| `stock cn shareholder-top10-free` | 十大流通股东 | `order_book_ids` |
| `stock cn announcement` | 公告信息 | `order_book_ids` |
| `stock cn suspended` | 停牌信息 | `order_book_ids` |
| `stock cn st-status` | ST状态 | `order_book_ids` |

## stock hk — 港股(9 个)

| 命令 | 用途 | 必填参数 |
|---|---|---|
| `stock hk list` | 港股列表 | 无 |
| `stock hk instruments` | 港股基础信息 | `order_book_ids` |
| `stock hk price` | 港股行情 | `order_book_ids` |
| `stock hk ex-factor` | 港股复权因子 | `order_book_ids` |
| `stock hk shares` | 港股股本数据 | `order_book_ids` |
| `stock hk industry` | 港股行业分类 | `order_book_ids` |
| `stock hk turnover-rate` | 港股换手率 | `order_book_ids` |
| `stock hk dividend` | 港股分红 | `order_book_ids` |
| `stock hk financial` | 港股财务数据 PIT | `order_book_ids` + `fields` + `start_quarter` + `end_quarter` |

## index — 指数(5 个)

| 命令 | 用途 | 必填参数 |
|---|---|---|
| `index instruments` | 指数基础信息 | `order_book_ids` |
| `index list` | 指数列表 | 无 |
| `index price` | 指数行情 | `order_book_ids` |
| `index constituents` | 指数成分股 | `order_book_id`(**单数**) |
| `index weights` | 成分股权重 | `order_book_id`(**单数**) |

## fund — 基金(7 个)

| 命令 | 用途 | 必填参数 |
|---|---|---|
| `fund list` | 基金列表 | 无 |
| `fund instruments` | 基金基础信息 | `order_book_ids` |
| `fund nav` | 基金净值(单位/累计) | `order_book_ids` |
| `fund holdings` | 基金持仓 | `order_book_ids` |
| `fund indicators` | 基金指标 | `order_book_ids` |
| `fund manager` | 基金经理 | `order_book_ids` |
| `fund dividend` | 基金分红 | `order_book_ids` |

## futures — 期货(7 个)

| 命令 | 用途 | 必填参数 |
|---|---|---|
| `futures list` | 期货合约列表 | 无 |
| `futures instrument` | 期货合约基本信息 | `order_book_ids` |
| `futures price` | 期货行情 | `order_book_ids` |
| `futures dominant` | 主力合约(按品种) | `underlying_symbol`(**单数**,如 "IF") |
| `futures dominant-price` | 主力连续合约行情 | `underlying_symbols`(**复数**) |
| `futures basis` | 期现基差(历史区间) | `order_book_ids` |
| `futures current-basis` | 当前基差 | `order_book_ids` |

主力合约 `rule`(0=默认 1.1 倍持仓切换 / 1=最大昨仓 / 2=量仓双最大 / 3=末日不计)、`rank`(1 主力 / 2 次主力 / 3 次次主力);`dominant-price` 另有 `adjust_method`(默认 prev_close_spread)。

## options — 期权(8 个)

| 命令 | 用途 | 必填参数 |
|---|---|---|
| `options list` | 期权合约列表(全市场) | 无 |
| `options instruments` | 期权合约信息 | `order_book_ids` |
| `options price` | 期权行情 | `order_book_ids` |
| `options contracts` | 按标的/到期/行权价筛合约 | `underlying`(品种字母或具体合约) |
| `options greeks` | 期权希腊字母(iv/delta/gamma/vega/theta/rho) | `order_book_ids` |
| `options indicators` | 期权指标(PCR/skew/IV) | `underlying_symbols` + `maturity`(如 "2503") |
| `options dominant-month` | 期权主力月份 | `underlying_symbol`(**单数**) |
| `options contract-property` | 期权合约属性 | `order_book_ids` |

`options contracts` 的 `maturity` 是 YYMM 数字;`strike` 查询向左靠档匹配。

## macro — 宏观(9 个,含隐藏命令)

| 命令 | 用途 | 必填参数 |
|---|---|---|
| `macro indicators` | **宏观指标(因子名)列表** — 不在 schema list 中! | 无 payload |
| `macro get` | 通用宏观查询 | `factors` + `start_date` + `end_date` |
| `macro reserve-ratio` | 存款准备金率 | 无 |
| `macro money-supply` | 货币供应量 | 无 |
| `macro price-cpi` | CPI | `factors` + `start_date` + `end_date` |
| `macro price-ppi` | PPI | `factors` + `start_date` + `end_date` |
| `macro gdp` | GDP | `factors` + `start_date` + `end_date` |
| `macro pmi` | PMI | `factors` + `start_date` + `end_date` |
| `macro interest-rate` | Shibor利率 | `factors` + `start_date` + `end_date` |

**`factors` 取值来源**:`rqdata macro indicators` 输出的 `indicator` 字段(中文全名,如 `居民消费价格指数CPI_当月同比(上年同月=100)`),不要凭空编造因子名。README 示例省略 factors 属文档错误。

## calendar — 交易日历(3 个)

| 命令 | 用途 | 必填参数 |
|---|---|---|
| `calendar trading-dates` | 交易日列表 | `start_date` + `end_date` |
| `calendar prev` | 往前第 n 个交易日 | `date`(n 默认 1) |
| `calendar next` | 往后第 n 个交易日 | `date`(n 默认 1) |

## price 族共享参数(stock/index/futures/options 的 price 命令)

| 参数 | 默认 | 说明 |
|---|---|---|
| `frequency` | `1d` | `1m`/`5m` 分钟线、`1d` 日线、`1w` 周线、`tick` |
| `adjust_type` | `pre` | `none` 不复权 / `pre` 前复权 / `post` 后复权(仅股票和 ETF 有效) |
| `skip_suspended` | `false` | 是否跳过停牌期 |
| `time_slice` | 当天全部 | 分钟/tick 级切分,如 `"09:30-10:00"` |
| `market` | `cn` | `cn` 内地 / `hk` 香港 |

## 因子名(factor)获取限制

`stock cn financial-indicator` / `consensus` 的 `factor` 参数:schema 提示"可查询 get_all_factor_names() 得到",但那是 rqdatac Python SDK 函数,**CLI 无对应命令**,因子名无法完整自省。策略:用米筐因子文档确认名称后,先以单只股票小日期范围试跑验证,再扩大查询。

## 辅助命令

| 命令 | 用途 |
|---|---|
| `rqdata auth login` / `status` / `logout` | 认证管理(status 输出 JSON) |
| `rqdata schema list` | 数据命令清单(注意有盲区,见 SKILL.md) |
| `rqdata <group> --help` | 组内完整命令树(可发现 schema list 遗漏的命令) |
| `rqdata completion <shell>` | shell 补全脚本 |
