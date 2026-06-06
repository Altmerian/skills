# CONTEXT.md Format

A glossary of project-specific terms — nothing else. One `CONTEXT.md` at the repo root.

## Structure

```md
# {Context Name}

{One or two sentence description of what this context is.}

## Language

**Order**:
A customer's request to buy goods.
_Avoid_: Purchase, transaction

**Customer**:
A person or organization that places orders.
_Avoid_: Client, buyer, account
```

## Rules

- **Be opinionated.** When several words exist for one concept, pick the best and list the rest under `_Avoid_`.
- **Keep definitions tight.** One or two sentences. Define what it IS, not what it does.
- **Only project-specific terms.** General programming concepts (timeouts, retries) don't belong, even if used heavily.
- **No implementation details.** It is not a spec or a scratch pad.

Create it lazily — only when the first term is resolved.
