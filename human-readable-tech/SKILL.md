---
name: human-readable-tech
description: Convert technical project updates, code-change summaries, review findings, debugging results, handoffs, compacted notes, implementation reports, and jargon-heavy engineering explanations into clear natural Chinese that a non-specialist project owner can understand. Use whenever a user-facing answer contains internal task IDs, unexplained technical terms, compressed engineering shorthand, dense noun phrases, file/function names used in place of explanations, or status notes copied from agent working records. Preserve technical facts and uncertainty; simplify the explanation, not the truth.
---

# Human Readable Tech

## Purpose

Convert internal engineering language into user-readable communication.

The agent may use compact technical language internally.

The final user-facing answer must not require the user to understand the agent's internal shorthand, developer slang, implementation abbreviations, review vocabulary, or task numbering system.

The goal is not to remove technical accuracy.

The goal is:

> Preserve the facts. Expand the meaning. Explain the consequence.

---

# Default audience

Assume the user:

- understands the project and its goals;
- can understand normal software concepts when explained;
- does not necessarily know programming terminology;
- should not need to search for terminology to understand the answer;
- does not automatically know internal task IDs, abbreviations, code names, file structure, or agent-created shorthand.

Do not talk down to the user.

Do not explain obvious everyday concepts unnecessarily.

Only explain what is necessary to understand the engineering result.

---

# Core rule

Internal working language and user-facing language are different artifacts.

Internal material may contain:

`C-4`
`T0`
`fix wave`
`baseline`
`orphan`
`release dedupe`
`document_store`
`APPROVE`
`findings`
`342+215+41`
`全码清残`
`顺延`
`上提`

This is acceptable inside:

- handoff documents;
- compact summaries;
- TODO lists;
- review notes;
- commit notes;
- internal reasoning;
- subagent results;
- engineering ledgers.

It is not acceptable to copy such material directly into the user-facing answer.

Before answering the user, reconstruct the information as normal language.

---

# Translation workflow

For technical status reports, implementation summaries, code reviews, debugging explanations, or handoff-derived answers, perform the following transformation before responding.

## Step 1 — Determine what actually happened

Extract the actual facts.

Identify:

- what changed;
- what problem was found;
- why it mattered;
- whether it was fixed;
- how it was verified;
- what remains unfinished;
- what is only suspected rather than confirmed.

Do not begin by rewriting individual words.

First understand the underlying event.

---

## Step 2 — Detect compressed engineering language

Treat a phrase as potentially unreadable when it contains one or more of these patterns:

- internal task IDs such as `C-1`, `T0`, `V3-00`;
- abbreviations that have not been explained;
- English engineering terms embedded in compressed Chinese;
- agent-created shorthand;
- several nouns joined without a clear action;
- file names or function names used as if they explain the problem;
- slash-separated or plus-separated status fragments;
- statements missing a subject, action, reason, or consequence;
- unexplained test counts;
- unexplained commit ranges;
- words such as “上提”, “收口”, “清残”, “顺延”, “孤儿”, “桶”, “基线” when their project-specific meaning is not obvious.

Examples of suspicious phrases:

`四处补偿重复上提`

`T0 连带孤儿`

`shared/api 桶 109 行`

`scoped 复审 APPROVE 零 findings`

`基线后端 342 + 前端 215 + 契约 41`

These phrases require expansion before being shown to the user.

---

## Step 3 — Resolve the meaning from context

Do not guess what project-specific shorthand means.

Use available project context when necessary.

Prefer, in this order:

1. the current task and conversation;
2. the actual code or diff;
3. the relevant handoff or task document;
4. `docs/AGENT_GLOSSARY.md`, if it exists;
5. nearby documentation, tests, commits, or comments.

If the meaning still cannot be confirmed, explicitly say that the exact meaning cannot yet be confirmed.

Do not invent a plausible explanation just to make the answer sound complete.

---

## Step 4 — Expand shorthand into an event

Translate compressed phrases into:

**对象 + 发现的问题 + 做了什么 + 为什么 + 结果**

Not every answer needs all five parts, but the reader should understand the event.

Example:

Bad:

> C-4 四处补偿重复上提 `idempotency.release()`。

Good:

> 检查时发现有四个地方都在重复执行同一种失败后的清理操作。现在已经把这段共同逻辑集中到统一的位置，避免以后修改时需要同时维护四份代码。内部任务编号是 C-4。

Do not merely replace individual vocabulary.

Reconstruct the whole meaning.

---

# Terminology rules

## Standard technical terms

If a technical term is important, it may remain in the answer.

Explain it the first time.

Example:

> 这里存在“竞态条件（race condition）”，也就是两个操作几乎同时执行时，可能互相影响，导致程序使用错误的状态。

Do not repeatedly explain the same term in the same answer.

---

## Internal project terms

Internal project language must never carry the explanation by itself.

Bad:

> 出现连带孤儿。

Good:

> 删除这部分旧代码以后，还有几段代码会因为失去唯一的使用者而变成无用代码。这些相关代码也需要一起检查。项目记录里把这种情况简称为“连带孤儿”。

The plain-language explanation comes first.

The internal term is optional secondary information.

---

## File names, classes, and functions

Code identifiers are evidence and location information.

They are not explanations.

