---
name: to-task-spec
description: Synthesise a lean task specification (docs/task-spec.md) from the grilling conversation and existing artifacts for a timeboxed coding task.
disable-model-invocation: true
---

# To Task Spec

Synthesise a lean task specification at **`docs/task-spec.md`** from the `grill-with-docs-quick` conversation and the existing artifacts. This skill does **not** interview — it writes down what has already been clarified. The file is the only output.

Run this in the **same session** as `grill-with-docs-quick`, so the conversation is still in context.

The skill is a part of the coding-interview / timeboxed-task pipeline that can span multiple stages. Each stage runs the grill → spec → implement sequence. The spec grows cumulatively, with one `## Stage N` section per stage. When a stage is revised, its section is updated in place instead of appending a new one.

## Read first

- the `grill-with-docs-quick` conversation should be in the context already (the source of the current stage's requirements),
- `CONTEXT.md` and any ADRs in `docs/adr/` **if present** (use their vocabulary and decisions) — both are created lazily upstream, so their absence is normal; skip silently when missing,
- `docs/codebase/` if present, else the relevant project source files.

## Fail fast

If you cannot assemble the current stage's requirements and acceptance criteria from the conversation or the artifacts, **ask for them** — do not fabricate a spec.

## Write
Append a new `## Stage N` section to `docs/task-spec.md`, where `N` = the highest existing stage number + 1 (or 1 if the file is absent), and mark the prior stage as completed. If the user says this run is a **revision** of the current stage, update the latest section in place instead.

Use the template in [TASK-SPEC-FORMAT.md](./TASK-SPEC-FORMAT.md). Keep it JBGE: just enough to implement the stage and present it to the interviewer, no more. Drop the PRD's extensive user-story list and the Problem/Solution/Further-Notes prose.

### Requirements vs Behaviours to test

- **Requirements** state the stage's functional scope — the acceptance criteria. Every requirement is implemented.
- **Behaviours to test** is the prioritised, observable, interface-level test list that drives `tdd-task`: **one behaviour ≈ one test ≈ one red-green slice**, phrased as a `should…` specification (condition → observable outcome) at the public API. It is the critical subset — happy-path tracer bullet, key edge cases, concurrency invariants when relevant — not an exhaustive enumeration. Only behaviours that carry real risk get a bespoke test (remember: **minimal essential tests**).

### Concurrency

When shared mutable state is in scope, record the concurrency requirement (expected concurrent access, atomicity / isolation / ordering, performance under contention) under **Constraints & assumptions**, and add the concurrent invariants to **Behaviours to test**.

### Supersession

When a later stage changes an earlier stage's assumption, fill the **Supersedes** field so the active scope is unambiguous — e.g. "Stage 1 assumed single-threaded; this stage now requires concurrent access".
Mark a previous stage superseded when its requirements are no longer in force, but keep it in the spec for historical context.

Don't commit — leave the file for review and hand off to `/tdd-task`.
