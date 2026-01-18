# CLAUDE.md

This is the rulebook for Claude Code sessions working in this repository.

## Goals

- Simple, maintainable TUI (Terminal User Interface) todo list manager
- Interactive terminal interface with keyboard navigation
- Built primarily with Claude Code assistance following Boris Cherny "Plant" workflow
- Human role: review, define requirements, approve design decisions
- Claude role: plan, implement, test, document
- Docker-first development for work project isolation
- Future expansion path for wafer tracking with Rasters.jl

## Hard Rules

- Never commit directly to `main`; always use feature branches
  - This applies to ALL code changes: planning, implementation, testing, refactoring, bug fixes
  - Branch naming: `feature/NAME`, `bugfix/NAME`, `refactor/NAME`, or `test/NAME`
  - Only exception: updating this CLAUDE.md file itself (can be on main with approval)
- Always run tests before proposing a PR
- Never touch the user's database file (`~/.todo-list/todos.db`)
- Never commit database files or temporary files
- Keep dependencies minimal (avoid bloat)
- Prioritize simplicity over features
- Prefer small, incremental PRs that fully implement one unit of work

## Coding Style & Stack

- **Language:** Julia 1.12+
- **TUI Framework:** Term.jl (rendering) + TerminalMenus.jl (navigation, stdlib)
- **Database:** SQLite with SQLite.jl + DBInterface.jl
- **Testing:** Julia's `Test` stdlib for all tests
- **Containerization:** Docker + docker-compose (required for work projects)
- **Style:**
  - 4 spaces indentation
  - Type annotations for public function signatures
  - Docstrings for public functions
  - Follow Julia naming conventions (lowercase with underscores)
- **Future:** Rasters.jl for wafer visualization (not in Phase 1)

### Julia Version Policy
- **New projects**: Always use the latest stable Julia release unless a dependency requires a specific version
- **Existing/production code**: Stick with the version used to build the project until deciding to migrate
- **Current project**: Julia 1.12+ (latest stable as of Phase 2)

## Development Workflow

### Setup
```bash
cd C:\Git\Projects\my-todo-list
julia --project=. -e 'using Pkg; Pkg.instantiate()'
julia --project=. scripts/install.jl
```

### Run CLI
```bash
julia --project=. -e 'using TodoList; @main' [command] [args]
```

### Run Tests
```bash
julia --project=. test/runtests.jl
```

### Initialize Database
```bash
julia --project=. scripts/install.jl
```

### Context Management (for Claude Code sessions)

**Clear context after completing each major feature unit** to maintain token efficiency and fresh focus.

**Unit of work definition:**
- Feature fully implemented (e.g., Todo CRUD, filtering functions)
- All tests written and passing
- Plan file updated with ✅ status and handoff notes
- Code follows established patterns

**Before clearing context:**
1. Run full test suite: `julia --project=. test/runtests.jl`
2. Verify all tests pass
3. Update `plans/[phase-name].md` with:
   - ✅ Completed step checkmarks
   - Current status summary
   - Files created/modified with line counts
   - Test results (pass count)
   - Next steps with specific instructions
   - Key patterns to follow
   - Important gotchas/learnings
4. Commit work to feature branch (optional but recommended)

**After clearing context (next session):**
1. Read `CLAUDE.md` (this file) for rules and patterns
2. Read `plans/[phase-name].md` for current status and next steps
3. Check git branch: `git status`
4. Run tests to verify clean state: `julia --project=. test/runtests.jl`
5. Review existing code patterns in relevant files
6. Begin next unit of work

**Benefits:**
- Token efficiency: Each task gets full context budget
- Fresh perspective: No accumulated implementation cruft
- Clear boundaries: Forces proper "definition of done"
- Pattern reinforcement: Must read existing code to match style
- Real-world alignment: Developers rely on tests/docs, not memory

## Work Units (PR-Sized Chunks)

### What is a Work Unit?

A **Work Unit** is a grouping of plan steps that forms a coherent, testable chunk of work:
- **Self-contained**: Can be implemented, tested, and merged independently
- **PR-sized**: Results in ONE pull request (typically 1-3 days of work)
- **Testable**: Has clear acceptance criteria that can be verified
- **Depends on prior units**: Units are ordered by dependency

### Work Unit Lifecycle

```
PENDING → IN_PROGRESS → IMPLEMENTED → VERIFIED → MERGED
                │              │
                │              └── FAILED → back to IN_PROGRESS
                │
                └── BLOCKED (dependency not met)
```

