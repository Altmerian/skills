# Map specs

Per-agent prompts and per-doc content specs for `/document-codebase`. Each agent explores its focus area and writes its assigned doc(s) directly to `docs/codebase/`. Give every agent the shared rules plus its focus block.

## Shared rules (include in every agent prompt)

- Explore the codebase for your focus area, then write your assigned doc(s) to `docs/codebase/`.
- JBGE: Just Barely Good Enough. Keep each doc terse — just enough for another agent to orient. A map, not a manual.
- Cite real file paths in backticks (`src/foo.ts`) instead of describing code in prose.
- Never copy secret values (API keys, tokens, passwords, connection strings, `.env` values) into a doc. Name the integration or config key only.
- Read `CONTEXT.md` (or `CONTEXT-MAP.md` and its per-context `CONTEXT.md` files) yourself if present, and reuse its vocabulary so the map matches the project's language. Proceed silently if absent.
- Start each doc with a YAML frontmatter block holding today's date:
  ```yaml
  ---
  lastUpdated: YYYY-MM-DD
  ---
  ```
- On a refresh pass you'll be given a date — limit attention to what changed since then and update the existing doc in place.

## Stage 1 — Tech agent → `STACK.md`, `INTEGRATIONS.md`

### `STACK.md`

- Languages and their versions; runtime (Node, Python, JVM, Go…).
- Frameworks and major libraries.
- Dependencies and notable versions — from `package.json`, `Cargo.toml`, `go.mod`, `requirements.txt`, `pom.xml`, `build.gradle`, etc.
- Build system and tooling.
- Configuration: config files, env loaders, how settings are sourced (names only — never values).

### `INTEGRATIONS.md`

- Third-party APIs (REST, GraphQL, webhooks).
- Databases and ORM / data-access patterns.
- Auth providers (OAuth, JWT, API keys).
- Message queues and event systems.
- Other external services (payments, CDNs, email, monitoring).
- Cite the evidence: imports, client instantiation, env-var names (never values).

## Stage 1 — Architecture agent → `ARCHITECTURE.md`, `STRUCTURE.md`

### `ARCHITECTURE.md`

- Overall pattern (layered, MVC, event-driven, microservices, hexagonal…).
- Layers and module responsibilities; the main abstraction boundaries.
- Data flow / request lifecycle through the system.
- Entry points (HTTP servers, CLI, lambdas, workers, cron).
- A concrete example or two of the key abstractions, with file paths.

### `STRUCTURE.md`

- Top-level directory tree and what each part holds.
- Key locations: business logic, utilities, config, assets, tests.
- Module / file naming patterns.
- Where a newcomer should look first for a given concern, with example paths.

## Stage 1 — Quality agent → `CONVENTIONS.md`, `TESTING.md`

### `CONVENTIONS.md`

- Naming conventions (camelCase / snake_case / PascalCase, file naming).
- Code organization (classes vs functions, export / module style, import / aliasing).
- Error-handling patterns (exceptions, error objects, try / catch usage).
- Comment and documentation style.
- Lint / format configuration in force.

### `TESTING.md`

- Test framework(s).
- if TDD is used, describe the pattern and workflow briefly.
- Test file location and naming (`*.test.ts`, `__tests__/`, etc.).
- Unit vs integration vs e2e split.
- Mocking and fixture patterns.
- Coverage tooling and posture; where tests run in CI.

## Stage 2 — Concerns agent → `CONCERNS.md`

Read the six stage-1 docs first, then run your own scan and synthesize — cite the other docs rather than re-deriving their facts.

- TODO / FIXME / HACK markers worth attention.
- Known bugs and performance bottlenecks.
- Security risks: input-validation gaps, weak secrets handling (describe, never paste values).
- Fragile or tightly-coupled areas; seams that break easily.
- Deprecated dependencies or patterns; areas overdue for refactoring. 
- Use web search and official docs to check actual versions and framework/libraries docs.

Keep it to the load-bearing risks. Each entry: what it is, where (file path), why it matters — one or two lines.
