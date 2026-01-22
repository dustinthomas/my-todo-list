# Feature: Phase 3 - Database Layer

**Status:** COMPLETE (Archived)
**Owner:** Human + Claude Code
**Date:** 2026-01-16

## Goal

Implement a complete SQLite database layer for the todo list application, including schema definition, data models, CRUD operations, and comprehensive testing. This establishes the data persistence foundation that all TUI features will build upon.

## User Story

As a developer, I want a robust database layer with CRUD operations and tests so that I can reliably store and retrieve todos, projects, and categories for the TUI application.

## Inputs/Outputs

### Inputs
- Database file path: `~/.todo-list/todos.db` (production)
- Test database: `:memory:` or temporary files
- CRUD operation parameters (titles, descriptions, status, priority, dates, etc.)

### Outputs
- SQLite database with proper schema
- Julia data structures (Todo, Project, Category models)
- CRUD functions returning results or throwing errors
- Test suite with full coverage

## Functional Requirements

### Must Have
- [ ] Database schema with three tables: projects, categories, todos
- [ ] Foreign key constraints and proper indexing
- [ ] Julia structs for Todo, Project, Category
- [ ] Database initialization and connection management
- [ ] Full CRUD operations for all three entities
- [ ] Query functions with filtering capabilities
- [ ] Comprehensive test suite (unit + integration)
- [ ] Installation script for first-time database setup
- [ ] Demo data generation script
- [ ] Cross-platform path handling (Windows/Linux/Mac)

### Nice to Have
- [ ] Database migration system (for future schema changes)
- [ ] Query result caching (performance optimization)
- [ ] Database backup/restore utilities

## Acceptance Criteria

- [ ] Database schema matches specification in CLAUDE.md
- [ ] All tables have correct columns, types, and constraints
- [ ] Foreign keys are enforced (PRAGMA foreign_keys = ON)
- [ ] Data models (structs) accurately represent database tables
- [ ] CRUD operations work for projects: create, read, update, delete
- [ ] CRUD operations work for categories: create, read, update, delete
- [ ] CRUD operations work for todos: create, read, update, delete
- [ ] Query functions support filtering by status, project, category, date range
- [ ] All database operations use parameterized queries (SQL injection prevention)
- [ ] Tests cover: empty database, populated database, edge cases, constraints
- [ ] Installation script creates database and schema on first run
- [ ] Demo script populates database with sample data
- [ ] All tests pass in Docker environment
- [ ] No database files committed to git (.gitignore configured)
- [ ] README.md updated with database schema documentation

## Technical Approach

### High-Level Design

1. **Schema Definition (database.jl)**
   - SQL DDL for creating tables
   - Database connection management
   - Schema initialization function

2. **Data Models (models.jl)**
   - Julia structs: Project, Category, Todo
   - Type definitions matching database schema
   - Constructor functions

3. **CRUD Operations (queries.jl)**
   - Generic database interface using DBInterface.jl
   - Parameterized query functions
   - Error handling with user-friendly messages

4. **Testing (test/)**
   - Unit tests for each CRUD operation
   - Integration tests for complex queries
   - Edge case testing (nulls, foreign keys, duplicates)

5. **Scripts (scripts/)**
   - install.jl: First-time database setup
   - demo.jl: Generate sample data for testing

### Files Expected to Change

**New Files:**
- `src/TodoList.jl` - Main module entry point
- `src/models.jl` - Data structure definitions (Project, Category, Todo)
- `src/database.jl` - Schema, connections, initialization
- `src/queries.jl` - CRUD operations and query functions
- `test/runtests.jl` - Test suite entry point
- `test/test_database.jl` - Database schema and connection tests
- `test/test_queries.jl` - CRUD operation tests
- `scripts/install.jl` - Database initialization script
- `scripts/demo.jl` - Demo data generation

**Modified Files:**
- `Project.toml` - Add SQLite.jl, DBInterface.jl dependencies
- `.gitignore` - Exclude database files and test artifacts
- `README.md` - Document database schema and setup instructions

### Dependencies

