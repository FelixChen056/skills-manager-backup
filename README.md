# Skills 技能池说明

本目录是 CC Switch 的技能池（`C:\Users\admin\.cc-switch\skills`），存放供各 Agent CLI 共用的 Agent Skills。
整个目录本身是一个 git 仓库（远程：`FelixChen056/skills-manager-backup`），可运行同目录下的 `skill-backup.cmd`
执行「pull → status → add → commit → push」的定期备份。

共收录 **26 个 skill** + 1 个备份脚本。按来源平台分为四类：OpenAI Codex 官方、Anthropic 官方、
社区（skills.sh / npx skills 生态）、用户自建。所有出处均于 2026-11-04 逐一经 GitHub 检索核实。

## 平台归属速查表

| Skill | 一句话能力 | 来源 / 平台归属 | 跨平台? |
|---|---|---|---|
| imagegen | AI 图像生成 / 编辑（位图资产） | **OpenAI Codex 官方**（openai/skills `.system`） | ❌ Codex 专属 |
| pdf | PDF 读取 / 生成 / 渲染视觉校验 | **OpenAI Codex 官方**（openai/skills `.curated`） | ✅ 工具通用，为 Codex 打包 |
| playwright | playwright-cli 浏览器终端自动化 | **OpenAI Codex 官方**（openai/skills `.curated`） | ✅ 工具通用，为 Codex 打包 |
| playwright-interactive | js_repl 持久浏览器 / Electron 调试 | **OpenAI Codex 官方**（openai/skills `.curated`） | ❌ 依赖 Codex `js_repl` 特性 |
| review-agent | 只读「缺陷优先」代码审查 | **OpenAI Codex 内置**（Codex `.system` skill） | ✅ 纯指令，通用 |
| frontend-design | 高辨识度生产级前端设计 | **Anthropic 官方**（anthropics/skills） | ✅ 纯指令，通用 |
| find-skills | 发现 / 安装新 skill（`npx skills`） | skills.sh 生态官方配套 | ✅ 跨 agent |
| huashu-design | HTML 高保真原型 / 幻灯片 / 动画 | 社区 `alchaincyf/huashu-design`（MIT） | ✅ 跨 agent |
| design-taste-frontend | tasteskill v2 反 AI-slop 艺术指导 | 社区 `Leonxlnx/taste-skill`（MIT） | ✅ 跨 agent |
| impeccable | 前端设计 / 审查 / 打磨全流程 | 社区 `pbakaus/impeccable` | ✅ 跨 agent（Codex `$` 命令风格） |
| baseline-ui | Tailwind UI 基线规范检查 | 社区（skills.sh，sickn33） | ✅ 通用 |
| gpt-taste | Awwwards 级前端（AIDA + GSAP） | 社区 `sickn33/agentic-awesome-skills` | ✅ 通用（为 GPT/Codex 改写，仅手动调用） |
| eli5 | 按受众水平解释任意概念 | 社区（广泛流传） | ✅ 通用 |
| redesign-existing-projects | 存量项目设计升级审计 | 社区（广泛流传） | ✅ 通用 |
| codeagent | codeagent-wrapper 多后端调度 | 社区（codeagent-wrapper 配套） | ✅ 通用（需安装该 CLI） |
| handoff | 会话压缩成交接文档 | 社区原版 + 用户自定义规则 | ✅ 通用 |
| antidebug-breaker-skills | 反调试绕过 / JS 加密逆向 / 隐藏路由 | 用户自建 | ✅ 通用（依赖 AntiDebug Breaker MCP） |
| jd-auto-review | 京东待评价商品自动评价流水线 | 用户自建 | ✅ 通用（依赖 AntiDebug Breaker MCP） |
| rqdata-cli | 米筐 RQData 中国金融数据查询 | 用户自建 | ✅ 通用（需 rqdata CLI） |
| tqsdk-trading-and-data | TqSdk 期货行情 / 交易 / 回测 | 用户自建 | ✅ 通用（需 TqSdk） |
| human-readable-tech | 面向用户的中文可读技术表达 | 用户自建 | ✅ 通用 |
| xmz-commit-skill | xmz Git 提交工作流（逐文件 commit） | 用户自建（xmz 个人规范） | ✅ 通用 |
| xmz-style-check | Python 代码风格规范与检查 | 用户自建（xmz 个人规范） | ✅ 通用 |
| xmz-task-gate | 代码变更前置任务审批闸门 | 用户自建（xmz 个人规范） | ⚠️ 依赖 Claude Code 工具 |
| skill-backup.cmd | 目录 git 备份脚本（非 skill） | 用户自建运维脚本 | — |

