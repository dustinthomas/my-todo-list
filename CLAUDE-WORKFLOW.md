# Claude Code Workflow Guide

This project follows the **Boris Cherny "Plant" workflow**, where multiple Claude Code sessions work in parallel with specialized roles.

## The "Plant" Concept

Instead of one Claude session doing everything, we use **5 specialized sessions** that each excel at one task:

| Tab | Role | Slash Command | Responsibility |
|-----|------|---------------|----------------|
| Tab 1 | **Planner** | `/plan-feature` | Create detailed implementation plans (read-only) |
| Tab 2 | **Implementer** | `/implement-step` | Execute one plan step at a time, test after each |
| Tab 3 | **Tester** | `/verify-feature` | Run tests and verify acceptance criteria |
| Tab 4 | **Refactorer** | `/simplify` | Clean and optimize code without behavior changes |
| Tab 5 | **Docs** | `/update-rules` | Update CLAUDE.md with lessons learned |

**Key Principle:** Each session does ONE job well, enabling parallel work while maintaining quality.

## Workflow Cycle

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  1. PLAN    │────▶│ 2. IMPLEMENT│────▶│  3. VERIFY  │
│  (Tab 1)    │     │   (Tab 2)   │     │   (Tab 3)   │
└─────────────┘     └─────────────┘     └─────────────┘
     ▲                                       │
     │                                       ▼
     │             ┌─────────────┐     ┌─────────────┐
     └─────────────│  5. SHIP    │◀────│ 4. SIMPLIFY │
                   │   (Any)     │     │   (Tab 4)   │
                   └─────────────┘     └─────────────┘
```

### Step-by-Step Process

1. **Plan (Tab 1)**
   - Use `/plan-feature` with feature spec from `docs/features/`
   - Claude reads CLAUDE.md, explores codebase, creates detailed plan
   - Plan saved to `plans/FEATURE-NAME.md`
   - Commit plan for team review

2. **Human Reviews Plan**
   - Review plan in `plans/` directory
   - Discuss, comment, approve
   - Approve means implementation can begin

3. **Implement (Tab 2)**
   - Create feature branch: `git checkout -b feature/FEATURE-NAME`
   - Use `/implement-step` with plan file
   - Execute ONE step at a time
   - Run tests after each step
   - Claude reports completion, waits for next step

4. **Verify (Tab 3)**
   - Use `/verify-feature` with plan file
   - Runs full test suite
   - Checks acceptance criteria
   - Identifies any issues (doesn't fix them)
   - Reports pass/fail

5. **Simplify (Tab 4)**
   - Use `/simplify` on completed feature
   - Identifies simplification opportunities
   - Makes incremental changes
   - Runs tests after every change
   - Never changes public APIs or behavior

6. **Ship (Any tab)**
   - Use `/commit-push-pr`
   - Creates descriptive commit message
   - Pushes branch with `-u origin`
   - Creates PR with formatted description

7. **Update Rules (Tab 5)**
   - When mistakes happen, use `/update-rules`
   - Document lesson learned in CLAUDE.md
   - Prevents recurrence

## Slash Commands Reference

### `/plan-feature` - Planner Role

**Purpose:** Create detailed implementation plans without writing code

**Input:** Feature specification from `docs/features/`

**Process:**
1. Reads CLAUDE.md for project rules
2. Explores codebase to understand context
3. Designs implementation approach
4. Creates plan in `plans/FEATURE-NAME.md`

**Output:** Detailed plan with:
- Step-by-step instructions
- Files to modify
- Risks and considerations
- Acceptance criteria

**Example Usage:**
```bash
# In Tab 1 (Planner)
/plan-feature docs/features/add-todo-list-view.md
```

**Key Rule:** Planner is READ-ONLY. No code edits, only planning.

---

### `/implement-step` - Implementer Role

**Purpose:** Execute ONE step from an approved plan

**Input:** Plan file from `plans/` directory

**Process:**
1. Reads CLAUDE.md and plan file
2. Identifies next incomplete step
3. Makes code changes for that step only
4. Runs tests
5. Reports completion

**Output:** Code changes + test results for one step

**Example Usage:**
```bash
# In Tab 2 (Implementer)
/implement-step plans/add-todo-list-view.md

# Claude implements step 1, reports completion
# You review, then:
/implement-step plans/add-todo-list-view.md

