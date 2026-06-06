# task-spec.md Format

A minimal header plus one `## Stage N` section per interview stage. Append a section per stage; the newest is the active scope that drives `tdd-task`. `CONTEXT.md` (glossary) and `docs/adr/` (decisions) stay separate and cumulative.

```md
# Task Spec — {task name}

{one-line context}

## Stage N — {stage title} - {_in-progress|completed|superseded_}

**Goal:** {1–2 sentences — what this stage delivers}

**Supersedes (optional):** {what this stage changes or replaces from an earlier stage}

**Requirements:**
- {concise functional requirement / acceptance criterion}

**Constraints & assumptions:**
- {interviewer-stated constraint or key assumption}

**Key decisions:**
- {critical decision} (see ADR-NNNN where one was recorded)

**Behaviours to test:**
- {observable `should…` behaviour tdd-task must verify}

**Out of scope (this stage):**
- {deferred to a later stage}
```

Omit any field that has nothing to record — except **Goal**, **Requirements**, and **Behaviours to test**, which every stage needs.