---

## 一、OpenAI Codex 官方（出自 github.com/openai/skills，5 个）

Codex CLI 的官方技能库分 `.system`（系统内置，随 CLI 分发）与 `.curated`(官方精选) 两层，
下列 skill 与仓库内容逐一比对一致。

### imagegen
- **能力**：生成 / 编辑位图图片（网站资产、游戏素材、UI mockup、纹理、透明底抠图等）。
  默认走 Codex 内置 `image_gen` 工具（无需 API Key）；备选 CLI 模式 `scripts/image_gen.py`
  （需 `OPENAI_API_KEY`，支持 generate / edit / generate-batch）。
- **平台**：❌ **Codex 专属** —— 依赖 Codex 内置 `image_gen` 工具与 `$CODEX_HOME` 保存路径约定（openai/skills `.system`）。
- **调用**：Codex 内自动触发，或 `$imagegen`。

### pdf
- **能力**：PDF 读取、程序化生成（reportlab）、文本抽取（pdfplumber / pypdf），
  交付前用 Poppler（pdftoppm）渲染成 PNG 做视觉校验。
- **平台**：openai/skills `.curated`。工具链（Python 库 + Poppler）本身跨平台，但打包面向 Codex。

### playwright
- **能力**：终端驱动真实浏览器（导航、填表、快照、截图、取数、UI 流程调试），
  优先用自带 wrapper 脚本调用 `playwright-cli`，明确不走 `@playwright/test`。
- **平台**：openai/skills `.curated`。wrapper 路径约定为 `$CODEX_HOME/skills/playwright/`（面向 Codex 安装布局）。

### playwright-interactive
- **能力**：用持久 `js_repl` 会话调试本地 Web / Electron 应用——QA 清单 → 启动 → 复用同一组
  Playwright 句柄 → 功能 QA + 视觉 QA 双轮 → 截图取证。
- **平台**：❌ **Codex 专属** —— `js_repl` 是 Codex CLI 的特性，需在 `~/.codex/config.toml` 开启
  `[features] js_repl = true`，且当前要求非沙箱模式运行。

### review-agent
- **能力**：只读、缺陷优先的代码变更审查（未提交变更 / 基线分支 diff / 单个 commit），
  按 P0–P3 输出每个可行动发现，不修改文件、不委托他人。Codex CLI 将其作为内置 `.system` skill 分发
  （多台机器的 `.agents/skills/.system/` 下均有同文件）。内容为纯指令，任何 Agent 均可使用。

## 二、Anthropic 官方（出自 github.com/anthropics/skills，1 个）

### frontend-design
- **能力**：生成有辨识度、生产级的前端界面——先选定大胆的美学方向（极简 / 极繁 / 复古未来 / 杂志编辑风等），
  再在字体、配色、动效、空间构成上执行到位，明确禁止 Inter/Roboto、紫色渐变等「AI 味」默认审美。
- **平台**：Anthropic 官方技能库（Claude Code / Claude 生态），正文以 Claude 为第一人称；
  但内容是纯设计指令，无平台私有依赖，其他 Agent 亦可使用。

## 三、社区技能（skills.sh / `npx skills` 生态及 GitHub 社区，10 个）

skills.sh 是开放的跨 Agent 技能市场（CLI：`npx skills find/add`），技能安装在 `.agents/skills/`
并链接到各 Agent。下列均经 GitHub 检索定位到原始仓库。

### find-skills
- **能力**：引导用户发现并安装新 skill——先查 skills.sh 排行榜，再 `npx skills find <query>` 搜索，
  按安装量 / 来源信誉 / star 数甄别后推荐。
- **来源**：skills.sh 生态官方配套 skill（随 `npx skills` CLI 分发，众多项目 `.agents/skills/` 中均有收录）。

### huashu-design（花叔Design）
- **能力**：用 HTML 产出可交付的设计——高保真交互原型、1920×1080 幻灯片、时间轴动画 Demo（可导出 MP4/GIF）、
  信息图；按任务化身 UX 设计师 / 动画师 / 幻灯片设计师；含 40 种 HTML 原生风格库、三版设计方向顾问、
  5 维设计评审；核心原则「事实验证先于假设」（涉产品事实必先 WebSearch）。
- **来源**：社区 `alchaincyf/huashu-design`（MIT，2026-05 起），安装方式 `npx skills add alchaincyf/huashu-design`，
  明确支持 Claude Code、Cursor、Codex、OpenClaw、Hermes。

