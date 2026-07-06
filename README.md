# Autowikipathy

**A self-assembling, self-organizing research archive for AI coding sessions.** Point it at your
work and, once a day, your AI agent stops, researches one outside concept you're actually working
on, and files it into a cited, subject-organized, cross-linked wiki — no manual upkeep — so the
you-and-AI loop stays grounded in real sources instead of drifting into a confident echo chamber
of two.

It's not an app. There's no daemon, no service, no account. It's **two Claude Code skills + one
runbook (`CLAUDE.md`) + a daily scheduled task your agent sets up for you.** Any AI agent that
reads a rules file and can schedule a recurring task can run it; the skills are Claude Code's
native format.

## Why

Talk to an AI long enough with no new input and the loop produces confident nonsense. The fix is
cheap: every so often, pull fresh outside research on what you're *actually* working on, and keep
it — organized well enough that it's findable later. Autowikipathy automates the "every so often"
(a daily run), the "keep it" (a cited [OKF](OKF-SPEC.md)-conformant wiki), and the "organized
well" (subject-grouped, cross-linked, reindexed by a dedicated curator skill).

## How it works

1. You clone this repo (or drop it into a workspace) and open it with your AI agent.
2. Your agent reads [`CLAUDE.md`](CLAUDE.md) and, on first run, asks three questions: **what time**
   to run daily, **which repos** to sweep for recent work, and **where the wiki lives**.
3. It creates a **daily scheduled task** at your chosen time and scaffolds an empty wiki. Setup
   is done; nothing else to install.
4. Each day, unattended, the task sweeps your recent commits and mines **1–3 concepts** through
   three lenses — the most-engaged, the next-phase need, and the alternatives to a problem still
   in progress.
5. For each, it invokes the **`wiki-entry-author`** skill (dispatched as a subagent, so it doesn't
   burn your main session's context): it researches the concept, **verifies every load-bearing
   claim against real sources**, and writes one cited entry into the right subject folder.
6. The **`knowledge-curator`** skill cross-links the new entries, refreshes the subject and
   top-level indexes, and closes the matching `_gaps.md` lines. Next session, that knowledge is
   right there — and findable.

## Setup

```bash
git clone https://github.com/Lars-n-Anderson/Autowikipathy
```

Open the folder with Claude Code (or any agent that reads `CLAUDE.md` and can schedule tasks). It
will walk you through the three setup questions and wire the daily run. That's the whole install —
no scripts, no git hooks.

> Prefer to trigger grounding manually or from your own scheduler? Skip the scheduled task and
> just tell your agent to "run the Autowikipathy grounding cycle in CLAUDE.md" whenever you want.

## Tune it — [`KNOBS.md`](KNOBS.md)

| Knob | Default | Meaning |
|---|---|---|
| `sweep_repos` | `["."]` | Repos/paths the daily sweep scans for recent commits. |
| `wiki_dir` | `./research` | Where entries live. Absolute path shares one wiki across repos. |
| `article_target_words` | `600` | Standard entry length; the writer scales prose to this. |
| `jargon_density` | `medium` | `low` \| `medium` \| `high` — plain-language vs. domain-dense. |
| `depth_boost` | `1.5` | Length/depth multiplier when 2+ topic lenses agree on the same concept. |
| `min_sources` | `3` | Minimum independent sources before an entry may be marked `verified`. |

## What's in here

- [`CLAUDE.md`](CLAUDE.md) — the setup gate + the daily grounding runbook (the source of truth).
- `skills/wiki-entry-author/` — researches and writes one cited entry, with a verification pass.
- `skills/knowledge-curator/` — cross-links, reindexes, and closes gaps.
- [`OKF-SPEC.md`](OKF-SPEC.md) — the Open Knowledge Format the wiki conforms to.
- `KNOBS.md` — your config.

Your own `research/` wiki stays local and is never committed to this public repo.

## License

MIT. Take it, use it however, keep the copyright line, no warranty. See [LICENSE](LICENSE).
