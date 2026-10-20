# Common Finance and Options Terms

This glossary supports terminology explanations and supplies general meanings. Explicit definitions from the current platform, contract, field, or data provider take precedence. Other domains do not require this glossary, and answering does not depend on collecting every possible term first. Chinese labels below are intentional target wording for user-facing Chinese responses.

## Usage

- For non-specialists, use the original term followed by its Chinese name or meaning, as in `原词（中文名称或含义）`. If the name remains specialized, add one short explanation of its role.
- Use definitions already supplied by the current material. The same abbreviation may occur in different domains; identify the subject first.
- General knowledge in this table does not establish a particular value's units, period, calculation method, relative level, or business conclusion. Leave annualization, day-count conventions, Greek measurement conventions, and similar unspecified details unknown.
- Preserve original fields, capitalization, and values. Do not insert Chinese annotations into code keys or formulas.
- When a definition refers to another term, as Gamma refers to Delta, ensure the reader also understands that term. Avoid explaining one unfamiliar term with another.

## Suggested Wording

| Term | Suggested Chinese wording | Brief meaning and constraints |
|---|---|---|
| IV | IV（隐含波动率） | Volatility inferred from an option's market price. Use the current data description to establish calculation and annualization; do not present it as a certain future realized movement.[1] |
| HV | HV（历史波动率） | A measure of variability calculated from historical price changes. The observation window, sampling method, and annualization require the data description.[1] |
| Delta | Delta（标的价格敏感度） | Sensitivity of an option's price to changes in the underlying asset's price. Distinguish a single option's metric from a whole position's metric using the current field definition.[1] |
| Gamma | Gamma（标的价格敏感度的变化程度） | How Delta changes as the underlying price changes. Explain Delta first when the reader does not yet understand it.[1] |
| Theta | Theta（时间流逝敏感度） | The effect of passing time on an option's price. Time units and sign depend on the field definition and current position.[1] |
| Vega | Vega（隐含波动率敏感度） | The effect of changes in implied volatility on an option's price. Use the field definition to determine the volatility-change unit and whether position size or a contract multiplier is included.[1] |
| OI | OI（未平仓合约数量） | The number of outstanding contracts. Preserve the provider's quantity unit and counting convention; do not automatically interpret it as account holdings or trading volume.[2] |
| DTE | DTE（距到期天数） | Days remaining until a contract expires. Whether the count uses calendar days or trading days follows the provider's definition.[3] |

## Boundaries That Are Easy to Misstate

- If only `IV=24.5%` is supplied, retain 24.5% and its original unit. Do not add annualization without the current definition. Assess relative levels only when the comparison target and reference range are defined.
- If `DTE=30` is supplied and the field meaning is confirmed, explain that the days-to-expiration value is 30. Do not add an unconfirmed qualifier such as 30 calendar days.
- Converting `0.245` to `24.5%` requires a known original unit. Preserve the original value if its meaning or unit is unconfirmed.
- A single option's sensitivity, a value multiplied by the contract unit, and an aggregate position sensitivity are not interchangeable. Do not infer which applies without the field description.
- A Chinese annotation does not create a trading recommendation or turn an unconfirmed calculation method into an established fact.

## Definition Sources

Definitions checked on 2026-10-20. Chinese wording is an accessible summary; use the source material together with the current field definition to determine applicability.

1. [OIC: Volatility & the Greeks](https://prd-web.optionseducation.org/advancedconcepts/volatility-the-greeks): general concepts of IV, historical volatility, and option sensitivities.
2. [OIC: Options Glossary](https://prd-web.optionseducation.org/referencelibrary/optionsglossary): open interest and other options terms.
3. [Cboe: Understanding Retail Investors' Dynamic Trading Behavior in the US Options Market, 2024](https://cdn.cboe.com/resources/government_relations/Understanding-Retail-Investors-Dynamic-Trading-Behavior-in-the-US-Options-Market_2024.pdf): DTE means days-to-expiration. This source confirms the abbreviation, not the day-count method of a current field.
