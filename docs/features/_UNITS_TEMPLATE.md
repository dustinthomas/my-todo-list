# Work Units: [Feature Name]

**Spec:** docs/features/[FEATURE].md
**Plan:** plans/[FEATURE].md
**Created:** [YYYY-MM-DD]
**Status:** Not Started | In Progress | Complete

---

## Micro-Units Principle

> **Keep units as small as logically possible.** Each unit = smallest coherent change that can be independently tested and merged. Prefer many small PRs over few large ones.

## Progress Summary

| Unit | Name | Status | PR |
|------|------|--------|-----|
| 1 | [Name] | PENDING | - |
| 2 | [Name] | PENDING | - |
| 3 | [Name] | PENDING | - |

**Status:** `PENDING` → `IN_PROGRESS` → `IMPLEMENTED` → `VERIFIED` → `MERGED`

---

## Work Units

### Unit 1: [Name]

**Status:** PENDING
**Branch:** `feature/[name]-unit-1`
**Plan Steps:** [1, 2]
**Depends On:** None

**Scope:**
- [What this unit delivers]
- [Files to create/modify]

**Acceptance Criteria:**
- [ ] [Specific criterion]
- [ ] [Specific criterion]
- [ ] All tests pass

---

### Unit 2: [Name]

**Status:** PENDING
**Branch:** `feature/[name]-unit-2`
**Plan Steps:** [3, 4]
**Depends On:** Unit 1

**Scope:**
- [What this unit delivers]

**Acceptance Criteria:**
- [ ] [Criterion]
- [ ] All tests pass

---

### Unit 3: [Name]

**Status:** PENDING
**Branch:** `feature/[name]-unit-3`
**Plan Steps:** [5, 6]
**Depends On:** Unit 2

**Scope:**
- [What this unit delivers]

**Acceptance Criteria:**
- [ ] [Criterion]
- [ ] All tests pass

---

## Session Log

### [YYYY-MM-DD] - [Role]: Unit [N]
**Result:** [Complete/Partial/Blocked]
**Notes:**
- [What was done]
- [Handoff notes]

---

## Workflow

```
For each unit:
1. CLEAR CONTEXT
2. /implement-step docs/features/THIS-FILE.md [N]
3. CLEAR CONTEXT
4. /verify-ship docs/features/THIS-FILE.md [N]
   (combines verification + PR creation)
5. After PR merged → next unit
```

---

## Completion Checklist

- [ ] All units MERGED
- [ ] Full test suite passes
- [ ] Plan file milestones updated
- [ ] Documentation updated (if needed)
