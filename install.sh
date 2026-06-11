#!/bin/sh
# Autowikipathy installer. Run from the ROOT of the git repo you want to add it to:
#   sh install.sh [path-to-Autowikipathy-source] [--wiki-dir PATH]
#   --wiki-dir PATH : reuse an existing wiki folder instead of scaffolding one.
# Idempotent: safe to re-run.
set -e

# Parse args: a positional SRC (kit dir) plus an optional --wiki-dir <path>.
SRC=""
WIKI_DIR=""
while [ $# -gt 0 ]; do
  case "$1" in
    --wiki-dir) WIKI_DIR="${2:-}"; shift 2 ;;
    --wiki-dir=*) WIKI_DIR="${1#--wiki-dir=}"; shift ;;
    *) [ -z "$SRC" ] && SRC="$1"; shift ;;
  esac
done
[ -n "$SRC" ] || SRC="$(cd "$(dirname "$0")" && pwd)"

[ -d .git ] || { echo "Error: run from the root of a git repository (no .git here)." >&2; exit 1; }
[ -d "$SRC/template/autowikipathy" ] || { echo "Error: Autowikipathy source not found at $SRC/template" >&2; exit 1; }

MARK="# autowikipathy-hook"

# 1. Scaffold autowikipathy/ if absent; always ensure runtime state exists.
if [ ! -d autowikipathy ]; then
  cp -R "$SRC/template/autowikipathy" autowikipathy
  if [ -n "$WIKI_DIR" ]; then
    # Reuse an existing wiki dir: rewrite the wiki_dir knob and drop the
    # bundled autowikipathy/wiki/. Pipe delimiter (a path never holds '|') and
    # no inline comment in the replacement — a '#' there would collide with the
    # delimiter and emit a junk file.
    tmpf="autowikipathy/KNOBS.md.tmp.$$"
    sed -E "s|^([[:space:]]*wiki_dir:)[[:space:]]*.*|\1 ${WIKI_DIR}|" \
      autowikipathy/KNOBS.md > "$tmpf" && mv "$tmpf" autowikipathy/KNOBS.md
    rm -rf autowikipathy/wiki
    echo "  + scaffolded autowikipathy/ (reusing wiki dir: $WIKI_DIR)"
  else
    echo "  + scaffolded autowikipathy/"
  fi
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
