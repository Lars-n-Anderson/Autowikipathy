---
name: wiki-entry-author
description: >-
  Authors or updates a single cited entry in the Autowikipathy research/ knowledge
  wiki — researches one external concept from authoritative sources and writes it in
  the repo's canonical OKF-conformant format with a mandatory citation-verification
  pass. Use this whenever a concept gap is dispatched from research/_gaps.md,
  whenever manually adding or updating a research/ entry, or whenever work surfaces a
  known-unknown that deserves a durable, cited explanation — even if the user doesn't
  say "wiki" or "research entry." This is the AUTHOR primitive in the demand-driven
  expansion loop. Do NOT use it to fact-check an existing external document (use a
  document-verification skill for that) or to index/cross-link existing entries
  (that's knowledge-curator).
---

# Authoring a research/ wiki entry

You are writing **one** entry about **one** concept for the `research/` wiki — a
demand-driven, cited knowledge layer that turns a known-unknown into a high-level
map of the known-known landscape.

The wiki exists to do one job well: give the owner a fast, trustworthy orientation to
a concept and a clean path to the authoritative source. It is **not** a replacement
for official docs, specs, or papers. An entry that tries to reproduce those will
always be a worse copy. Your value is *orientation + synthesis + citations*, not
exhaustive reference.

`research/` is an **Open Knowledge Format (OKF) bundle** — see the host repo's
`autowikipathy/OKF-SPEC.md` for the full standard. The two things that matters most here: every entry's
frontmatter carries a required `type` field, and `research/index.md` (OKF's directory
listing) is kept current on every write.

## Why these rules exist

This skill usually runs **unattended** (dispatched in the background while the owner
is away). That changes everything: there is no human mid-run to catch a hallucinated
source, rein in scope creep, or answer a clarifying question. So the discipline below
is what stands in for the missing human. Follow the spirit, not just the letter.

## Core principles

- **One concept per entry.** Focus is what makes an entry retrievable and reusable.
  If the brief names several concepts, write the one named and *append* the others
  to `research/_gaps.md` as new gap lines (you may append gaps — never delete them;
  that file is authored by the owner and the loop, not by you).
- **Orient, then link out.** Explain what the concept is, why it matters, its key
  tradeoffs, and where it fits relative to neighbors — then cite the canonical
  reference for the exhaustive detail. Resist the urge to grow a shabbier copy of the
  primary source.
- **Every load-bearing claim carries a citation.** A confident sentence with no
  source is the single most dangerous output of unattended research. If you can't
  find a source for a claim, either cut it or mark it explicitly as uncertain.
- **Prefer primary and authoritative sources** — official docs, standards/RFCs,
  peer-reviewed papers, source code — over blog posts and content farms. Gather at
  least `min_sources` (see the host repo's `autowikipathy/KNOBS.md`) independent
  sources where the topic allows. Capture every URL as you go.
- **Write at the owner's level.** Assume competence; skip the over-explaining. Name
  the precise concept and the underlying principle. Note where the concept connects
  to the owner's actual work, if a connection is real — don't invent one.

## Process

1. **Read the brief.** A gap line from `research/_gaps.md` (or a direct request)
   tells you the concept and the angle/level wanted. Confirm it's a single concept.
2. **Read the knobs.** Pull `article_target_words`, `jargon_density`, `min_sources`,
   `depth_boost`, and `wiki_dir` from the host repo's `autowikipathy/KNOBS.md`. If the dispatch told you this
   was a **convergence win** (two or more topic-prioritization lenses named the same
   concept), multiply your target length/depth by `depth_boost`.
3. **Research.** Web-search to discover the landscape; fetch the best sources.
4. **Determine subject placement.** `research/` is organized into subject-matter
   subfolders (e.g. `ai-agent-systems/`, `economics/`), not per-project. Pick the
   existing subfolder the concept belongs to, or propose a new one if none fits —
   don't force a mismatch. See `research/index.md` for the current subject list.
5. **Draft** the entry as `research/<subject-folder>/<kebab-concept>.md` in the
   format below, honoring the length and jargon knobs. Set `status: draft`.
6. **Mandatory citation-verification pass.** Extract every load-bearing and
   numerical claim. Check each against an **independent** source. Fix or flag
   anything you cannot support. Only when every load-bearing claim carries an
   independent source may you set `status: verified`. If you cannot reach that bar,
   leave `status: draft` and add a short `> Note:` line saying what is unverified —
   that is an acceptable outcome.
7. **Update the index.** Add or refresh this entry's bullet under the relevant
   heading in `research/<subject-folder>/index.md`, AND in the top-level
   `research/index.md` if the subject section needs a new entry there too.
   OKF-format: `* [Title](<kebab-concept>.md) - one-line description.`
8. **Leave the gap line in place.** The loop's curation step (`knowledge-curator`)
   closes the gap and wires in deeper cross-links. Your job ends at a verified,
   indexed entry.

## Entry format

```markdown
---
type: Research Report   # REQUIRED (OKF) — use "Research Report" unless the concept
                         # is clearly a different kind (e.g. "Reference", "Deep Dive")
title: <Concept name>
created: <YYYY-MM-DD>
updated: <YYYY-MM-DD>
tags: [<domain>, <subtopic>, ...]
status: draft | verified
sources:
  - <url>
  - <url>
---

# <Concept name>

One-sentence plain-language definition.

## TL;DR
- 3–6 bullets: what it is, why it matters, the central tradeoff, and the one
  canonical reference to read next.

## <Body sections, scaled to the concept>
The actual explanation. Inline-cite load-bearing claims. Name sub-concepts so they
become future gap candidates. Flag contested or version-dependent points honestly.

## How this relates to our work
Concrete connection to the owner's projects or architecture, and which gap/concept
surfaced this. If there's no real connection yet, say so briefly rather than
inventing one.

## Open questions
- Honest unknowns and things to revisit. These are good seeds for future gaps.

## Sources
- [Title — publisher](url) · one line on what this source is good for
```

## Example

**Input (gap line):** `- [ ] Cloudflare Tunnel vs Tailscale — zero-trust remote access for a personal VPS/desktop. Came up designing phone access to the home machine; want the tradeoff framed.`

**Output:** `research/networking-and-infra/cloudflare-tunnel-vs-tailscale.md` — a
verified entry whose TL;DR states the core distinction (public-relay-with-auth vs.
private WireGuard mesh), a body section comparing exposure model, NAT traversal,
auth, and cost, a "How this relates to our work" section tying it to a real remote-
access design, and a Sources list citing both vendors' official docs plus one
independent comparison.

## Boundaries

- **Not fact-checking external documents** — this skill *uses* verification as an
  internal step but its product is a new entry, not a verdict on someone else's text.
- **Not deep cross-linking or corpus-wide reindexing** — that's `knowledge-curator`.
  This skill only appends its own entry's line to the relevant `index.md` files.
- **Not journal/task ingestion** — this skill writes wiki entries only.
- **No irreversible actions.** This skill only reads the web and writes/appends
  inside `research/`. If a task seems to require anything else, stop and surface it.
