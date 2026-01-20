# TUI Bug Tracking

**Created:** 2026-01-18
**Phase:** Phase 4 - TUI Components (Unit 8 Integration & Polish)
**Status:** Active

---

## Bug Summary

| ID | Title | Priority | Status | Branch |
|----|-------|----------|--------|--------|
| BUG-001 | Text input not populating in form fields | HIGH | MERGED (PR #11) | bugfix/tui-raw-terminal |
| BUG-002 | Keys require Enter to respond | HIGH | MERGED (PR #11) | bugfix/tui-raw-terminal |
| BUG-003 | Table column misalignment | MEDIUM | MERGED (PR #12) | bugfix/tui-table-alignment |
| BUG-004 | Database locked error on save | HIGH | OPEN | - |
| BUG-005 | Form navigation enters submenu instead of next field | MEDIUM | OPEN | - |
| BUG-006 | Error navigating past last submenu item | HIGH | OPEN | - |

**Note:** BUG-001 and BUG-002 share the same root cause (TTY detection failing in Docker).
**Note:** BUG-005 and BUG-006 are related - BUG-006 occurs as a consequence of BUG-005's incorrect navigation behavior.

**Legend:** OPEN | IN_PROGRESS | FIXED | VERIFIED | WONTFIX

---

## BUG-001: Text input not populating in form fields

**Priority:** HIGH
**Status:** VERIFIED
**Discovered:** 2026-01-18 during manual testing
**Fixed:** 2026-01-18
**Verified:** 2026-01-18
**Branch:** bugfix/tui-raw-terminal

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

### Fix Applied
Updated `has_tty()` in `src/tui/tui.jl` (lines 125-153) to use multiple detection methods:
1. **Primary:** POSIX `isatty()` via ccall - most reliable for Docker/containers
2. **Fallback 1:** Julia's `stdin isa Base.TTY` check - works for native terminals
3. **Fallback 2:** Try running `stty` - indicates TTY availability

This multi-method approach ensures TTY detection works in Docker containers where
`stdin isa Base.TTY` returns false even with `-it` flags.

---

## BUG-002: Keys require Enter to respond

**Priority:** HIGH
**Status:** VERIFIED
**Discovered:** 2026-01-18 during manual testing
**Fixed:** 2026-01-18
**Verified:** 2026-01-18
**Branch:** bugfix/tui-raw-terminal

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
**Status:** MERGED (PR #12)
**Discovered:** 2026-01-18 during manual testing
**Fixed:** 2026-01-18
**Verified:** 2026-01-18
**Merged:** 2026-01-18
**Branch:** bugfix/tui-table-alignment

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
The issue was in `src/tui/components/table.jl` at line 155. The code used Julia's built-in `rpad()` function to pad styled strings:

```julia
row = "$selector $id_str │ $title_padded │ $(rpad(status, 11)) │ $(rpad(priority, 8)) │ $due_date"
```

The problem is that `rpad()` counts Term.jl style tags (like `{yellow}pending{/yellow}`) as part of the string length. For example:
- `"pending"` has 7 visible characters
- `"{yellow}pending{/yellow}"` has 7 visible characters but 27 total characters
- `rpad("{yellow}pending{/yellow}", 11)` doesn't add any padding because the string is already > 11 characters

This caused the Status and Priority columns to be under-padded, breaking alignment.

### Fix Applied
Two issues were fixed:

**Issue 1: Header column width mismatch**
The header row had `   #` (4 chars) but data rows have selector(1) + space(1) + id(3) = 5 chars.
Fixed by adding one space: `    #` (5 chars) and updating separator line accordingly.

**Issue 2: Styled string padding**
Added two helper functions in `src/tui/components/table.jl`:

1. **`visible_length(s::String)::Int`** (lines 34-39) - Calculates visible string length by stripping Term.jl style tags using regex: `r"\{/?[a-zA-Z_ ]+\}"`

2. **`styled_rpad(s::String, width::Int)::String`** (lines 62-69) - Right-pads a styled string based on its visible length, not raw string length

Updated `render_todo_table()` (lines 194-197, 213-216) to:
- Fix header and separator line column widths
- Use `styled_rpad()` instead of `rpad()` for styled Status and Priority columns

Added tests for:
- `visible_length()` with various style tag combinations
- `styled_rpad()` with plain and styled strings
- Regression test for table alignment with styled content

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

## BUG-005: Form navigation enters submenu instead of next field

**Priority:** MEDIUM
**Status:** OPEN
**Discovered:** 2026-01-18 during manual testing

### Description
When navigating the "Add New Todo" form using the down arrow key, pressing down on the Status field incorrectly enters the Status submenu (showing pending/in_progress/completed/blocked options) instead of moving to the next form field (Priority).

### Screenshots
`docs/bugs/screenshots/bug-005-status-error.png`

### Steps to Reproduce
1. Start TUI: `julia --project=. -e 'using TodoList; run_tui()'`
2. Press 'a' to add a new todo
3. Use down arrow to navigate from Title → Description → Status
4. Press down arrow again while on Status field
5. Observe: The Status submenu opens showing all status options

### Expected Behavior
Down arrow should navigate between top-level form fields in sequence:
- Title → Description → Status → Priority → Start Date → Due Date → [Save] → [Cancel]

The Status submenu should only be entered via Enter key or a specific "expand" action, not by down arrow navigation.

### Actual Behavior
Down arrow on Status field enters the Status submenu, drilling into the sub-options instead of moving to Priority.

### Design Decision
How should navigation behave at form boundaries?
1. **Wrap around**: Last field → First field (and vice versa)
2. **Stop at boundary**: Require explicit up/down to change direction ✅ **CHOSEN**
3. **Hybrid**: Stop at boundaries but allow Tab to cycle

**Decision:** Option 2 (stop at boundary) - can revisit if it feels cumbersome in practice.

### Root Cause Analysis
Likely in `src/tui/screens/todo_form.jl` or `src/tui/input.jl`. The form navigation logic is not distinguishing between:
1. **Field navigation** (moving between form fields at same hierarchy level)
2. **Menu navigation** (drilling into/selecting within a submenu)

The down arrow should only trigger field navigation, not submenu entry.

---

## BUG-006: Error navigating past last submenu item

**Priority:** HIGH
**Status:** OPEN
**Discovered:** 2026-01-18 during manual testing

### Description
When inside the Status submenu (due to BUG-005), navigating to the last item ("blocked") and pressing down arrow throws a `MethodError`.

### Screenshots
`docs/bugs/screenshots/bug-006-downarrow-error.png`

### Steps to Reproduce
1. Start TUI
2. Press 'a' to add a new todo
3. Navigate to Status field and enter submenu (via BUG-005 behavior)
4. Press down arrow repeatedly until reaching "blocked" (last item)
5. Press down arrow one more time
6. Error appears

### Expected Behavior
When at the last submenu item, down arrow should either:
1. Do nothing (stay on last item), or
2. Wrap to first item, or
3. Exit submenu and move to next form field

### Actual Behavior
```
ERROR: MethodError: Cannot convert an object of type Nothing to an object of type String
```

Stack trace shows error originates in:
- `handle_menu_navigation`
- `handle_form_input`

### Root Cause Analysis
The navigation function returns `nothing` when attempting to navigate past the last item, but the calling code expects a `String` return type. Missing boundary check or improper handling of edge case.

Likely location: `src/tui/screens/todo_form.jl` in `handle_menu_navigation` function.

Possible fixes:
1. Add boundary check to prevent navigation past last item
2. Handle `nothing` return value gracefully in calling code
3. Implement wrap-around behavior

---

## Resolution Plan

### Recommended Fix Order

1. ~~**BUG-001 + BUG-002** (same root cause - fix together)~~ ✅ MERGED (PR #11)
   - Branch: `bugfix/tui-raw-terminal`
   - Fix: Update `has_tty()` in `src/tui/tui.jl` to work in Docker

2. ~~**BUG-003** (table alignment)~~ ✅ MERGED (PR #12)
   - Branch: `bugfix/tui-table-alignment`
   - Fix: Added `visible_length()` and `styled_rpad()` helpers

3. **BUG-004** (database locked) - HIGH PRIORITY
   - Branch: `bugfix/tui-db-locked`
   - Fix: Investigate connection management in `src/tui/screens/todo_form.jl`
   - This prevents saving todos

4. **BUG-005 + BUG-006** (related navigation issues - fix together)
   - Branch: `bugfix/tui-form-navigation`
   - Fix: Refactor form navigation to separate field-level vs submenu navigation
   - BUG-006 is a crash bug triggered by BUG-005's incorrect behavior
   - **Design decision needed:** Boundary behavior (wrap vs stop)

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
| 2026-01-18 | BUG-001/002 FIXED | Updated `has_tty()` in src/tui/tui.jl to use POSIX isatty() via ccall. All tests pass (939/939). |
| 2026-01-18 | BUG-001/002 VERIFIED | Manual testing in Docker confirms keys respond immediately and text input works. |
| 2026-01-18 | BUG-003 IN_PROGRESS | Starting fix for table column misalignment. Root cause: rpad() counts style tags. |
| 2026-01-18 | BUG-003 FIXED | Added visible_length() and styled_rpad() helpers. Fixed header column width mismatch. All tests pass (960/960). |
| 2026-01-18 | BUG-003 VERIFIED | Manual testing confirms columns now align correctly. |
| 2026-01-18 | BUG-003 MERGED | PR #12 merged to main. |
| 2026-01-18 | BUG-005 documented | Form navigation enters Status submenu instead of moving to next field. |
| 2026-01-18 | BUG-006 documented | MethodError crash when navigating past last submenu item. Related to BUG-005. |
