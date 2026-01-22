# Implementation Plans

Plans are **living documents** that guide development and track progress at the milestone level.

## Document Hierarchy

```
SPEC (Human writes)     →  PLAN (Planner creates)    →  UNITS (Work tracking)
docs/features/FEATURE.md   plans/FEATURE.md             docs/features/FEATURE-units.md
What we want               How we'll build it           What to do next
```

| Document | Owner | Purpose | Updates |
|----------|-------|---------|---------|
| **Spec** | Human | Requirements, acceptance criteria | Rarely |
| **Plan** | Planner | Architecture, milestones, approach | After each milestone |
| **Units** | Implementer | Micro-unit status, session logs | During implementation |

## Plan as Living Document

**Plans are updated as work progresses:**
- Milestones marked complete with dates
- Lessons learned added
- Approach adjustments documented

This keeps the plan as accurate documentation, not a stale artifact.

## Plan Structure

```markdown
# Plan: [Feature Name]

## Overview
[2-3 sentences describing the feature]

## Milestones
| Milestone | Units | Status | Completed |
|-----------|-------|--------|-----------|
| Foundation | 1-2 | ✅ DONE | 2026-01-20 |
| Core Features | 3-5 | 🔄 IN PROGRESS | - |
| Polish | 6-7 | ⏳ PENDING | - |

## Architecture
[Key technical decisions and patterns]

## Steps

### Step 1: [Name]
**Unit:** 1
**Files:** [files to create/modify]
[Implementation details]

### Step 2: [Name]
**Unit:** 1
...

## Risks & Mitigations
[Potential issues and how to handle them]

## Lessons Learned
[Added after each milestone - what worked, what didn't]
```

## Workflow

### Creating Plans
```bash
/plan-feature docs/features/my-feature.md
```

Creates both:
- `plans/my-feature.md` (this directory)
- `docs/features/my-feature-units.md`

### Implementing
```bash
# For each unit:
/implement-step docs/features/my-feature-units.md 1
# Then:
/verify-ship docs/features/my-feature-units.md 1
```

### Updating Plans
Plans are updated by:
- `/implement-step` - updates milestones on completion
- `/verify-ship` - updates milestones when shipping

## Naming Convention

Use lowercase with hyphens:
- `todo-filtering.md`
- `phase-4-tui-components.md`
- `user-authentication.md`

## Key Principles

1. **Micro-units:** Keep work units as small as logically possible
2. **Living docs:** Update plans as work progresses
3. **Session isolation:** Clear context between roles
4. **Units file is source of truth** for implementation status

---

See `_PLAN_TEMPLATE.md` for the full template.
