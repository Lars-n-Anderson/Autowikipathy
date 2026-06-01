#!/bin/sh
# Autowikipathy uninstaller. Run from the root of the repo it was installed in.
# Leaves your wiki/ and KNOBS.md untouched — that's your knowledge and settings.
set -e

# 1. Strip the activation snippet from any rules file.
for f in CLAUDE.md AGENTS.md .cursorrules; do
  [ -f "$f" ] || continue
  if grep -q "AUTOWIKIPATHY:BEGIN" "$f"; then
    sed '/AUTOWIKIPATHY:BEGIN/,/AUTOWIKIPATHY:END/d' "$f" > "$f.awptmp" && mv "$f.awptmp" "$f"
    echo "  - removed activation snippet from $f"
  fi
done

# 2. Remove the hook (standalone) or unchain it (foreign hook).
rm -f .git/hooks/autowikipathy-post-commit
HOOK=.git/hooks/post-commit
if [ -f "$HOOK" ]; then
  if grep -q 'DIR="autowikipathy"' "$HOOK"; then
    rm -f "$HOOK"; echo "  - removed post-commit hook"
  elif grep -q '# autowikipathy-hook' "$HOOK"; then
    sed -e '/# autowikipathy-hook/d' -e '\#autowikipathy-post-commit#d' "$HOOK" > "$HOOK.awptmp" && mv "$HOOK.awptmp" "$HOOK"
    echo "  - unchained Autowikipathy from your post-commit hook"
  fi
fi

# 3. Remove runtime state only.
rm -rf autowikipathy/.state
echo "Autowikipathy uninstalled. Your autowikipathy/wiki/ and KNOBS.md were left untouched."
