---
name: xmz-commit-skill
description: 适用于用户 xmz 的 Git 提交规范(逐文件粒度 + 多 agent 并行摘要)。当用户说"提交"、"提交代码"、"commit"、"git commit"、"创建 commit"、"做一次提交"、"打个提交"、"批量提交"或要求生成 Git 提交时触发。流程:git status 收集 → 用户勾选排除 → N 个 agent 并发生成摘要 → 批量审核 → 串行逐文件 commit。强制中文 + 类型前缀,禁止 add . / amend / 跳 hook。
version: 2.1.0
---

# xmz Commit Skill

xmz 的 Git 提交工作流:**勾排除、并发摘、批量审、串行交**。每个文件独立成一个 commit,摘要由并发 agent 生成,中文 + 类型前缀。

## 核心原则

**每个文件 = 一个 commit;message 解释 why,不解释 what;并行的是大脑(摘要生成),串行的是手(commit 执行)。**

---

## 前置约束:中文编码契约

**所有 commit message 含中文 → 编码必须为 UTF-8。** 中文乱码进 git 历史不可逆,只能 force-push 修复(同样违反禁令)。

### Shell 编码

**Windows Git Bash / cmd / PowerShell**(用户主环境):

```bash
chcp 65001                      # cmd/PowerShell 切 UTF-8 代码页
export LANG=zh_CN.UTF-8         # bash locale
export LC_ALL=zh_CN.UTF-8       # 覆盖所有 LC_*
export PYTHONIOENCODING=utf-8   # 防 Python 子进程输出乱码
```

**Linux/macOS**:默认 UTF-8,通常无需额外配置。验证:`locale | grep -i utf`。

### Git 全局编码(一次性配置)

```bash
git config --global i18n.commitEncoding utf-8       # commit message 存储编码
git config --global i18n.logOutputEncoding utf-8    # git log 输出编码
git config --global core.quotepath false            # 中文文件名不转义
```

提交前用 `git config --get i18n.commitEncoding` 校验,值不为 `utf-8` → 先配置再提交。

### HEREDOC 编码风险

`git commit -m "$(cat <<'EOF' ... EOF)"` 的安全性依赖三点同时满足:
1. **shell 编码**正确(前两节保证)
2. **git i18n.commitEncoding** = utf-8
3. **`<<'EOF'`** 用单引号包裹 EOF,禁止 shell 对 HEREDOC 内容做变量展开 / 反引号执行(防中文里偶现 `$x` 被误展开)

任意一项失守 → 中文进 git 后是 `?? ?? ??` 或 `锟斤拷` → **立即停下重新配置环境**,**绝不**用 `--amend` 修复(违反禁令清单第 2 条)。

### 提交后验证回路

每次串行 commit 完(步骤 7)必须执行:

```bash
git log -1 --format='%s%n%b'    # 看最新 commit message
```

输出乱码 → 编码契约失效 → 标记本次提交为失败,修复编码后**新建 commit 替换**(不 amend)。

---

## 0. 工作流总览

```
触发词 → [步骤1: 状态收集] → [步骤2: 反选排除] → [步骤3: 敏感扫描]
       → [步骤4: 并发摘要] → [步骤5: 批量审核] → [步骤6: 串行commit]
       → [步骤7: 验证]
```

任何一步异常 → **立即停下**,告知用户,不要硬着头皮往下走。

---

## 1. 步骤 1:状态收集(并行三连查)

在**同一条消息**里并行调用以下命令:

```bash
git status              # 列出所有有变化的文件(禁用 -uall)
git diff                # 看 unstaged 改动总览
git diff --cached       # 看 staged 改动总览
git log -10 --oneline   # 学习仓库 commit 风格
```

候选文件范围(**全部**进入勾选清单):
- modified 已 staged
- modified 未 staged
- untracked

> 已 staged 也要列入,用户可能误 stage 不该提交的文件。

---

## 2. 步骤 2:反选排除(关键交互)

**勾选语义**:**勾选 = 排除,未勾 = 提交**。什么都不选 = 全部提交。

### 2.1 文件数分级策略

