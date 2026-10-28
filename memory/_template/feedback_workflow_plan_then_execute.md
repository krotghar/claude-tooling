---
name: feedback-workflow-plan-then-execute
description: "Standard task workflow — Opus plans (with subagents for research), user reviews plan, switch to Sonnet to execute, then a separate subagent runs verification"
metadata:
  node_type: memory
  type: feedback
---

The user's preferred end-to-end workflow for a task has four distinct phases, each with a
specific model/actor:

1. **Task description → planning (Opus).** The user describes the task while on Opus. Opus
   produces an implementation plan. If research/exploration is needed, Opus should launch
   subagents for it rather than doing it inline.
2. **Plan review (user).** The user reviews the plan before anything is implemented.
3. **Execution (Sonnet).** Once the plan is approved, the user switches the model to Sonnet,
   and Sonnet performs the actual implementation.
4. **Verification (separate subagent).** After execution finishes, a SEPARATE subagent runs
   verification — both the verification steps specified in the plan itself AND a general/
   global verification pass (build, tests, lint, etc. beyond what the plan explicitly
   listed). See [[feedback-verification-via-subagent]] — the entire verification phase must
   run in a subagent, never inline in the main session; this describes where that subagent
   step fits in the larger flow.

**Why:** separating planning (Opus, higher reasoning) from execution (Sonnet, cheaper/faster)
matches cost/capability to each phase, and routing verification through an independent
subagent keeps the main session's context/state from biasing or contaminating the check.

**How to apply:** when starting a new substantial task, default to this flow rather than
planning-and-implementing in a single pass — propose a plan first (delegating research to
subagents as apt), wait for explicit plan approval, and after implementing, spawn
a dedicated verification subagent covering both plan-specific and general checks before
declaring the task done.
