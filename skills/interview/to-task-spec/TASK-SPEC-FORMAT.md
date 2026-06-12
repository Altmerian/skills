# task-spec.md Format

A minimal header plus one `## Stage N` section per interview stage. Append a section per stage; the newest is the active scope that drives `tdd-task`. `CONTEXT.md` (glossary) and `docs/adr/` (decisions) stay separate and cumulative.

```md
# Task Spec — {task name}

{one-line context}

## Stage N — {stage title} - {_in-progress|completed|superseded_}

**Goal:** {1–2 sentences — what this stage delivers}

**Supersedes (optional):** {what this stage changes or replaces from an earlier stage, naming the FR ids affected — e.g. "FR4: single-threaded assumption lifted"}

**Requirements:**
- **FR{n}:** {concise functional requirement / acceptance criterion}

**Public surface (when types change):**
- {named entry-point type(s) the tests construct/call; the construction/config shape — type + field names; any domain value objects the tests reference}

**Constraints & assumptions:**
- {interviewer-stated constraint or key assumption}

**Key decisions:**
- {critical decision} (see ADR-NNNN where one was recorded)

**Behaviours to test:** {`tdd-task` ticks each `- [x]` once its slice is approved}
- [ ] {observable `should…` behaviour tdd-task must verify} (FR{n}[, FR{m}])

**Out of scope (this stage):**
- {deferred to a later stage}
```

**FR numbering** is global across the whole spec, not per stage: a new stage continues from the highest existing FR. Ids are stable references — used in Supersedes fields, Behaviours-to-test, ADRs, and conversation — so never renumber or reuse one; a requirement no longer in force is superseded by a later stage's **Supersedes** field, keeping its id. Each behaviour cites the FR id(s) it verifies; an FR cited by no behaviour is still implemented (low-risk, code-covered).

Omit any field that has nothing to record — except **Goal**, **Requirements**, and **Behaviours to test**, which every stage needs. Include **Public surface** whenever the stage introduces or changes the types the tests name; it records only the public API the caller touches (entry-point types, construction/config shape, domain value objects) — never internal classes, helpers, or private structure, which stay TDD-emergent in `tdd-task`.
