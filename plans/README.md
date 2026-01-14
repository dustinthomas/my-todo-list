# Implementation Plans

This directory contains detailed implementation plans for features. Plans are version-controlled documentation that guide development and serve as permanent records of design decisions.

## Purpose

Implementation plans serve multiple purposes:

1. **Pre-Implementation Design:** Think through approach before coding
2. **Team Collaboration:** Review and discuss plans before implementation begins
3. **Step-by-Step Guidance:** Break complex features into manageable steps
4. **Historical Documentation:** Permanent record of why decisions were made
5. **Knowledge Transfer:** Help new contributors understand feature development

## Workflow

### 1. Create Feature Specification

Start with a feature spec in `docs/features/`:

```bash
# Use the template
cp docs/features/_TEMPLATE.md docs/features/my-feature.md

# Fill in the details
vim docs/features/my-feature.md
```

### 2. Generate Implementation Plan

Use the Planner role to create a detailed plan:

```bash
# In Planner tab (Tab 1)
/plan-feature docs/features/my-feature.md
```

This creates `plans/my-feature.md` with:
- Step-by-step implementation instructions
- Files to create or modify
- Testing strategy
- Acceptance criteria
- Risk assessment

### 3. Review and Approve Plan

- Read the plan in `plans/my-feature.md`
- Discuss with team (via PR comments or direct discussion)
- Request changes if needed
- Approve when ready

### 4. Implement the Plan

Use the Implementer role to execute the plan:

```bash
# Create feature branch
git checkout -b feature/my-feature

# In Implementer tab (Tab 2)
/implement-step plans/my-feature.md

# After each step completion:
/implement-step plans/my-feature.md

# Continue until all steps complete
```

### 5. Keep Plan as Documentation

After implementation:
- Plans stay in this directory permanently
- They document design decisions
- They help understand why code works the way it does
- They guide future modifications

## Plan Structure

Each plan follows this structure:

```markdown
# Plan: [Feature Name]

## Overview
Brief description of the feature

## Steps
Detailed step-by-step implementation guide

## Files
List of files to create or modify

## Risks
Potential issues and mitigation strategies

## Acceptance Criteria
Specific, measurable completion criteria

## Testing Strategy
How to verify the feature works

## Notes
Additional context or considerations
```

## Example Plans

This repository contains implementation plans for all major features:

- `plans/project-foundation.md` - Initial project setup
- `plans/docker-setup.md` - Docker configuration
- `plans/database-layer.md` - Database schema and CRUD operations
- *(Future plans will be added as features are developed)*

## Plan Naming Convention

Plans should use descriptive names matching their feature:

- `todo-list-view.md` - Feature: Todo list view
- `add-filter-screen.md` - Feature: Filter screen
- `project-management.md` - Feature: Project management

Use lowercase with hyphens, not underscores or spaces.

## Committing Plans

Plans can be committed to `main` branch for review:

```bash
# After creating plan
git add plans/my-feature.md
git commit -m "docs: add implementation plan for my-feature"
git push
```

Or create a PR for team review:

```bash
# On a branch
git checkout -b plan/my-feature
git add plans/my-feature.md
git commit -m "docs: add implementation plan for my-feature"
git push -u origin plan/my-feature

# Create PR for review
gh pr create --title "Plan: My Feature" --body "Implementation plan for my-feature. Ready for review."
```

## Parallel Planning

Multiple features can be planned simultaneously:

```bash
# Tab 1: Plan feature A
/plan-feature docs/features/feature-a.md

# Tab 2: Plan feature B
/plan-feature docs/features/feature-b.md

# Tab 3: Plan feature C
/plan-feature docs/features/feature-c.md
```

This enables:
- Faster overall planning
- Clearer priority discussions
- Better resource allocation

## Plan Maintenance

Plans should be updated when:

1. **Implementation Deviates:** If implementation differs significantly from plan, update plan to reflect reality
2. **New Risks Discovered:** Add newly identified risks to plan
3. **Steps Changed:** If steps are reordered or modified, update plan
4. **Acceptance Criteria Adjusted:** If criteria change during implementation, update plan

Keep plans as accurate historical documentation.

## Plan Templates

For TUI features, include:
- Screen wireframes (ASCII art)
- Keyboard mappings
- Component breakdown
- Rendering strategy

For database features, include:
- Schema changes (SQL)
- Migration strategy
- Data validation rules
- Index considerations

For refactoring, include:
- Current state analysis
- Target state description
- Migration approach
- Rollback strategy

## Finding Plans

To find a plan:

```bash
# List all plans
ls plans/

# Search plan content
grep -r "keyword" plans/

# Find plans mentioning a file
grep -r "src/database.jl" plans/
```

## Benefits of Version-Controlled Plans

1. **Parallel Planning:** Multiple features can be planned simultaneously
2. **Pre-Code Collaboration:** Team discusses design before coding begins
3. **Design Documentation:** Plans explain why code works the way it does
4. **Onboarding Aid:** New contributors understand feature development
5. **Audit Trail:** Historical record of all design decisions

## Common Pitfalls to Avoid

❌ **DON'T:** Write vague plans like "Implement feature"
✅ **DO:** Break down into specific, testable steps

❌ **DON'T:** Skip planning for "simple" features
✅ **DO:** Plan all but trivial changes (reduces mistakes)

❌ **DON'T:** Delete or modify plans after implementation
✅ **DO:** Keep plans as historical documentation

❌ **DON'T:** Make plans overly prescriptive (line-by-line code)
✅ **DO:** Provide clear direction while allowing implementation flexibility

❌ **DON'T:** Skip acceptance criteria
✅ **DO:** Define specific, measurable completion criteria

## Integration with Workflow

Plans integrate with the Boris Cherny "Plant" workflow:

1. **Planner (Tab 1):** Creates plans using `/plan-feature`
2. **Implementer (Tab 2):** Executes plans using `/implement-step`
3. **Tester (Tab 3):** Verifies using acceptance criteria from plan
4. **Refactorer (Tab 4):** Simplifies after plan completion
5. **Docs (Tab 5):** Updates CLAUDE.md with lessons learned

See [CLAUDE-WORKFLOW.md](../CLAUDE-WORKFLOW.md) for full workflow details.

## Questions?

For questions about planning process:
- Read: [CLAUDE-WORKFLOW.md](../CLAUDE-WORKFLOW.md)
- Check: `.claude/commands/plan-feature.md`
- Refer to: Example plans in this directory

---

**Remember:** Plans are permanent documentation. They help everyone understand not just *what* was built, but *why* and *how*.
