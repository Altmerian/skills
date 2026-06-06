---
name: tdd-task
description: Spec-driven red-green TDD for a timeboxed coding task — implements the current stage's behaviours-to-test from docs/task-spec.md in vertical slices, building on prior still-green stages. Use when implementing an interview or timeboxed-task stage from an existing task-spec.
disable-model-invocation: true
---

# TDD Task

The skill is a part of the coding-interview / timeboxed-task pipeline that can span multiple stages. Each stage runs the grill → spec → implement sequence. The spec grows cumulatively.

Spec-driven red-green implementation of one stage of a timeboxed coding task. Planning already happened in `grill-with-docs-quick` + `to-task-spec`, so there is no heavy approval gate — just a one-line confirm, then build in vertical slices.

## Philosophy (lean)

- **Test observable behavior through the public interface, not implementation** — tests survive refactors, and a good test reads like a specification. See [tests.md](./tests.md).
- **Vertical slices, not horizontal** — one test → minimal code to pass → repeat. Never write all the tests up front.
- **Minimal essential tests** — you can't test everything; implement every requirement, but only test the behaviours that carry real risk (happy-path tracer bullet, key edge cases, concurrency invariants).

## Fail fast

Refuse to run unless `docs/task-spec.md` has a current `## Stage N` section to implement.

## Read first (full context)

- the **entire** `docs/task-spec.md` — every stage's requirements, so this stage doesn't regress earlier behaviours;
- `CONTEXT.md` (vocabulary for test names and interfaces) and any ADRs in `docs/adr/` (decisions in force) **if present** — both are created lazily upstream, so their absence is normal; skip silently when missing;
- `docs/codebase/` if present, and the existing code and tests from prior stages.

Match the project's existing test framework, Java version, assertion style, and conventions. For a blank Java project with nothing set up yet, default to **Java 25**, latest JUnit (**JUnit 6** / Jupiter), and AssertJ Core for fluent assertions.

The **current** stage's **Requirements** are the full implementation scope — every requirement must be satisfied. Its **Behaviours to test** is the prioritised subset that drives the red-green loop (the risky, observable behaviours); a low-risk requirement may carry no bespoke test, but it must still be implemented. Prior requirements stay binding **unless a later stage supersedes them** (the stage's **Supersedes** field or a superseded ADR); earlier behaviours remain regression tests only while still applicable.

## Flow

1. **Confirm** (one line): restate the current-stage test list and the intended public interface. Catches a spec mismatch before coding.
2. **Tracer bullet → incremental loop:** for each behaviour, RED (write one failing test) → GREEN (minimal code to pass). One test at a time; don't anticipate future tests.
3. **Refactor once green:** extract duplication, simplify. Never refactor while red. Re-run the **full** suite so earlier still-applicable behaviours stay green; drop or update tests a later stage has superseded.
4. **Requirement audit:** before declaring the stage done, confirm every current-stage **Requirement** is actually satisfied — covered by a behaviour test or by straightforward code. A green suite is not proof of completeness; Behaviours to test is only a subset of Requirements.

Keep each stage's solution **simple** — completing enough stages matters more than gold-plating one. Mock only at system boundaries; see [mocking.md](./mocking.md).

## Concurrency (when in scope)

Drive concurrency from tests, then use the same guide for the implementation choices:

- Only write a concurrency test when shared mutable state or an explicit concurrency guarantee is in scope.
- Exercise real contention: many workers via `ExecutorService`, released together with `CountDownLatch` / `CyclicBarrier` / `Phaser`.
- Repeat enough iterations to expose races; assert **invariants** on the end state, not timing or a specific interleaving.
- Collect workers in a `List<Future<?>>` and call `get(timeout)` so worker exceptions surface; clean up with `shutdownNow` + `awaitTermination`. **No `Thread.sleep`-based race tests.**
- Prefer the simplest correct strategy — `synchronized` / `Lock`, concurrent collections, exact atomics — over hand-rolled lock-free code unless the spec demands the performance.

Concurrency guide for the test harness, implementation choices, and official Java/JUnit docs: [concurrency.md](./concurrency.md).

Don't commit — leave the tests and implementation for review.