### Workflow with Work Units

```
┌──────────────────┐
│ Feature Spec     │
│ docs/features/   │
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
│ Unit 1              │                              │ Unit N              │
│ CLEAR → Implement   │                              │ CLEAR → Implement   │
│ CLEAR → Verify      │                              │ CLEAR → Verify      │
│ CLEAR → Ship (PR)   │ ─── ... ───────────────────► │ CLEAR → Ship (PR)   │
└─────────────────────┘                              └─────────────────────┘
```

### Key Files

| File | Purpose | Created By |
|------|---------|------------|
| `docs/features/FEATURE.md` | Feature specification (requirements) | Human |
| `plans/FEATURE.md` | Detailed implementation steps | Planner |
| `docs/features/FEATURE-units.md` | Work units checklist | Planner |

### Commands by Role

| Role | Command | Input | Output |
|------|---------|-------|--------|
| Planner | `/plan-feature` | Feature spec | Plan + Work units files |
| Implementer | `/implement-step UNITS-FILE N` | Work unit N | Code + tests for unit N |
| Tester | `/verify-feature UNITS-FILE N` | Work unit N | PASS/FAIL report |
| Refactorer | `/simplify` | File or feature | Improved code |
| Shipper | `/commit-push-pr` | Branch | Commit + PR |

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
2. **Clean handoffs**: Work units file tracks state between sessions
3. **Reduced errors**: No stale context leading to mistakes
4. **Parallel work**: Different units can be worked on by different sessions

### What Each Session Reads

| Role | Must Read | May Read |
|------|-----------|----------|
| Planner | CLAUDE.md, Feature spec | Existing code patterns |
| Implementer | CLAUDE.md, Work units file, Plan | Source files for unit |
| Tester | CLAUDE.md, Work units file | Test files, source files |
| Refactorer | CLAUDE.md, Source files | Tests |
| Shipper | CLAUDE.md, Git status | Work units file |

### Session Handoff Protocol

**At end of every session:**
1. Update work units file with current status
2. Add session log entry with notes
3. Report next steps explicitly
4. Tell user: "CLEAR CONTEXT, then run [next command]"

**At start of every session:**
1. Read CLAUDE.md
2. Read work units file
3. Find current unit status
4. Proceed with appropriate action

## TodoWrite Tool Usage

### When to Use TodoWrite

**USE FOR:** Session-internal progress tracking

```
Working on Unit 2: Base Components

- [x] Create header.jl
- [x] Create footer.jl
- [ ] Create message.jl
- [ ] Create table.jl
- [ ] Write tests
- [ ] Run tests
```

TodoWrite helps YOU track progress within a single implementation session.

### When NOT to Use TodoWrite

**DON'T USE FOR:** Cross-session planning or state tracking

The work units file (`docs/features/FEATURE-units.md`) is the persistent state tracker.
TodoWrite is session-scoped and lost on context clear.

| Tracking Need | Use This |
|---------------|----------|
| Steps within current session | TodoWrite |
| Unit status across sessions | Work units file |
| Overall feature progress | Work units file |
| Implementation details | Plan file |

### Rule

- **Work units file**: Source of truth for progress
- **TodoWrite**: Convenience for current session only
- **Never rely on TodoWrite** surviving context clears

## Project Structure

```
my-todo-list/
├── CLAUDE.md              # This file (rulebook)
├── README.md              # User documentation
├── Project.toml           # Dependencies
├── Manifest.toml          # Lock file
├── .gitignore             # Git ignore patterns
├── LICENSE                # Project license
│
├── src/
│   ├── TodoList.jl       # Main module entry point
│   ├── models.jl         # Data structures (Todo, Project, Category)
│   ├── database.jl       # Database initialization and connections
│   ├── queries.jl        # CRUD operations and SQL queries
│   ├── cli.jl            # CLI commands using Comonicon
│   └── visualization.jl  # Gantt chart HTML generation
│
├── test/
│   ├── runtests.jl       # Test suite entry point
│   ├── test_database.jl  # Database tests
│   └── test_queries.jl   # Query logic tests
│
├── scripts/
│   ├── install.jl        # First-time database setup
│   └── demo.jl           # Generate sample data
│
└── docs/
    └── examples.md       # Usage examples
```

## Branching Strategy

**All code changes must happen on feature branches, never directly on `main`.**

