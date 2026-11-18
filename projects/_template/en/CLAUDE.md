# <Project>

## About the project

<fill in: what the project is, stack, repository layout (main directories/modules),
where the team's documentation lives, environment specifics (network, private repositories, secrets)>

## Commands

The `verifier`, `regression-checker` and `bug-investigator` agents don't know their own
commands — they take build, test, lint and app-launch commands from here. If a command is
missing, the agent reports that rather than making one up.

```bash
<build / compile a single module or package>
<all tests>
<tests for a single module or package>
<a single test by name/filter>
<lint>
<launch the app and how to observe the result>
```

<fill in: where test-runner reports, linter configs, CI, pre-commit/pre-push hooks live;
what to run only with permission (long, heavy, or side-effecting commands)>

## Tooling

- Project wiki — `<DataRoot>/projects/<Project>/wiki/` (the SessionStart hook
  `wiki_index.sh` puts its index into context), task wiki —
  `<DataRoot>/projects/<Project>/tasks/` (task key like `PROJ-123`).
- Don't add `.claude/skills/`, `.claude/agents/`, `.claude/scripts/`, `.claude/settings.json`
  to git (they are excluded via `.git/info/exclude`).
- Skills:
  - `orchestrate` — plan → execute → verify with subagents for a task;
  - `check` — user-invoked `/check`: `verifier` and `reviewer` in parallel;
  - `diff-review` — inline review of the current diff, report format in `skills/diff-review/report-format.md`;
  - `commit` — user-invoked `/commit`: commit via `scripts/commit.sh` (one-line title, no list, no `Co-Authored-By`);
  - `save-task-context` — task document in the task wiki (Claude may invoke it on its own at the end of a session);
  - `update-wiki` — ingest what was learned into the project wiki (Claude may invoke it on its own at the end of a session);
  - `unit-tests` — test standards; stack-specific libraries are added in the project.
- Agents:
  - `verifier` — build/tests/lint for what was touched, read-only;
  - `regression-checker` — mutations: break the code → confirm the target test fails → restore;
  - `bug-investigator` — reproduces the bug and finds the root cause before planning, in its own research worktree;
  - `reviewer` — in-depth review; stack-specific rules are added to the project's `agents/reviewer.md`.

No confirmed conventions yet — add them here only by agreement.
