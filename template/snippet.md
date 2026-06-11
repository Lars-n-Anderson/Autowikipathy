<!-- AUTOWIKIPATHY:BEGIN (managed by Autowikipathy — edit autowikipathy/KNOBS.md to tune, or run uninstall to remove) -->
## Autowikipathy grounding

At the **start of each session**, check whether the file `autowikipathy/.state/DUE`
exists. If it does, then **before any other substantive work**:

1. **Offer three grounding topics** drawn from recent work, one per lens, plus a
   fill-in-the-blank:
   - (a) the **most conceptually complex** topic in play,
   - (b) the **most frequently engaged** topic,
   - (c) one topic likely relevant in the **next phase** of this project,
   - (d) "…or name your own."
2. **Convergence:** if two or more of lenses (a)–(c) name the **same** topic and the
   user picks it, instruct the writer to apply the `depth_boost` from
   `autowikipathy/KNOBS.md` (a deeper, longer entry).
3. On the user's choice, **dispatch a subagent** instructed to follow
   `autowikipathy/WRITER.md` (and read `autowikipathy/KNOBS.md`) to research one
   concept, verify its citations, and write one entry into the wiki dir named in
   `autowikipathy/KNOBS.md` (`wiki_dir`, default `autowikipathy/wiki/`),
   updating `index.md`. Running it as a subagent keeps this session's context clean.
4. When the subagent finishes — **or if the user skips** — delete
   `autowikipathy/.state/DUE` and reset `autowikipathy/.state/count` to `0`.
   A skip is completely fine; **never nag.**
<!-- AUTOWIKIPATHY:END -->
