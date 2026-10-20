# Examples and Acceptance Scenarios

Each example's stated facts are its complete premises. These examples illustrate expression boundaries; they do not establish the meaning of shorthand, causes, or completion status in a real project. Alternative wording is acceptable when accurate, clear, and complete. Chinese quotations are intentional source samples and target outputs.

## 1. Keep Wording That Is Already Clear

**Known facts and request:** Polish a notice, with permission to leave it unchanged. The original text is the only source of information.

> 会议改到周五下午三点，地点仍是原会议室。

**Acceptable output:**

> 会议改到周五下午三点，地点仍是原会议室。

**Check:** Preserve the time and location. Greetings, pleasantries, explanations, and new arrangements are unnecessary.

## 2. Reconstruct the Actual Matter Behind Internal Notes

**Known facts:** Four duplicated pieces of failure-cleanup code are planned to be consolidated in one place. The change has not been implemented. The task ID is C-4.

**Hard-to-read wording:**

> C-4 四处补偿重复上提待收口。

**Acceptable output:**

> 计划把四处重复的失败清理代码合并到一处，目前尚未实施。对应任务编号是 C-4。

**Check:** Ordinary sentences explain what is planned and its current status. A plan must not become a completed change. Retain the ID when useful for traceability.

## 3. Preserve the Scope of Testing

**Known facts:** Only the export feature was changed. Its three tests passed. No other tests were run. Release arrangements remain unconfirmed.

**Unacceptable wording:**

> 基线全绿，发布闭环完成。

**Acceptable output:**

> 本次只修改了导出功能，相关的三项测试都通过了。其他测试还没有运行，上线安排也尚未确认。

**Check:** Do not expand the checked scope, turn passed tests into a released feature, infer a delay from an unconfirmed release, or add promises about subsequent updates.

## 4. Explain Financial Abbreviations Without Adding Measurement Assumptions

**Known facts:** IV=24.5%, DTE=30 days, and OI=1200 contracts. The provider defines them as implied volatility, days to expiration, and open interest. Annualization, high/low reference levels, and trading judgments were not supplied. The finance glossary provides IV's general meaning.

**Acceptable output:**

> IV（隐含波动率，即从期权价格反推的波动率）为24.5%；DTE（距到期天数）为30天；OI（未平仓合约数量，即尚未平仓的合约数量）为1200张。记录没有说明 IV 的年化口径，这里保留原始数值和单位。

**Check:** Preserve values, units, and terms. Explain Chinese names further when needed. Do not describe 24.5% as annualized, an actual future price movement, or a trading signal. Natural wording is sufficient; reproducing this exact sentence is unnecessary.

## 5. Do Not Invent Meanings for Undefined Internal Terms

**Known facts:** The only record is “NEX层已完成蓝轨化，推进语义收敛”. No definitions, change details, or verification material are available.

**Acceptable output:**

> 这条记录没有说明“NEX层”“蓝轨化”和“语义收敛”具体指什么，因此目前无法确认实际完成了哪些修改，也无法确认验证情况。

**Check:** Identify the specific unknowns. Do not invent plausible interpretations such as interface unification or a completed refactor. Unknown completion status does not mean that the work was not completed.

## 6. Prefer the Current Project's Definition

**Known facts:** Project documentation explicitly defines `Delta` as data newly added or changed in the current update. The discussion concerns data export, not options.

**Acceptable output:**

> 这里的 Delta（本次新增或发生变化的数据）采用项目文档中的定义。

**Check:** Do not substitute the options definition. Explain that it is a project-specific name when useful.

## 7. Preserve Original Fields and Code

**Known facts and request:** Reproduce the JSON below exactly, then explain its fields. The provider defines `iv` as implied volatility measured in %, and `dte` as days to expiration measured in days.

```json
{"iv":24.5,"dte":30}
```

**Acceptable output:**

```json
{"iv":24.5,"dte":30}
```

> `iv`（隐含波动率）的值为24.5，单位为%；`dte`（距到期天数）的值为30，单位为天。

**Check:** Do not translate JSON keys, insert annotations inside code, or change values. Put explanations outside the code block.

## 8. Preserve the Difference Between Observation and Suspicion

**Known facts:** Logs show an external request timeout. A network issue is only an investigation direction. The cause remains unknown, and reproduction work is not yet complete.

**Unacceptable wording:**

> 已定位网络故障。

**Acceptable output:**

> 日志显示，访问外部服务时发生了超时。原因还没有确定，目前正在排查是否与网络有关，复现尚未完成。

**Check:** Keep the observed event separate from the suspected cause. An investigation direction must not become a confirmed cause. Do not replace “复现尚未完成” with “尚未复现”; the latter is not established by the supplied facts.

## 9. Keep Quantities Attached to Their Actual Objects and Units

**Known facts:** One test file contains three wait-time settings that are planned to be changed to 15 seconds. Nothing has been changed yet, and the failure cause is unconfirmed.

**Unacceptable wording:**

> 已修复三个因等待时间不足而失败的测试。

**Acceptable output:**

> 计划把这个测试文件里的三处等待时间设置改为15秒，目前尚未修改，也还没有确认失败原因。

**Check:** Three settings are not three tests. A plan is not completed work. Planning to adjust a timeout does not prove the cause of failure.

## 10. Explain Chinese Industry Jargon Too

**Known facts:** This project explicitly defines “兜底” as handing failed automatic processing to staff for continued handling. Explain the workflow to a colleague unfamiliar with the system.

**Hard-to-read wording:**

> 失败后进入人工兜底链路。

**Acceptable output:**

> 自动处理失败后，由工作人员接手继续处理。

**Check:** Describe the actual action when ordinary wording is accurate; keeping the jargon or inventing a new label is unnecessary. “自动” describes the earlier processing step, not necessarily the handoff. Do not add an unstated purpose such as preventing unattended work.

## Reader Check

Have a reader unfamiliar with the working notes and internal project vocabulary inspect only the final text:

- Can they explain the main matter, subject, action, and current result?
- Are the terms needed for the current conclusion explained? Does an explanation introduce further unfamiliar terms?
- Can they distinguish planned, completed, verified, and still-unknown information?
- Are values, units, conditions, and scope preserved? Are original artifacts intact?
- Is already-clear wording preserved? Are explanations unnecessarily repetitive?

These questions assess expression. They do not mandate a uniform answer structure or an independent reader review for every simple reply.

## Sources of the Adapted Principles

These sources identify borrowed ideas, not dependencies that must be loaded to use this skill. Follow this skill's own instructions.

- [shuorenhua](https://github.com/MrGeDiao/shuorenhua/blob/main/SKILL.md): preserve values, conditions, actors, status, and meaning.
- [Cloudflare eli5](https://github.com/cloudflare/cloudflare-docs/blob/production/.agents/skills/eli5/SKILL.md): interpret terms in context, verify added explanations, and check whether explanations stand alone.
- [Humanizer-zh](https://github.com/op7418/Humanizer-zh/blob/main/SKILL.md): identify invented labels and hard-to-read wording while defining what should be retained.
- [ELI5](https://github.com/DreambigOu/ELI5/blob/main/skills/eli5/SKILL.md): adapt explanation depth to the reader's background; this skill always preserves accuracy.
- [doc-coauthoring](https://github.com/anthropics/skills/blob/main/skills/doc-coauthoring/SKILL.md): use readers without prior context to uncover comprehension gaps.
