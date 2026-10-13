---
name: xmz-task-gate
description: 当用户消息包含"实现/修改/添加/新增/修复/重构/优化/删除/替换/迁移/重写/调整"等动作动词，且任务涉及代码或文件变更时使用此 skill。生成 TodoWrite 任务清单+详细步骤，经 AskUserQuestion 审批后再逐 task 执行。与 writing-plans 分工：>5 个文件或需正式 spec 时建议转 writing-plans；极简改动(1 行/错字/格式)豁免。
---

# xmz-task-gate — 前置任务闸门

代码/文件变更类任务的前置闸门：先拆 task、列步骤、审批，再动手。

## 核心工作流

```
用户消息(含触发动词)
  → 解析意图，拆为 N 个 task
  → TaskCreate 逐 task 创建，description 填写 step 序列
  → AskUserQuestion 展示清单，等待审批
  → 审批通过 → 逐 task 串行执行
  → 完成后标记 completed
```

## 触发条件

### 触发动词（任一命中即触发）

`实现` `修改` `添加` `新增` `修复` `重构` `优化` `删除` `替换` `迁移` `重写` `调整`

### 豁免场景（不触发）

- 只读操作：读文件、搜索(grep/glob)、git log/status/diff、解释代码
- 纯对话：问答、讨论方案、brainstorming 阶段
- 用户声明："直接改"/"不用清单"/"快速修复"/"小改动"
- 纯格式/错字修正（≤3 行且无逻辑变更）

## 清单格式

每个 task 通过 TaskCreate 创建：

- **subject**：一句话，动词开头，描述目标
- **description**：数字序号 step 序列，每行一个动作，极简无代码块

```
# 示例
subject: 修改 lawyerProtocolCrawlerAsync.py 重试逻辑
description: |
  1. _fetch_lawyer_list 方法中 retry=3 改为 retry=5
  2. cookie_construct 方法添加指数退避 sleep(min(2**retry,5))
  3. 运行 python lawyerProtocolCrawlerAsync.py 验证 3 律所无报错
```

### task 粒度的判断

- 1 个写入点 → 1 个 task
- 2-5 个写入点 → 每个 1 个 task
- >5 个文件 → 建议用户转 writing-plans（走正式 spec/plan），不抢地盘

## 审批交互

用 AskUserQuestion，header="审批"，multiSelect=false，固定 4 选项：

| label | description |
|-------|-------------|
| OK 开始执行 | 按清单顺序逐 task 推进 |
| 调整某 task | 在 Other 中说明改哪个 task、怎么改 |
| 补充遗漏 | 在 Other 中补充缺失的 step 或 task |
| 取消 | 不执行，清空本次创建的 task |

**审批返回后**：
- OK → 逐 task 串行执行
- 调整/补充 → 修改对应 task，重新 AskUserQuestion 审批
- 取消 → 不再执行

## 执行纪律

- 逐 task 串行：in_progress → 完成所有 step → completed → 下一个
- 禁止并发执行 task（上下文混乱）
- 每个 task 完成后才标记 completed，未完成不跨步

## 与现有 skill 边界

| skill | 场景 | xmz-task-gate 行为 |
|-------|------|--------------------|
| writing-plans | >5 文件或需正式 spec | 主动建议转 writing-plans |
| brainstorming | 需求讨论阶段 | 不触发 |
| executing-plans | 已有正式 plan | 不触发（plan 内自带 task 跟踪） |
| xmz-commit-skill | 提交操作 | 不触发 |
| xmz-tdd | TDD 循环 | 不触发（TDD 自带纪律） |
| xmz-diagnose | 诊断循环 | 不触发（诊断自带纪律） |

## 理性化防御

| 借口 | 现实 |
|------|------|
| "改动太小，不用清单" | 小改动也是改动，2 秒生成清单不亏 |
| "用户说了直接改" | 豁免场景已覆盖，其余走闸门 |
| "上下文太长，先做了再说" | 清单只需 3-5 行，反而省 token |
| "我已经在脑子里计划好了" | 写出来让用户确认，避免方向跑偏 |
| "用户没有说'修复'这词" | 动词列表是信号不是门槛，意图驱动判断 |

## Red Flags（出现立即停下）

- 想跳过清单直接调 Edit/Write
- 用户意图模糊但不去追问直接拆 task
- task 数 >5 但不建议转 writing-plans
- 审批未通过就开始执行
- 连续 3 次审批被拒还继续生成新清单 → [STOP]，请用户说明期望方向

## 决策优先级

**审批确认 > 清单完整性 > 执行速度**

宁可多问一次，不要写错方向。