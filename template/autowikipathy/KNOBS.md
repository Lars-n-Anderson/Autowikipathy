# Autowikipathy — knobs

This is the one place to tune Autowikipathy's behavior. Edit the values in the
block below; everything else in `autowikipathy/` is managed by the tool. The
`post-commit` hook reads only `commit_ratio`; the research writer reads the rest.

```yaml
commit_ratio: 3            # ground once every N commits
article_target_words: 600  # standard entry length; the writer scales prose to this
jargon_density: medium     # low | medium | high  — plain-language vs. domain-dense
depth_boost: 1.5           # length/depth multiplier when 2+ topic lenses agree (see WRITER.md)
min_sources: 3             # minimum independent sources before an entry may be 'verified'
wiki_dir: autowikipathy/wiki  # where entries + _gaps.md live; point at an existing wiki to reuse it
```

- **`wiki_dir`** — where wiki entries and `_gaps.md` live. Defaults to
  `autowikipathy/wiki`. Point it at an existing wiki folder to reuse that one
  instead of keeping a separate scaffolded copy.

**Adding a knob:** add a documented key here and reference it in `WRITER.md`. No
code changes are needed — the writer is an instruction document, not a program.
