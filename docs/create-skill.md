## Context

The project is a fork of the  [Matt Pocock Skills Pack](https://github.com/mattpocock/skills). The goal is to enrich the existing skills set to support the following scenario: 
- This project is a coding interview task implementation, not a real production system. No MVP, risks, deployment, monitoring, or other production-related aspects are required. Quick, clean, concise, up-to-the-point implementation is expected, using red-green TDD approach.
- Speed is important, we can't spend much time on the design phase, we need quickly document the existign codebase, clarify the requirements and constraints, and get to the implementation as soon as possible. The documentation should be just barely good enough to get the job done, not more.


## New Skills Requirements

1. `interview/grill-with-docs-quick` - a variant of the existing `grill-with-docs` skill, but with a focus on speed and efficiency. 
- Only main decisions that are critical and implemenation can't start without should be covered. 
- The conversation context and output created by the new skill will be used as input for another new skill - `to-task-spec`, a lightweight variant of the existing `to-prd` skill.
2. `interview/to-task-spec` - a variant of the existing `to-prd` skill, but with a focus on creating a task specification for an interview task implementation, not a full PRD. 
- The output should be a concise document `task-spec.md` that captures the clarified requirements and constraints for the implementation, as well as any important decisions made during the `grill-with-docs-quick` process. The document should be structured in a way that is easy to read, present to interviewer and understand, and should contain just enough information to perform the task, but not more. Very lean version of the `to-prd` template.
3. If we get some preexisting project as a task baseline, we will document it using the `document-codebase` skill before invoking the new skill, so the new skill should assume the presence of `docs/codebase/` for non-blank projects (silently skip if absent). `CONTEXT.md` and ADRs will be absent and will be produced by the new skill for both blank and non-blank projects.
4. We clarify functional requirements and ask interviewer questions before starting any task. There are a few stages for the interview; it's important to keep our solution **simple** on each stage in order to complete the necessary amount of stages to pass the interview. We invoke these new skills in order on each stage to clarify the requirements and constraints for that stage, and to produce/update the necessary `task-spec` for the implementation. The skills should be able to handle multiple invocations, updating the same `CONTEXT.md` and ADRs as needed.
5. `interview/tdd-task` - a variant of the existing `tdd` skill, but with a focus on implementing the task specification produced by the `to-task-spec` skill. The implementation should follow the red-green TDD approach, and should be clean, concise, and to-the-point. 
6. **JBGE: - Just Barely Good Enough** - the main principle both for the skill itself and for the documentation it will produce. Docs and specs should contain just right enough information to perform the task they are intended for, but not more.

---

## Decisions made and rationale

### 1. Artifact ownership across the three skills

`grill-with-docs-quick` owns **both** `CONTEXT.md` and ADRs, creating and updating them inline during the blocking-only Q&A. `to-task-spec` and `tdd-task` only read them.

**Rationale:** Faithful mirror of the original `grill-with-docs → to-prd` split, where grilling produces the glossary and decisions and the downstream skill consumes them. Keeps each skill single-responsibility: grill = elicit + record domain language and decisions; to-task-spec = synthesise the work; tdd-task = implement.

```
(non-blank) /document-codebase     → docs/codebase/
/interview:grill-with-docs-quick   → CONTEXT.md (glossary) + docs/adr/*.md (decisions)
/interview:to-task-spec            → reads both, writes task-spec.md
/interview:tdd-task                → reads all, red-green implementation
```

### 2. Multi-stage accumulation model

The interview runs in stages; the skills are re-invoked each stage. Artifacts evolve as follows:

- **`task-spec.md`** — single file, **append a `## Stage N` section** per invocation. The full stage progression stays visible in one document; the newest section is the active scope that drives `tdd-task`.
- **`CONTEXT.md`** — living glossary, updated **in place** (terms accrete; no per-stage sections). Mirrors the original `grill-with-docs`.
- **ADRs** — **append-only** numbered files (`0001-…`, `0002-…`), one per decision, created across any stage. When a later stage reverses an earlier decision, mark the old ADR superseded via its status frontmatter rather than deleting it. Mirrors the original.

**Rationale:** Showing each stage as its own section lets the candidate present scope growth to the interviewer and keeps stage boundaries explicit, while the glossary and decision log remain cumulative living artifacts.

### 3. `task-spec.md` template (lean PRD)

A minimal file header plus one section per stage. Each stage section carries six tight fields:

```md
# Task Spec — {task name}

{one-line context}

## Stage N — {stage title}

**Goal:** {1–2 sentences — what this stage delivers}

**Supersedes (optional):** {what this stage changes or replaces from an earlier stage — e.g. "Stage 1 assumed single-threaded; this stage now requires concurrent access"}

**Requirements:**
- {concise functional requirement / acceptance criterion}

**Constraints & assumptions:**
- {interviewer-stated constraint or key assumption}

**Key decisions:**
- {critical decision} (see ADR-NNNN where one was recorded)

**Behaviours to test:**
- {observable behaviour `tdd-task` must verify}

**Out of scope (this stage):**
- {deferred to a later stage}
```

**Requirements vs Behaviours to test:** *Requirements* state the stage's functional scope — the acceptance criteria you present to the interviewer. *Behaviours to test* is the prioritised, observable, interface-level test list that drives `tdd-task`: **one behaviour ≈ one test ≈ one red-green slice**, phrased as a `should…` specification (condition → observable outcome) at the public API. It is the critical subset — happy-path tracer bullet, key edge cases, and concurrency invariants when relevant — not an exhaustive enumeration. Every requirement is implemented; only behaviours that carry real risk get a bespoke test (minimal essential tests).

**Rationale:** Drops the PRD's "extremely extensive" user-story list and the Problem/Solution/Further-Notes prose in favour of acceptance-criteria-style requirements plus an explicit behaviours-to-test list that feeds `tdd-task`. JBGE: just enough to implement the stage and present it to the interviewer. Decisions are summarised here and cross-linked to ADRs (which hold the full rationale). The optional **Supersedes** field records where a later stage overrides an earlier stage's provisional assumption, so the active scope is unambiguous.

### 4. `task-spec.md` location

Written to **`docs/task-spec.md`**.

**Rationale:** Keeps the repo root uncluttered and groups the spec with the other generated docs (`docs/adr/`, `docs/codebase/`). `CONTEXT.md` stays at the root per the original `grill-with-docs` convention.

### 5. No issue tracker for `to-task-spec`

`to-task-spec` only writes `docs/task-spec.md` locally — no issue-tracker publishing, no triage labels, no dependency on `/setup-matt-pocock-skills`.

**Rationale:** An interview task is a self-contained throwaway repo. Publishing to a tracker is pure overhead and adds a setup dependency. This is the main divergence from `to-prd`. Like `to-prd`, `to-task-spec` does **not** interview — it synthesises `task-spec.md` from the `grill-with-docs-quick` conversation, `CONTEXT.md`, ADRs, and `docs/codebase/` (if present).

### 6. `grill-with-docs-quick` — blocking-only stop rule

The quick variant asks **only blocking questions**: those whose answer is required to start coding the current stage and main essential architecture decisions — i.e. would change the first tests, the interfaces, or the scope. It stops the moment no blocker remains.

- **Keep:** one question at a time; inline `CONTEXT.md` updates (essential terms only); ADR offers restricted to choices that are both blocking *and* hard-to-reverse; light cross-referencing against `docs/codebase/` and code to ground the questions.
- **Drop:** edge-case scenario stress-testing, exhaustive glossary sharpening, "relentless" depth.
- **Time budget:** target **2–3 blocking questions per stage** (a few minutes of clarification, per the interview brief); soft backstop ~4 — then pause and propose proceeding.
- **Record only what changes the next step:** add a `CONTEXT.md` term or an ADR only when it changes the next test or interface; otherwise leave it in the conversation for `to-task-spec` to capture.

**Rationale:** A blocking-only rule keys the stopping point to genuine implementation readiness rather than an arbitrary count, and a tight time budget protects the coding minutes the candidate needs to clear later stages. Gating artifact writes on whether they change the next step keeps documentation JBGE under the interview clock.

### 7. `tdd-task` — spec-driven, minimal ceremony, full context

`tdd-task` runs **once per stage** and builds incrementally on the code and tests from prior stages, which must stay green.

It ingests the **full context** before coding:

- the **entire** `docs/task-spec.md` — every stage's requirements, not only the current one — so later stages don't regress earlier behaviours;
- `CONTEXT.md` (vocabulary for test names and interfaces) and **all** ADRs (decisions in force);
- `docs/codebase/` if present, and the existing codebase from prior stages.

The **current** stage's **Behaviours to test** is the active increment to implement now. Prior requirements remain binding **unless a later stage explicitly supersedes them** (via the stage's **Supersedes** field or a superseded ADR); earlier behaviours stay as regression tests only while still applicable.

