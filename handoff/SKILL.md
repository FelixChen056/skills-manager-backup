---
name: handoff
description: Compact the current working context into a reliable project-state handoff document so another agent can continue from the exact current state.
argument-hint: Optional focus or goal for the next session.
disable-model-invocation: true
---

# Handoff

Create a reliable, state-oriented handoff document that allows a fresh agent to continue the current project with minimal context loss.

The handoff is a snapshot of the project's **current actionable state**, not a chronological session log.

## Output location

Save the handoff to:

`docs/HANDOFF.md`

Rules:

- Create the `docs/` directory if it does not exist.
- Always overwrite the existing `docs/HANDOFF.md`.
- Never append historical session notes.
- Never create timestamped copies.
- Never create archive copies.
- Never save the handoff to the OS temporary directory.
- Treat `docs/HANDOFF.md` as the single source of truth for the current handoff state.
- Replace stale information instead of preserving obsolete state.

After writing the file, print:

`Handoff saved to: docs/HANDOFF.md`

## Core principles

### 1. Current state over history

The document must describe what is true **now**.

Do not write a chronological transcript of the conversation.

Do not preserve obsolete plans, assumptions, or intermediate states unless they are still relevant to the next agent.

The handoff should answer:

- What are we trying to accomplish?
- What is already done?
- What is currently in progress?
- What decisions are already settled?
- What constraints must not be violated?
- What remains unresolved?
- What should the next agent do first?

### 2. No inference

Do not invent missing facts.

Do not convert assumptions into decisions.

Do not infer user preferences, technical requirements, project state, or intent unless they were explicitly established.

If something is uncertain, mark it as uncertain.

If something was not established, omit it or place it under `Open Questions`.

Use wording such as:

- `Confirmed:`
- `Assumption:`
- `Unverified:`
- `Open question:`

when distinction is useful.

### 3. Preserve decision rationale

For important decisions, record both:

- the decision;
- why it was made.

A decision without its rationale is incomplete if the rationale is known.

Also preserve important rejected approaches when forgetting them would cause the next agent to repeat already-discarded work.

### 4. Reference, do not duplicate

Do not duplicate substantial information that already exists in project artifacts.

Prefer references to:

- specifications;
- PRDs;
- architecture documents;
- ADRs;
- plans;
- issues;
- source files;
- tests;
- commits;
- pull requests;
- generated artifacts.

Use paths or URLs where available.

For example:

`See docs/architecture.md for the full architecture.`

rather than copying the architecture into the handoff.

The handoff should contain only enough context to explain why the referenced artifact matters.

### 5. Make the next action executable

The handoff must end with a concrete continuation point.

The next agent should be able to begin work immediately without reconstructing the conversation.

Avoid vague instructions such as:

`Continue implementation.`

Prefer:

`Next: update src/controller/fan.ts to apply the agreed standby-RPM behavior, then run the controller unit tests.`

### 6. Separate facts from recommendations

Do not present a recommendation as though it has already been approved.

Clearly distinguish:

- confirmed decisions;
- current implementation state;
- proposed next steps;
- unresolved options.

### 7. Remove stale state

Because `docs/HANDOFF.md` represents current state, remove information that is no longer relevant.

Examples of stale information:

- completed TODOs;
- superseded implementation plans;
- abandoned alternatives that no longer matter;
- old blockers that have been resolved;
- previous next actions that are already complete.

Keep rejected alternatives only when remembering them prevents likely repetition or regression.

### 8. Security and privacy

Do not include secrets or sensitive credentials.

Redact or omit:

- API keys;
- access tokens;
- passwords;
- private keys;
- authentication cookies;
- secret environment variables;
- personally identifiable information that is not necessary for the work.

Reference secure storage locations rather than copying secrets.

## Required document structure

Write `docs/HANDOFF.md` using the following structure.

# Project Handoff

## Objective

Describe the current project objective in a few concise sentences.

Include the desired outcome and, when relevant, the immediate milestone.

## Current State

Describe the project's current state.

Use these subsections when applicable:

### Completed

Only include work that is actually complete and still relevant to understanding the current state.

### In Progress

Describe work that has started but is not complete.

Include relevant files, branches, components, or artifacts.

### Not Started

Include only significant remaining work that the next agent needs to understand.

Do not turn this into a full backlog unless the backlog itself is relevant to the immediate continuation.

## Confirmed Decisions

For each important confirmed decision, use:

### Decision: <short name>

**Decision:**  
What was decided.

**Reason:**  
Why this decision was made.

**Implications:**  
What the next agent must preserve or account for.

Only include confirmed decisions.

## Active Constraints

List constraints that currently govern the work.

Examples:

- technical constraints;
- compatibility requirements;
- product requirements;
- architecture boundaries;
- file or directory conventions;
- performance requirements;
- user-requested behavior;
- formatting requirements.

Do not include expired constraints.

## Rejected Approaches

Include only rejected approaches that are important enough that a future agent might otherwise repeat them.

For each:

### Rejected: <approach>

**Why rejected:**  
Reason it should not be repeated.

If there are no important rejected approaches, write:

`None currently relevant.`

## Important Artifacts

Reference the most important existing project artifacts.

For each artifact, provide:

- path or URL;
- one-line explanation of why it matters.

Example:

- `docs/spec.md` — authoritative product behavior specification.
- `src/controller/fan.ts` — current fan-control implementation.
- `tests/controller.test.ts` — regression coverage for controller behavior.

Do not reproduce the full contents of referenced artifacts.

## Known Issues / Risks

List active issues, blockers, risks, or fragile areas.

For each item, distinguish between confirmed problems and suspected risks.

Example:

- **Confirmed:** current integration test fails when no fan signal is present.
- **Risk:** controller state restoration after restart has not yet been tested.

If there are none, write:

`No known active issues.`

## Open Questions

List unresolved questions that materially affect future work.

Do not invent questions merely to fill this section.

If there are none, write:

`No open questions currently.`

## Next Action

Provide exactly one primary next action.

It must be specific and executable.

Include:

- what to do;
- where to do it;
- how to verify success.

Format:

**Do:**  
<concrete next task>

**Location:**  
<file, directory, issue, command, or artifact>

**Verify:**  
<test, expected behavior, review condition, or acceptance criterion>

## Suggested Skills

Recommend only skills that are genuinely useful for the next agent.

For each suggested skill, briefly explain why it is relevant.

If no additional skill is required, write:

`No additional skills required.`

## Optional next-session focus

If the user supplied arguments when invoking the skill, treat them as the intended focus of the next session.

Use that focus to prioritize:

- what appears in `Current State`;
- which artifacts are highlighted;
- which risks and open questions are included;
- the `Next Action`.

Do not alter established project facts merely to match the requested focus.

## Quality check before saving

Before writing `docs/HANDOFF.md`, verify all of the following:

- The file describes current state, not conversation history.
- Old or superseded state has been removed.
- No unconfirmed inference is presented as fact.
- Important decisions include rationale where known.
- Confirmed decisions are clearly separated from proposals.
- Existing project artifacts are referenced rather than duplicated.
- The next action is concrete and immediately executable.
- The next action includes a verification method.
- Sensitive information has been removed.
- The document is concise enough for a fresh agent to read quickly.
- A fresh agent could continue the work using this document plus the referenced artifacts.

If any of these checks fail, revise the handoff before saving.

Finally, overwrite:

`docs/HANDOFF.md`

and print:

`Handoff saved to: docs/HANDOFF.md`