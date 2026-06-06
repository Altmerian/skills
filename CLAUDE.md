Skills are organized into bucket folders under `skills/`:

- `engineering/` — daily code work
- `interview/` — lean variants for fast coding-interview / timeboxed tasks
- `productivity/` — daily non-code workflow tools
- `misc/` — kept around but rarely used
- `personal/` — tied to my own setup, not promoted
- `in-progress/` — drafts not yet ready to ship
- `deprecated/` — no longer used

Every skill in `engineering/`, `interview/`, `productivity/`, or `misc/` must have a reference in the top-level `README.md` and an entry in `.claude-plugin/plugin.json`, unless it is marked `internal: true` in its frontmatter — that flag excludes a skill from the plugin manifest and skills.sh installation (it may still be documented in the `README.md`), regardless of bucket. Skills in `personal/`, `in-progress/`, and `deprecated/` must not appear in either.

Each skill entry in the top-level `README.md` must link the skill name to its `SKILL.md`.

Each bucket folder has a `README.md` that lists every skill in the bucket with a one-line description, with the skill name linked to its `SKILL.md`.
