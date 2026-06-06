# ADR Format

ADRs live in `docs/adr/` with sequential numbering: `0001-slug.md`, `0002-slug.md`, … Create the directory lazily — only when the first ADR is needed. Scan for the highest existing number and increment.

## Template

```md
# {Short title of the decision}

{1–3 sentences: the context, what we decided, and why.}
```

An ADR can be a single paragraph. The value is recording *that* a decision was made and *why* — not filling out sections.

## When to offer one (quick variant)

Offer an ADR only when the decision is **both blocking and hard-to-reverse** — e.g. a concurrency strategy, a storage model, a boundary choice with real lock-in. Skip easily-reversed or unsurprising decisions.

## Supersession

When a later stage reverses an earlier decision, don't delete the old ADR — add a status line marking it superseded:

```md
---
status: superseded by ADR-0004
---
```
