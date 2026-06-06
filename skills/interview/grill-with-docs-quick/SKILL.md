---
name: grill-with-docs-quick
description: Fast blocking-only grilling for a timeboxed coding task — asks only the questions that must be answered before coding the current stage, and records essential glossary terms (CONTEXT.md) and hard-to-reverse decisions (ADRs) inline. Use when running a coding-interview or timeboxed-task stage and you need to clarify just the blockers before implementing.
disable-model-invocation: true
---

# Grill With Docs — Quick

A fast, blocking-only grilling pass for one stage of a timeboxed coding task (e.g. a live coding interview). Clarify just enough to start coding the current stage, then stop. First skill in the per-stage pipeline:

```text
(non-blank baseline) /document-codebase → docs/codebase/
/grill-with-docs-quick  → CONTEXT.md + docs/adr/*.md
/to-task-spec           → docs/task-spec.md
/tdd-task               → tests + implementation
```

Run `grill-with-docs-quick → to-task-spec` for a stage in the **same working session**, so the conversation is still in context when the spec is written.

## What to do

Ask the interviewer/user **only blocking questions** — those whose answer is required to start coding the current stage, plus the essential architecture decisions. A question is blocking if its answer would change:

- the first tests, or
- the public interfaces, or
- the scope of the stage.

Ask **one question at a time**, with your recommended answer, and wait for the reply before the next. If a question can be answered by reading the code or `docs/codebase/`, read it instead of asking.

Stop the moment no blocker remains. **Target 2–3 blocking questions per stage** (a few minutes of clarification); soft backstop ~4 — then pause and propose proceeding to `to-task-spec`.

**Drop**: edge-case scenario stress-testing, exhaustive glossary sharpening, relentless depth.

## Concurrency is blocking

When the task involves shared mutable state, treat concurrency and data-consistency as blocking questions:

- expected concurrent access,
- required atomicity / isolation / ordering guarantees,
- performance expectations under contention.

A concurrency strategy that is hard to reverse is a candidate for an ADR.

## Recording (JBGE)

Record only what changes the next step — otherwise leave it in the conversation for `to-task-spec` to capture.

- **CONTEXT.md** — glossary at the repo root, updated **in place**. Add a term only when it is essential and would change a test name or interface. It is a glossary only: no implementation details, not a spec. Format: [CONTEXT-FORMAT.md](./CONTEXT-FORMAT.md).
- **ADRs** — `docs/adr/NNNN-*.md`, **append-only**. Offer one only when a decision is **both blocking and hard-to-reverse**. When a later stage reverses an earlier decision, mark the old ADR superseded via its status rather than deleting it. Format: [ADR-FORMAT.md](./ADR-FORMAT.md).

Create both lazily — only when you have the first thing to write. They start absent for both blank and non-blank projects.

## Orienting

- If `docs/codebase/` exists, skim the relevant files to ground your questions.
- Otherwise read the relevant source files directly (skip a full `/document-codebase` pass for a small skeleton — it costs more than it's worth under the clock).
- Blank/greenfield: nothing to read yet; ground questions in the task statement.
- Tech stack:
  - non-blank project: stick to the existing Java version, libraries, and frameworks.
  - blank/greenfield: ask if there are any preferences or constraints, if not default to Java 25, JUnit 6, latest Gradle as a build tool. No Spring or other heavy frameworks unless the task explicitly requires it.

Re-invoked once per stage: it updates the same `CONTEXT.md` and appends ADRs as the interview grows.
