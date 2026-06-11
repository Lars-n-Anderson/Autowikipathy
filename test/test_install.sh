#!/usr/bin/env bash
# Installer: idempotent scaffold + hook + single snippet; uninstall reverses cleanly.
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
cd "$tmp"
git init -q && git config user.email t@t && git config user.name t

sh "$REPO/install.sh" "$REPO" >/dev/null
sh "$REPO/install.sh" "$REPO" >/dev/null   # twice — must stay idempotent

[ -f autowikipathy/KNOBS.md ]      || { echo "FAIL: no scaffold"; exit 1; }
[ -f autowikipathy/.state/count ]  || { echo "FAIL: no state seed"; exit 1; }
[ -x .git/hooks/post-commit ]      || { echo "FAIL: hook not executable"; exit 1; }
rules=$(ls CLAUDE.md AGENTS.md .cursorrules 2>/dev/null | head -1 || true)
n=$(grep -c "AUTOWIKIPATHY:BEGIN" "$rules")
[ "$n" -eq 1 ] || { echo "FAIL: snippet present x$n (want 1)"; exit 1; }

# The hook actually fires end-to-end after install.
echo a > f; git add f; git commit -q -m c1
echo b > f; git add f; git commit -q -m c2
echo c > f; git add f; git commit -q -m c3
[ -f autowikipathy/.state/DUE ] || { echo "FAIL: hook did not fire at ratio after install"; exit 1; }

# Uninstall reverses snippet + hook, keeps wiki + KNOBS.
sh "$REPO/uninstall.sh" >/dev/null
[ ! -f .git/hooks/post-commit ] || { echo "FAIL: hook survived uninstall"; exit 1; }
m=$(grep -c "AUTOWIKIPATHY:BEGIN" "$rules" || true)
[ "${m:-0}" -eq 0 ] || { echo "FAIL: snippet survived uninstall x$m"; exit 1; }
[ -f autowikipathy/KNOBS.md ] || { echo "FAIL: uninstall ate KNOBS.md"; exit 1; }
[ -d autowikipathy/wiki ]     || { echo "FAIL: uninstall ate wiki/"; exit 1; }

# --- --wiki-dir reuses an existing dir: rewrites the knob, skips the scaffold ---
tmp3=$(mktemp -d)
cd "$tmp3"
git init -q && git config user.email t@t && git config user.name t
sh "$REPO/install.sh" "$REPO" --wiki-dir research >/dev/null
grep -qE '^[[:space:]]*wiki_dir:[[:space:]]*research[[:space:]]*$' autowikipathy/KNOBS.md \
  || { echo "FAIL: wiki_dir not rewritten to research"; grep wiki_dir autowikipathy/KNOBS.md; exit 1; }
[ ! -d autowikipathy/wiki ] || { echo "FAIL: wiki/ scaffolded despite --wiki-dir"; exit 1; }
# No junk file from a sed-delimiter collision.
ls -A | grep -q '#' && { echo "FAIL: junk file created by install"; ls -A; exit 1; }
rm -rf "$tmp3"

echo "PASS test_install"
