---
name: feedback-review-findings-need-approval
description: After a review (reviewer, /check, diff-review) — show the findings and stop; don't apply fixes yourself
metadata:
  node_type: memory
  type: feedback
---

A review's result is input for the user's decision. By default: run the review → show the
findings → wait to hear which to act on. I don't apply fixes for the findings myself, even
if a finding is obviously right and concerns code I wrote.

**Why:** a review is requested so the user can decide, not so the agent can grow the diff by
another iteration. The line isn't who wrote the code, it's that the review has already been
handed to the user.

**How to apply:** end a review report with a "what I propose to do" list per finding, and
wait. If the same message said "run the review and fix it", fixing is fine.
