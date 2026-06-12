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
Append a new `## Stage N` section to `docs/task-spec.md`, where `N` = the highest existing stage number + 1 (or 1 if the file is absent), and mark the prior stage as completed. If the user says this run is a **revision** of the current stage, update the latest section in place instead — keeping existing FR ids stable and appending new requirements with the next free id.

Use the template in [TASK-SPEC-FORMAT.md](./TASK-SPEC-FORMAT.md). Keep it JBGE: just enough to implement the stage and present it to the interviewer, no more. Drop the PRD's extensive user-story list and the Problem/Solution/Further-Notes prose.

## Hand-off
Before proceeding to `tdd-task`, confirm with the user that the spec is ready and we can start implementing. 
User can ask to brainstorm some more aspects and decisions, re-iterate with the user and refine the spec one question at a time. Don't proceed to the `tdd-task` until the user explicitly confirms we are ready.
Write all changes and updates in place to the spec during additional brainstorming.

### Requirements vs Behaviours to test

- **Requirements** state the stage's functional scope — the acceptance criteria. Every requirement is implemented. Index each as **FR{n}**, numbered globally across the whole spec (continue from the highest existing FR in any prior stage). Ids are stable handles for documents and conversation: never renumber or reuse one — when a revision drops or reworks a requirement, supersede it instead.
- **Behaviours to test** is the prioritised, observable, interface-level test list that drives `tdd-task`: **one behaviour ≈ one red-green slice** (one test, or a `@ParameterizedTest` covering a family of equivalent inputs), phrased as a `should…` specification (condition → observable outcome) at the public API. It is the critical subset — happy-path tracer bullet, key edge cases, concurrency invariants when relevant — not an exhaustive enumeration. Only behaviours that carry real risk get a bespoke test (remember: **minimal essential tests**). Write each as an unchecked checkbox (`- [ ]`) ending with the FR id(s) it verifies — e.g. `- [ ] should reject an overdraft transfer (FR4)` — so `tdd-task` can tick it (`- [x]`) once the user approves that slice and the requirement audit can walk FR by FR. A durable progress marker that survives the per-slice back-and-forth.

### Public surface

Record the **public surface** the tests will name so `tdd-task` confirms it instead of inventing it mid-test: the entry-point type(s) the caller constructs/calls, the construction/config shape (type name + field names), and any domain value objects that appear in test arrange/assert. The method signatures usually live in **Requirements**; this field pins how the service is *constructed and configured*, which is just as public yet easy to leave implicit.

Keep it JBGE and draw the line firmly: only the public API the caller touches goes here. Internal classes, private helpers, and whether to extract an interface stay **TDD-emergent** in `tdd-task` — pinning them here would over-specify and kill the red-green design discovery. Omit the field when the stage reuses the prior stage's surface unchanged.

### Concurrency

When shared mutable state is in scope, record the concurrency requirement (expected concurrent access, atomicity / isolation / ordering, performance under contention) under **Constraints & assumptions**, and add the concurrent invariants to **Behaviours to test**.

### Supersession

When a later stage changes an earlier stage's assumption, fill the **Supersedes** field naming the affected FR ids so the active scope is unambiguous — e.g. "FR4 (Stage 1, single-threaded): this stage now requires concurrent access". The superseded FR keeps its id and stays in its stage for history.
Mark a previous stage superseded when its requirements are no longer in force, but keep it in the spec for historical context.

Don't commit — leave the file for review and hand off to `/tdd-task`.