### design-taste-frontend（tasteskill v2）
- **能力**：基于 247 个获奖网站（One Page Love / Awwwards）研究的反 AI-slop 前端技能：
  `draw.mjs` 从风格库发 3 个设计方向供选择 → 生成字体 / 配色 / hero / 区块蓝图 →
  `inspect.mjs` 真实浏览器三宽度检测宅规（无渐变、无紫罗兰、标题 ≤2 行等）→ 截图自评修复循环。
  页面（营销页 / 落地页）与应用界面（dashboard / 后台）各有独立流程。需 Node 22+ 与 Chrome/Edge。
- **来源**：社区 `Leonxlnx/taste-skill`（MIT），skills.sh / Codex 插件市场分发。

### impeccable
- **能力**：前端设计全流程大技能——craft / shape / audit / polish 等子命令各有关卡文件；
  以 PRODUCT.md / DESIGN.md 为项目上下文，OKLCH 配色生成、对比度硬校验、排版 / 布局 / 动效 /
  交互细则、设计检测 hook、drift 修复 doctor。
- **来源**：社区 `pbakaus/impeccable`（Paul Bakaus），skills.sh 明星技能；文档以 Codex 的 `$命令`
  语法为主（`.agents/skills/` 安装布局），亦适配 Claude Code（`/命令`）等。

### baseline-ui
- **能力**：Tailwind 项目的 UI 基线守则——动画时长 / 合成器属性、排版缩放、组件可访问性
  （Base UI / Radix 等原语、aria-label）、`h-dvh`、`text-balance`、禁渐变等硬约束，防「AI 生成界面 slop」。
- **来源**：社区（skills.sh，作者 sickn33）。

### gpt-taste
- **能力**：Awwwards 级前端设计工程——用「模拟 Python 随机」强制打破 LLM 布局惯性（Hero 架构 /
  字体栈 / 组件架构 / GSAP 范式随机组合）、AIDA 页面结构、2-3 行大标题铁律、无缝 Bento 网格、
  GSAP 滚动动效，全部动效强制尊重 `prefers-reduced-motion`。
- **来源**：社区 `sickn33/agentic-awesome-skills`（上游标注 tools: claude/cursor/codex/antigravity）；
  本地版本按「GPT / Codex 经典款」定位改写，`disable-model-invocation: true` 仅手动 `/gpt-taste` 调用。

### eli5
- **能力**：面向指定受众解释任意主题 / 代码 / 概念 / 报错——按年龄段、学历、职业角色、亲密关系
  校准语言与类比（默认 Age 5 经典 ELI5）。
- **来源**：社区广泛流传的 skill（GitHub 上大量 dotfiles / `.agents/skills/` 收录，如 DreambigOu/ELI5），
  未定位到唯一权威原始仓库。

### redesign-existing-projects
- **能力**：存量网站 / 应用设计升级——扫描现有代码栈 → 按审计清单（字体、配色、布局、间距、
  组件模式）逐项诊断通用 AI 痕迹 → 在原栈上定向修复，不推倒重写。
- **来源**：社区广泛流传（GitHub 846 处收录），未定位到唯一权威原始仓库。

### codeagent
- **能力**：调用 `codeagent-wrapper` 执行多后端 AI 编码任务——Codex（默认，深度分析）/ Claude（文档、
  快速实现）/ Gemini（UI 原型）三后端切换，支持 `@file` 引用与并行任务。
- **来源**：社区 codeagent-wrapper 工具的配套 skill（需本机安装该 CLI）。

### handoff
- **能力**：把当前会话压缩成交接文档写入 `docs/HANDOFF.md`（目标、进度与验证状态、约束与授权、
  失败尝试、恰好一个下一步），供新会话接续；文末返回可直接复制的中文接续指令。
- **来源**：社区原版（Claude Code slash 风格 frontmatter：`argument-hint` / `disable-model-invocation`，
  dotfiles 中广泛收录）+ 本地追加 8 条「Additional Custom Rules」自定义规则。

## 四、用户自建（8 个）

### antidebug-breaker-skills
- **能力**：三大方向——网站反调试识别 / 绕过与持久脚本交付；指定接口参数的 JS 加密逆向
  （默认交付纯本地 Python 复现脚本）；Vue / React 隐藏动态路由收集与加载方案。
  强调交付语义：区分「发现可疑代码 / 实际触发 / 已验证绕过」。