| 文件数 | 策略 |
|-------|------|
| ≤ 4 | 单次 `AskUserQuestion`,`multiSelect: true` |
| 5 ~ 16 | 分批 `AskUserQuestion`(每批 ≤ 4 个),按目录归类后再分批 |
| > 16 | 退回 markdown 编号清单,让用户口头说"排除 #3 #5 #7" |

### 2.2 AskUserQuestion 模板(≤ 4 文件场景)

```
question: "以下是本次候选提交文件,请勾选**不要**提交的(留空 = 全部提交)。"
header: "排除清单"
multiSelect: true
options:
  - label: "applications/foo/bar.py"
    description: "modified, +12/-3"
  - label: "applications/foo/baz.py"
    description: "untracked, new file"
  - ...
```

每个 option 的 description **必须**带状态(modified/staged/untracked)和增删行数,便于用户判断。

### 2.3 分批策略(5-16 文件)

按**顶层目录**归类,每批一个目录:

```
批次 1 (目录 applications/officeProtocolCrawlerAsync/, 4 个文件)
批次 2 (目录 applications/officeFont/, 3 个文件)
...
```

每批问完 → 累计排除列表 → 进入步骤 3。

### 2.4 大批量退化(> 16 文件)

输出 markdown 编号清单:

```
**本次候选 23 个文件,数量超过批量勾选上限,请直接回复要排除的编号(如 "排除 #3 #5"):**

#1  M  applications/foo/a.py     (+12/-3)
#2  M  applications/foo/b.py     (+5/-1)
...
#23 ?? scripts/new_tool.py       (untracked, +120)
```

用户回复后再进入步骤 3。

---

## 3. 步骤 3:敏感信息扫描

**留下来的文件**(未被排除的)逐一扫描:

**文件名层(命中即停)**:
- `.env`, `.env.*`, `*.env`
- `credentials.json`, `secrets.yaml`, `config.local.*`
- `*.pem`, `*.key`, `id_rsa*`, `*.p12`

**diff 内容层**:
- AWS Key: `AKIA[0-9A-Z]{16}`
- 长度 ≥ 32 的连续 hex / base64 字符串
- 行内 `password=` / `api_key=` / `secret=` / `token=` 后跟非空值

发现疑似 → **立即停**,列出可疑行,等用户明确确认后才继续。

---

## 4. 步骤 4:并发摘要(多 agent 派发)

**核心性能优化点**:N 个文件,N 个 subagent,**一条消息里并发**调用 Task 工具。

### 4.1 派发原则

- 每个 agent 负责**一个**文件,prompt 自包含
- 用 `Explore` agent(只读、轻量、便宜),除非该文件需要跨文件上下文才能理解
- 一条消息里发出全部 N 个 Task 调用 → Claude Code 并发执行

### 4.2 Agent prompt 模板(逐字使用)

```
你是 xmz-commit-skill 派发的 commit 摘要 agent,职责单一:为单个文件生成 commit 摘要。

文件路径: <file_path>

diff 内容:
```
<git diff <file_path> 的完整输出>
```

请按以下严格格式输出(不要任何额外解释、不要 markdown 代码块包裹):

TYPE: <feat|fix|refactor|perf|docs|test|chore|style|revert>
SUBJECT: <50 字内中文摘要,动词开头,不带类型前缀>
BODY: <可选,空一行后写 why,每行 ≤ 72 字;无正文则填 (无)>

TYPE 判定优先级:
1. 新增能力 → feat
2. 修 bug → fix
3. 内部重构(不改外部行为) → refactor
4. 性能优化 → perf
5. 仅注释/文档/README → docs
6. 仅测试代码 → test
7. 仅依赖/构建/配置 → chore
8. 仅格式调整 → style
9. 回滚之前 commit → revert

硬约束:
- SUBJECT 写 why 不写 what(避免"修改了 xxx 文件")
- 中文,极简,不啰嗦
- 不要包裹 ``` 代码块,不要任何前后缀文字
```

### 4.3 并发数控制

- 文件数 ≤ 8: 全部并发
- 文件数 9 ~ 20: 分 2 批,每批最多 10 个 agent
- 文件数 > 20: 警告用户"文件数过多,建议拆分多次提交",请用户确认是否继续

---

## 5. 步骤 5:批量审核

收集所有 agent 输出,以 markdown 表格展示:

```markdown
## 摘要预览(共 N 个 commit)

