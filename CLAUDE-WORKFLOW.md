# Claude Code Workflow Guide

This project follows the **Boris Cherny "Plant" workflow**, where multiple Claude Code sessions work in parallel with specialized roles. Each session has a narrow scope and fresh context.

## The "Plant" Concept

Instead of one Claude session doing everything, we use **specialized sessions** that each excel at one task:

| Role | Slash Command | Input | Responsibility |
|------|---------------|-------|----------------|
| **Planner** | `/plan-feature` | Feature spec | Create plan + work units (read-only) |
| **Implementer** | `/implement-step UNITS N` | Work unit N | Execute ONE work unit, test, hand off |
| **Tester** | `/verify-feature UNITS N` | Work unit N | Verify ONE unit, report PASS/FAIL |
| **Refactorer** | `/simplify` | Files | Clean code without behavior changes |
| **Shipper** | `/commit-push-pr` | Branch | Create commit and PR |
| **Docs** | `/update-rules` | Lesson | Update CLAUDE.md with lessons learned |

**Key Principles:**
- Each session does ONE job well
- Context is cleared between roles
- Work units file tracks state across sessions
- Each work unit = one PR

## Work Units: The Key Concept

A **Work Unit** is a PR-sized chunk of work:
- Groups multiple plan steps together
- Self-contained and testable
- Results in ONE pull request
- Has clear acceptance criteria

### Work Unit Lifecycle

```
PENDING → IN_PROGRESS → IMPLEMENTED → VERIFIED → MERGED
                │              │
                │              └── FAILED → back to IN_PROGRESS
                └── BLOCKED (dependency not met)
```

### Two-File Planning System

The Planner creates TWO files:

| File | Purpose |
|------|---------|
| `plans/FEATURE.md` | Detailed step-by-step implementation plan |
| `docs/features/FEATURE-units.md` | Work units checklist (PR-sized chunks) |

## Workflow Diagram

```
┌──────────────────┐
│ Feature Spec     │
│ docs/features/   │
│ FEATURE.md       │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐     ┌─────────────────────────────────────────┐
│ /plan-feature    │ ──► │ TWO OUTPUTS:                            │
│ (Planner)        │     │  1. plans/FEATURE.md (detailed steps)   │
│ READ-ONLY        │     │  2. docs/features/FEATURE-units.md      │
└──────────────────┘     │     (work units checklist)              │
                         └────────────────┬────────────────────────┘
                                          │
         ┌────────────────────────────────┴────────────────────────┐
         │                                                         │
         ▼                                                         ▼
┌─────────────────────┐                              ┌─────────────────────┐
│ Work Unit 1         │                              │ Work Unit N         │
├─────────────────────┤                              ├─────────────────────┤
│ CLEAR CONTEXT       │                              │ CLEAR CONTEXT       │
│ /implement-step 1   │                              │ /implement-step N   │
│ ─────────────────── │                              │ ─────────────────── │
│ CLEAR CONTEXT       │                              │ CLEAR CONTEXT       │
│ /verify-feature 1   │ ───────── ... ─────────────► │ /verify-feature N   │
│ ─────────────────── │                              │ ─────────────────── │
│ CLEAR CONTEXT       │                              │ CLEAR CONTEXT       │
│ /commit-push-pr     │                              │ /commit-push-pr     │
│ (creates PR #1)     │                              │ (creates PR #N)     │
└─────────────────────┘                              └─────────────────────┘
```

## Session Isolation Rules

### Core Principle

**Each session = One role, One work unit**

Context MUST be cleared between:
- Planner → Implementer
- Implementer → Tester
- Tester → Implementer (on FAIL)
- Tester → Shipper (on PASS)
- Unit N → Unit N+1

### Why Session Isolation?

1. **Fresh context**: Each session gets full token budget
2. **Clean handoffs**: Work units file tracks state
3. **Reduced errors**: No stale context causing mistakes
4. **Parallel work**: Different units can be worked on independently

