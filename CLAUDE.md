# CLAUDE.md

This is the rulebook for Claude Code sessions working in this repository.

> **Note:** `CLAUDE-WORKFLOW.md` exists for human onboarding. Claude sessions should NOT read it - all necessary rules are here.

> **Required reading:** `CODE_INDEX.md` - Codebase navigation map. Read this to quickly find functions, files, and patterns.

## Goals

- Simple, maintainable TUI (Terminal User Interface) todo list manager
- Interactive terminal interface with keyboard navigation
- Built with Claude Code assistance following Boris Cherny "Plant" workflow
- Human role: review, define requirements, approve design decisions
- Claude role: plan, implement, test, document
- Docker-first development for work project isolation

## Hard Rules

- Never commit directly to `main`; always use feature branches
  - Branch naming: `feature/NAME`, `bugfix/NAME`, `refactor/NAME`, or `test/NAME`
  - Only exception: updating this CLAUDE.md file itself (with approval)
- Always run tests before proposing a PR
- Never touch the user's database file (`~/.todo-list/todos.db`)
- Never commit database files or temporary files
- Keep dependencies minimal (avoid bloat)
- Prioritize simplicity over features
- **Keep work units as small as logically possible** - Each unit should represent the smallest coherent change that can be independently tested and merged. Prefer many small PRs over few large ones.

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

## Development Commands

```bash
# Setup
julia --project=. -e 'using Pkg; Pkg.instantiate()'
julia --project=. scripts/install.jl

# Run TUI
julia --project=. -e 'using TodoList; run_tui()'

# Run Tests
julia --project=. test/runtests.jl
```

## Document Hierarchy

This project uses a three-tier documentation system:

```
SPEC (Human writes)     →  PLAN (Planner creates)    →  FEATURES (Work units)
docs/features/FEATURE.md   plans/FEATURE.md             docs/features/FEATURE-units.md
What we want               How we'll build it           What to do next
```

| Document | Location | Owner | Purpose |
|----------|----------|-------|---------|
| **Spec** | `docs/features/FEATURE.md` | Human | Requirements, user stories, acceptance criteria |
| **Plan** | `plans/FEATURE.md` | Planner | Architecture, approach, milestones (living doc) |
| **Units** | `docs/features/FEATURE-units.md` | Planner → Implementer | Actionable micro-units with status |

**Key rules:**
- Planner creates BOTH plan and units files
- Plan file is updated after each milestone completes
- Units file tracks implementation progress
- Implementer works from units file, references plan file

## Work Units

A **Work Unit** is the smallest coherent, testable chunk of work:
- Results in ONE pull request
- Can be implemented, tested, and merged independently
- Has clear acceptance criteria

**Lifecycle:**
```
PENDING → IN_PROGRESS → IMPLEMENTED → VERIFIED → MERGED
```

**Skills update files automatically:**
- `/implement-step` updates units file status + plan milestones
- `/verify-ship` updates units file + plan on milestone complete

## Session Rules

**Each session = One role, One work unit**

| Role | Reads | Outputs |
|------|-------|---------|
| Planner | CLAUDE.md, CODE_INDEX.md, Spec | Plan + Units files |
| Implementer | CLAUDE.md, CODE_INDEX.md, Units file, Plan | Code + tests |
| Verifier | CLAUDE.md, Units file | PASS/FAIL report |
| Bug Fixer | CLAUDE.md, CODE_INDEX.md, Bug doc | Fixed code |

**At session end:**
1. Update units file with status
2. Update plan file if milestone complete
3. Tell user: "CLEAR CONTEXT, then run [next command]"

**TodoWrite:** Use for session-internal tracking only. Units file is the cross-session source of truth.

## Project Structure