- SQLite.jl (^1.6) - SQLite database interface
- DBInterface.jl (^2.5) - Generic database interface
- Dates (stdlib) - Date parsing and formatting
- Test (stdlib) - Testing framework

### Database Changes

```sql
-- projects table
CREATE TABLE IF NOT EXISTS projects (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    color TEXT,  -- Hex color for Gantt charts
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- categories table
CREATE TABLE IF NOT EXISTS categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    color TEXT,  -- Hex color for Gantt charts
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- todos table
CREATE TABLE IF NOT EXISTS todos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT,
    status TEXT NOT NULL DEFAULT 'pending',  -- pending, in_progress, completed, blocked
    priority INTEGER NOT NULL DEFAULT 2,     -- 1=high, 2=medium, 3=low
    project_id INTEGER,
    category_id INTEGER,
    start_date TEXT,      -- ISO 8601: YYYY-MM-DD
    due_date TEXT,        -- ISO 8601: YYYY-MM-DD
    completed_at TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE SET NULL,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
    CHECK (status IN ('pending', 'in_progress', 'completed', 'blocked')),
    CHECK (priority IN (1, 2, 3))
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_todos_status ON todos(status);
CREATE INDEX IF NOT EXISTS idx_todos_project ON todos(project_id);
CREATE INDEX IF NOT EXISTS idx_todos_category ON todos(category_id);
CREATE INDEX IF NOT EXISTS idx_todos_due_date ON todos(due_date);
```

## Edge Cases

1. **Foreign Key Violations**
   - Scenario: Attempt to create todo with non-existent project_id
   - Expected behavior: Throw error with message "Project with id X does not exist"

2. **Duplicate Names**
   - Scenario: Create project with name that already exists
   - Expected behavior: Throw error with message "Project 'name' already exists"

3. **Invalid Status Values**
   - Scenario: Create todo with status "invalid"
   - Expected behavior: Throw error "Invalid status. Must be: pending, in_progress, completed, blocked"

4. **Invalid Priority Values**
   - Scenario: Create todo with priority 5
   - Expected behavior: Throw error "Invalid priority. Must be 1 (high), 2 (medium), or 3 (low)"

5. **Date Parsing Errors**
   - Scenario: Provide date in wrong format "01/16/2026"
   - Expected behavior: Throw error "Invalid date format. Use YYYY-MM-DD"

6. **Empty Database**
   - Scenario: Query for todos when database is empty
   - Expected behavior: Return empty array, not error

7. **NULL Foreign Keys**
   - Scenario: Create todo without project or category
   - Expected behavior: Allow NULL values, create successfully

8. **Windows Path Handling**
   - Scenario: Create database on Windows with path like "C:\Users\..."
   - Expected behavior: Use Julia's homedir() and joinpath() for cross-platform compatibility

## Out of Scope

This feature does NOT include:
- TUI interface (Phase 4+)
- CLI commands using Comonicon (Phase 5+)
- Gantt chart visualization (Phase 8+)
- Database migration system (future enhancement)
- Multi-user support or authentication
- Remote database connections (SQLite is local only)

## Testing Strategy

### Unit Tests

**test/test_database.jl:**
- `test_database_creation`: Verify database and tables are created
- `test_schema_structure`: Verify columns exist with correct types
- `test_foreign_keys_enabled`: Verify PRAGMA foreign_keys = ON
- `test_constraints`: Verify CHECK constraints work
- `test_indexes`: Verify indexes are created

**test/test_queries.jl:**
- Project CRUD:
  - `test_create_project`: Create new project
  - `test_read_project`: Retrieve project by id
  - `test_update_project`: Modify project fields
  - `test_delete_project`: Remove project
  - `test_duplicate_project_name`: Verify unique constraint

- Category CRUD:
  - `test_create_category`: Create new category
  - `test_read_category`: Retrieve category by id
  - `test_update_category`: Modify category fields
  - `test_delete_category`: Remove category
  - `test_duplicate_category_name`: Verify unique constraint