### What Each Session Reads

| Role | Must Read | May Read |
|------|-----------|----------|
| Planner | CLAUDE.md, Feature spec | Existing code patterns |
| Implementer | CLAUDE.md, Work units file, Plan | Source files for unit |
| Tester | CLAUDE.md, Work units file | Test files, source files |
| Refactorer | CLAUDE.md, Source files | Tests |
| Shipper | CLAUDE.md, Git status | Work units file |

## Step-by-Step Process

### 1. Plan (Planner Session)

```bash
# CLEAR CONTEXT if coming from another session
/plan-feature docs/features/my-feature.md
```

**Process:**
1. Claude reads CLAUDE.md and feature spec
2. Explores codebase to understand context
3. Creates detailed plan in `plans/FEATURE.md`
4. Creates work units in `docs/features/FEATURE-units.md`
5. Hands off with: "CLEAR CONTEXT, run /implement-step"

**Output:** Two files ready for implementation

### 2. Human Reviews Plan

- Review plan in `plans/` directory
- Review work units breakdown
- Discuss, comment, approve
- Ensure work units are properly sized (1-3 days each)

### 3. Implement (Implementer Session) - ONE UNIT

```bash
# CLEAR CONTEXT
# Create branch for this unit
git checkout -b feature/my-feature-unit-1

# Implement ONLY unit 1
/implement-step docs/features/my-feature-units.md 1
```

**Process:**
1. Claude reads work unit 1 scope and acceptance criteria
2. Updates status: PENDING → IN_PROGRESS
3. Implements all steps in that unit
4. Writes tests, runs tests
5. Updates status: IN_PROGRESS → IMPLEMENTED
6. Hands off with: "CLEAR CONTEXT, run /verify-feature"

**Output:** Code + tests for ONE work unit

### 4. Verify (Tester Session) - ONE UNIT

```bash
# CLEAR CONTEXT
/verify-feature docs/features/my-feature-units.md 1
```

**Process:**
1. Claude checks unit status (must be IMPLEMENTED)
2. Runs full test suite
3. Checks each acceptance criterion
4. Updates status: IMPLEMENTED → VERIFIED (if pass)
5. Reports PASS or FAIL with details

**If PASS:** "CLEAR CONTEXT, run /commit-push-pr"
**If FAIL:** "CLEAR CONTEXT, run /implement-step to fix issues"

### 5. Simplify (Refactorer Session) - Optional

```bash
# CLEAR CONTEXT
/simplify src/tui/components/
```

**Process:**
1. Identifies simplification opportunities
2. Makes incremental changes
3. Tests after every change
4. Stops if tests fail

**Key Rules:**
- Never change public APIs
- Never change behavior
- Test after every change

### 6. Ship (Shipper Session)

```bash
# CLEAR CONTEXT
/commit-push-pr
```

**Process:**
1. Reviews staged changes
2. Creates descriptive commit message
3. Pushes branch
4. Creates PR with formatted description

**After PR merged:** Proceed to next unit

### 7. Repeat for Next Unit

```bash
# CLEAR CONTEXT
git checkout -b feature/my-feature-unit-2
/implement-step docs/features/my-feature-units.md 2
# ... continue cycle
```

### 8. Update Rules (Docs Session) - When Needed

```bash
# CLEAR CONTEXT
/update-rules
```

Use when mistakes happen to document lessons learned in CLAUDE.md.

## Slash Commands Reference

### `/plan-feature` - Planner Role

**Purpose:** Create detailed plan AND work units (without writing code)

**Input:** Feature spec path (e.g., `docs/features/my-feature.md`)

**Output:**
- `plans/FEATURE.md` - Detailed steps
- `docs/features/FEATURE-units.md` - Work units checklist

**Key Rules:**
- READ-ONLY: No code edits
- Must create BOTH files
- Must define PR-sized work units
- Must end with handoff instructions

