# Work Units: Term.jl Enhancement

**Feature:** Refactor TUI to better utilize Term.jl features
**Feature Spec:** docs/features/term-jl-enhancement.md
**Plan:** plans/term-jl-enhancement.md
**Created:** 2026-01-18
**Status:** In Progress (3/6 units merged)

---

## Overview

This file tracks testable work units for the Term.jl enhancement refactoring. Each unit is:
- **Self-contained:** Can be implemented, tested, and merged independently
- **PR-sized:** Results in one pull request
- **Testable:** Has clear acceptance criteria that can be verified

---

## Progress Summary

| Unit | Name | Status | Branch | PR |
|------|------|--------|--------|-----|
| 1 | Category Table with Term.jl | MERGED | refactor/term-jl-category-table | #15 |
| 2 | Project Table with Term.jl | MERGED | refactor/term-jl-project-table | #16 |
| 3 | Todo Table with Term.jl | MERGED | refactor/term-jl-todo-table | #17 |
| 4 | Layout Operators for List Screens | PENDING | - | - |
| 5 | Layout Operators for Detail/Filter Screens | PENDING | - | - |
| 6 | Enhanced Panel Styling | PENDING | - | - |

**Status Legend:**
- `PENDING` - Not started
- `IN_PROGRESS` - Implementer working on it
- `IMPLEMENTED` - Code complete, ready for verification
- `VERIFIED` - Tester approved
- `MERGED` - PR merged to main
- `BLOCKED` - Waiting on dependency
- `FAILED` - Verification failed, needs fixes

---

## Work Units

### Unit 1: Category Table with Term.jl

