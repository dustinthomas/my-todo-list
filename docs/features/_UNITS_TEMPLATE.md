# Work Units: [Feature Name]

**Feature:** [Feature description]
**Feature Spec:** docs/features/[FEATURE].md
**Plan:** plans/[FEATURE].md
**Created:** [YYYY-MM-DD]
**Status:** Not Started | In Progress | Complete

---

## Overview

This file tracks testable work units derived from the implementation plan. Each unit is:
- **Self-contained:** Can be implemented, tested, and merged independently
- **PR-sized:** Results in one pull request
- **Testable:** Has clear acceptance criteria that can be verified

## Progress Summary

| Unit | Name | Status | Branch | PR |
|------|------|--------|--------|-----|
| 1 | [Name] | PENDING | - | - |
| 2 | [Name] | PENDING | - | - |
| 3 | [Name] | PENDING | - | - |

**Status Legend:**
- `PENDING` - Not started
- `IN_PROGRESS` - Implementer working on it
- `IMPLEMENTED` - Code complete, ready for verification
- `VERIFIED` - Tester approved
- `MERGED` - PR merged to main
- `BLOCKED` - Waiting on dependency
- `FAILED` - Verification failed, needs fixes

---

## Work Units

### Unit 1: [Descriptive Name]

**Status:** PENDING
**Branch:** `feature/[feature-name]-unit-1`
**Plan Steps:** [1, 2] *(reference step numbers from plan)*
**Depends On:** None

**Scope:**
- [Brief description of what this unit accomplishes]
- [What files will be created/modified]

**Acceptance Criteria:**
- [ ] [Specific, testable criterion]
- [ ] [Specific, testable criterion]
- [ ] [Specific, testable criterion]
- [ ] All unit tests pass
- [ ] No regressions in existing tests

**Estimated Files:** [N] files, ~[N] lines

**Notes:**
- [Any special considerations for this unit]

---

### Unit 2: [Descriptive Name]

**Status:** PENDING
**Branch:** `feature/[feature-name]-unit-2`
**Plan Steps:** [3, 4, 5]
**Depends On:** Unit 1

**Scope:**
- [Brief description]

**Acceptance Criteria:**
- [ ] [Criterion]
- [ ] [Criterion]
- [ ] All unit tests pass
- [ ] No regressions in existing tests

**Estimated Files:** [N] files, ~[N] lines

**Notes:**
- [Notes]

---

### Unit 3: [Descriptive Name]

**Status:** PENDING
**Branch:** `feature/[feature-name]-unit-3`
**Plan Steps:** [6, 7]
**Depends On:** Unit 1, Unit 2

**Scope:**
- [Brief description]

**Acceptance Criteria:**
- [ ] [Criterion]
- [ ] [Criterion]
- [ ] All unit tests pass
- [ ] No regressions in existing tests

**Estimated Files:** [N] files, ~[N] lines

---

## Session Log

Track work sessions for handoff context:

### [YYYY-MM-DD] - [Role]: [Unit N]
**Session:** [Implementer/Tester/Refactorer]
**Result:** [Complete/Partial/Blocked]
**Notes:**
- [What was accomplished]
- [Any issues encountered]
- [Handoff notes for next session]

---

## Issues & Fixes

Track issues found during verification:

### Issue #1: [Title]
**Found in:** Unit [N] verification
**Severity:** [High/Medium/Low]
**Description:** [What's wrong]
**Resolution:**
- [ ] Fix in Unit [N] (minor fix)
- [ ] Create fix plan (design issue)

---

## Completion Checklist

Before marking feature complete:

- [ ] All units have status MERGED
- [ ] Full test suite passes
- [ ] Manual verification complete (if TUI)
- [ ] Documentation updated
- [ ] CLAUDE.md lessons learned updated (if applicable)

---

**Workflow Reminder:**

```
For each unit:
1. CLEAR CONTEXT
2. /implement-step docs/features/THIS-FILE.md Unit N
3. CLEAR CONTEXT
4. /verify-feature docs/features/THIS-FILE.md Unit N
5. If PASS: /simplify (optional) then /commit-push-pr
6. If FAIL: Back to step 1 (or /plan-feature for design fix)
7. After PR merged: Repeat for next unit
```