---

### `/implement-step` - Implementer Role

**Purpose:** Execute ONE work unit from the work units file

**Input:** Work units file + unit number (e.g., `docs/features/my-feature-units.md 1`)

**Process:**
1. Check dependencies met
2. Create branch for unit
3. Update status to IN_PROGRESS
4. Implement all steps in unit
5. Write tests, run tests
6. Update status to IMPLEMENTED
7. Hand off to tester

**Key Rules:**
- ONE unit per session
- Update work units file status
- Test before marking complete
- CLEAR CONTEXT before next unit

---

### `/verify-feature` - Tester Role

**Purpose:** Verify ONE work unit against acceptance criteria

**Input:** Work units file + unit number (e.g., `docs/features/my-feature-units.md 1`)

**Process:**
1. Check unit status is IMPLEMENTED
2. Run full test suite
3. Check each acceptance criterion
4. Report PASS or FAIL
5. Update status (VERIFIED if pass)

**Key Rules:**
- ONE unit per session
- Report issues, DON'T fix them
- Clear PASS/FAIL recommendation
- Update work units file

---

### `/simplify` - Refactorer Role

**Purpose:** Improve code without changing behavior

**Input:** Files or directory to simplify

**Key Rules:**
- Never change public APIs
- Never change behavior
- Test after every change
- Incremental changes only

---

### `/commit-push-pr` - Ship Role

**Purpose:** Create commit, push branch, create PR

**Input:** Current branch with changes

**Key Rules:**
- Never commit to main
- Never merge directly
- Include Claude co-author line
- Check for secrets before committing

---

### `/update-rules` - Docs Role

**Purpose:** Update CLAUDE.md with lessons learned

**Input:** Description of what went wrong

**Key Rules:**
- Document immediately after mistakes
- Include what happened, why, new rule
- Get approval before editing

## Feature Development Example

Let's walk through developing a "Todo List TUI" feature.

### Phase 1: Planning

**Session 1 (Planner):**
```bash
/plan-feature docs/features/tui-components.md
```

Claude creates:
- `plans/tui-components.md` with 16 detailed steps
- `docs/features/tui-components-units.md` with 5 work units:
  - Unit 1: Core Infrastructure (steps 1-2)
  - Unit 2: Base Components (steps 3-6)
  - Unit 3: Form Components (steps 7-8)
  - Unit 4: Screen Implementations (steps 9-14)
  - Unit 5: Integration & Polish (steps 15-16)

**Human reviews, approves.**

### Phase 2: Implementation (Unit 1)

**Session 2 (Implementer):**
```bash
# Create branch
git checkout -b feature/tui-components-unit-1

# Implement unit 1
/implement-step docs/features/tui-components-units.md 1
```

Claude:
- Updates Unit 1 status: PENDING → IN_PROGRESS
- Implements AppState, Screen enum, state helpers
- Writes tests (15 tests)
- Updates status: IN_PROGRESS → IMPLEMENTED
- Reports: "CLEAR CONTEXT, run /verify-feature"

### Phase 3: Verification (Unit 1)

**Session 3 (Tester):**
```bash
/verify-feature docs/features/tui-components-units.md 1
```

Claude:
- Runs full test suite (15/15 pass)
- Checks acceptance criteria (all pass)
- Updates status: IMPLEMENTED → VERIFIED
- Reports: "PASS - CLEAR CONTEXT, run /commit-push-pr"

### Phase 4: Ship (Unit 1)

**Session 4 (Shipper):**
```bash
/commit-push-pr
```

Claude creates PR #1 for Unit 1.

### Phase 5: Repeat for Units 2-5

After PR #1 merged:

**Session 5 (Implementer):**
```bash
git checkout -b feature/tui-components-unit-2
/implement-step docs/features/tui-components-units.md 2
```

Continue until all units complete.

## Work Units File Example

