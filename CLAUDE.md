# Autowikipathy — autonomous daily grounding

This workspace runs **Autowikipathy**: once a day, unattended, an AI agent mines 1–3 concepts
from your recent work, researches each into a cited wiki entry, and cross-links + reindexes the
result — so the you-and-AI loop stays anchored to outside sources instead of drifting into a
confident echo chamber of two.

It is **not** an app or a daemon. It is two Claude Code skills — `wiki-entry-author` (researches
one cited entry) and `knowledge-curator` (cross-links + reindexes) — driven once a day by a
**scheduled task** that executes the cycle below. This file is both the one-time setup and the
runbook the scheduled task reads.

---

## First-run setup — do this BEFORE other work if not yet configured

**Gate:** if `.state/SCHEDULE-SET` does not exist next to this file, this workspace is not yet
scheduled. Before doing anything else, ask the user these three questions in one message, then wait:

1. **What local time** should the daily research + curate run fire? (e.g. `05:00`)
2. **Which repos / paths** should it sweep for recent work? (default: this repository)
3. **Where should the wiki live** — `wiki_dir`? (default: `./research`)

Then:
- Write the answers into `KNOBS.md` (create it from the defaults table below if absent).
- **Scaffold the wiki if empty.** If `wiki_dir` has no `index.md` / `_gaps.md`, create them: an
  `index.md` with a `# Subjects` heading (subjects get added as entries are written) and a
  `_gaps.md` with the gap-queue header. A fresh clone starts here.
- **Create a daily scheduled task** at the chosen time whose single instruction is:
  *"Execute the grounding cycle in `<abs-path>/CLAUDE.md`, top to bottom. That runbook is the
  single source of truth; do not improvise around it."* Use the scheduling capability available
  to you (Claude Code scheduled task, cron, or OS scheduler — whichever this environment offers).
- `touch .state/SCHEDULE-SET` so you never re-prompt.
- Confirm the schedule back to the user in one line, and stop. (The first grounding run happens
  at the scheduled time, not now.)

---

## The daily grounding cycle

Read the config first: `KNOBS.md` → `wiki_dir`, `article_target_words`, `jargon_density`,
`min_sources`, `depth_boost`, and the sweep repo list.

1. **Evidence sweep.** For each configured repo, `git log --since=36.hours --oneline --no-merges`
   (fall back to `--since=7.days`, capped at 30 commits, if a repo is quiet in 36h). Also read any
   project/memory index the config names. This is what you actually worked on.

2. **Mine topics through three lenses** (one candidate concept each):
   - **most-engaged** — the concept with the most commit/attention mass in the sweep.
   - **next-phase** — a concept the work is clearly about to need (declared next steps, open
     items, the natural successor to what just shipped).
   - **alternative-solutions** — a nuanced problem *currently in progress*: research the
     alternative approaches the field uses, while the decision is still open.

3. **Dedup.** Drop any candidate already covered by an existing entry (check every subject
   `index.md`) or already in `_gaps.md` (open or ticked). If 2+ lenses name the same concept,
   keep it once and mark it a **convergence win** (apply `depth_boost` when authoring).

4. **Append 1–3 gap lines** to `<wiki_dir>/_gaps.md` under `## Open gaps`, each tagged
   `(daily YYYY-MM-DD, <lens>)`. Never remove or edit existing lines. If every candidate deduped
   away, research the **oldest open gap** instead — a run never wastes the day.

5. **Author.** For each gap (max 3), follow `skills/wiki-entry-author/SKILL.md` exactly:
   research from authoritative sources, draft into the right `<wiki_dir>/<subject>/` folder
   (propose a new subject when none fits), honor `article_target_words` / `jargon_density`, run
   the mandatory citation-verification pass, set `status: verified` only if it survives
   (`draft` + a `> Note:` is an acceptable, honest outcome). Dispatch authors as parallel
   subagents when available.

6. **Curate.** Follow `skills/knowledge-curator/SKILL.md` over today's new/updated entries:
   cross-link bidirectionally where a real relationship exists, sanity-check subject placement,
   refresh subject indexes AND the top-level `index.md`, and tick `[x]` every gap line whose
   entry now exists **and is verified** (a `draft` entry leaves its gap open).

7. **Bookkeeping & backup.** Clear the cadence flag if present (`.state/DUE`, reset
   `.state/count` to `0`); append one line to the daily log. Then **commit the wiki** locally
   (`git -C <wiki_dir> add -A && git commit`). If a backup remote or bundle is configured for
   `wiki_dir`, push/write it — otherwise note in the log that the wiki is local-only.

### Failure honesty
- A claim that can't be independently sourced gets cut or flagged — never stated confidently.
- If web research is unavailable: write nothing, log `SKIPPED (no web)`, and stop.
- If a step errors, still write the log line with what happened — the log is how silent failure
  gets noticed.

---

## Config — `KNOBS.md` (defaults)

| Knob | Default | Meaning |
|---|---|---|
| `sweep_repos` | `.` (this repo) | Repos/paths the evidence sweep scans for recent commits. |
| `wiki_dir` | `./research` | Where entries and `_gaps.md` live. Absolute path shares one wiki across repos. |
| `article_target_words` | `600` | Standard entry length; the writer scales prose to this. |
| `jargon_density` | `medium` | `low` \| `medium` \| `high` — plain-language vs. domain-dense. |
| `depth_boost` | `1.5` | Length/depth multiplier on a convergence win. |
| `min_sources` | `3` | Minimum independent sources before an entry may be `verified`. |

## Hard rules (write scope)
Write only inside `wiki_dir` and the `.state` / log paths named above — nothing else. Never
delete or edit existing `_gaps.md` lines (append and tick `[x]` only). No irreversible actions
beyond the local wiki commit.
