---
name: handoff
description: Compact the current conversation into a handoff document for another agent to pick up.
argument-hint: "What will the next session be used for?"
disable-model-invocation: true
---

Write a handoff document summarising the current conversation so a fresh agent can continue the work.

Include a "suggested skills" section in the document, naming which skills the next agent should call the Skill tool for.

Do not duplicate content already captured in other artifacts (specs, plans, ADRs, issues, commits, diffs). Reference them by path or URL instead.

Redact any sensitive information, such as API keys, passwords, or personally identifiable information.

If the user passed arguments, treat them as a description of what the next session will focus on and tailor the doc accordingly.

## Additional Custom Rules

1. **Preserve the current goal and the user's latest decisions**
   Use the current conversation and relevant workspace materials to describe the current goal, acceptance criteria, and the user's latest corrections. Clearly mark cancelled or superseded requirements so the next session does not continue an obsolete plan.

2. **State actual progress and verification status**
   Record only confirmed facts; do not present guesses as conclusions. Describe completed work, work in progress, and outstanding items. Clearly distinguish "completed and verified", "modified but unverified", "not started", and "blocked". Record the checks actually performed, their results, and their scope; explain why any work remains unverified. Do not present plans, assumptions, or pending tool results as facts about work already performed.

3. **Preserve user constraints and authorization scope**
   Record restrictions, approved actions, and matters awaiting confirmation that affect subsequent work. Preserve the targets and conditions of each authorization. Do not describe a discussed proposal as approved by the user, and do not omit existing authorization in a way that causes the next session to ask for it again.

4. **Preserve key decisions, failed attempts, risks, and open questions**
   Record confirmed decisions and their rationale. Briefly explain why the current approach was chosen, which approaches have already failed, and their known failure causes. List risks supported by evidence and unresolved questions. Present unconfirmed information as questions requiring confirmation rather than definitive conclusions. Retain only information that affects subsequent work.

5. **Provide exactly one concrete, actionable next step**
   End the handoff document with exactly one next step of the highest current priority. Specify the action, where to perform it, how to verify it, and the acceptance criteria. Keep other unfinished items in the outstanding items list without expanding them into additional next steps. If progress depends on missing information, make confirming that information the sole next step and specify exactly what must be confirmed. Place references and the existing `suggested skills` section before the next step so the document ends with that single next step.

6. **Record the workspace context and references needed to resume work**
   As needed, record the working directory, branch, uncommitted changes, relevant files, and tasks that are still running. Record only known state and remind the next session to recheck information that may have changed. Reference key files, tests, plans, and other project materials by path or link instead of copying large passages of existing content. Follow the existing redaction requirements; do not include keys, passwords, or other sensitive information.

7. **Make continuation straightforward**
   After confirming that the handoff document was saved successfully, return its full path to the user along with one instruction that can be copied directly into a new session. Explicitly tell the new session to read the document first.

8. **Use a fixed save location and update the same file**
   Save the handoff document to `docs/HANDOFF.md` under the working directory established for the current task. Temporary directory changes while running commands must not change this path base. Create `docs` if it does not exist. If the file already exists, read it first, preserve information that remains valid and relevant to subsequent work, and then fully rewrite the same file using the current conversation and workspace state. Do not append historical entries to the end or create handoff copies under other names.
