# Implementation Plans

This directory contains detailed implementation plans for features. Plans are version-controlled documentation that guide development and serve as permanent records of design decisions.

## Purpose

Implementation plans serve multiple purposes:

1. **Pre-Implementation Design:** Think through approach before coding
2. **Team Collaboration:** Review and discuss plans before implementation begins
3. **Step-by-Step Guidance:** Break complex features into manageable steps
4. **Historical Documentation:** Permanent record of why decisions were made
5. **Knowledge Transfer:** Help new contributors understand feature development

## Two-File Planning System

The Planner role creates TWO files:

| File | Location | Purpose |
|------|----------|---------|
| **Plan** | `plans/FEATURE.md` | Detailed implementation steps |
| **Work Units** | `docs/features/FEATURE-units.md` | PR-sized chunks with acceptance criteria |

### Plan File (`plans/FEATURE.md`)

Contains:
- Detailed step-by-step implementation instructions
- Files to create or modify per step
- Testing strategy
- Risk assessment
- Each step tagged with its Work Unit number

### Work Units File (`docs/features/FEATURE-units.md`)

Contains:
- Progress summary table
- PR-sized work units (groups of steps)
- Acceptance criteria per unit
- Dependency ordering
- Session log for handoff notes
- Status tracking (PENDING → MERGED)

## Workflow

### 1. Create Feature Specification

Start with a feature spec in `docs/features/`:

```bash
# Use the template
cp docs/features/_TEMPLATE.md docs/features/my-feature.md

# Fill in the details
vim docs/features/my-feature.md
```

### 2. Generate Plan and Work Units

Use the Planner role to create both files:

```bash
# Clear context first if coming from another session
/plan-feature docs/features/my-feature.md
```

This creates:
- `plans/my-feature.md` - Detailed steps
- `docs/features/my-feature-units.md` - Work units checklist

### 3. Review and Approve

- Read both plan and work units files
- Discuss with team (via PR comments or direct discussion)
- Request changes if needed
- Approve when ready

### 4. Implement Work Units

Each work unit is implemented in a separate session:

```bash
# CLEAR CONTEXT first
# Create or switch to feature branch
git checkout -b feature/my-feature-unit-1

# Implement unit 1
/implement-step docs/features/my-feature-units.md 1

# CLEAR CONTEXT
# Verify unit 1
/verify-feature docs/features/my-feature-units.md 1

# If PASS: CLEAR CONTEXT, ship
/commit-push-pr

# After PR merged, CLEAR CONTEXT, repeat for next unit
/implement-step docs/features/my-feature-units.md 2
```

### 5. Keep Files as Documentation

After implementation:
- Plan files stay in `plans/` permanently
- Work units files stay in `docs/features/`
- They document design decisions and implementation history
- They help understand why code works the way it does

## Plan Structure

Each plan follows this structure:

```markdown
# Plan: [Feature Name]

## Overview
Brief description of the feature

**Work Units:** See `docs/features/FEATURE-units.md` for PR-sized breakdown

## Steps

### Step 1: [Description]
**Work Unit:** 1
**Files:** [files to modify]
**Changes:** [specific changes]
**Tests:** [how to verify]

### Step 2: [Description]
**Work Unit:** 1
...

### Step 3: [Description]
**Work Unit:** 2
...

## Files
List of files to create or modify

## Risks
Potential issues and mitigation strategies

## Acceptance Criteria (Overall)
Specific, measurable completion criteria for entire feature

## Testing Strategy
How to verify the feature works
```

## Work Units Structure

See `docs/features/_UNITS_TEMPLATE.md` for the full template.

Key sections:
- Progress summary table
- Work units with:
  - Status (PENDING/IN_PROGRESS/IMPLEMENTED/VERIFIED/MERGED)
  - Branch name
  - Plan steps covered
  - Dependencies
  - Acceptance criteria
- Session log for handoff notes
- Issues tracking

## Session Isolation

**Critical:** Context MUST be cleared between:
- Planning → Implementation
- Implementation → Verification
- Verification → Next Unit
- Any role transition

The work units file is the source of truth that survives context clears.

## Plan Naming Convention

Plans should use descriptive names matching their feature:

- `todo-list-view.md` - Feature: Todo list view
- `add-filter-screen.md` - Feature: Filter screen
- `project-management.md` - Feature: Project management
- `phase-4-tui-components.md` - Phase: TUI Components

Use lowercase with hyphens, not underscores or spaces.

## Committing Plans

Plans can be committed to `main` branch for review:

```bash
# After creating plan
git add plans/my-feature.md docs/features/my-feature-units.md
git commit -m "docs: add implementation plan for my-feature"
git push
```

Or create a PR for team review:

```bash
# On a branch
git checkout -b plan/my-feature
git add plans/my-feature.md docs/features/my-feature-units.md
git commit -m "docs: add implementation plan for my-feature"
git push -u origin plan/my-feature

# Create PR for review
gh pr create --title "Plan: My Feature" --body "Implementation plan for my-feature. Ready for review."
```

## Plan Maintenance

Plans should be updated when:

1. **Implementation Deviates:** If implementation differs significantly from plan, update plan to reflect reality
2. **New Risks Discovered:** Add newly identified risks to plan
3. **Steps Changed:** If steps are reordered or modified, update plan
4. **Acceptance Criteria Adjusted:** If criteria change during implementation, update plan

Keep plans as accurate historical documentation.

## Common Pitfalls to Avoid

❌ **DON'T:** Create plan without work units file
✅ **DO:** Always create both `plans/` and `docs/features/` files

❌ **DON'T:** Make work units too large (entire feature) or too small (single function)
✅ **DO:** Size units for 1-3 days of work, resulting in one PR

❌ **DON'T:** Skip context clearing between units
✅ **DO:** Clear context after every role transition

❌ **DON'T:** Use TodoWrite for cross-session tracking
✅ **DO:** Use work units file for persistent state

❌ **DON'T:** Write code during planning
✅ **DO:** Only create markdown files during planning

❌ **DON'T:** Skip verification before shipping
✅ **DO:** Always run `/verify-feature` before `/commit-push-pr`

## Integration with Workflow

Plans integrate with the Boris Cherny "Plant" workflow:

1. **Planner:** Creates plans + work units using `/plan-feature`
2. **Implementer:** Executes ONE unit using `/implement-step UNITS-FILE N`
3. **Tester:** Verifies ONE unit using `/verify-feature UNITS-FILE N`
4. **Refactorer:** Simplifies code using `/simplify`
5. **Shipper:** Creates PR using `/commit-push-pr`

Each role operates in a fresh context session.

## Questions?

For questions about planning process:
- Read: [CLAUDE.md](../CLAUDE.md) for workflow rules
- Check: `.claude/commands/plan-feature.md` for planner instructions
- Template: `docs/features/_UNITS_TEMPLATE.md` for work units structure
- Refer to: Example plans in this directory

---

**Remember:** Plans are permanent documentation. Work units track progress. Together they ensure clean handoffs and complete implementations.