```
my-todo-list/
├── CLAUDE.md              # This file (rulebook for Claude)
├── CLAUDE-WORKFLOW.md     # Human onboarding guide (Claude: do not read)
├── CODE_INDEX.md          # Codebase navigation map
├── README.md              # User documentation
├── Project.toml           # Dependencies
│
├── src/
│   ├── TodoList.jl       # Main module entry point
│   ├── models.jl         # Data structures (Todo, Project, Category)
│   ├── database.jl       # Database initialization and connections
│   ├── queries.jl        # CRUD operations and SQL queries
│   └── tui/              # TUI subsystem
│       ├── tui.jl        # Entry point: run_tui()
│       ├── state.jl      # AppState, Screen enum
│       ├── input.jl      # Key handling
│       ├── render.jl     # Screen dispatch
│       ├── components/   # Reusable UI components
│       └── screens/      # Screen implementations
│
├── test/
│   ├── runtests.jl       # Test suite entry point
│   └── test_*.jl         # Test files by area
│
├── scripts/
│   ├── install.jl        # First-time database setup
│   └── demo.jl           # Generate sample data
│
├── plans/                 # Implementation plans (living docs)
│
└── docs/
    ├── features/         # Specs and units files
    └── bugs/             # Bug tracking
```

## Branching Strategy

| Role | Branch Prefix | Example |
|------|---------------|---------|
| Implementer | `feature/` | `feature/add-filter` |
| Bug Fixer | `bugfix/` | `bugfix/null-pointer` |
| Refactor | `refactor/` | `refactor/simplify-state` |

**Exceptions (direct commits to main):**
- Updating `CLAUDE.md` with explicit approval
- Updating units file status to MERGED after PR merge

## Testing Requirements

- All database operations must have tests
- Test with `:memory:` database for isolation
- Test edge cases (invalid dates, missing foreign keys, duplicates)
- Run full test suite before any PR
- Never commit test databases

## Data Model

**projects:** id, name (UNIQUE), description, color, created_at, updated_at

**categories:** id, name (UNIQUE), color, created_at

**todos:** id, title, description, status, priority, project_id, category_id, start_date, due_date, completed_at, created_at, updated_at

- Status: pending, in_progress, completed, blocked
- Priority: 1 (high), 2 (medium), 3 (low)
- Dates: ISO 8601 (YYYY-MM-DD)

## TUI Guidelines

### Rendering
- Use Term.jl for ALL output (Panels, tables, styled text)
- `fit=true` for headers; `box=:HEAVY` for forms; `box=:SIMPLE` for tables
- Avoid fixed `width=80` - causes artifacts on narrow terminals
- Vertical composition: use `join(lines, "\n")` (not `/` operator)

### Navigation
- Arrow keys: Navigate
- Enter: Select/Confirm
- Esc/q: Back/Quit
- Letter keys: Quick actions (a=add, e=edit, d=delete, f=filter)

### State Management
- Single mutable `AppState` struct
- Per-screen state in `screen_state.jl`
- Functions with `!` suffix modify state

### Testing
- Component tests: verify type AND content
  ```julia
  @test output isa Panel
  @test contains(string(output), "Expected Text")
  ```
- Manual testing required for visual/keyboard verification

## Implementation Notes

- Use `homedir()` and `joinpath()` for cross-platform paths
- Use string keys for SQLite: `row["column"]` not `row[:column]`
- Enable foreign keys: `PRAGMA foreign_keys = ON`
- Wrap database operations in try-catch with user-friendly messages

## Lessons Learned

### 2026-01-16 - Implement with tests incrementally, not waterfall
**What happened:** Implemented features first, planned tests for later.
**Rule:** Create test suite FIRST. Write tests BEFORE implementing. Run tests after EVERY step.

### 2026-01-17 - Planner wrote code instead of creating plan
**What happened:** Planner created test code instead of plan file.
**Rule:** Planner MUST create `plans/FEATURE.md`. Planner MUST NOT write `.jl` files.

### 2026-01-18 - Implementer invoked with plan file instead of units file
**What happened:** `/implement-step` was given plan file instead of units file.
**Rule:** Skills validate input: must be in `docs/features/` and end with `-units.md`.

### 2026-01-20 - Term.jl layout operators unsuitable for vertical composition
**What happened:** `/` operator caused rendering artifacts.
**Rule:** Use `join(lines, "\n")` for vertical composition. Layout operators are for horizontal only.

### Template
```
### [DATE] - [Brief description]
**What happened:** [describe]
**Rule:** [new rule]
```