| # | 文件 | TYPE | 摘要 | 正文 |
|---|------|------|------|------|
| 1 | applications/foo/a.py | feat | 新增异步并发 cookie 显式管理 | DummyCookieJar 禁用自动持久化... |
| 2 | applications/foo/b.py | fix | 修复分页时 cookie 污染 | (无) |
| 3 | applications/foo/c.py | refactor | 抽取 jsScript 路径为绝对路径 | 消除 CWD 依赖... |

请审核:
- 回复 **OK** / **1** / **确认** → 按上述顺序串行提交
- 回复 **改 #2 摘要为 xxx** → 替换指定项
- 回复 **删 #3** → 该文件改为不提交
- 回复 **取消** → 中止全部
```

用户未明确 OK 之前**不得**进入步骤 6。

---

## 6. 步骤 6:串行 commit(逐文件)

收到用户 OK 后,**严格串行**逐文件提交。**绝不**尝试并发——`.git/index` 文件锁互斥,并发必冲突。

```bash
# 文件 1
git add applications/foo/a.py    # 单文件 add,绝不 git add . / -A
git commit -m "$(cat <<'EOF'
feat: 新增异步并发 cookie 显式管理

DummyCookieJar 禁用 aiohttp 自动持久化,
cookie 完全由 self.cookies 显式控制。
EOF
)"

# 文件 2
git add applications/foo/b.py
git commit -m "$(cat <<'EOF'
fix: 修复分页时 cookie 污染
EOF
)"

# ...
```

任何一个 commit 失败(pre-commit hook 拒绝、签名失败等):
1. **立即停下**,不继续后续文件
2. 报告失败原因
3. 等用户决策:修复后重 add → **新建 commit**(绝不 `--amend`),或跳过该文件

---

## 7. 步骤 7:验证

```bash
git status                          # 工作树是否干净(未排除文件应全部进 commit)
git log -<N> --oneline --stat       # 看最近 N 个 commit 是否符合预期
```

输出最近 N 条 commit 摘要给用户,确认全部成功。

---

## 8. 类型前缀对照

| 前缀 | 含义 | 适用场景 |
|------|------|---------|
| `feat` | 新功能 | 引入全新能力 |
| `fix` | 修复 | 修正已知 bug |
| `refactor` | 重构 | 不改外部行为的内部重组 |
| `perf` | 性能 | 性能优化(不改功能) |
| `docs` | 文档 | README / CLAUDE.md / 注释 / API 文档 |
| `test` | 测试 | 新增或修改测试 |
| `chore` | 杂项 | 依赖更新、构建脚本、配置文件 |
| `style` | 格式 | 不影响运行的格式调整 |
| `revert` | 回滚 | 撤销之前的 commit |

---

## 9. 禁令清单(铁律)

| 禁止 | 原因 | 例外 |
|------|------|------|
| `git add . / -A / *` | 单文件粒度流程要求逐个 add(**由 PreToolUse hook 自动拦截**,见 `~/.claude/settings.json`) | 无例外 |
| `git commit --amend` | 改写历史 | 用户**明确**要求 |
| `--no-verify` | hook 是项目质量底线 | 用户**明确**要求 |
| `--no-gpg-sign` | 绕过签名策略 | 用户**明确**要求 |
| 单行 `git commit -m "..."` | 中文/换行/转义易出问题 | 极简单 ASCII 短消息 |
| 提交 `.env / *.pem / credentials.*` | 密钥泄漏 | 用户明确 + 警告后 |
| **非 UTF-8 环境下提交中文 message** | git history 出现 `锟斤拷` / `?? ??` 不可逆 | 无例外(必须先修编码) |
| **跨文件批量 commit** | 违反"每文件一 commit"约定 | 用户**明确**说"合并提交" |
| **并发 commit** | `.git/index` 互斥,必冲突 | 无例外 |
| `git push --force` 到 main / master | 摧毁主分支历史 | 用户明确 + 警告后 |

**pre-commit hook 失败处理**:commit 没生效 → 修问题 → 重新 add → 创建**新 commit**(绝不 `--amend` 修复)。

---

## 10. Rationalization 表(自检清单)

| 借口 | 现实 |
|------|------|
| "git add . 比较快" | 流程明确要求逐文件,效率不是借口 |
| "几个文件改的相关,合并 commit 算了" | git log 粒度越粗越难 bisect / revert |
| "并行 commit 应该能加速" | `.git/index` 文件锁互斥,并发必冲突 |
| "agent 摘要可能不准,直接 commit 算了" | 不准就让 agent 重生成,不是跳过审核的理由 |
| "amend 一下不影响" | 已 push 的 amend 等于改写历史 |
| "hook 太严先 --no-verify" | hook 反映的是项目底线,该修问题不是绕过 |
| "这是私有仓库,提交 .env 没事" | 仓库可能变 public,token 可能 leak,永远不提交密钥 |
| "用户没勾排除,默认全提交,sensitive 文件也算" | 默认全提交不豁免敏感扫描,扫到照样停 |
| "中文乱码了 amend 一下修编码" | amend = 改写历史 = 违反禁令第 2 条;新建 commit 替换才对 |
| "hook 拦了 git add . 我用 git stage 绕过" | git stage 是 git add 别名,行为等价,违反单文件粒度;真要批量请展开为单文件列表 |
| "shell 编码先不管,提交看看" | 中文乱码进 git 不可逆,先 chcp/LANG 验证再提交 |

---

## 11. Red Flags(出现立即停下)

- `git status` 里有 `.env` / `credentials.json` / `*.key` / `*.pem`
- diff 里出现 `AKIA[A-Z0-9]+` / 长 token / `password=` 后跟非空值
- 想跳过步骤 5 的审核直接 commit
- 想用 `git add .` 简化逐文件 add
- 想"并行" git commit
- pre-commit hook 失败后想 `--amend` 修复
- agent 输出格式不规范(没有 TYPE/SUBJECT/BODY)还硬塞进 commit message
- 文件数 > 20 时不警告用户、直接派发 20+ 个 agent
- `git log -1` 输出含 `锟` / `??` / 问号方块 → 编码契约失效
- 准备提交含中文 message 但 shell 未设 `LANG=zh_CN.UTF-8` / `LC_ALL` / `chcp 65001`
- `git config --get i18n.commitEncoding` 不为 `utf-8` 还想直接提交

---

## 12. 完整调用示例(端到端)

**用户**: "提交一下"

**Claude 响应骨架**:

```
[步骤 1: 并行三连查]
> Bash: git status
> Bash: git diff
> Bash: git diff --cached
> Bash: git log -10 --oneline

