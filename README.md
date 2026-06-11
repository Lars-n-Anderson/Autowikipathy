# Autowikipathy

**A portable grounding kit for AI coding sessions.** Drop it into any git repo and your AI agent will periodically stop, research one outside concept, and file it into a self-indexing, [Karpathy-style](https://github.com/karpathy) wiki — so the you-and-AI loop stays grounded in real, cited sources instead of drifting into an echo chamber of two.

It's not an app. There's no daemon, no service, no account. It's **plain files + a git hook + one paragraph in your rules file**. Any AI agent that reads a rules file (Claude Code, Cursor, etc.) can use it.

## Why

Talk to an AI long enough with no new input and the loop produces confident nonsense. The fix is cheap: every so often, pull fresh outside research on what you're *actually* working on, and keep it. Autowikipathy automates the "every so often" (off your git commits) and the "keep it" (a cited wiki that indexes itself).

## How it works

1. You commit code like normal.
2. A `post-commit` hook counts commits. Every **3rd** commit (tunable), it drops a `DUE` marker.
3. Next time you start a session, your agent sees the marker and offers you **3 topics** drawn from your recent work — the most complex, the most frequently engaged, and one it predicts you'll need next — plus "or name your own."
4. You pick one. Your agent dispatches a **subagent** that researches it, verifies every claim against real sources, and writes one cited entry into `autowikipathy/wiki/` — **without burning your main session's context window**.
5. The wiki re-indexes itself. Next session, that knowledge is right there.

## Install

From the root of the git repo you want to add it to:

```bash
# macOS / Linux / Git Bash
git clone https://github.com/Lars-n-Anderson/Autowikipathy /tmp/awp
sh /tmp/awp/install.sh /tmp/awp
```

```powershell
# Windows PowerShell
git clone https://github.com/Lars-n-Anderson/Autowikipathy $env:TEMP\awp
powershell -File $env:TEMP\awp\install.ps1 $env:TEMP\awp
```

This adds an `autowikipathy/` folder, installs the `post-commit` hook, and appends a short activation paragraph to your `CLAUDE.md` / `AGENTS.md` (creating one if needed). Re-running is safe.

## Tune it — `autowikipathy/KNOBS.md`

| Knob | Default | Meaning |
|---|---|---|
| `commit_ratio` | `3` | Ground once every N commits. |
| `article_target_words` | `600` | Standard entry length; the writer scales prose to this. |
| `jargon_density` | `medium` | `low` \| `medium` \| `high` — plain-language vs. domain-dense. |
| `depth_boost` | `1.5` | Length/depth multiplier when 2+ topic lenses agree on the same concept. |
| `min_sources` | `3` | Minimum independent sources before an entry may be marked `verified`. |
| `wiki_dir` | `autowikipathy/wiki` | Where entries + `_gaps.md` live; point at an existing wiki folder to reuse it. |

## Uninstall

```bash
sh uninstall.sh        # or: powershell -File uninstall.ps1
```

Removes the hook and the activation paragraph. **Leaves your `wiki/` and `KNOBS.md` alone** — that's your knowledge.

## License

MIT. Take it, use it however, keep the copyright line, no warranty. See [LICENSE](LICENSE).

---

*Lineage: this packages the "look outside" loop-breaker + LLM-wiki pattern (Andrej Karpathy's llm-wiki: `raw/` source material, an LLM-maintained `wiki/`, and an `index.md` routing layer) into a tiny, portable giveaway.*
