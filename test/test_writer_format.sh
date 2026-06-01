#!/usr/bin/env bash
# Guard the entry format and the writer's load-bearing instructions.
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
E="$REPO/test/fixtures/example-entry.md"
W="$REPO/template/autowikipathy/WRITER.md"

need() { grep -q "$1" "$2" || { echo "FAIL: '$1' missing from $(basename "$2")"; exit 1; }; }

# The example entry must match the format WRITER.md prescribes.
need '^title:'        "$E"
need '^sources:'      "$E"
need '^## TL;DR'      "$E"
need '^## Why this matters' "$E"
need '^## Sources'    "$E"

# At least 3 source links (http/https) in the entry.
links=$(grep -cE 'https?://' "$E")
[ "$links" -ge 3 ] || { echo "FAIL: only $links source links (want >= 3)"; exit 1; }

# WRITER.md must reference every behavioural knob and the mandatory verification.
need 'jargon_density' "$W"
need 'depth_boost'    "$W"
need 'min_sources'    "$W"
need 'article_target_words' "$W"
grep -qi 'verify' "$W" || { echo "FAIL: WRITER.md omits the verification pass"; exit 1; }

echo "PASS test_writer_format"
