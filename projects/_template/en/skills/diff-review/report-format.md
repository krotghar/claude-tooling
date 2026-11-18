# Review report format

A single format for all reviews in this project: the `diff-review` skill, the `reviewer`
subagent, and the summary in `/check`. It's edited in one place —
here.

The report is written **to a markdown file** and sent to the user via
`SendUserFile` (`display: "render"`). The default path is the session scratchpad,
file name `review-<ticket or branch>.md`. The chat gets only the verdict in one line and
the list of finding titles — don't duplicate the whole document there.

## Severity scale

Every finding must have exactly one label. Not "important/unimportant" by eye — the
criterion is in the right column.

| Label | Means | Criterion |
|---|---|---|
| 🔴 **Critical** | Blocks the merge | Crash, data loss/corruption, wrong data in production, regression of working functionality, leak |
| 🟠 **Important** | Fix in this task | A real defect in a rare scenario, wrong analytics, divergence from the requirements, a gap in coverage of a critical path |
| 🟡 **Debt** | Can go in a separate commit | Not a defect: duplication, fragility, noise in the diff, inconsistency within a single diff |
| 🔵 **FYI** | No change needed | A question for the author, an observation, something that can't be checked from the code (access to docs, an agreement with the analyst) |

Don't invent anything between 🟡 and 🔵. If a finding doesn't even qualify as 🟡, drop it
rather than downgrading it.

## Verdict

Goes in the header, in one line, and is repeated in the chat:

- 🟢 **OK to merge** — no 🔴 or 🟠.
- 🟡 **Merge after fixes** — there's a 🟠, no 🔴.
- 🔴 **Do not merge** — at least one 🔴.

## Document skeleton

```markdown
# Review: <PROJ-123 — short gist>

| | |
|---|---|
| **Branch** | `PROJ-123` |
| **Diff** | 44 files, +883 / −22 |
| **Verdict** | 🟡 Merge after fixes |

<One or two sentences: what the diff does and the overall impression.>

## Summary

| # | | Finding | Where |
|---|---|---|---|
| 1 | 🟠 | Event is sent before the error check | 10 files, 5 modules |
| 2 | 🟡 | Call verified without a call count | 3 tests |

## Findings

### 🟠 1. <Title as a statement, not a topic>

**Where:** [file.ext:123](src/.../file.ext:123)
**Scenario:** <specifics: with what input/state what breaks>

<Analysis. Code snippets only if it's unclear without them.>

**What to do:** <one sentence>

---

### 🟡 2. ...

## ✅ Checked and confirmed

- <What you specifically checked and what held up — so the depth of the review is
  visible, not just a list of complaints.>

## 🔵 Outside the code

- <Questions for the author, what can't be checked from the code, what's worth raising
  in the PR/MR.>
```

## Content rules

- **A finding's title is a statement**, not a topic. "Event is sent before the error
  check", not "About analytics and errors".
- **A failure scenario is mandatory** for 🔴 and 🟠. No scenario — it's 🟡 or junk.
- **File references as markdown links** with `:line`, path relative to the repository
  root: `[file.ext:42](src/.../file.ext:42)`.
- **The ✅ section is mandatory.** A review without it reads as "found only bad things"
  and doesn't show what has already been checked and needn't be asked again.
- **Don't bloat it.** One finding — one paragraph of analysis. A 40-file diff fits into
  5–8 findings; if there are more, some of them are 🟡 that should have been merged into
  one.
- Emoji — only the ones in this file (severity labels, verdict, ✅). Don't decorate the
  text with arbitrary ones.
