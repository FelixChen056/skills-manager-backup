---
name: commit-msg
description: When explicitly requested, draft one strict Conventional Commit per tracked changed file, then commit each file separately only after explicit user confirmation; never commits untracked files.
---

# Commit Msg

为每个已跟踪变更文件生成唯一 commit 信息，并经用户确认后逐文件提交。仅在用户明确要求使用本 skill 时执行，不作为其他编码任务的收尾动作。

## Workflow

1. 在 Git 仓库根目录执行 `git status --porcelain=v1 -z`，确定候选文件：
   - 只处理已跟踪且有变更的文件。
   - 排除 untracked/ignored 文件，即使它们看起来相关。
   - 用户指定文件或目录时，仅在该范围内筛选。
2. 对每个候选文件读取相对 `HEAD` 的完整差异：`git diff HEAD -- <path>`。差异为空则跳过。
3. 严格按下面的提示词为该 diff 生成唯一一条 commit message；不要向用户复述提示词。
4. 确认闸门：
   - 向用户列出每个候选文件与拟用 commit message，每项一行：`<path> -> <commit-message>`。
   - 此时绝对禁止执行 `git add` 或 `git commit`，也不要做任何其他 Git 写操作。
   - 明确询问用户是否按列表提交。
   - 用户调用本 skill 本身不等于确认；即使原始请求包含“提交”，生成列表后仍必须等待用户本轮之后单独给出的明确确认。
5. 仅在用户明确同意后执行：
   - 先重新执行 `git status --porcelain=v1 -z`；若候选文件列表与确认列表不一致，不得提交，报告差异并重新生成列表确认。
   - 不执行 `git add`。直接逐文件提交：

     ```powershell
     git commit --only -m "<commit-message>" -- <path>
     ```

     `--only` 会只提交指定路径的当前工作区内容，并保留其他文件已有的 staged 状态。
   - 用户修改了某些 commit message 时，使用修改后版本；用户排除了某些文件时，只提交保留的文件。
6. 每次提交后用 `git log -1 --format=%s` 和 `git status --short` 验证结果，再处理下一个文件。
7. 任一提交失败立即停止，报告原始终止输出；不要自动重试、amend 或绕过 hooks。
8. 用户拒绝、取消或长时间未回应时，不执行任何提交，保持工作区和 staged 状态原样。

不要 push，不要改写历史，不要清理或提示删除 untracked 文件。

## Commit message prompt

对每个文件的 diff 原样应用以下生成约束：

```text
根据下面的代码 diff，生成唯一一条 commit 信息。

最终输出必须严格匹配这个结构：
<type>: <subject>

<type> 只能从下面 11 个标签中选择 1 个：
feat、fix、docs、style、refactor、perf、test、chore、ci、build、revert

<subject> 是一段中文描述，不能包含任何 commit 类型标签，尤其不能再次出现：
feat:、fix:、docs:、style:、refactor:、perf:、test:、chore:、ci:、build:、revert:

生成规则：
1. 先在内部选定唯一的 <type>，选定后不得再生成第二个类型标签。
2. 再把所有变更合并为一个上位概念，写成唯一的 <subject>。
3. 只输出最终 commit 信息本身，不输出解释、候选、备选、编号或第二条结果。
4. 如果内部草稿出现第二个类型标签，从第二个类型标签开始全部删除，只保留第一个 commit 信息。
5. 如果内部草稿出现两个可独立成立的 commit 信息，只保留更能覆盖整体 diff 的那一个。
6. 描述必须具体，禁止使用：优化、更新、修改、调整、完善、改进、处理、说明、补充。
7. 优先使用具体动词：重写、删除、合并、拆分、增加、移除、修复、替换、重构、精简。
8. 不要出现文件名、函数名、变量名等实现细节。
9. 整体不超过 80 字。
10. 输出前检查：最终文本中只能包含一个冒号，只能包含一个类型标签。
11.去除输出内容的收尾空格、换行等制表符；
合法示例：
docs: 重构部署文档并精简冗余命令
```