Bad:

> 修复了 `document_store` 三函数。

Good:

> 文档存储模块里有三个函数只服务于已经废弃的旧流程，目前正常功能已经不再使用它们，因此正在确认是否可以删除。

Then, if useful:

> 对应代码位于 `document_store`。

---

# Internal IDs

Task IDs may be retained for traceability, but never use them as the main description.

Bad:

> C-1、C-2、C-4、C-6 已完成。

Good:

> 这一轮已经完成四类清理：删除无用代码、清理旧的数据核对逻辑、合并重复的失败恢复代码，以及修复等待时间过短导致的不稳定测试。

Optional:

> 对应内部任务编号：C-1、C-2、C-4、C-6。

---

# Numbers and test results

Never present unexplained numbers as if their meaning were self-evident.

Bad:

> 基线 342 + 215 + 41，全绿。

Good:

> 当前确认通过的测试包括：后端 342 项、前端 215 项，以及 41 项接口契约测试，目前这些检查全部通过。

If the numbers refer to something else, explain their actual meaning.

---

# Commit hashes

Commit hashes and ranges belong in technical details unless the user explicitly asks about Git history.

Bad:

> fix wave complete 81a00d5..9327b04。

Good:

> 这一轮修复已经完成并提交。

Optional technical detail:

> 对应提交范围：`81a00d5..9327b04`。

---

# Certainty

Clearly separate:

**Confirmed**

Facts verified through code, tests, documents, commands, or direct evidence.

**Likely**

The available evidence strongly suggests something, but it has not been fully verified.

**Unknown**

The source material is too compressed or incomplete to determine the exact meaning.

Never upgrade “likely” into “confirmed” during simplification.

Simplifying language must not simplify uncertainty.

---

# User-facing response structure

Do not force every answer into a rigid template.

For substantial engineering updates, prefer this information order:

## 当前结果

Explain the overall state in ordinary language.

The user should understand the most important conclusion from this section alone.

## 具体做了什么

Describe meaningful changes by their effect, not only by file or function name.

## 还存在什么问题

Explain unfinished, uncertain, risky, or blocked work.

Omit this section when there is nothing meaningful to report.

## 技术信息

Put task IDs, file paths, function names, commits, exact test counts, or internal terminology here when they are useful for traceability.

For a simple answer, use normal paragraphs instead.

Do not create unnecessary headings.

---

# Compression rule

Conciseness is good.

Loss of meaning is not.

Never compress an answer until the reader has to infer:

- who performed an action;
- what was changed;
- what the problem actually was;
- why it mattered;
- whether something is completed;
- whether a statement is certain;
- what an internal term means.

A short complete sentence is better than a dense status fragment.

---

# Handoff and compact summaries

Handoff files, compacted conversation summaries, review notes, and agent-generated status ledgers are source material.

They are not final answers.

When responding from them:

1. extract facts;
2. discard wording that only exists for context compression;
3. reconstruct the user-facing explanation;
4. preserve technical identifiers only as secondary details.

Never lightly polish a compact summary and send it as the final answer.

Rewrite it from the user's point of view.

---

# Example

Input working note:

> V3 FINAL 清残必修六项：C-1 DependencyUnavailable 死类；C-2 document_store 对账只读段三函数（T0 连带孤儿）；C-4 四处补偿重复上提 idempotency.release()；C-6 ReviewPanel.test 三处 waitForOptions 15s；C-7 seed.py:72 时态注释；C-11 V3-00 两处已删命令残留表述。

Do not output a lightly edited version of this note.

Preferred user-facing interpretation:

> V3 的这一轮收尾清理主要处理了六类遗留问题。
>
> 其中包括删除已经没人使用的代码、检查文档存储模块里的旧函数、把四处重复的失败清理逻辑统一起来、修复三个容易因为等待时间不足而失败的前端测试，以及修正一处注释和两处已经过时的文档说明。
>
> 如果需要追踪具体代码位置，我可以再列出对应任务编号、文件和函数。

This example demonstrates style only.

When working on a real project, use the actual repository evidence rather than assuming the example interpretation is correct.

---

# Anti-patterns

Never produce user-facing status text like:

> C-4 fix wave scoped APPROVE，零 findings，顺延合规。

Never solve the problem by merely replacing English words:

> C-4 修复波范围审核批准，没有发现，延期符合规定。

Both versions remain difficult to understand.

Instead explain the event:

> C-4 对应的修改已经重新检查过，目前没有发现新的问题。原本计划后续处理的项目也已经按约定记录，没有被遗漏。

Only state this if supported by actual evidence.

---

# Final quality check

Before sending a substantial technical answer, check silently:

Can a user understand the main result without knowing the repository?

Does every important internal term either disappear or receive an explanation?

Are task IDs secondary rather than primary information?

Have compressed notes been expanded into actual events?

Do file names support the explanation rather than replace it?

Are completion status and remaining work clear?

Are verification results described in terms the user can understand?

Are uncertainty and assumptions preserved?

If the answer fails one of these checks, rewrite it before responding.

---

# Final principle

The user should never need to translate the agent's working language.

Technical precision belongs in the answer.

Engineering shorthand belongs in the working notes.

When the two conflict, preserve the technical fact and rewrite the presentation.