Flow:

1. One-line confirmation of the current-stage test list + intended public interface (catches a spec mismatch before coding).
2. Tracer bullet → red-green **vertical slices** (one test → one implementation, repeat).
3. Light refactor once green; re-run the **full** test suite so earlier still-applicable behaviours stay green (drop or update tests a later stage has superseded).

- **Inline (lean):** the core TDD philosophy — test observable behaviour not implementation, vertical not horizontal slices, minimal essential tests.
- **Drop:** the architecture-deepening reference files (`deep-modules.md`, `interface-design.md`) to avoid interview over-engineering.
- **Keep (concise):** mocking and good-test guidance.

**Rationale:** Planning already happened in `grill-with-docs-quick` + `to-task-spec`, so the heavy approval gate is redundant; the one-line confirm is the cheap insurance against a spec mismatch. Reading the whole spec + decisions + existing code keeps each stage coherent with the accumulated solution rather than treating stages in isolation. Keeping the solution simple per stage is essential to completing enough interview stages (req #4), so deepening/gold-plating guidance is deliberately omitted.

### 8. Placement — promoted `interview/` bucket

The three skills form a new first-class `interview/` bucket and are promoted like `engineering/`:

- `skills/interview/{grill-with-docs-quick,to-task-spec,tdd-task}/`
- New `## Interview` section in the top-level `README.md`, each skill name linked to its `SKILL.md`.
- Three entries in `.claude-plugin/plugin.json`.
- A `skills/interview/README.md` listing the three skills with one-line descriptions.
- Project `CLAUDE.md` updated to add `interview/` to the set of buckets that must appear in `README.md` + `plugin.json`.

**Rationale:** The workflow is broadly useful for any coding-interview/timeboxed-task scenario, so it's worth sharing rather than hiding under `personal/`.

### 9. Slash-only invocation

All three skills set `disable-model-invocation: true` and are invoked deliberately by name (`/interview:grill-with-docs-quick`, `/interview:to-task-spec`, `/interview:tdd-task`).

**Rationale:** The variants share triggers with the originals (`grill-with-docs`, `to-prd`, `tdd`), so leaving them model-invocable would risk the wrong variant firing. The interview pipeline is run as a deliberate per-stage sequence, so explicit invocation is natural and keeps the originals clean for normal work.

### 10. `to-task-spec` re-invocation — append by default, revise on request

Each `to-task-spec` run appends a new `## Stage N` section, where `N` = the highest existing stage number in `docs/task-spec.md` + 1 (1 if the file is absent). If the user indicates the run is a revision of the current stage, it updates the latest section in place instead.

**Rationale:** A deterministic append default keeps stage boundaries clean and predictable, while the explicit-revision escape hatch avoids spurious stages when a candidate just refines the current stage's spec.

### 11. Blank vs non-blank projects

Both project types are supported with the same skills; the only difference is the presence of `docs/codebase/`:

- **Non-blank, large/unfamiliar baseline:** run `/document-codebase` first → `docs/codebase/`, then each skill reads the relevant `docs/codebase/` files to orient.
- **Non-blank, small/sparse repo or skeleton:** **skip `/document-codebase` by default** — the full parallel-mapping pass costs more than it's worth under the interview clock.
- **When `docs/codebase/` is absent, all three skills read the relevant source files directly** to orient: `grill-with-docs-quick` to ground its questions, `to-task-spec` to synthesise the spec, and `tdd-task` to build on the existing code. When `docs/codebase/` is present they read it first and fall back to source as needed (same silent-skip posture as the originals).
- **Blank (greenfield):** no `docs/codebase/` and no source yet. `grill-with-docs-quick` creates `CONTEXT.md` lazily on the first resolved term and `docs/adr/` lazily on the first ADR.

In both cases `CONTEXT.md` and ADRs start absent and are produced by `grill-with-docs-quick` (per decision 1).

### 12. Concurrency awareness

Concurrency is a first-class concern when the task involves shared mutable state, kept general (any concurrent task) rather than tied to one interview:

- **`grill-with-docs-quick`** treats concurrency and data-consistency as **blocking** questions when shared mutable state is in play — e.g. expected concurrent access, required atomicity / isolation / ordering, performance expectations under contention. A concurrency strategy that is hard to reverse is a candidate for an ADR.
- **`to-task-spec`** records the resulting concurrency requirement under **Constraints & assumptions** and adds the concurrent behaviours to **Behaviours to test**.
- **`tdd-task`** drives concurrency from tests when it's in scope, using a compact recipe: exercise real contention (many threads via `ExecutorService`, released together with a `CountDownLatch` / `CyclicBarrier`), repeat enough iterations to expose races, assert invariants on the end state, and bound with timeouts / `awaitTermination` — **no `Thread.sleep`-based race tests**. Prefer the simplest correct strategy (`synchronized` / `Lock`, `java.util.concurrent` collections, atomics) over hand-rolled lock-free code unless the spec demands the performance.

**Rationale:** Race conditions and thread safety are the kind of blocking, hard-to-reverse design decisions the pipeline exists to surface early, and they must be driven by tests like any other behaviour. Keeping the guidance general avoids over-fitting the skills to a single interview while still covering concurrency-heavy tasks.

### 13. Pipeline guards (durable handoff)

A stage's functional requirements live in the `grill-with-docs-quick` conversation until `to-task-spec` writes them into `docs/task-spec.md`; `CONTEXT.md` and ADRs deliberately hold only glossary terms and sparse decisions. To stop the pipeline running on stale or missing requirements:

- Run `grill-with-docs-quick → to-task-spec` for a stage within the **same working session**, so the conversation is still in context when the spec is synthesised.
- **`to-task-spec` fails fast:** if it cannot assemble the current stage's requirements and acceptance criteria from the grill conversation or existing artifacts, it asks for them rather than fabricating a spec.
- **`tdd-task` fails fast:** it refuses to run unless `docs/task-spec.md` has a current stage section to implement.

**Rationale:** The durable record of requirements is `task-spec.md` itself; these guards prevent silent synthesis or implementation from incomplete input after context loss, a skipped step, or an out-of-order invocation.

---

## Build plan

The three skills live under a new promoted `skills/interview/` bucket, all with `disable-model-invocation: true`:

| Skill | Role | Reads | Writes |
| --- | --- | --- | --- |
| `grill-with-docs-quick` | Blocking-only grilling (one Q at a time; 1–2 blockers/stage, ~3 soft backstop) | `docs/codebase/` if present, else source | `CONTEXT.md` (in place), `docs/adr/*.md` (append) |
| `to-task-spec` | Synthesise, no interview; fail fast if current-stage requirements missing | grill conversation, `CONTEXT.md`, ADRs, `docs/codebase/` or source | `docs/task-spec.md` (append `## Stage N`, or revise latest) |
| `tdd-task` | Spec-driven red-green per stage, minimal ceremony, builds on prior (still-green) stages | **full** `docs/task-spec.md` (all stages), `CONTEXT.md`, all ADRs, `docs/codebase/`, existing code | tests + implementation |

### Authoring conventions

- **One folder per skill** at `skills/interview/<name>/` with a required `SKILL.md`. Add one-level-deep reference files only when `SKILL.md` would exceed ~100 lines or holds rarely-needed detail; no deeper nesting.
- **Frontmatter:** `name`, a `description`, and `disable-model-invocation: true` (decision 9). Write the description in third person — first sentence states what the skill does, second is "Use when …" naming the interview / timeboxed-task context. (Invocation is manual, but the description still documents the skill.)
- **Self-contained:** bundle the format files each skill needs (`CONTEXT-FORMAT.md`, `ADR-FORMAT.md`, the `task-spec.md` template from decision 3) inside the skill's own folder rather than cross-linking to a sibling skill — skills install independently. Trim them to the quick-variant essentials.
- **No scripts** — these are instruction-based skills, like their originals.
- **JBGE:** terse `SKILL.md`, concrete examples, consistent vocabulary (reuse `CONTEXT.md` terms), references one level deep, no time-sensitive info.

### Build steps

1. Create `skills/interview/{grill-with-docs-quick,to-task-spec,tdd-task}/SKILL.md`, deriving each from its original (`grill-with-docs`, `to-prd`, `tdd`) and applying the decisions above. Weave in concurrency awareness rather than adding a separate doc.
2. Bundle the trimmed format files / task-spec template where each skill needs them.
3. Promote the bucket: add `skills/interview/README.md`; add an `## Interview` section to the top-level `README.md` with each skill name linked to its `SKILL.md`; add the three entries to `.claude-plugin/plugin.json`; add `interview/` to the promoted-bucket rule in the project `CLAUDE.md`.
4. Pre-flight per project `CLAUDE.md` (formatting/lint clean, consistent terminology), then leave the files for review.
