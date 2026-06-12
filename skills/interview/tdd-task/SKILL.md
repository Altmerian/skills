---
name: tdd-task
description: Spec-driven red-green TDD for a timeboxed coding task — implements the current stage's behaviours-to-test from docs/task-spec.md in vertical slices, building on prior still-green stages. Use when implementing an interview or timeboxed-task stage from an existing task-spec.
disable-model-invocation: true
---

# TDD Task

The skill is a part of the coding-interview / timeboxed-task pipeline that can span multiple stages. Each stage runs the grill → spec → implement sequence. The spec grows cumulatively.

Spec-driven red-green implementation of one stage of a timeboxed coding task. Planning already happened in `grill-with-docs-quick` + `to-task-spec`, so there is no heavy approval gate — just a one-line confirm, then build in vertical slices. Each slice pauses three times: after RED (the interviewer must see the test fail), after minimal GREEN (the interviewer showcases the passing test before any refactoring), and after refactor (the interviewer approves the behaviour).

## Philosophy (lean)

- **Test observable behavior through the public interface, not implementation** — tests survive refactors, and a good test reads like a specification. See [tests.md](./tests.md).
- **Vertical slices, not horizontal** — drive one *behaviour* at a time → minimal code to pass → repeat. The slice unit is the behaviour, not a fixed test count. Never write tests for *later* behaviours up front; adding cases to the *current* one is fine.
- **Minimal green is partial on purpose** — write the least code that turns *this* test green, even if it looks embarrassingly incomplete. The complete, clean solution is the destination across *all* slices, never slice 1's output. A capable model's instinct is to write the whole obvious solution behind one happy-path test — resist it: no validation, dedup, collision handling, or locking exists until a behaviour's failing test demands it.
- **Minimal essential tests** — you can't test everything; implement every requirement, but only test the behaviours that carry real risk (happy-path tracer bullet, key edge cases, concurrency invariants).

## Fail fast

Refuse to run unless `docs/task-spec.md` has a current `## Stage N` section to implement.

## Read first (full context)

- the **entire** `docs/task-spec.md` — every stage's requirements, so this stage doesn't regress earlier behaviours;
- `CONTEXT.md` (vocabulary for test names and interfaces) and any ADRs in `docs/adr/` (decisions in force) **if present** — both are created lazily upstream, so their absence is normal; skip silently when missing;
- `docs/codebase/` if present, and the existing code and tests from prior stages.

Match the project's existing test framework, Java version, assertion style, and conventions. For a blank Java project with nothing set up yet, default to **Java 25**, latest JUnit (**JUnit 6** / Jupiter), and AssertJ Core for fluent assertions.

The **current** stage's **Requirements** are the full implementation scope — every requirement must be satisfied. Requirements are indexed **FR1, FR2, …** (global across stages); use these ids when discussing scope with the user — "this slice drives FR3" — and expect each behaviour checkbox to cite the FR id(s) it verifies. Its **Behaviours to test** is the prioritised subset that drives the red-green loop (the risky, observable behaviours); a low-risk requirement may carry no bespoke test, but it must still be implemented. Prior requirements stay binding **unless a later stage supersedes them** (the stage's **Supersedes** field or a superseded ADR); earlier behaviours remain regression tests only while still applicable.

## Flow

1. **Confirm** (one line): restate the current-stage test list and the **Public surface** — the entry-point type(s), the construction/config shape (type + field names), and any domain value objects the tests name. Get a one-line OK *before* the first red test: this is where the names you'll present are agreed, not invented mid-test. If the spec has no Public surface field, propose one here and confirm it. Catches a spec mismatch before coding.
2. **RED — and stop:** the slice unit is one *behaviour*: write the fewest tests that specify and force it — usually one, a `@ParameterizedTest` for a family of equivalent inputs (see [tests.md](./tests.md)), or a triangulating second case that forces the real logic past a fake. Add cases only for the *current* behaviour; don't anticipate later ones. If the test doesn't compile, add only **inert stubs** of the agreed public surface (`throw new UnsupportedOperationException()` or equivalent) — never working logic — so the test runs and fails on the behaviour itself, not on compilation. Run the test, show the interviewer the **failing output**, and confirm in one line that it fails for the right reason, naming the FR id(s) this slice drives. Then **stop and wait**: no production code until the user validates the red and says go. This pause is the point of the interview — skipping it looks like test-after.
3. **GREEN — only after the user's go-ahead:** write the minimal code to pass, run the test, show the **passing output**. **Over-build self-check:** scan your own diff — every branch, guard, loop, and field must trace to the current failing test or an already-green one. A production path that handles a behaviour with no failing test behind it was built ahead of the bar; delete it and let its own slice reintroduce it. Then **stop and wait** again: the interviewer showcases the now-passing test before any refactoring. Name what you'd refactor (or say "nothing to refactor") and wait for the go-ahead. Green alone doesn't complete a behaviour — it stays `- [ ]` until user approves it (step 5).
4. **Refactor — only after the user's approval**, user can also provide input depending on your refactoring proposal. Extract duplication, simplify. Never refactor while red. Re-run the **full** suite so earlier still-applicable behaviours stay green; drop or update tests a later stage has superseded.
5. **One scenario at a time:** do the full tdd loop for one behaviour, then wait for explicit user approval. Only once approved, tick that behaviour `- [x]` in `docs/task-spec.md` and move on — the first unchecked behaviour is always the next slice, a durable marker so we never lose where we are across the back-and-forth. Don't write all the tests up front. User can flag some issues that will affect the next tests or implementation, so it's better to wait for feedback after each behaviour tdd slice.
6. **Requirement audit:** before declaring the stage done, walk the current-stage **Requirements** FR by FR and report a one-line verdict per id — satisfied by which behaviour test(s) (the checkbox citations make this mechanical) or by which straightforward code. A green suite is not proof of completeness; Behaviours to test is only a subset of Requirements.

Keep each stage's solution **simple** — completing enough stages matters more than gold-plating one. Introduce only the types the current behaviour forces: don't prematurely extract an interface, add a config field no test needs yet, or split helpers the spec didn't ask for (YAGNI). The agreed Public surface is fixed; internal structure stays emergent and minimal. The spec's **Key decisions** and algorithm details (hashing, collision strategy, locking, storage layout) describe the design that *emerges* across the full behaviour list — they are not a build order for slice 1; wire in each decision's machinery only when a behaviour's failing test requires it. Mock only at system boundaries; see [mocking.md](./mocking.md).

## Concurrency (when in scope)

Drive concurrency from tests, then use the same guide for the implementation choices:

- Only write a concurrency test when shared mutable state or an explicit concurrency guarantee is in scope.
- Exercise real contention: many workers via `ExecutorService`, released together with `CountDownLatch` / `CyclicBarrier` / `Phaser`.
- Repeat enough iterations to expose races; assert **invariants** on the end state, not timing or a specific interleaving.
- Collect workers in a `List<Future<?>>` and call `get(timeout)` so worker exceptions surface; clean up with `shutdownNow` + `awaitTermination`. **No `Thread.sleep`-based race tests.**
- Prefer the simplest correct strategy — `synchronized` / `Lock`, concurrent collections, exact atomics — over hand-rolled lock-free code unless the spec demands the performance.

Concurrency guide for the test harness, implementation choices, and official Java/JUnit docs: [concurrency.md](./concurrency.md).

Don't commit — leave the tests and implementation for review.