- Todo CRUD:
  - `test_create_todo`: Create new todo
  - `test_create_todo_with_project`: Create todo with project_id
  - `test_create_todo_with_category`: Create todo with category_id
  - `test_read_todo`: Retrieve todo by id
  - `test_update_todo`: Modify todo fields
  - `test_delete_todo`: Remove todo
  - `test_invalid_status`: Verify status CHECK constraint
  - `test_invalid_priority`: Verify priority CHECK constraint
  - `test_foreign_key_violation`: Verify FK constraint on invalid project_id

- Query Functions:
  - `test_filter_by_status`: Query todos by status
  - `test_filter_by_project`: Query todos by project
  - `test_filter_by_category`: Query todos by category
  - `test_filter_by_date_range`: Query todos by date range
  - `test_empty_database`: Verify queries return [] on empty database

### Integration Tests

- `test_complete_workflow`: Create project, category, todo; update; delete
- `test_cascading_deletes`: Delete project, verify todos' project_id set to NULL
- `test_multiple_filters`: Combine status + project + date range filters

### Manual Tests

- [ ] Run install.jl and verify database created at ~/.todo-list/todos.db
- [ ] Run demo.jl and verify sample data appears in database
- [ ] Open database in SQLite browser and verify schema structure
- [ ] Run tests in Docker: ./scripts/docker-test

## Security Considerations

- [ ] All queries use parameterized statements (no string concatenation)
- [ ] SQL injection prevention through DBInterface parameter binding
- [ ] No sensitive data logged (database paths only, not contents)
- [ ] Database file permissions: user-only read/write (0600)
- [ ] Test databases use :memory: or temp files (automatically cleaned up)

## Performance Considerations

- Expected query response time: < 10ms for single record retrieval
- Expected query response time: < 50ms for filtered list queries
- Maximum todos supported: 10,000+ (SQLite handles this easily)
- Indexes on frequently queried columns: status, project_id, category_id, due_date
- Memory usage: Minimal (SQLite is efficient, :memory: tests use < 10MB)

## Documentation Requirements

- [ ] README.md: Add "Database Schema" section with table descriptions
- [ ] README.md: Document installation and setup process
- [ ] README.md: Add example queries in "Quick Start" section
- [ ] Docstrings for all public functions in queries.jl
- [ ] Comments in database.jl explaining schema design decisions
- [ ] CLAUDE.md: Update "Implementation Notes" if new patterns discovered
- [ ] Update Project.toml with correct dependency versions

## Open Questions

1. **Should we support database migrations?**
   - Option A: Add migration system now (Flyway-style)
   - Option B: Manual schema updates until needed
   - **Decision:** Option B - keep it simple for Phase 3, add migrations later if needed

2. **How to handle updated_at timestamps?**
   - Option A: Database triggers (automatic)
   - Option B: Application code (explicit)
   - **Decision:** Option B - explicit in Julia code for clarity and cross-platform compatibility

3. **Should categories be hierarchical?**
   - Option A: Flat structure (simpler)
   - Option B: Parent/child relationships (more flexible)
   - **Decision:** Option A - flat structure for Phase 3, can extend later

## Timeline (Optional)

Not applicable - using step-by-step implementation via /implement-step

## References

- CLAUDE.md: Data Model and Database Schema section
- SQLite.jl documentation: https://github.com/JuliaDatabases/SQLite.jl
- DBInterface.jl: https://github.com/JuliaDatabases/DBInterface.jl
- Julia Dates stdlib: https://docs.julialang.org/en/v1/stdlib/Dates/

---

## Notes

- This is the foundation layer that all TUI features depend on
- Proper testing is critical since all future features rely on this
- Cross-platform compatibility (Windows/Linux/Mac) is essential
- Database location (~/.todo-list/) keeps user data separate from code
- Using SQLite.jl string keys (row["column"]) not symbols (row[:column])
- Foreign keys must be enabled explicitly: PRAGMA foreign_keys = ON

---

**After completing this spec:**
1. Review with human for approval
2. Use `/plan-feature docs/features/phase-3-database-layer.md` (in Planner tab)
3. Implementation plan will be saved to `plans/phase-3-database-layer.md`
4. Execute plan using `/implement-step` (in Implementer tab)
