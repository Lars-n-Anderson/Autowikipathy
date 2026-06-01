#!/usr/bin/env bash
# Hook lifecycle: DUE appears exactly at commit_ratio, and the ratio is tunable.
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$REPO/template/hooks/post-commit"

run_case() {
  ratio="$1"; expect_at="$2"
  tmp=$(mktemp -d)
  (
    cd "$tmp"
    git init -q && git config user.email t@t && git config user.name t
    mkdir -p autowikipathy/.state autowikipathy/wiki
    printf 'commit_ratio: %s\n' "$ratio" > autowikipathy/KNOBS.md
    echo 0 > autowikipathy/.state/count
    cp "$HOOK" .git/hooks/post-commit && chmod +x .git/hooks/post-commit
    i=0
    while [ "$i" -lt "$expect_at" ]; do
      i=$((i + 1))
      echo "$i" > f; git add f; git commit -q -m "c$i"
      if [ "$i" -lt "$expect_at" ] && [ -f autowikipathy/.state/DUE ]; then
        echo "FAIL: DUE appeared early (commit $i, ratio $ratio)"; exit 1
      fi
    done
    if [ ! -f autowikipathy/.state/DUE ]; then
      echo "FAIL: no DUE at commit $expect_at (ratio $ratio)"; exit 1
    fi
  )
  rc=$?
  rm -rf "$tmp"
  return $rc
}

run_case 3 3
run_case 2 2
echo "PASS test_hook"
