# Interview

Lean, slash-only variants of the engineering skills for fast, multi-stage Java coding-interview / timeboxed tasks (e.g. live coding). Clarify assumptions and blockers, then run them per stage in order: grill → spec → implement.

- **[grill-with-docs-quick](./grill-with-docs-quick/SKILL.md)** — Starts with an interviewer-facing clarification script, then asks only remaining blockers before coding the current stage, recording essential `CONTEXT.md` terms and hard-to-reverse ADRs inline.
- **[to-task-spec](./to-task-spec/SKILL.md)** — Synthesise a lean `docs/task-spec.md` (one `## Stage N` per stage) from the grilling conversation — no interview, no issue tracker.
- **[tdd-task](./tdd-task/SKILL.md)** — Spec-driven red-green TDD of the current stage's behaviours, building on prior still-green stages, with a compact Java concurrency recipe.