**Status:** MERGED (PR #15)
**Branch:** `refactor/term-jl-category-table`
**Plan Steps:** 1, 2, 3, 4
**Depends On:** None

**Scope:**
- Spike Term.jl Table API to understand capabilities
- Replace manual `render_category_table()` with Term.jl Table
- Integrate into category list screen
- Clean up old implementation

**Acceptance Criteria:**
- [x] Category table renders using `Term.Tables.Table`
- [x] Selection indicator (►) visible on selected row
- [x] Columns: #, Name, Todos, Color all display correctly
- [x] Empty state message still works ("No categories found")
- [x] All category list tests in `test_tui_screens.jl` pass
- [x] Manual visual verification: table looks good in terminal
- [x] No regressions in other screens

**Estimated Files:** 2 files, ~100 lines changed

**Notes:**
- This is the simplest table (3 data columns + selector)
- Start here to validate the Term.jl Table approach
- If this doesn't work well, reconsider the approach before continuing

---

### Unit 2: Project Table with Term.jl

**Status:** MERGED (PR #16)
**Branch:** `refactor/term-jl-project-table`
**Plan Steps:** 5, 6
**Depends On:** Unit 1

**Scope:**
- Apply same Term.jl Table pattern to project table
- Slightly more complex: 4 columns (Name, Description, Todos, Color)

**Acceptance Criteria:**
- [x] Project table renders using `Term.Tables.Table`
- [x] Selection indicator visible on selected row
- [x] Columns: #, Name, Description, Todos, Color all display correctly
- [x] Description truncation works for long text
- [x] Empty state message works ("No projects found")
- [x] All project list tests pass
- [x] Manual visual verification
- [x] No regressions

**Estimated Files:** 2 files, ~80 lines changed

**Notes:**
- Pattern should be established from Unit 1
- Main difference is extra column and description truncation

---

### Unit 3: Todo Table with Term.jl

**Status:** MERGED (PR #17)
**Branch:** `refactor/term-jl-todo-table`
**Plan Steps:** 7, 8, 9
**Depends On:** Unit 1, Unit 2

**Scope:**
- Apply Term.jl Table to the most complex table (todos)
- Handle scrolling (visible rows only)
- Handle 5 columns with styled content (status, priority)

**Acceptance Criteria:**
- [x] Todo table renders using `Term.Tables.Table`
- [x] Selection indicator visible on selected row
- [x] Columns: #, Title, Status, Priority, Due Date all display
- [x] Status column has correct colors (yellow/blue/green/red)
- [x] Priority column has correct colors (red/yellow/dim)
- [x] Scrolling works: only visible rows shown
- [x] Scroll indicator shows "Showing X-Y of Z" when needed
- [x] Empty state message works ("No todos found")
- [x] All main list tests pass
- [ ] Manual testing: scroll up/down with j/k keys
- [x] No regressions

**Estimated Files:** 2 files, ~150 lines changed

**Notes:**
- Most complex table - validates approach fully
- Scrolling requires slicing data before building Table
- Styled content (status, priority) must render correctly in Table cells

---

### Unit 4: Layout Operators for List Screens

**Status:** FAILED
**Branch:** `refactor/term-jl-layout-lists`
**Plan Steps:** 10, 11, 12, 13
**Depends On:** Unit 1, Unit 2, Unit 3

**Scope:**
- Spike layout operators (`/` for vertical stacking)
- Refactor category_list, project_list, main_list screens
- Replace `join(lines, "\n")` with Term.jl `/` operator

**Acceptance Criteria:**
- [ ] Category list uses `/` operator for composition
- [ ] Project list uses `/` operator for composition
- [ ] Main list uses `/` operator for composition
- [ ] Optional message component handled correctly (included when present)
- [ ] All list screen tests pass
- [ ] Manual visual verification: screens look identical or better
- [ ] No regressions

**Estimated Files:** 3 files, ~60 lines changed

**Notes:**
- Step 10 spikes the API first
- If `/` operator doesn't work well, can skip this unit
- Main benefit: cleaner code, not visual change

---

### Unit 5: Layout Operators for Detail/Filter Screens

**Status:** PENDING
**Branch:** `refactor/term-jl-layout-detail`
**Plan Steps:** 14, 15
**Depends On:** Unit 4

**Scope:**
- Apply `/` operator to todo_detail screen
- Apply `/` operator to filter screens (menu, status, project, category)

**Acceptance Criteria:**
- [ ] Todo detail screen uses `/` operator
- [ ] Filter menu uses `/` operator
- [ ] Filter status/project/category screens use `/` operator
- [ ] All detail and filter tests pass
- [ ] Manual visual verification
- [ ] No regressions

**Estimated Files:** 5 files, ~80 lines changed

**Notes:**
- Straightforward application of pattern from Unit 4
- Filter screens are simple menus

---

### Unit 6: Enhanced Panel Styling

**Status:** PENDING
**Branch:** `refactor/term-jl-panels`
**Plan Steps:** 16, 17, 18
**Depends On:** Unit 4, Unit 5

**Scope:**
- Enhance header panel with box style, title, subtitle
- Enhance form panels with heavier box style
- Final cleanup and documentation

**Acceptance Criteria:**
- [ ] Header uses `box=:ROUNDED` for visual distinction
- [ ] Header title and subtitle use Panel parameters (not content)
- [ ] Form screens use `box=:HEAVY` for input areas
- [ ] All tests pass
- [ ] Manual visual verification: improved appearance
- [ ] No dead code remaining in table.jl
- [ ] CLAUDE.md updated with any new Term.jl patterns learned
- [ ] No regressions

**Estimated Files:** 5 files, ~100 lines changed

**Notes:**
- Visual polish unit
- Can be skipped if earlier units reveal issues
- Final cleanup of any technical debt from refactoring

---

## Session Log

Track work sessions for handoff context:

### 2026-01-20 - Implementer: Unit 1
**Session:** Implementer
**Result:** Complete
**Notes:**
- Spiked Term.jl Table API to understand capabilities
- Created render_category_table() using Term.jl Tables.Table with:
  - Fixed column widths for consistency
  - box=:SIMPLE style for cleaner appearance
  - Selection indicator (►) with cyan bold styling
  - Support for styled content in cells
- Integrated into category_list.jl
- Removed old manual table implementation
- All 960 tests pass (170 TodoList + 790 TUI)
- Files modified:
  - src/tui/components/table.jl (~40 lines changed, net reduction)
  - src/tui/screens/category_list.jl (1 line comment update)
  - src/TodoList.jl (import updated)
- Branch: refactor/term-jl-category-table
- Ready for verification

### 2026-01-20 - Tester: Unit 1
**Session:** Tester
**Result:** PASS
**Notes:**
- All 960 tests pass (170 TodoList + 790 TUI)
- Acceptance criteria verification:
  - ✓ Category table renders using Term.Tables.Table
  - ✓ Selection indicator (►) visible on selected row (cyan bold)
  - ✓ Columns #, Name, Todos, Color all display correctly
  - ✓ Empty state message works ("No categories found")
  - ✓ All category list tests pass
  - ✓ Manual visual verification: table looks clean with :SIMPLE box style
  - ✓ No regressions in other screens
- Explored alternative box styles (:ROUNDED, :SQUARE, :HEAVY) - decided to keep :SIMPLE for minimal appearance
- Unit ready for shipping

### 2026-01-20 - Implementer: Unit 2
**Session:** Implementer
**Result:** Complete
**Notes:**
- Applied same Term.jl Table pattern from Unit 1 to project table
- Replaced manual ASCII table with Term.jl Tables.Table:
  - Fixed column widths: [8, 22, 26, 7, 10] for #, Name, Description, Todos, Color
  - box=:SIMPLE style (consistent with category table)
  - Selection indicator (►) with cyan bold styling
  - Support for styled content in cells
- Description truncation works correctly (ellipsis for long text)
- All 960 tests pass (170 TodoList + 790 TUI)
- Files modified:
  - src/tui/components/table.jl (~35 lines changed in render_project_table)
- Manual visual verification: table renders cleanly with all columns aligned
- Ready for verification

### 2026-01-20 - Tester: Unit 2
**Session:** Tester
**Result:** PASS
**Notes:**
- All 960 tests pass (170 TodoList + 790 TUI)
- Acceptance criteria verification:
  - ✓ Project table renders using Term.Tables.Table (lines 281-286 in table.jl)
  - ✓ Selection indicator (►) visible on selected row (cyan bold styling)
  - ✓ Columns #, Name, Description, Todos, Color all display correctly
  - ✓ Description truncation works for long text (24 char max with ellipsis)
  - ✓ Empty state message works ("No projects found. Press 'a' to add...")
  - ✓ All project list tests pass (verified in test_tui_screens.jl)
  - ✓ Manual visual verification: table renders cleanly with :SIMPLE box style
  - ✓ No regressions in other screens (all 960 tests passing)
- Nil description renders as empty cell, nil color renders as dimmed dash (—)
- Pattern consistent with Unit 1 category table
- Unit ready for shipping

### 2026-01-20 - Implementer: Unit 3
**Session:** Implementer
**Result:** Complete
**Notes:**
- Applied same Term.jl Table pattern from Units 1 and 2 to todo table
- Replaced manual ASCII table with Term.jl Tables.Table:
  - Fixed column widths: [8, 30, 13, 10, 12] for #, Title, Status, Priority, Due Date
  - box=:SIMPLE style (consistent with category and project tables)
  - Selection indicator (►) with cyan bold styling
  - Status formatting with colors (yellow/blue/green/red)
  - Priority formatting with colors (red/yellow/dim)
- Scrolling handled by slicing data before building Table
- Scroll indicator appended after table when list > visible_rows
- Updated test_tui_components.jl:
  - Modified "Table Alignment with Styled Content" test to work with Term.jl Table format
  - Test now verifies header columns and data content presence
  - Term.jl Table handles alignment automatically for styled content
- All 967 tests pass (170 TodoList + 797 TUI)
- Files modified:
  - src/tui/components/table.jl (~40 lines changed in render_todo_table)
  - test/test_tui_components.jl (~20 lines changed in alignment test)
- Ready for verification

### 2026-01-20 - Tester: Unit 3
**Session:** Tester
**Result:** PASS
**Notes:**
- All 967 tests pass (170 TodoList + 797 TUI)
- Acceptance criteria verification:
  - ✓ Todo table renders using Term.Tables.Table (lines 223-228 in table.jl)
  - ✓ Selection indicator (►) visible on selected row (cyan bold styling)
  - ✓ Columns #, Title, Status, Priority, Due Date all display correctly
  - ✓ Status colors: pending=yellow, in_progress=blue, completed=green, blocked=red
  - ✓ Priority colors: HIGH=red bold, MEDIUM=yellow, LOW=dim
  - ✓ Scrolling works: only visible rows shown (verified with offset=0,5,10)
  - ✓ Scroll indicator shows "Showing X-Y of Z" when list > visible_rows
  - ✓ Empty state message works ("No todos found. Press 'a' to add...")
  - ✓ All main list tests pass
  - ⚠ Manual j/k key testing requires interactive TUI (not verifiable in automated tests)
  - ✓ No regressions in other screens (all 967 tests passing)
- Term.jl converts style tags to ANSI escape codes (verified in raw output)
- Pattern consistent with Units 1 and 2
- Unit ready for shipping

### 2026-01-20 - Implementer: Unit 4
**Session:** Implementer
**Result:** FAILED - Reverted
**Notes:**
- Spiked Term.jl `/` operator for vertical layout composition
  - Panel / String → Renderable
  - Panel / Panel → Renderable
  - string(composed) converts result to String
- Refactored all three list screens to use `/` operator
- All 967 automated tests passed
- **FAILED manual visual verification:**
  - Headers repeated multiple times (4+ duplicates of "Todo List [11 items]")
  - Table rows spread across entire terminal with huge vertical gaps
  - The `/` operator is designed for full-screen layouts with padding, NOT for simple vertical concatenation
- **Root cause:** Term.jl `/` operator pads each element to terminal dimensions and creates a layout grid, which doesn't match our immediate-mode rendering approach
- **Resolution:** Reverted all changes back to `join(lines, "\n")` pattern
- All tests still pass after revert (967/967)
- **Recommendation:** Skip Unit 4 - the `/` operator is not suitable for this use case. The existing `join(lines, "\n")` pattern works correctly.
- Branch changes discarded

---

## Issues & Fixes

Track issues found during verification:

### Issue #1: Term.jl `/` operator unsuitable for screen composition
**Unit:** 4
**Discovered:** 2026-01-20
**Severity:** Blocker

**Problem:** The Term.jl `/` operator causes:
1. Repeated headers (content duplicated 4+ times)
2. Excessive vertical spacing (rows spread across entire terminal)

**Root Cause:** The `/` operator is designed for full-screen layout composition where each element is padded to terminal dimensions. It creates a layout grid, not simple vertical concatenation.

**Resolution:** Keep existing `join(lines, "\n")` pattern. Skip Unit 4 entirely - the feature doesn't provide value for this use case.

**Impact:** Units 4 and 5 should be marked as SKIPPED. Unit 6 (Panel styling) can proceed independently.

---

## Completion Checklist

Before marking feature complete:

- [ ] All units have status MERGED
- [ ] Full test suite passes
- [ ] Manual verification complete for all TUI screens
- [ ] Documentation updated (CLAUDE.md if needed)
- [ ] No increase in code complexity

---

## Manual Testing Checklist

After each unit, run through this checklist:

### Category List Screen
- [ ] Opens from main list (press 'g')
- [ ] Table displays with selection indicator
- [ ] Navigate up/down with j/k
- [ ] Add category works (press 'a')
- [ ] Edit category works (press 'e')
- [ ] Delete shows confirmation (press 'd')
- [ ] Back returns to main list (press 'b')

### Project List Screen
- [ ] Opens from main list (press 'p')
- [ ] Table displays with selection indicator
- [ ] Description truncates if long
- [ ] Todo counts display correctly
- [ ] All navigation works

### Main List Screen
- [ ] Table displays with todos
- [ ] Status colors correct (yellow/blue/green/red)
- [ ] Priority colors correct (red/yellow/dim)
- [ ] Scrolling works with many todos
- [ ] Scroll indicator shows when needed
- [ ] Empty state shows when no todos

### Todo Detail Screen
- [ ] Opens on Enter from main list
- [ ] All fields display
- [ ] Back navigation works

### Filter Screens
- [ ] Filter menu opens (press 'f')
- [ ] Status filter works
- [ ] Project filter works
- [ ] Category filter works
- [ ] Clear all filters works

### Form Screens
- [ ] Add/Edit todo forms work
- [ ] Add/Edit project forms work
- [ ] Add/Edit category forms work
- [ ] Validation errors display

---

**Workflow Reminder:**

```
For each unit:
1. CLEAR CONTEXT
2. /implement-step docs/features/term-jl-enhancement-units.md 1
3. CLEAR CONTEXT
4. /verify-feature docs/features/term-jl-enhancement-units.md 1
5. If PASS: /commit-push-pr
6. If FAIL: Back to step 1
7. After PR merged: Update status to MERGED, repeat for next unit
```
