---
name: feedback-commit-message-no-bullet-list
description: "Commit messages need only the task title the user gives — no bulleted list of changes"
metadata:
  node_type: memory
  type: feedback
---

When the user supplies a commit title, use just that title as the commit message — no bulleted
list of changes underneath.

Правило адресовано мне, а не истории. Разбирая чужой/уже сделанный коммит (ревью, лог,
`git show`), не поднимать расхождения формата сообщения как замечание: коммиты подписаны
пользователем и без его апрува не проходят, а стандарт написан чтобы агенты не дописывали
лишнего. Замечание уместно, только если коммит буду делать я.

**Why:** the user cancelled the old "title + bulleted list (max 5 items)" convention mid-session
(2026-07-30). `CLAUDE.md`'s "Conventions" section has since been fixed to match
(2026-07-31), so this is no longer a memory-only override of a stale doc — it's just current
project convention. See [[feedback-commit-approval]] for the rest of the commit rules (approval
gate, format, no `Co-Authored-By`). `/commit` validates the title format, but there is no hook
guard on `git commit` (removed 2026-09-15) — the rule rests on `CLAUDE.md` and memory.
