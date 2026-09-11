#!/usr/bin/env bash
# Generates anima/SKILL.md from skills/anima/SKILL.md.
#
# Why a mirror exists: anima/SKILL.md is the URL non-Claude-Code surfaces fetch,
# and by repo traffic it is the most-read file here. skills/anima/SKILL.md is the
# source of truth (that path is what `codex skill install` and the Claude Code
# plugin read). Relative reference links work in place but not from anima/, so
# they are rewritten to absolute URLs on the way out.
#
# Run after editing the skill; CI fails if the mirror is stale.
set -euo pipefail

cd "$(dirname "$0")/.."

SRC="skills/anima/SKILL.md"
DEST="anima/SKILL.md"
BASE="https://github.com/AnimaApp/mcp-server-guide/blob/main/skills/anima"

mkdir -p "$(dirname "$DEST")"

# The banner goes AFTER the frontmatter block: a SKILL.md must begin with `---`
# or loaders will not parse its frontmatter.
sed "s#](references/#](${BASE}/references/#g" "$SRC" \
  | awk -v note="<!-- Generated from $SRC by scripts/build-mirror.sh — do not edit directly. -->" '
      { print }
      /^---$/ { if (++fence == 2) print "\n" note }
    ' > "$DEST"

echo "Wrote $DEST"

for NAME in agent-grid-full agent-grid-sandboxed; do
  SRC="skills/${NAME}/SKILL.md"
  DEST="${NAME}/SKILL.md"
  BASE="https://github.com/AnimaApp/mcp-server-guide/blob/main/skills/${NAME}"

  mkdir -p "$(dirname "$DEST")"

  sed "s#](references/#](${BASE}/references/#g" "$SRC" \
    | awk -v note="<!-- Generated from $SRC by scripts/build-mirror.sh — do not edit directly. -->" '
        { print }
        /^---$/ { if (++fence == 2) print "\n" note }
      ' > "$DEST"

  echo "Wrote $DEST"
done
