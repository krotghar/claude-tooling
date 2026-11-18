---
name: update-wiki
description: Records significant facts from the current session in the project's personal wiki (ingest per Karpathy's methodology) — makes targeted page edits, updates index.md and log.md, lints links. Use at the end of a session if you learned something about how the project works that holds beyond the current task (modules, patterns, component pitfalls), or when asked to update the wiki.
argument-hint: "[optional: which topic to focus on]"
---

The user asks to record in the wiki what was learned during the session. Focus (if given): $ARGUMENTS

The wiki lives **outside the git repository**, at an absolute path:
`<DataRoot>/projects/<Project>/wiki/`
(`CLAUDE.md` — schema, `index.md` — catalog, `log.md` — operations log, `pages/*.md` — pages).
Don't create anything inside the project repository and don't offer to commit it.

## Order

1. **Read `wiki/CLAUDE.md` and `wiki/index.md`.** The schema is the source of truth for
   the format; the index shows which topics are already covered. Then read the pages
   the new material touches.
2. **Pick out what's significant** (see the filter below).
3. **Check every fact against the source**, not your memory of the session: open the
   code/config and make sure the claim is still true and precise
   (file name, signature, regex, constant value). Session memory lies —
   especially about things that "I think it was like this".
4. **Write in a targeted way.** The topic is already on a page → extend/fix it there.
   Start a new page only for a new topic; slug in kebab-case.
5. **Update `index.md`** (a line in the catalog) and **append an entry to `log.md`**
   (append-only, prefix `## [YYYY-MM-DD] ingest | Title`, list the sources and what was
   created/updated).
6. **Run the link lint** (script below) — don't leave broken `[[links]]` or pages
   missing from the index.
7. Report briefly to the user: which pages appeared/were updated and exactly which facts
   went into them.

## What to record and what not

**Record** what will still be true in a month and will save a future session time:

- Quirks of shared components (shared libraries, base modules/packages) that aren't
  visible from the signature: implicit defaults, side effects, unavoidable
  deprecations, which of several similar APIs to use when.
- Rules that are **enforced by something** (linter rules, module boundaries, hooks) —
  with the exact wording and the path to the config.
- Divergences between what a skill/doc says and how things actually turned out in the
  code (and which of the two to treat as the norm).
- Established recipes: package/module skeleton, contracts between components,
  schemes for enabling functionality behind a flag.
- The history of decisions on a feature: what was done differently from legacy and why;
  which divergences from the design were agreed on deliberately.
- Methodology for working with external sources (designs, proxies, logs, external APIs) —
  where the tool lies and how to work around it.

**Don't record:**

- Session and repository state: which branch is checked out, what's committed, whether
  the tests passed, which tasks are closed. It will be stale by the next conversation.
  (A commit hash in the "Sources" section is fine — it's a reference to a source.)
- Things already in the project's `CLAUDE.md` or in skills — put a link instead of a
  copy. Duplication = two places where the rule will drift apart.
- A retelling of code that's easier to just read. Record **conclusions and pitfalls**,
  not listings.
- Secrets, personal data, sensitive ticket contents.

If nothing significant came out of the session, say so — don't invent content.

## Page format

```markdown
# Title

Briefly, what the page is about (1-2 sentences).

## <sections by meaning>

...

## See also
- [[other-page-slug]]

## Sources
- <file/commit/design/page it was taken from> + date
```

Put a date in "Sources" — it later shows how stale a fact is.

## Link lint

```bash
cd <DataRoot>/projects/<Project>/wiki && python3 - <<'EOF'
import re, os, io, glob
pages = {os.path.basename(p)[:-3] for p in glob.glob('pages/*.md')}
bad = [(f, l) for f in glob.glob('*.md') + glob.glob('pages/*.md')
       for l in re.findall(r'\[\[([^\]]+)\]\]', io.open(f, encoding='utf-8').read())
       if l not in pages]
idx = set(re.findall(r'\[\[([^\]]+)\]\]', io.open('index.md', encoding='utf-8').read()))
print("pages:", len(pages))
print("broken links:", bad or "none")
print("not in index:", sorted(pages - idx) or "none")
EOF
```

The only expected "breakage" is `[[other-page-slug]]` in the template inside
`wiki/CLAUDE.md`; it's a placeholder.

## Neighbouring routes

- A short, targeted fact about **me** or about how to work with me
  (feedback, preferences, task context) → that's auto-memory
  (`~/.claude/projects/<repo>/memory/`), not the wiki.
- A confirmed mandatory "always do X" convention → belongs in the project's `CLAUDE.md`;
  don't move it silently — propose it to the user first.
