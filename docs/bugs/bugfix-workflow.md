# Bug Fix Workflow

**Created:** 2026-01-18
**Purpose:** Reference guide for the bug fix cycle in this project

---

## Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                         CURRENT STATE                               │
│  Branch: feature/tui-components-unit-8 (Unit 8 implementation)      │
│  Status: Code complete, tests pass, bugs found in manual testing    │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│  STEP 1: Ship Unit 8 as-is                                          │
│  • Commit current work on feature/tui-components-unit-8             │
│  • Create PR #10 for Unit 8 (reference bugs in PR description)      │
│  • Merge to main                                                    │
│  • Unit 8 status → MERGED                                           │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│  STEP 2: Fix bugs (one branch per bug or bug group)                 │
│                                                                     │
│  For BUG-001 + BUG-002:                                             │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ git checkout main                                              │ │
│  │ git pull                                                       │ │
│  │ git checkout -b bugfix/tui-raw-terminal                        │ │
│  │ ... fix code ...                                               │ │
│  │ ... run tests ...                                              │ │
│  │ git commit                                                     │ │
│  │ git push -u origin bugfix/tui-raw-terminal                     │ │
│  │ gh pr create → PR #11                                          │ │
│  │ ... review & merge ...                                         │ │
│  │ Update docs/bugs/tui-bugs.md: BUG-001, BUG-002 → FIXED         │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  Repeat for BUG-004, then BUG-003                                   │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│  STEP 3: Verify fixes                                               │
│  • Manual test each fix                                             │
│  • Update bug status: FIXED → VERIFIED                              │
│  • Close bug tracking doc when all verified                         │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Key Rules

| Rule | Why |
|------|-----|
| One branch per bug (or related bug group) | Focused PRs, easy to review/revert |
| Branch from `main`, not feature branch | Bug fixes apply to latest stable code |
| Run tests before PR | Ensure fix doesn't break anything |
| Update bug doc after each fix | Track progress, maintain history |
| Clear context between bugs | Fresh perspective for each fix |

---

## Session Flow

```
Session 1: Ship Unit 8 PR        → CLEAR CONTEXT
Session 2: Fix BUG-001+002       → CLEAR CONTEXT
Session 3: Verify BUG-001+002    → CLEAR CONTEXT
Session 4: Fix BUG-004           → CLEAR CONTEXT
...and so on
```

---

## Bug Status Lifecycle

```
OPEN → IN_PROGRESS → FIXED → VERIFIED → (closed)
              │
              └── WONTFIX (if decided not to fix)
```

| Status | Meaning |
|--------|---------|
| OPEN | Bug documented, not yet being worked on |
| IN_PROGRESS | Someone is actively fixing it |
| FIXED | Code fix merged to main |
| VERIFIED | Manual testing confirms fix works |
| WONTFIX | Decided not to fix (with documented reason) |

---

## Branch Naming Convention

```
bugfix/tui-raw-terminal     # For BUG-001 + BUG-002
bugfix/tui-db-locked        # For BUG-004
bugfix/tui-table-alignment  # For BUG-003
```

Format: `bugfix/<short-description>`

---

## PR Description Template for Bug Fixes

```markdown
## Bug Fix

Fixes: BUG-001, BUG-002 (docs/bugs/tui-bugs.md)

## Problem
[Brief description of what was broken]

## Solution
[Brief description of the fix]

## Testing
- [ ] All existing tests pass
- [ ] Manual testing confirms fix
- [ ] No regression in related functionality
```

---

## Alternative Approach (Fix Before Shipping)

Instead of shipping Unit 8 first, you could fix bugs on the feature branch:

```
feature/tui-components-unit-8
    │
    ├── fix BUG-001+002
    ├── fix BUG-004
    ├── fix BUG-003
    │
    └── Create PR with all fixes included
```

**Pros:** Single PR, cleaner history
**Cons:** Larger PR, harder to review, delays shipping working code

**Recommended:** Ship first, fix separately (unless bugs are critical blockers)
