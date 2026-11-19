---
name: orchestrate
description: Run a task in orchestrator mode — planning, execution, verification and review are done by subagents; the main chat only gets oriented in the task, hands work between roles and brings the user decisions that aren't covered by the requirements.
disable-model-invocation: true
argument-hint: "<task number and/or description> [requirements and recommendations for the work]"
---

The user is running a task in orchestrator mode. Invocation arguments:

<arguments>
$ARGUMENTS
</arguments>

The main chat here is the **orchestrator**: it understands the task, hands out work to
subagents, reads their results and brings the user questions the requirements don't answer.
It doesn't write code itself and doesn't run builds/tests itself — except on the fast path.

## Fast path

The full pipeline (bug investigation, planner, plan approval, review) costs more than the
change itself on small things: "just do it directly" runs took 20–31 minutes versus 74–168
for full ones (measured 2026-10-15…22). So in phase 0, if the task fits, **offer the fast
path yourself** in one line together with the other phase 0 questions — the decision is
the user's. The user may also ask for it themselves ("do it directly", "no pipeline").

It fits when all of these hold: one module and a few files; what to change is clear from
the requirements, a screenshot, a design or the task document (a fix after QA, a
separator, a margin, a text); no product or design forks.

How it goes — **the orchestrator does everything itself, without subagents; at most `verifier`**:
1. Phase 0 — as usual (branch, task document, wiki).
2. No `bug-investigator`, no planner, no executor, no reviewer. No `plan.md` and no
   WIP commits.
3. The orchestrator checks the source of truth itself (design, reference class, precedent
   in git) and edits the code itself — the code style rules of the project's CLAUDE.md
   are the same.
4. Verification — `verifier` (build/tests for the touched modules); if eyeballing the diff
   is enough, it can be skipped. The orchestrator doesn't run builds and tests itself.
   Review and verification by launching the app — only if the user asks.
5. Wrap-up — as usual; the material for `save-task-context` is the session itself.

Off the fast path — a question comes up that takes more than one line, the change spreads
to several modules, verification by launching the app is needed — tell the user and switch
to the full pipeline from the phase where you stopped.

## Requirements from the arguments

Besides the task itself (number and/or description), the arguments may contain the user's
requirements and recommendations: what to rely on, what not to touch, how to run the
process. They take priority over this skill's defaults (models, phase composition, WIP
commits, when to show the plan).

- Write them **verbatim** into the "User requirements" section of `plan.md` — that way all
  roles see them. Also pass them to the planner in the prompt.
- Requirements on the process itself (no review, a different executor model, what else to
  run through `verifier`) are carried out by the orchestrator.
- If a requirement contradicts the project's CLAUDE.md or it's unclear what it applies to —
  ask in phase 0 together with the other gaps.

## Orchestrator context hygiene

You may read yourself: the task document, the wiki, the requirements/design to the extent
needed for understanding, the plan, the execution log, `git status --short`,
`git diff --stat`, targeted pieces of the diff if you can't make a decision without them.

You may not: read code in bulk "to figure it out", write code (except on the fast path),
run builds and tests. If
research is needed, that's the planner's job or a separate `Explore` agent's.

## Working directory

The plan, the execution log and all orchestration artifacts live in the task wiki's
ticket folder: `<DataRoot>/projects/<Project>/tasks/<number or kebab-topic>/`. The
folder may not exist yet — create it; its layout and artifact examples are in
`tasks/CLAUDE.md`. It holds:

- `plan.md` — the plan (written by the orchestrator from the planner's output) + the
  "User requirements" and "Decisions along the way" sections (written by the orchestrator)
  + the "Execution log" section (written by the executor).
- `investigation.md` — the `bug-investigator` report (bugs only, phase 0.5).
- `bug-investigation/` — its evidence (screenshots, logs, command output).
- From there on — the same: verification reports, investigations and the rest of the
  task's artifacts go into this same folder.

Don't create a parallel orchestration directory in the checkout: `.claude/orchestrate/`
is a rejected path — the artifacts belong next to the task document, where
`save-task-context` will pick them up and where they don't pollute the project's
`git status`.

Handoff between roles goes **only through the files of this folder**, not by retelling in
the prompt: a retelling loses details, and every role reads the file the same way. Pass
the absolute path to `plan.md` to every subagent.

## Intermediate commits

Before every stage where a subagent may change files, the orchestrator itself makes a
WIP commit, so that a rollback goes to a known point rather than "reverse edits from
memory". Such stages: an executor run (the first one and every follow-up via `SendMessage`)
and a `regression-checker` run. Stages that don't change the main checkout (bug
investigation, plan, review, `verifier`) don't need a commit.

- **Base.** Before the first WIP commit, write `git rev-parse HEAD` into the plan's
  "Decisions along the way": the squash later goes from it.