```markdown
# Work Units: TUI Components

**Feature:** Phase 4 TUI Components
**Plan:** plans/tui-components.md
**Status:** In Progress

## Progress Summary

| Unit | Name | Status | Branch | PR |
|------|------|--------|--------|-----|
| 1 | Core Infrastructure | MERGED | feature/tui-unit-1 | #12 |
| 2 | Base Components | VERIFIED | feature/tui-unit-2 | #13 |
| 3 | Form Components | IN_PROGRESS | feature/tui-unit-3 | - |
| 4 | Screen Implementations | PENDING | - | - |
| 5 | Integration & Polish | PENDING | - | - |

## Work Units

### Unit 1: Core Infrastructure
**Status:** MERGED
**Branch:** feature/tui-unit-1
**Plan Steps:** 1, 2
**Acceptance Criteria:**
- [x] AppState struct with all fields
- [x] Screen enum defined
- [x] State transitions work
- [x] All tests pass

### Unit 2: Base Components
**Status:** VERIFIED
**Branch:** feature/tui-unit-2
**Plan Steps:** 3, 4, 5, 6
**Depends On:** Unit 1
**Acceptance Criteria:**
- [x] Header renders with title
- [x] Footer shows shortcuts
- [x] Table supports scrolling
- [x] All tests pass

### Unit 3: Form Components
**Status:** IN_PROGRESS
**Branch:** feature/tui-unit-3
**Plan Steps:** 7, 8
**Depends On:** Unit 2
**Acceptance Criteria:**
- [ ] Text fields work
- [ ] Dropdowns work
- [ ] Validation works
- [ ] All tests pass

## Session Log

### 2026-01-17 - Implementer: Unit 3
**Result:** In Progress
**Notes:**
- Created text field component
- Working on dropdown next
- Handoff: Continue implementation
```

## Tips for Success

### For Planning
- Provide detailed feature specs
- Size work units for 1-3 days of work
- Each unit should result in ONE PR
- Include acceptance criteria per unit

### For Implementation
- ONE unit per session
- Update work units file status
- Test before marking complete
- Clear, specific handoff notes

### For Testing
- Run FULL test suite (catch regressions)
- Check ALL acceptance criteria
- Report issues, don't fix them
- Clear PASS/FAIL recommendation

### For Session Management
- ALWAYS clear context between roles
- ALWAYS clear context between units
- Read work units file at session start
- Update work units file at session end

## Troubleshooting

### Problem: Context getting stale
**Solution:** Clear context more frequently. Each role = fresh session.

### Problem: Lost track of progress
**Solution:** Check work units file. It's the source of truth.

### Problem: Work units too large
**Solution:** Split into smaller units. Target: 1-3 days, one PR.

### Problem: Dependencies blocking
**Solution:** Complete dependent units first. Check "Depends On" field.

### Problem: Tests failing after implementation
**Solution:** Tester reports FAIL, implementer fixes in new session.

### Problem: Repeated mistakes
**Solution:** Use `/update-rules` immediately to document lesson.

## TodoWrite Tool Clarification

**Use TodoWrite for:** Session-internal progress tracking
```
Working on Unit 2:
- [x] Create header.jl
- [x] Create footer.jl
- [ ] Create table.jl
- [ ] Write tests
```

**Don't use TodoWrite for:** Cross-session state (use work units file)

TodoWrite is session-scoped and lost on context clear. The work units file is the persistent state tracker.

## Summary

The improved "Plant" workflow with work units:

1. **Planner** creates plan + work units file
2. **Implementer** executes ONE unit per session
3. **Tester** verifies ONE unit per session
4. **Each unit = one PR**
5. **Context cleared between every role/unit**
6. **Work units file tracks state across sessions**

**Key to Success:** Clear context frequently. Trust the work units file. One unit at a time.

---

For questions or workflow improvements, use `/update-rules` to update documentation.
