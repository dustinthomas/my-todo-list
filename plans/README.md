# Implementation Plans

Plans are **living documents** that guide development and track progress at the milestone level.

## Active Plans

| Plan | Status | Description |
|------|--------|-------------|
| [Phase 5: Extensibility](phase-5-extensibility.md) | IN PROGRESS | Screen state, abstract types, event-driven loop |

## Archived Plans

Completed plans are in `archive/`:

| Plan | Completed | PRs |
|------|-----------|-----|
| [Phase 3: Database Layer](archive/phase-3-database-layer.md) | 2026-01-16 | #4 |
| [Phase 4: TUI Components](archive/phase-4-tui-components.md) | 2026-01-18 | #5-#10 |
| [Term.jl Enhancement](archive/term-jl-enhancement.md) | 2026-01-20 | #15-#19 |

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

## Key Principles

1. **Micro-units:** Keep work units as small as logically possible
2. **Living docs:** Update plans as work progresses
3. **Session isolation:** Clear context between roles
4. **Units file is source of truth** for implementation status

---

See `_PLAN_TEMPLATE.md` for the full template.
