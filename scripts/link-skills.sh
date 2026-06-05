#!/usr/bin/env bash
set -euo pipefail

# Links the shippable skills into this repo's own agent skill dirs
# (.claude/skills and .agents/skills) so local agents discover them while
# you develop. Skips deprecated/, personal/, and in-progress/ skills.

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DESTS=(".claude/skills" ".agents/skills")

# Start clean: wipe each dest dir so renamed/removed/now-excluded skills don't linger.
# These dirs are gitignored and fully regenerated below.
for dest in "${DESTS[@]}"; do
  rm -rf "$REPO/$dest"
  mkdir -p "$REPO/$dest"
done

find "$REPO/skills" -name SKILL.md \
  -not -path '*/node_modules/*' \
  -not -path '*/deprecated/*' \
  -not -path '*/personal/*' \
  -not -path '*/in-progress/*' \
  -print0 |
while IFS= read -r -d '' skill_md; do
  src="$(dirname "$skill_md")"
  name="$(basename "$src")"
  rel_src="${src#"$REPO"/}"          # e.g. skills/engineering/tdd

  for dest in "${DESTS[@]}"; do
    target="$REPO/$dest/$name"

    if [ -e "$target" ] && [ ! -L "$target" ]; then
      rm -rf "$target"
    fi

    # dest dirs are two levels below the repo root, so ../../ reaches it.
    ln -sfn "../../$rel_src" "$target"
    echo "linked $dest/$name -> $rel_src"
  done
done