[步骤 2: 列文件 + 反选(假设 3 个文件)]
> AskUserQuestion: 勾选不要提交的文件(multiSelect)
  - applications/foo/a.py (modified, +12/-3)
  - applications/foo/b.py (modified, +5/-1)
  - scripts/tmp_debug.py (untracked, +30)
  
[用户勾选 scripts/tmp_debug.py → 实际提交 a.py 和 b.py]

[步骤 3: 敏感扫描 a.py / b.py — 通过]

[步骤 4: 并发派发 2 个 Explore agent]
> Task(subagent_type=Explore, prompt=<a.py 的 agent prompt>)
> Task(subagent_type=Explore, prompt=<b.py 的 agent prompt>)
[两个 Task 在同一条消息里发出,并发执行]

[步骤 5: 收集结果展示表格]
| # | 文件 | TYPE | 摘要 | 正文 |
| 1 | a.py | feat | ... | ... |
| 2 | b.py | fix | ... | (无) |
请审核 → 用户回 OK

[步骤 6: 串行 commit]
> Bash: git add applications/foo/a.py
> Bash: git commit -m "$(cat <<'EOF' ... EOF)"
> Bash: git add applications/foo/b.py
> Bash: git commit -m "$(cat <<'EOF' ... EOF)"

[步骤 7: 验证]
> Bash: git log -2 --oneline --stat
> Bash: git status
```

---

## 13. 决策优先级

**安全 > 历史完整性 > 摘要质量 > 提交速度**

任何一次提交,先确认不泄漏密钥、不改写历史,再追求完美的 message,最后才是速度。
并行只优化"摘要生成",绝不优化"commit 执行"。