- **Clean tree** — nothing to commit, the stage starts as is.
- **What to add.** Only the task's files from `git status --short`, by name (`git add
  <paths>`), no `-A`/`.`. A file outside the plan in the status — first find out where it
  came from.
- **Message.** `WIP before <what>`, for example
  `WIP before regression`. No description and no `Co-Authored-By`.
- **Notify.** Tell the user about every WIP commit in the same reply: hash and title.
- **Don't push.** WIP commits live only locally until the squash.
- **Subagents don't commit**: the `git commit` ban in their contracts stays.
- **Rolling back damage.** Look at `git diff` against the last WIP. Restoring a file to the
  WIP (`git checkout <wip> -- <path>`) is allowed only with the user's permission.

## Phase 0. Orientation (yourself)

0. The task branch — per the "Branch per task" rule in the project's CLAUDE.md, before any
   edits and WIP commits. No such rule — ask what to branch from and how to name it.
1. Task number → `tasks/<number>/<number>.md` (and related ones), if present.
2. `wiki/index.md` → the relevant pages.
3. Requirements: the ticket / the user's text; separate the requirements from the
   arguments from the task. Gaps already visible now (no design, unclear
   behaviour in an edge case, unknown whether a feature flag is needed) — ask the user
   **before** planning, in one message.
4. Type: **bug** or **task** — by the ticket type in the tracker or from the user's words.
   Unclear — ask together with the gaps from item 3. Bug → phase 0.5, task → straight to
   phase 1 (or the fast path, see above).

## Phase 0.5. Bug investigation (`bug-investigator` agent, bugs only)

The planner is read-only and won't reproduce the bug, so before the plan a separate agent
reproduces the bug and looks for the root cause — by launching and experimenting in its own
worktree. It doesn't change the main checkout.

In the prompt: the full requirements, the user's requirements verbatim, the answers from
phase 0, the paths of the wiki pages/task document you read, the absolute path to
`<working directory>/investigation.md` — where it writes its report, "stage 1 (triage)".

The agent works in two stages (see its item 0): first a triage, "does it reproduce and is
it worth pursuing", then — by the user's decision — the root cause. If asked "what's taking
so long" — answer from the "Progress" section of `investigation.md`, don't poke the agent.

By status after stage 1:

- **TRIAGE: …** — show the user briefly: whether it reproduces, where (tentatively),
  hypotheses, how long stage 2 will take. **Wait for a decision**: dig further →
  `SendMessage` to the same agent "stage 2" (it has the context; a new agent would re-read
  everything); don't fix → close the task (`save-task-context`), remove the agent's
  worktree (see below); fix based on a hypothesis without stage 2 → phase 1 with the
  triage report. Decision → "Decisions along the way".

By final status (after stage 2, or right away if the cause was confirmed in stage 1):

- **REPRODUCED** — show the user briefly: the root cause, the level of evidence and the
  confidence. Then phase 1 without waiting for approval: the plan waits for approval anyway.
- **REPRODUCED, CAUSE NOT ESTABLISHED**, **NOT REPRODUCED**, **UNDETERMINED** —
  to the user: what was done, what didn't work, options (provide what's missing and
  restart via `SendMessage` to the same agent, plan based on hypotheses, close the task).
  **Wait for a decision.** Decision → "Decisions along the way".
- Open questions from the report — to the user together with the status.

Check `git worktree list` yourself after the final status or a "no stage 2" decision:
no `*-research-bug-*` should remain. If one does — remove it
(`git worktree remove --force <path>` + `git worktree prune`) and mention it to the user.
After TRIAGE, while no decision has been made, the agent's worktree stays — that's normal.

## Phase 1. Plan (`Plan` subagent, `model: "opus"`)

The planner's prompt must contain: the full requirements, the user's requirements from the
arguments verbatim, the user's answers from phase 0, the list of wiki pages/task document
read (paths), for a bug — the path to `investigation.md` and the decisions from phase 0.5,
and these requirements:

- Check against the source of truth (the design via Figma MCP, real JSON/data model, a
  reference implementation in the code), don't plan from memory. State in the plan **what
  exactly was checked** (file, node, class).
- Scope — exactly the requirements; anything "while we're at it" goes into the "Out of
  scope" section, not into the steps.
- For a bug: rely on `investigation.md`, don't repeat the investigation — only verify what
  the fix is built on. Put the failing test from the report into the steps, and
  verification by launching after the fix into "Verification".
- Return the plan strictly in the format below.

```markdown
# <number> <title>

