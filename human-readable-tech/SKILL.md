---
name: human-readable-tech
description: Use when writing user-facing Chinese explanations, descriptions, analyses, plans, documents, progress updates, or review conclusions, especially when the content contains niche terminology, industry abbreviations, internal shorthand, invented labels, or compressed working notes. Apply to explanatory prose around code, commands, formulas, API fields, raw logs, and verbatim quotations; preserve those artifacts faithfully.
---

# Clear, Understandable Chinese

The user's core requirement: **AI-written explanations, descriptions, analyses, documents, and updates must be directly understandable, without making the user translate the AI's working language into ordinary language.**

Write user-facing prose in clear, natural Chinese by default. The instructions are written in English; Chinese examples and terminology labels illustrate the intended Chinese output. Honor an explicit request for another output language.

Optimize for reader comprehension while preserving factual accuracy. Adding Chinese annotations to terms is one technique; the whole passage must still be clear, concrete, and natural.

## Scope and Audience

- Apply to user-facing natural-language content, including replies, progress updates, analysis, proposals, and document prose, across engineering and other industries.
- Assume an adult who understands ordinary Chinese, logic, and the current goal. Do not assume knowledge of the industry, internal project names, code structure, or labels invented by an AI. Use a respectful, direct tone.
- This skill governs explanatory prose. Faithfully reproduce code, commands, configuration, formulas, field names, paths, raw logs, and verbatim quotations, with explanations alongside them. When the user explicitly requests editing, translating, or creating those artifacts, follow that actual request.
- Respect the user's requested original wording, technical detail, format, and style. Wording that is already clear and accurate may remain unchanged.

## Explain the Actual Matter

1. Determine what the user needs to know, separating established facts, inferences, and unknowns. When explaining existing material, first express its key facts as individual sentences, then connect them. Every added factual assertion needs supporting evidence.
2. Prefer everyday words, concrete verbs, and complete sentences that identify the subject, action, and result. Add causes, consequences, and background when supported and useful for understanding.
3. Internal notes, handoffs, compact summaries, and other agents' results are source material. Reconstruct the actual event before writing to the user; replacing a few words is insufficient.
4. Describe ordinary matters directly. Expand temporary labels, invented compounds, and internal abbreviations. If the task genuinely needs a newly named concept, define it when introducing it.
5. File names, function names, task IDs, and commit hashes locate evidence; they do not explain it. Preserve accurate identifiers beside the relevant explanation when the user needs traceability.
6. Answer the main question first, followed by necessary support. Choose length, paragraphs, lists, and tables for the question. Answer simple questions directly; avoid mandatory sections and repeated elementary explanations.

## Technical Terms and Industry Abbreviations

- Use ordinary wording when it remains accurate. If the original term is needed to match an interface, source, or industry convention, retain it and use `原术语（中文名称或含义）`.
- If the Chinese name is still specialized, add a brief explanation of what it describes or does. An English expansion, transliteration, or another obscure term alone is usually insufficient.
- Identify the subject, domain, and current provider's field definition before choosing a meaning. Explicit project definitions take precedence over a general glossary. Do not guess from an abbreviation or its capitalization.
- Reuse explanations that are already confirmed and applicable. Check reliable material when a term is ambiguous or an important definition needs confirmation. If it remains unknown, identify the specific gap and continue with other supported information.
- By default, explain a term at its first occurrence in each reply. A table intended to stand alone can explain terms in its headers. Reduce repeated annotations when the current context already makes the meaning clear.
- Industry conventions do not establish the current record's measurement basis. If it is unspecified, do not assign annualization, calendar versus trading days, single-sided versus double-sided counting, percentages versus percentage points, or similar assumptions to a particular number.
- Explain different metrics separately, attaching an unknown to the corresponding field, such as “IV 的年化口径未提供”. Do not apply one metric's limitation to other metrics.

## Preserve Meaning and Facts

- Check that subjects, values, units, calculation or counting conventions, time, scope, comparison targets, negation, causality, completion status, and certainty remain accurate.
- Keep each action's method, conditions, and frequency attached to that action. For example, rewrite “自动处理失败后交给人工” as “自动处理失败后，由工作人员接手”; do not transfer “自动” to the handoff action.
- Plans remain plans and suspicions remain suspicions. Passing some checks establishes only the checked scope. Do not invent causes, motives, verification results, or business recommendations to make an account sound complete.
- Prefer the source's explicit status phrase, adjusting word order as needed. For example, rewrite “尚未完成复现” as “复现工作尚未完成”. Assess degree of completion separately from whether an event occurred. If a record is absent, say that the record does not provide the information; absence alone does not establish whether the event happened.
- When explaining or reporting existing material, end with the established result or explicit unknown, such as “上线安排尚未确认”. Describe subsequent arrangements only when the material specifies them or the user asks for them. Purposes and benefits also need support. When the user requests a proposal or advice, clearly present new arrangements as suggestions.
- You may add confirmed definitions and necessary background. A general definition does not automatically establish the current data's units, period, calculation method, or business conclusion.
- When an inference is necessary, state its basis and what remains unconfirmed. Identify conflicts between sources rather than silently selecting one conclusion.
- Preserve the distinct sources and time scopes of user-provided information, code evidence, actual tests, and historical records. Do not present an old result or a second-hand account as something currently verified. Attach each unknown to its specific field or fact rather than generalizing one metric's limitation to all the data.

## Check Before Sending

Check silently and revise the prose when needed:

- Can the user explain what the passage actually says? Are the necessary background and relationships clear?
- Are specialized terms, internal abbreviations, invented labels, or sentences intelligible only from working notes still unexplained?
- Does a Chinese explanation depend on further unfamiliar terms? Are repetitions, introductions, or parenthetical notes unnecessary?
- Have facts, conditions, measurement conventions, status, or certainty been added, omitted, or changed? Have original artifacts been altered unintentionally?

## References to Read as Needed

- [Examples and acceptance scenarios](references/examples.md): check the boundaries between rewriting, preserving clear wording, and reporting unknowns. Each example depends on its explicitly stated facts.
- [Common finance and options terms](references/finance-terms.md): consult for relevant terminology. General meanings do not override an explicit platform or field definition.