# Claude implements step 2, and so on...
```

**Key Rule:** Implementer does ONE step at a time. Test after each step.

---

### `/verify-feature` - Tester Role

**Purpose:** Run tests and verify acceptance criteria

**Input:** Plan file with acceptance criteria

**Process:**
1. Runs full test suite
2. Checks each acceptance criterion
3. Identifies any failures
4. Reports pass/fail with details

**Output:** Test report + acceptance criteria status

**Example Usage:**
```bash
# In Tab 3 (Tester)
/verify-feature plans/add-todo-list-view.md
```

**Key Rule:** Tester identifies issues but doesn't fix them. Implementation issues go back to Implementer.

---

### `/simplify` - Refactorer Role

**Purpose:** Improve code without changing behavior

**Input:** Files or feature to simplify

**Process:**
1. Identifies simplification opportunities
2. Makes incremental changes
3. Runs tests after every change
4. Stops if tests fail

**Output:** Cleaner, more maintainable code

**Example Usage:**
```bash
# In Tab 4 (Refactorer)
/simplify src/tui/components.jl

# Or for whole feature:
/simplify feature add-todo-list-view
```

**Key Rules:**
- Never change public APIs
- Never change behavior
- Test after every change
- Incremental changes only

---

### `/commit-push-pr` - Ship Role

**Purpose:** Create commit, push branch, create PR

**Input:** Current branch with changes

**Process:**
1. Reviews staged changes
2. Creates descriptive commit message
3. Pushes branch with `-u origin BRANCH-NAME`
4. Creates PR with formatted description

**Output:** Commit + PR ready for review

**Example Usage:**
```bash
# In any tab (after implementation complete)
git add .
/commit-push-pr
```

**Key Rule:** Never merge directly. Always create PR for review.

---

### `/update-rules` - Docs Role

**Purpose:** Update CLAUDE.md after learning from mistakes

**Input:** Description of what went wrong

**Process:**
1. Analyzes the mistake
2. Identifies root cause
3. Proposes update to CLAUDE.md
4. Gets approval before editing

**Output:** Updated CLAUDE.md with new rule

**Example Usage:**
```bash
# In Tab 5 (Docs)
/update-rules

# Then explain what went wrong, Claude will propose update
```

**Key Rule:** Document lessons learned to prevent recurrence.

## Feature Development Example

Let's walk through developing a "Todo List View" feature for our TUI application.

### Phase 1: Planning (Tab 1)

```bash
# Create feature spec
echo "Feature: Todo List View
Goal: Display all todos in a styled table
[...details...]" > docs/features/todo-list-view.md

# Plan the feature
/plan-feature docs/features/todo-list-view.md
```

Claude creates `plans/todo-list-view.md` with:
```markdown
# Plan: Todo List View

## Steps
1. Create TodoTable component in src/tui/components.jl
2. Implement render_list_screen in src/tui/screens.jl
3. Add navigation logic in src/tui/navigation.jl
4. Write tests in test/test_tui.jl
5. Manual test: verify display and navigation

## Files
- src/tui/components.jl (create)
- src/tui/screens.jl (create)
- src/tui/navigation.jl (create)
- test/test_tui.jl (create)

## Risks
- Term.jl table rendering might not support all styles
- Keyboard input might be platform-specific

## Acceptance Criteria
- [ ] Table displays with correct columns
- [ ] Arrow keys navigate up/down
- [ ] Selected row is highlighted
- [ ] Tests pass
```

**Human reviews plan, approves.**

### Phase 2: Implementation (Tab 2)

```bash
# Create feature branch
git checkout -b feature/todo-list-view

# Implement step by step
/implement-step plans/todo-list-view.md
```

**After Step 1 completes:**
```
Claude: Step 1 complete. Created TodoTable component. Tests pass.
Ready for step 2.
```

**Continue:**
```bash
/implement-step plans/todo-list-view.md
```

Repeat until all steps complete.

### Phase 3: Verification (Tab 3)

```bash
/verify-feature plans/todo-list-view.md
```

**Output:**
```
Test Results: ✓ All 12 tests pass

Acceptance Criteria:
✓ Table displays with correct columns
✓ Arrow keys navigate up/down
✓ Selected row is highlighted
✓ Tests pass

Recommendation: PASS - Feature ready for merge
```

### Phase 4: Simplification (Tab 4)

```bash
/simplify feature todo-list-view
```

Claude identifies opportunities:
```
Simplifications:
1. Extract table styling to helper function
2. Combine similar navigation functions
3. Simplify test setup code

Applying changes incrementally...
```

### Phase 5: Ship (Any tab)

```bash
git add .
/commit-push-pr
```

Claude creates:
```
Commit: feat: add todo list view with navigation

PR Title: Add Todo List View with Navigation
PR Description:
## Summary
Implements styled todo list table with keyboard navigation

## Changes
- TodoTable component for rendering
- List screen with arrow key navigation
- Full test coverage

