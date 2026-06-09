---
name: grill-with-docs-quick
description: Use when running a coding-interview or timeboxed-task where assumptions, requirements, and blockers must be clarified before implementing.
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

Start **every invocation** by producing a tiny interviewer-facing clarification script and wait for the interviewer/user to bring back accepted, rejected, or corrected assumptions before the normal grilling loop. Coding-interview tasks are never treated as 100% clear up front, even when the prompt sounds specific.

The script is the only multi-question bundle in this skill. Format it as a numbered list the user can pass to the interviewer, then ask the user to return the clarifications/answers with the same numbers so you can map each answer to the original assumption. Keep it short enough to say aloud in a few minutes:

- **Public interface / delivery shape** — e.g. service API vs HTTP endpoint vs CLI, project skeleton and test framework constraints, and how the service is constructed/configured (not just the operation signatures).
- **Core functional contract** — the minimal happy path, required validation, and how failures are represented.
- **State, persistence, and concurrency assumptions** — in-memory vs persistent, single process vs distributed, and whether shared mutable state must be thread-safe.

Use assumption-first then question phrasing: propose the simplest Stage 1 contract and ask the interviewer if it is correct or we need additional details. Example for `build a URL shortener`:

```md
Please confirm or correct these assumptions before I start:

1. Public interface / delivery shape:
   I'll assume Stage 1 is a small Java service API covered by unit tests, not HTTP or CLI. Is it correct?

2. Core functional contract:
   I'll assume the service shortens a valid long URL into an opaque unique code and resolves that code back to the original URL. Do we need custom aliases, expiry, or deterministic reuse in the scope?

3. State, persistence, and concurrency:
   I'll assume in-memory storage in a single process. If the service can be called concurrently, I'll make shared state thread-safe. Do we need a database or distributed guarantees?
```

Do **not** write `CONTEXT.md` terms or ADRs from the script. The user's numbered answers stay in the same conversation context and feed the following grilling loop. If some assumptions are not answered by the user in the following response (e.g. they only clarify #1 and #3), take the rest as valid initial assumptions and proceed to the next step.

After the clarification script is answered, proceed with the next step: ask the interviewer/user **only blocking questions** — those whose answer is required to start coding the current stage, plus the essential architecture decisions. A question is blocking if its answer would change:

- the first tests, or
- the public interfaces, or
- the scope of the stage.

Ask any remaining blockers **one question at a time**, with your recommended answer, and wait for the reply before the next. If a question can be answered by reading the existing code or `docs/codebase/`, read it instead of asking.

Stop the moment no blocker remains. **Target 3–5 blocking questions per stage** (a few minutes of clarification); soft backstop ~5 — then pause and propose proceeding to `to-task-spec` or continue brainstorming.

**Drop**: edge-case scenario stress-testing, exhaustive glossary sharpening, relentless depth.

Do not proceed to `to-task-spec` until user explicitly confirms we are ready.

## Concurrency is blocking

When the task involves shared mutable state, treat concurrency and data-consistency as blocking questions:

- expected concurrent access,
- required atomicity / isolation / ordering guarantees,
- performance expectations under contention.

A concurrency strategy that is hard to reverse is a candidate for an ADR.

## Recording (JBGE)

Record only what changes the next step — otherwise leave it in the conversation for `to-task-spec` to capture.

- **CONTEXT.md** — glossary, updated **in place**. Add a term only when it is essential and would change a test name or interface. It is a glossary only: no implementation details, not a spec. Format: [CONTEXT-FORMAT.md](./CONTEXT-FORMAT.md).
- **ADRs** — `docs/adr/NNNN-*.md`, **append-only**. Offer one only when a decision is **both blocking and hard-to-reverse**. When a later stage reverses an earlier decision, mark the old ADR superseded via its status rather than deleting it. Format: [ADR-FORMAT.md](./ADR-FORMAT.md).

Create both lazily — only when you have the first thing to write. They start absent for both blank and non-blank projects.

## Orienting

- If `docs/codebase/` exists, skim the relevant files to ground your questions.
- Otherwise read the relevant source files directly (skip a full `/document-codebase` skill pass for a small skeleton — it costs more than it's worth under the clock).
- Blank/greenfield: nothing to read yet; ground questions in the task statement.
- Tech stack:
  - non-blank project: stick to the existing Java version, libraries, and frameworks.
  - blank/greenfield: ask if there are any preferences or constraints, if not default to Java 25, JUnit 6.1, latest Gradle as a build tool. No Spring or other heavy frameworks unless the task explicitly requires it.

Re-invoked once per stage: it updates the same `CONTEXT.md` and appends ADRs as the interview grows.