- **依赖**：用户的 AntiDebug Breaker 浏览器扩展及 MCP（端口 19876）；工具不可用时允许换路线。
- **附带**：`agents/openai.yaml`（Codex 元数据）。

### jd-auto-review
- **能力**：京东 PC 评价中心自动评价流水线——抓待评价列表（剔除外卖单）→ 取有图评价参考图 →
  按品类生成 ~110 字不重复好评 → React 受控组件填表 + DataTransfer 注图 → 提交验证。
  全部走 AntiDebug Breaker MCP 控制主浏览器；含 2026-09 实战验证的关键经验与选择器失效重定位法。
- **依赖**：AntiDebug Breaker MCP（extension transport）；执行前需先调 `antidebug-breaker-skills`。

### rqdata-cli
- **能力**：米筐 RQData 命令行查询——A股 / 港股 / 指数 / 基金 / 期货 / 期权 / 宏观 / 交易日历
  7 域 69 命令；`--payload` JSON 入参、NDJSON 输出；标识符后缀规则（.XSHE/.XSHG/.XHKG）、
  `--schema` 自省流程、认证与权限排查。
- **依赖**：本机 rqdata CLI；对应全局 CLAUDE.md 第 9.1 节路由规范。

### tqsdk-trading-and-data
- **能力**：TqSdk（快期）Python SDK 开发陪跑——环境检查脚本、行情 / K 线 / Tick 订阅模式、
  账户类型矩阵（TqSim / 快期模拟 / 实盘 / 股票）、下单与 TargetPosTask 纪律、回测与 TqScenario 试算、
  错误排查 FAQ，共 11 份专题参考。
- **依赖**：Python + TqSdk（可由 skill 引导安装）；附带 `agents/openai.yaml`。

### human-readable-tech
- **能力**：面向用户的中文可读技术表达规范——压缩工程语言（handoff、review note、内部缩写、
  生造标签）必须重组为自然完整中文；术语首现即注、口径不臆断、事实 / 推断 / 未知三分。
  与全局 CLAUDE.md「用户可读技术沟通」条款联动。
- **平台**：纯指令，任何 Agent 通用。

### xmz-commit-skill
- **能力**：xmz 的 Git 提交工作流——UTF-8 编码契约（防中文乱码进历史）→ git status 勾选排除 →
  N 个 agent 并发生成摘要 → 批量审核 → 逐文件串行 commit（中文 + 类型前缀），
  禁止 `add .` / `--amend` / 跳 hook。version 2.1.0。
- **平台**：通用（多 agent 并发依赖宿主 Agent 的子代理能力）。

### xmz-style-check
- **能力**：Python 代码风格规范定义 + 主动检查双角色——短守卫单行、Sphinx 风格 docstring、
  严格类型注解、中文 Why 注释等；与全局 `.claude/rules/code-style.md` 同源，含
  CHANGELOG 与 EXAMPLES。
- **平台**：纯指令，通用。

### xmz-task-gate
- **能力**：代码 / 文件变更类任务的前置闸门——触发动词（实现 / 修改 / 修复 / 重构…）命中时
  先拆 task 清单，经 AskUserQuestion 四选项审批后再逐 task 串行执行；与 writing-plans 分工
  （>5 文件转正式 spec）。
- **平台**：⚠️ 依赖 Claude Code 的 TaskCreate / AskUserQuestion 工具语义，在其他 CLI 中需等价物。

---

## 附：机制说明

- **`agents/openai.yaml`**：OpenAI Codex 的 skill 元数据文件（`interface.display_name`、
  `default_prompt` 的 `$skill` 调用语法、`policy.allow_implicit_invocation` 等）。
  带此文件的 skill（antidebug-breaker-skills、gpt-taste、handoff、imagegen、impeccable、pdf、
  playwright、playwright-interactive、review-agent、tqsdk-trading-and-data）均按 Codex 打包规范适配，
  可在 Codex 中以 `$名称` 直达；无此文件的 skill 在 Codex 中仍可正常自动触发。
- **`disable-model-invocation: true`**（gpt-taste、handoff）：Claude Code 的 frontmatter 字段，
  禁止模型自动调用，仅用户显式 `/名称` 触发。
- **skill-backup.cmd**：非 skill。cmd 批处理，依次 git pull / status / add / commit
  （`skill-backup-<时间戳>`）/ push 到 `FelixChen056/skills-manager-backup`，无变更时跳过提交。
- **备份历史**：见同目录 `.git` 与 `C:\Users\admin\.cc-switch\skill-backups`。
