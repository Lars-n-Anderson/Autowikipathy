# KNOBS — Autowikipathy config

The single place to tune Autowikipathy. Edit the values in the fenced `yaml` block. The daily
grounding runbook (`CLAUDE.md`) reads this file each run; if it's missing or malformed, the
documented defaults below apply rather than failing.

```yaml
sweep_repos: ["."]          # repos/paths the evidence sweep scans for recent commits
wiki_dir: ./research        # where entries and _gaps.md live (absolute path shares one wiki across repos)
article_target_words: 600   # standard entry length; the writer scales prose to this
jargon_density: medium      # low | medium | high — plain-language vs domain-dense
depth_boost: 1.5            # length/depth multiplier on a convergence win (2+ lenses agree)
min_sources: 3              # minimum independent sources before an entry may be 'verified'
```

## What each knob does

- **`sweep_repos`** — the repositories whose last ~36h of commits define "what you actually
  worked on." Defaults to this repo; list several absolute paths to ground across a workspace.
- **`wiki_dir`** — where the cited wiki is written. Point at an absolute path to share one wiki
  across multiple repos instead of a copy per project.
- **`article_target_words`** — target prose length for a standard entry.
- **`jargon_density`** — `low` favors plain language; `high` assumes a domain reader.
- **`depth_boost`** — when 2+ topic-prioritization lenses nominate the same concept, the writer
  multiplies target length/depth by this factor (convergence is a strong importance signal).
- **`min_sources`** — the floor of independent, authoritative sources an entry must cite before
  its `status` may be set to `verified`.
