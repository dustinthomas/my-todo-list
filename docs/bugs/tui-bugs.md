# TUI Bug Tracking

**Created:** 2026-01-18
**Phase:** Phase 4 - TUI Components (Unit 8 Integration & Polish)
**Status:** Active

---

## Bug Summary

| ID | Title | Priority | Status | Branch |
|----|-------|----------|--------|--------|
| BUG-001 | Text input not populating in form fields | HIGH | OPEN | - |
| BUG-002 | Keys require Enter to respond | HIGH | OPEN | - |
| BUG-003 | Table column misalignment | MEDIUM | OPEN | - |
| BUG-004 | Database locked error on save | HIGH | OPEN | - |

**Note:** BUG-001 and BUG-002 share the same root cause (TTY detection failing in Docker).

**Legend:** OPEN | IN_PROGRESS | FIXED | VERIFIED | WONTFIX

---

## BUG-001: Text input not populating in form fields

**Priority:** HIGH
**Status:** OPEN
**Discovered:** 2026-01-18 during manual testing

### Description
When typing in form text fields (Title, Description, etc.), characters do not appear in the field.

### Steps to Reproduce
1. Start TUI: `julia --project=. -e 'using TodoList; run_tui()'`
2. Press 'a' to add a new todo
3. Type characters in the Title field
4. Observe: characters do not appear in the field

### Expected Behavior
Characters should appear in the text field as they are typed.

### Actual Behavior
When typing on the "Add New Todo" screen:
1. Text appears at the bottom of the screen (not in the Title field)
2. Press down arrow, then Enter
3. Only then does text appear in the Title field

This suggests text input is being captured by Julia's `readline()` or similar line-buffered input instead of character-by-character raw input.

### Screenshots
`docs/bugs/screenshots/bug-001-text-at-bottom.png`

### Environment
- Julia 1.12.3
- Linux (Manjaro)
- Running in Docker container

### Root Cause Analysis
The issue is likely in `src/tui/input.jl` - the `read_char()` function or terminal raw mode setup. Possible causes:
1. Raw mode not being set correctly before reading input
2. Using `readline()` instead of single-character read
3. Terminal mode not preserved across screen renders


---

## BUG-002: Keys require Enter to respond

**Priority:** HIGH
**Status:** OPEN
**Discovered:** 2026-01-18 during manual testing

### Description
Keyboard input requires pressing Enter after each key instead of responding immediately.

### Steps to Reproduce
1. Start TUI
2. Press 'j' to navigate down
3. Observe: nothing happens until Enter is pressed

### Expected Behavior
Keys should respond immediately (standard TUI behavior).

### Actual Behavior
Keys like 'j', 'k', 'a', 'e', etc. require pressing Enter after the key before any action occurs. This is because the terminal is in canonical (line-buffered) mode instead of raw mode.

**SAME ROOT CAUSE AS BUG-001** - see BUG-002 Technical Notes below.

### Screenshots
(Same as BUG-001 - text appearing at bottom demonstrates line-buffered mode)


### Environment
- Docker container with `-it` flags
- Terminal emulator: Host terminal (stdin_open: true, tty: true in docker-compose)

### Technical Notes
Raw terminal mode should be set via `stty raw -echo`.

**ROOT CAUSE IDENTIFIED:**

In `src/tui/tui.jl:122-124`:
```julia
function has_tty()::Bool
    return stdin isa Base.TTY
end
```

This check returns `false` in Docker, even with `-it` flags. When `has_tty()` returns false:
1. `setup_raw_terminal()` (line 146) returns `nothing` without setting raw mode
2. Terminal stays in canonical (line-buffered) mode
3. BUG-001 and BUG-002 occur

**Fix:** Use a more robust TTY detection method that works in Docker containers.

Possible solutions:
1. Use `isatty(stdin)` (C library function via ccall)
2. Try `stty` and check if it succeeds rather than pre-checking
3. Check `/proc/self/fd/0` or environment variables

---

## BUG-003: Table column misalignment

**Priority:** MEDIUM
**Status:** OPEN
**Discovered:** 2026-01-18 during manual testing

### Description
The todo table columns do not align correctly with their headers. Column data appears offset from column headers, and table borders/separators don't render cleanly.

### Screenshots
`docs/bugs/screenshots/bug-003-alignment.png`

### Specific Issues
1. Column headers (#, Title, Status, Priority, Due Date) don't align with data below
2. Large gaps between some columns, cramped spacing in others
3. Table border separators appear broken/misaligned
4. The `>` selection indicator may be affecting column alignment

### Root Cause Analysis
Likely in `src/tui/components/table.jl`. Possible causes:
1. Fixed column widths not matching actual content width
2. Term.jl table formatting not handling Unicode/ANSI escape codes correctly
3. Selection indicator (`>`) adding extra width not accounted for
4. Status/Priority color codes affecting string width calculation

---

## BUG-004: Database locked error on save

**Priority:** HIGH
**Status:** OPEN
**Discovered:** 2026-01-18 during manual testing

### Description
When saving a todo, an error appears: `SQLite.SQLiteException("database is locked")`

This suggests the database connection is not being managed correctly - possibly multiple connections or a transaction not being committed/closed.

### Screenshots
`docs/bugs/screenshots/bug-003-alignment.png` (error visible in red at top)

### Steps to Reproduce
1. Start TUI
2. Press 'a' to add new todo
3. Enter title and save
4. Error appears: "Error saving todo: SQLite.SQLiteException("database is locked")"

### Root Cause Analysis
Likely in `src/tui/screens/todo_form.jl` or `src/queries.jl`. Possible causes:
1. Database connection opened multiple times without closing
2. Transaction started but not committed before next operation
3. Multiple threads/processes accessing same database file
4. Connection not being reused properly across operations


---

## Resolution Plan

### Recommended Fix Order

1. **BUG-001 + BUG-002** (same root cause - fix together)
   - Branch: `bugfix/tui-raw-terminal`
   - Fix: Update `has_tty()` in `src/tui/tui.jl` to work in Docker
   - This is blocking all TUI functionality

2. **BUG-004** (database locked)
   - Branch: `bugfix/tui-db-locked`
   - Fix: Investigate connection management in `src/tui/screens/todo_form.jl`
   - This prevents saving todos

3. **BUG-003** (table alignment)
   - Branch: `bugfix/tui-table-alignment`
   - Fix: Review column widths in `src/tui/components/table.jl`
   - Visual issue, lower priority

### Workflow

1. **Commit current Unit 8 work** to `feature/tui-components-unit-8`
2. **Create PR** for Unit 8 (with known issues documented in this file)
3. **For each bug group above**, create a branch and focused PR
4. **Update this document** as bugs are resolved

---

## Session Log

| Date | Action | Notes |
|------|--------|-------|
| 2026-01-18 | Document created | Initial bug documentation during Unit 8 manual testing |
| 2026-01-18 | All bugs documented | BUG-001/002 root cause: TTY detection. BUG-003: table alignment. BUG-004: DB locked. |
