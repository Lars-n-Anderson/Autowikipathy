---
name: knowledge-curator
description: >-
  Maintains, cross-links, and reindexes the Autowikipathy research/ knowledge wiki
  after wiki-entry-author writes or updates an entry — keeps the bundle Open
  Knowledge Format (OKF) conformant as it grows. Use this after any research/ entry
  is created or edited, when research/index.md or a subject subfolder's index.md
  looks stale or incomplete, when the user asks to reindex, reorganize, or clean up
  the wiki, or when research/_gaps.md has a line that should be checked off because
  its entry now exists and is verified. Do NOT use this to author new entries (that's
  wiki-entry-author) or to fact-check external documents.
---

# Curating the research/ wiki

You maintain `research/` — the Autowikipathy knowledge wiki — after
`wiki-entry-author` does the writing. Your job is everything that skill explicitly
does not do: corpus-wide cross-linking, subject placement sanity-checks, gap-closing,
and reindexing.

`research/` is an **Open Knowledge Format (OKF) bundle** — see the host repo's `autowikipathy/OKF-SPEC.md`
for the full standard. Your job is to keep the bundle **conformant** as it grows:
every concept file carries a valid `type` field, every `index.md` is a correct OKF
directory listing, and cross-links use OKF's bundle-relative link form (§5).

## Structure you're maintaining

```
research/
├── index.md                     # top-level: one line per SUBJECT SUBFOLDER
├── _gaps.md                     # open research queue — never delete lines, only tick [x]
├── <subject>/                   # e.g. ai-agent-systems/, economics/
│   ├── index.md                 # one line per concept in this subject
│   └── <concept>.md
└── <subject>/...
```

Entries are grouped by **subject matter**, never by the project that happened to
surface them — a concept about capability brokers belongs in a security/access-
control subject folder regardless of which project asked the question.

## Procedure

1. **Validate OKF conformance.** Confirm the entry has a non-empty `type` field
   (OKF's one hard requirement — see the host repo's `autowikipathy/OKF-SPEC.md` §9). If missing, flag it —
   don't silently invent a value; frontmatter is `wiki-entry-author`'s or the owner's
   to set.
2. **Subject placement check.** Confirm the entry lives under the right
   `research/<subject>/` folder. If it's misplaced (a genuinely different subject
   fits better than where it landed), move it and update both the old and new
   subject index — but don't bikeshed borderline calls; a reasonable placement beats
   a "perfect" one that requires constant reshuffling.
3. **Cross-link sweep.** Read the new/updated entry's body and tags. Search existing
   `research/**/*.md` for concepts it relates to (shared tags, explicit mentions, a
   "spawned by" lineage noted in `_gaps.md`). Add bundle-relative links in both
   directions where a real relationship exists — e.g. `[title](/economics/rent-seeking.md)`
   — do not force links for the sake of density.
4. **Update indexes.** Refresh the entry's bullet in its subject's `index.md`
   (`* [Title](file.md) - description`, per OKF §6). If the subject itself is new,
   add a line for it to the top-level `research/index.md`. If `curation_mode:
   reindex` was requested, rebuild the affected index files from the entries present
   rather than patching incrementally.
5. **Close the gap.** If this entry fulfills a `research/_gaps.md` line, tick it
   `[x]`. Never delete a gap line — that file is authored by the owner and the loop.
6. **Tolerate imperfection.** Per OKF §9, a bundle stays valid with missing optional
   fields, unknown `type` values, or broken links — don't block on those. Only a
   missing `type` field is worth flagging as a real defect.

## Error handling

- Ambiguous relatedness (unclear whether two concepts should cross-link) → skip the
  link rather than force it; over-linking is worse than under-linking.
- Entry missing `type` → flag it; do not invent a value.
- Two entries claim the same concept → surface for the owner to decide keep/merge/
  replace — don't silently pick a winner.
- A concept doesn't fit any existing subject folder → propose a new subject rather
  than cramming it into a mismatched one; a handful of one-entry subject folders is
  fine while the wiki is small.

## Boundaries

- **Not authoring entries** — that's `wiki-entry-author`.
- **Not fact-checking claims** — this skill trusts entries that already passed
  `wiki-entry-author`'s verification pass; it doesn't re-verify content.
- **Not journal ingestion.**
- Scoped to `research/` only.