## Testing
- [x] All tests pass (12/12)
- [x] Manual testing complete
```

### Phase 6: Update Rules (Tab 5, if needed)

If issues occurred during development:

```bash
/update-rules
```

Claude proposes addition to CLAUDE.md:
```markdown
### [2026-01-14] - Term.jl table column width
**What happened:** Table columns didn't align correctly
**Why:** Didn't specify fixed column widths
**Rule:** Always specify fixed widths for Term.jl tables
```

## Tips for Success

### For Planning (Tab 1)
- Provide detailed feature specs in `docs/features/`
- Plans should be thorough but not prescriptive
- Include acceptance criteria for verification
- Commit plans for team review

### For Implementation (Tab 2)
- ONE step at a time, test after each
- Don't skip ahead to future steps
- Report completion, wait for next instruction
- Keep commits atomic and focused

### For Testing (Tab 3)
- Run full test suite, not just new tests
- Check all acceptance criteria
- Report issues without fixing them
- Provide clear pass/fail recommendation

### For Refactoring (Tab 4)
- Wait until feature is complete and tested
- Make incremental changes
- Test after every change
- Focus on readability and maintainability

### For Shipping (Any tab)
- Always create PR, never merge directly
- Use descriptive commit messages
- Include "Co-Authored-By: Claude..." in commits
- Link PRs to related issues

### For Rules Updates (Tab 5)
- Document mistakes immediately
- Include what happened, why, and new rule
- Get approval before updating CLAUDE.md
- Be specific to prevent recurrence

## Common Patterns

### Pattern 1: Parallel Planning
Plan multiple features simultaneously in separate tabs:
```bash
# Tab 1: Plan feature A
/plan-feature docs/features/feature-a.md

# Tab 2: Plan feature B
/plan-feature docs/features/feature-b.md

# Tab 3: Plan feature C
/plan-feature docs/features/feature-c.md
```

### Pattern 2: Pipeline Development
Implement while planning next feature:
```bash
# Tab 1: Plan feature B
/plan-feature docs/features/feature-b.md

# Tab 2: Implement feature A
/implement-step plans/feature-a.md
```

### Pattern 3: Continuous Verification
Test while implementing:
```bash
# Tab 1: Implement step
/implement-step plans/feature-a.md

# Tab 2: Verify after each step
/verify-feature plans/feature-a.md
```

## Troubleshooting

### Problem: Tests failing after implementation
**Solution:** Use Tester tab (`/verify-feature`) to identify issues, then use Implementer tab to fix.

### Problem: Code getting messy
**Solution:** Use Refactorer tab (`/simplify`) regularly, not just at end.

### Problem: Repeated mistakes
**Solution:** Use Docs tab (`/update-rules`) to update CLAUDE.md immediately.

### Problem: Unclear plan
**Solution:** Improve feature spec in `docs/features/`, re-run `/plan-feature`.

### Problem: Implementation stuck
**Solution:** Check if plan step is too large. Break into smaller steps in plan file.

## TUI-Specific Workflow Notes

For TUI development, additional considerations:

### Testing TUI Components
- **Unit tests:** Test rendering logic (output strings)
- **Integration tests:** Test navigation state transitions
- **Manual tests:** Required for visual verification

### TUI Development Cycle
```bash
# 1. Implement component
/implement-step plans/tui-component.md

# 2. Test in Docker
./scripts/docker-start
julia --project=. -e 'using TodoTUI; ...'

# 3. Verify tests pass
./scripts/docker-test

# 4. Visual verification
# Manual keyboard testing in TUI
```

### TUI-Specific Slash Commands
When using slash commands for TUI features:
- Include screen wireframes in plans
- Specify keyboard mappings explicitly
- Document expected visual output
- Include manual testing checklist

## Version-Controlled Plans

Plans live in `plans/` directory as **permanent documentation**:

**Benefits:**
- Parallel feature planning
- Pre-code collaboration
- Design decision documentation
- Knowledge transfer for new contributors

**Workflow:**
1. Create plan in `plans/FEATURE-NAME.md`
2. Commit plan for review (on main or branch)
3. Get approval via discussion
4. Create feature branch
5. Implement step-by-step
6. Keep plan as permanent documentation

## Summary

The "Plant" workflow maximizes code quality through specialization:

- **Planner:** Thinks deeply about design before coding
- **Implementer:** Focuses on execution, one step at a time
- **Tester:** Ensures quality without implementation bias
- **Refactorer:** Improves code without feature pressure
- **Docs:** Captures lessons learned for future

**Key to Success:** Use the right tool (session) for each job. Don't mix responsibilities.

---

For questions or workflow improvements, update this document via `/update-rules`.
