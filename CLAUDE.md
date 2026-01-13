# CLAUDE.md

This is the rulebook for Claude Code sessions working in this repository.

## Goals

- Simple, maintainable CLI todo list manager
- Built primarily with Claude Code assistance
- Human role: review, define requirements, approve design decisions
- Claude role: plan, implement, test, document

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

- **Language:** Julia 1.9+
- **Testing:** Julia's `Test` stdlib for all tests
- **Style:**
  - 4 spaces indentation
  - Type annotations for public function signatures
  - Docstrings for public functions
  - Follow Julia naming conventions (lowercase with underscores)
- **Database:** SQLite with SQLite.jl
- **CLI:** Comonicon.jl
- **Visualization:** HTML + Plotly.js (CDN)

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

## Implementation Notes

- **Windows paths**: Use Julia's `homedir()` and `joinpath()` for cross-platform compatibility
- **Startup time**: Julia CLI has ~2s startup. For production, consider compiling to binary with PackageCompiler.jl
- **Gantt charts**: Only include todos with both start_date and due_date
- **Error handling**: Wrap database operations in try-catch blocks with user-friendly error messages

## Lessons Learned

<!-- Add entries here when mistakes are made, so we never repeat them -->

### Template for new lessons:
```
### [DATE] - [Brief description]
**What happened:** [describe the mistake]
**Why it happened:** [root cause]
**Rule to add:** [new rule to prevent recurrence]
```