## Goal
## User requirements
## Checked against sources
## Steps
1. <module/file> — what to do. Specific enough that the executor doesn't have to guess.
## Out of scope
## Verification
Modules to build/test; whether a regression check is needed and for which fix; which tests
to add/fix; whether behaviour needs to be checked by launching the app/CLI — items (what
each observation means) and preconditions (flags/config, auth, test data).
## Open questions
Question → options → planner's recommendation.
## Decisions along the way
## Execution log
```

Then: write the answer into `plan.md`, show the user the plan (briefly: steps, out of
scope, open questions). **Wait for approval.** Write answers to open questions and the
user's edits into the plan yourself (small things) or hand them to the planner via
`SendMessage` (a rework).

## Phase 2. Execution (`general-purpose` subagent, `model: "sonnet"`)

The executor's prompt — the path to `plan.md` and the contract below verbatim:

> You are the executor. Implement the plan from `<path>/plan.md` — only the "Steps",
> "User requirements" and "Decisions along the way" sections, nothing beyond. Before starting, read the project's CLAUDE.md; for tests,
> load the `unit-tests` skill via the Skill tool.
>
> **Don't guess.** If the plan doesn't answer a question (a field isn't in the API
> response, the design differs from the plan, the reference class is built differently, a
> step contradicts the code) — stop, add the question to the "Execution log" and return
> status BLOCKED. Don't roll back what you've done up to that point.
>
> Allowed: editing files per the plan, a quick compile check of the touched modules —
> with the command from the Commands section of the project's CLAUDE.md (each command
> once; if it fails, read the error rather than rerunning).
> Not allowed: `git commit`, `git checkout`/`restore`/`reset`/`clean`/`stash` in any form,
> lint, a full project build, edits outside the plan.
>
> Write everything that deviated from the plan (and why) into the "Execution log" as you go.
>
> Return:
> - Status: DONE | BLOCKED
> - Changed files
> - Deviations from the plan
> - For BLOCKED: question → options → your recommendation
> - Compile check result (the error verbatim, if it failed)

Remember the executor's ID: all further edits go **to the same executor** via `SendMessage`
— it already has the context of what was done.

**BLOCKED.** If the answer clearly follows from the plan, CLAUDE.md or the wiki — answer
yourself and write it into "Decisions along the way". If it's a new decision (product,
design, scope) — take it to the user: question, options, recommendation. Answer →
"Decisions along the way" → `SendMessage` to the executor "continue, the decision is in
the plan".

**DONE.** Look at `git status --short` and `git diff --stat` yourself: the file list
matches the report, no stray `.orig`/`.bak`, no files outside the plan. A subagent's report
is not proof.

## Phase 3. Verification and review (in parallel, in one message)

1. `verifier` — the modules and checks from the plan's "Verification" section, except
   mutations. It doesn't change files. In the prompt: "If it doesn't compile or fails, send
   the exact error text, don't fix it". Build and test commands — from the Commands section
   of the project's CLAUDE.md.
2. `reviewer` — on the current diff, with the path to `plan.md` (so it checks against the
   intent and the user's requirements, not just style).

Summarize for the user: the status of the checks, review findings by severity.
**Don't send findings for implementation without the user's decision**, even obvious ones.

**Behaviour check** — if the plan requires a check by launching the app/CLI (the
"Verification" section), after a green `verifier`: check it by launching as described in
the project's CLAUDE.md (assign it to the executor via `SendMessage`: the check items and
preconditions from the plan, no file changes); if CLAUDE.md has no way to launch it — give
the items to the user (what each observation means) and wait for their result. The outcome
per item → "Decisions along the way". Anything unexpected (crashes, bugs outside the list)
→ to the user; don't send it for implementation without their decision.

**Regression mutations** — if the plan requires them, as a separate stage after a green
`verifier` and after the review fixes (not in parallel with the review: the reviewer would
read a mutated file). Before the stage — a WIP commit. The agent is `regression-checker`;
in the prompt: the path to `plan.md`, the list of mutations with the expected tests, the
test filter, the WIP hash. After the run, check `git status --short` and `git diff --quiet`
against the WIP yourself. In the report, verify: every mutation has the names of the failed
tests, the target one among them; a dubious result (mutation BLOCKED, a verdict that
differs from the expectation without explanation) — rerun that mutation via `SendMessage`
to the same agent.

## Phase 4. Follow-up

Approved items → "Decisions along the way" → `SendMessage` to the executor. Then
`verifier` again (no edit rights) on the touched modules; if the edits touched something
verified by launching — repeat the behaviour check for the affected items (as in phase 3);
a repeat review — only if the user asks or the edits are substantial.

## Wrap-up

The task is done (everything in the plan is done and verified, or the user said "done" /
"push") — finish it yourself, without asking step by step: squash from the base in
"Decisions along the way", rebase, push, `save-task-context` (material — "Decisions along
the way" and the execution log from `plan.md`), an artifact report, the MR/PR link. If the
user asks to push unfinished work — a WIP commit and push, without a report and MR/PR.
