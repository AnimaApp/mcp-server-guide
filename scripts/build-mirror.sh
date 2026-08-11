#!/usr/bin/env bash
# Generates the public mirrors for the Agent Grid skills.
#
# Each skills/<name>/SKILL.md file is a source file. Each <name>/SKILL.md file is
# its public mirror. The script changes relative reference links in each mirror.
#
# Run after editing the skill; CI fails if the mirror is stale.
set -euo pipefail

cd "$(dirname "$0")/.."

for NAME in agent-grid-full agent-grid-sandboxed; do
  SRC="skills/${NAME}/SKILL.md"
  DEST="${NAME}/SKILL.md"
  BASE="https://github.com/AnimaApp/mcp-server-guide/blob/main/skills/${NAME}"

  mkdir -p "$(dirname "$DEST")"

# The banner goes AFTER the frontmatter block: a SKILL.md must begin with `---`
# or loaders will not parse its frontmatter.
  sed "s#](references/#](${BASE}/references/#g" "$SRC" \
    | awk -v note="<!-- Generated from $SRC by scripts/build-mirror.sh — do not edit directly. -->" '
        { print }
        /^---$/ { if (++fence == 2) print "\n" note }
      ' > "$DEST"

  echo "Wrote $DEST"
done
