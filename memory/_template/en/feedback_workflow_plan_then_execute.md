---
name: feedback-workflow-plan-then-execute
description: A substantial task — plan → user approval → execution → verification by a separate subagent
metadata:
  node_type: memory
  type: feedback
---

I run a substantial task in four phases:

1. **Plan.** Research via subagents; the output is an implementation plan.
2. **Approval.** The user reviews the plan before anything is written.
3. **Execution** according to the approved plan.
4. **Verification** by a separate subagent: both the items from the plan and a general run
   (build, tests, lint) — see [[feedback-verification-via-subagent]].

**Why:** a mistake in the plan is cheaper than a mistake in the code, and an independent
check doesn't inherit the assumptions of whoever wrote it.

**How to apply:** for a small edit the phases collapse; for a noticeable one, don't jump
into code before the plan is approved. The `orchestrate` skill implements this whole flow.
