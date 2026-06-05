---
name: document-codebase
description: Explores a brownfield codebase with parallel agents and writes a concise factual map under docs/codebase/ — stack, integrations, architecture, structure, conventions, testing, and concerns. Use when onboarding onto an unfamiliar or undocumented codebase, when the user asks to map, document, or explore a codebase, or to refresh an existing docs/codebase/ map.
disable-model-invocation: true
---

# Document Codebase

Explore an existing codebase and write seven terse, factual reference docs under `docs/codebase/`. These are a *map*, not a manual: each doc gives a downstream skill just enough to orient, citing real file paths rather than restating the code.

This is the factual layer only. It never writes `CONTEXT.md` or ADRs — it hands off to `/grill-with-docs` for the interpretive glossary and decisions.

## The seven docs

Per-agent prompts and the full content spec live in [MAP-SPECS.md](MAP-SPECS.md).

| Doc | Covers |
| --- | --- |
| `STACK.md` | languages, runtime, frameworks, dependencies, configuration |
| `INTEGRATIONS.md` | external APIs, databases, auth providers, queues, webhooks |
| `ARCHITECTURE.md` | pattern, layers, data flow, key abstractions, entry points |
| `STRUCTURE.md` | directory layout, key locations, naming |
| `CONVENTIONS.md` | code style, naming, common patterns, error handling |
| `TESTING.md` | framework, test layout, mocking, coverage posture |
| `CONCERNS.md` | tech debt, known bugs, security/performance risks, fragile areas |

## Process

### 1. Detect existing docs

If `docs/codebase/` already holds docs, ask the user to choose:

- **Refresh** — bring every doc up to date. Read each doc's `lastUpdated` stamp and scope the pass to what has changed in the codebase since that date, updating the docs in place rather than rewriting from scratch. If a doc is missing, empty, or has no stamp, generate it from scratch.
- **Skip** — leave the existing map untouched and stop.

If `docs/codebase/` is absent, create it and continue.

### 2. Reuse existing vocabulary

Each mapper agent reads `CONTEXT.md` (or `CONTEXT-MAP.md` and its per-context `CONTEXT.md` files) itself, if present, and reuses its terms so the map matches the project's language. If absent, it proceeds silently — never create it. This is part of every agent's prompt (see [MAP-SPECS.md](MAP-SPECS.md)).

### 3. Map — two stages

**Stage 1 (parallel).** Spawn three exploration agents at once, each writing its own docs directly. Give each a fresh context and its focus prompt from [MAP-SPECS.md](MAP-SPECS.md):

- **Tech** → `STACK.md`, `INTEGRATIONS.md`
- **Architecture** → `ARCHITECTURE.md`, `STRUCTURE.md`
- **Quality** → `CONVENTIONS.md`, `TESTING.md`

Wait for all three to finish, then confirm the six stage-1 docs exist and are non-empty. Re-run (or inline) any pass that failed before continuing.

**Stage 2.** Spawn the **Concerns** agent. It reads the six stage-1 docs *and* runs its own scan (TODO/FIXME, swallowed exceptions, hardcoded values, fragile seams, stale deps), then writes `CONCERNS.md` — citing the other docs rather than re-deriving them.

Every doc opens with a YAML frontmatter block stamped with today's date:

```yaml
---
lastUpdated: YYYY-MM-DD
---
```

**Fallback** — if the Agent tool is unavailable, do the passes inline in the same order: Tech, Architecture, Quality, then Concerns.

### 4. Verify

Confirm all seven docs exist and are non-empty. Report each doc's path and line count.

### 5. Hand off

Point the user to:

- `/grill-with-docs` — build or sharpen `CONTEXT.md` and record ADRs from what the map surfaced.
- `/improve-codebase-architecture` — act on the fragile seams in `CONCERNS.md`.

Don't commit — leave the new files for the user to review.

## Writing rules (every doc)

- **JBGE: Just Barely Good Enough.** Terse. Just enough for a downstream skill to orient. A map, not a report.
- **Cite real paths** in backticks — `src/services/user.ts` — over prose description.
- **Never copy secret values.** Reference integrations and config by name only; never paste API keys, tokens, passwords, connection strings, or `.env` values into a doc.
- **Reuse `CONTEXT.md` vocabulary** wherever it exists.