| Context | Branch Prefix | Example | When to Use |
|---------|---------------|---------|-------------|
| Planner | N/A | N/A | Read-only; no branch needed (creates plan files only) |
| Implementer | `feature/` | `feature/cli-commands` | Adding new features or capabilities |
| Tester | `bugfix/` or `test/` | `bugfix/fix-date-parsing` | Fixing test failures or adding tests |
| Refactor | `refactor/` | `refactor/simplify-queries` | Code improvements without behavior changes |
| Bug Fix | `bugfix/` | `bugfix/null-pointer` | Fixing broken functionality |

### Workflow for ALL Contexts

1. **Before making ANY code changes**: `git checkout -b TYPE/NAME`
2. **Make changes**: Edit, test, iterate
3. **Test thoroughly**: Run all relevant tests
4. **Commit**: With descriptive message
5. **Push**: `git push -u origin TYPE/NAME`
6. **Create PR**: For review (never merge directly)

### Exception

- Updating `CLAUDE.md` itself can be done on main with explicit approval
- Everything else: use a branch

## Testing Requirements

- All database operations must have tests
- Test with empty database and populated database (use `:memory:` for tests)
- Test edge cases (invalid dates, missing foreign keys, duplicate names)
- Test CLI command parsing
- Never commit test databases or temporary files

## Data Model

### Database Schema

**projects table:**
- id (PRIMARY KEY)
- name (UNIQUE, NOT NULL)
- description
- color (hex, for Gantt charts)
- created_at, updated_at

**categories table:**
- id (PRIMARY KEY)
- name (UNIQUE, NOT NULL)
- color (hex, for Gantt charts)
- created_at

**todos table:**
- id (PRIMARY KEY)
- title (NOT NULL)
- description
- status (pending/in_progress/completed/blocked)
- priority (1=high, 2=medium, 3=low)
- project_id (FOREIGN KEY)
- category_id (FOREIGN KEY)
- start_date (ISO 8601: YYYY-MM-DD)
- due_date (ISO 8601: YYYY-MM-DD)
- completed_at
- created_at, updated_at

### Database Location

- **User database**: `~/.todo-list/todos.db` (never commit this)
- **Test database**: Use `:memory:` or temporary files

## Commands Reference

```bash
# Project management
todo project add <name> [--description=<desc>] [--color=<hex>]
todo project list
todo project remove <name>

# Category management
todo category add <name> [--color=<hex>]
todo category list
todo category remove <name>

# Todo operations
todo add <title> [--description=<desc>] [--project=<name>]
                 [--category=<name>] [--priority=<1-3>]
                 [--start=<YYYY-MM-DD>] [--due=<YYYY-MM-DD>]

todo list [--project=<name>] [--category=<name>] [--status=<status>]
todo show <id>
todo update <id> [options...]
todo complete <id>
todo delete <id>

# Visualization
todo gantt [--project=<name>] [--output=<path>] [--open]

# Utility
todo init     # Initialize database (first run)
todo stats    # Show statistics
```

## TUI Development Guidelines

### Rendering
- **Use Term.jl for ALL output**: Panels, tables, styled text
- **Immediate mode rendering**: Re-render entire screen on each update
- **Fixed column widths**: Always specify widths for Term.jl tables to prevent misalignment
- **Component composition**: Build complex screens from reusable components

### Navigation
- **TerminalMenus.jl patterns**: Use for interactive selection and keyboard input
- **Standard keys**:
  - Arrow keys: Navigation
  - Enter: Select/Confirm
  - Esc/q: Back/Quit
  - Letter keys: Quick actions (a=add, e=edit, d=delete, f=filter, etc.)
- **Consistent across screens**: Same key should do same thing everywhere

### State Management
- **Separate UI state from data**: Keep AppState struct for UI, database for data
- **Immutable updates preferred**: Use `@set` macro or return new state
- **Screen transitions**: Clear state that maintains current screen, selected item, filters

### Testing
- **Unit test business logic**: Database operations, filtering, data transformations
- **Component tests**: Verify rendering produces correct output types (Panel, Table)
- **Content verification**: Test that rendered output contains expected text, not just types
  ```julia
  # Good:
  @test output isa Panel
  @test contains(string(output), "Todo List")

  # Bad (insufficient):
  @test output isa Panel  # Type check alone is not enough
  ```
- **Manual testing required**: Visual verification of TUI appearance and keyboard navigation
- **Manual test checklist**: Document expected behavior for manual testing

### Error Handling
- **Show errors in dedicated panel**: Don't break UI
- **User-friendly messages**: Avoid stack traces in TUI
- **Graceful degradation**: If component fails to render, show error panel instead

