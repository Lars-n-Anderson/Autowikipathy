#!/bin/sh
# Autowikipathy installer. Run from the ROOT of the git repo you want to add it to:
#   sh install.sh [path-to-Autowikipathy-source]
# Idempotent: safe to re-run.
set -e
SRC="${1:-$(cd "$(dirname "$0")" && pwd)}"
[ -d .git ] || { echo "Error: run from the root of a git repository (no .git here)." >&2; exit 1; }
[ -d "$SRC/template/autowikipathy" ] || { echo "Error: Autowikipathy source not found at $SRC/template" >&2; exit 1; }

MARK="# autowikipathy-hook"

# 1. Scaffold autowikipathy/ if absent; always ensure runtime state exists.
if [ ! -d autowikipathy ]; then
  cp -R "$SRC/template/autowikipathy" autowikipathy
  echo "  + scaffolded autowikipathy/"
else
  echo "  = autowikipathy/ already present (left as-is)"
fi
mkdir -p autowikipathy/.state
[ -f autowikipathy/.state/count ] || echo 0 > autowikipathy/.state/count

# 2. Install / chain the post-commit hook.
mkdir -p .git/hooks
HOOK=.git/hooks/post-commit
if [ ! -f "$HOOK" ]; then
  cp "$SRC/template/hooks/post-commit" "$HOOK"
  chmod +x "$HOOK"
  echo "  + installed post-commit hook"
elif grep -q "$MARK" "$HOOK"; then
  echo "  = post-commit hook already has Autowikipathy"
else
  cp "$SRC/template/hooks/post-commit" .git/hooks/autowikipathy-post-commit
  chmod +x .git/hooks/autowikipathy-post-commit
  printf '\n%s\nsh "$(dirname "$0")/autowikipathy-post-commit" || true\n' "$MARK" >> "$HOOK"
  echo "  + chained Autowikipathy onto your existing post-commit hook"
fi

# 3. Append the activation snippet to a rules file (create AGENTS.md if none exist).
RULES=""
for f in CLAUDE.md AGENTS.md .cursorrules; do
  [ -f "$f" ] && RULES="$f" && break
done
[ -z "$RULES" ] && RULES="AGENTS.md"
if grep -q "AUTOWIKIPATHY:BEGIN" "$RULES" 2>/dev/null; then
  echo "  = activation snippet already in $RULES"
else
  printf '\n' >> "$RULES"
  cat "$SRC/template/snippet.md" >> "$RULES"
  echo "  + added activation snippet to $RULES"
fi

echo "Autowikipathy installed. Tune it in autowikipathy/KNOBS.md; remove it with uninstall.sh."