### Docker Development
- **All development in Docker**: Required for work projects
- **docker-compose with TTY**: `stdin_open: true` and `tty: true` required for interactive TUI
- **Mounted volumes**: Use for live editing (hot reload)
- **Test in Docker**: Always run `./scripts/docker-test` before committing

### Performance
- **Efficient screen updates**: Only re-render when state changes
- **Limit data fetched**: Don't load entire database for displays
- **Responsive input**: Keyboard handling should feel instant

## Implementation Notes

- **Windows paths**: Use Julia's `homedir()` and `joinpath()` for cross-platform compatibility
- **Startup time**: Julia CLI has ~2s startup. For production, consider compiling to binary with PackageCompiler.jl
- **Database**: Always use string keys for SQLite queries (`row["column"]` not `row[:column]`)
- **Error handling**: Wrap database operations in try-catch blocks with user-friendly error messages
- **Foreign keys**: Enable with `PRAGMA foreign_keys = ON` immediately after opening connection

## Lessons Learned

<!-- Add entries here when mistakes are made, so we never repeat them -->

### 2026-01-16 - Implement with tests incrementally, not waterfall
**What happened:** During Phase 3 database implementation, we implemented Project and Category CRUD first, planning to write tests later in Step 9. This is waterfall development, not incremental/TDD.

**Why it happened:** The approved plan structured it as "implement all features → create test suite → run tests" rather than "create test suite → test-driven implementation of each feature."

**Rule to add:**
- **Create test suite structure FIRST** before implementing features
- **Write tests for each feature BEFORE implementing it** (TDD for business logic)
- **Keep test suite passing** throughout development
- **Run tests after EVERY implementation step** - never batch testing
- **Exception:** Choose appropriate testing method for the use case:
  - Logic/algorithms: TDD (write tests first)
  - Database operations: Integration tests (test actual DB behavior)
  - UI/TUI: Component tests + manual verification checklists
  - API contracts: Contract tests
- **Plans should reflect incremental delivery**, not big-bang integration

### 2026-01-17 - Planner wrote code instead of creating plan
**What happened:** The planner role created test code (`test/test_components.jl`) and a design document (`docs/tui-design.md`) but did NOT create an implementation plan in the `plans/` folder. It also did not instruct the user to clear context and invoke the implementer.

**Why it happened:**
1. Planner conflated "TDD test-first" with planning - but TDD is implementation work, not planning
2. Design documents are useful but are NOT the same as implementation plans with steps
3. No explicit handoff instruction to clear context and switch to implementer session

**Rules to add:**
- **Planner MUST create `plans/FEATURE-NAME.md`** - This is the PRIMARY deliverable of planning, not optional
- **Planner MUST NOT write any `.jl` files** - Tests are implementation, not planning
- **Design docs (`docs/`) are supplementary** - They do not replace implementation plans
- **Planner MUST end with explicit handoff:** Tell user to clear context and run `/implement-step`
- **Implementer owns test creation** - TDD test-first approach happens during implementation, not planning
- **Before ending a planning session, verify:** The plan file exists in `plans/` with all required sections (Steps, Files, Acceptance Criteria, Testing Strategy)

### 2026-01-18 - Implementer invoked with plan file instead of units file
**What happened:** The `/implement-step` command was run pointing at `plans/phase-4-tui-components.md` (the detailed plan) instead of `docs/features/phase-4-tui-components-units.md` (the work units file). This caused the implementer to work from the wrong file type.

**Why it happened:**
1. Both files exist and have similar names
2. The skill commands did not validate the input file type
3. Easy to confuse which file goes with which command

**Rules to add:**
- **Skills MUST validate input file types** - `/implement-step` and `/verify-feature` now validate:
  - File must be in `docs/features/` directory
  - File must end with `-units.md`
  - If wrong file provided, show error with correct path suggestion
- **File purposes are distinct:**
  - `plans/*.md` = Detailed HOW (implementation steps, TDD patterns, testing strategy)
  - `docs/features/*-units.md` = Actionable WHAT (PR-sized work units with acceptance criteria)
- **Commands use units file, not plan file:**
  - `/implement-step docs/features/FEATURE-units.md N` (correct)
  - `/implement-step plans/FEATURE.md N` (WRONG - now errors)
- **Plan file is reference material** - Implementer reads it for details but executes from units file

### Template for new lessons:
```
### [DATE] - [Brief description]
**What happened:** [describe the mistake]
**Why it happened:** [root cause]
**Rule to add:** [new rule to prevent recurrence]
```
