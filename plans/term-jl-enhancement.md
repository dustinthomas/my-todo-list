# Plan: Term.jl Enhancement

## Overview

Refactor TUI components to better utilize Term.jl's built-in features, replacing manual ASCII table rendering with `Term.Tables.Table`, using layout operators for screen composition, and enhancing Panel usage.

**Work Units:** See `docs/features/term-jl-enhancement-units.md` for PR-sized breakdown

## Current State Analysis

### Files to Modify
- `src/tui/components/table.jl` - Manual ASCII tables (326 lines)
- `src/tui/screens/category_list.jl` - Screen composition (210 lines)
- `src/tui/screens/project_list.jl` - Screen composition (212 lines)
- `src/tui/screens/main_list.jl` - Screen composition (297 lines)
- `src/tui/screens/todo_detail.jl` - Screen composition (232 lines)
- `src/tui/components/header.jl` - Panel enhancement (50 lines)
- `test/test_tui_screens.jl` - Update tests for new return types

### Current Patterns
1. Tables built with string arrays and `join(lines, "\n")`
2. Selection indicator embedded in first column
3. Screens return `String` from `join(lines, "\n")`
4. Tests check `contains(output_str, "text")`

## Steps

### Step 1: Spike Term.jl Table API
**Work Unit:** 1
**Files:** None (exploration only)

**Changes:**
- Test Term.jl `Table` API in REPL
- Verify it works with styled content (markup tags)
- Test selection indicator approach (prepend to data vs separate column)
- Document findings in session notes

**Tests:**
- No automated tests - exploratory work
- Document API patterns discovered

---

### Step 2: Create Table Factory Functions
**Work Unit:** 1
**Files to modify:**
- `src/tui/components/table.jl` (add new functions)

**Changes:**
- Add `using Term.Tables: Table` import
- Create `build_category_table_data()` to prepare matrix for Table
- Create `render_category_table_v2()` using Term.jl Table
- Keep original `render_category_table()` for comparison

**Tests:**
- Manual visual comparison in REPL
- Verify Table renders correctly with styled content

---

### Step 3: Integrate Category Table into Screen
**Work Unit:** 1
**Files to modify:**
- `src/tui/screens/category_list.jl` (switch to v2 table)
- `test/test_tui_screens.jl` (update tests if needed)

**Changes:**
- Update `render_category_list()` to use `render_category_table_v2()`
- Verify all existing tests pass
- If tests fail due to output format changes, update test assertions

**Tests:**
- Run `test_tui_screens.jl` - Category List tests must pass
- Manual visual verification in TUI

---

### Step 4: Clean Up Category Table Implementation
**Work Unit:** 1
**Files to modify:**
- `src/tui/components/table.jl`

**Changes:**
- Remove old `render_category_table()` function
- Rename `render_category_table_v2()` to `render_category_table()`
- Remove any unused helper functions

**Tests:**
- Full test suite pass
- Manual visual verification

---

### Step 5: Implement Project Table with Term.jl
**Work Unit:** 2
**Files to modify:**
- `src/tui/components/table.jl` (add project table)

**Changes:**
- Create `build_project_table_data()` to prepare matrix
- Create new `render_project_table()` using Term.jl Table
- Handle 4 columns: Name, Description, Todos, Color

**Tests:**
- Existing project list tests must pass
- Manual visual verification

---

### Step 6: Integrate Project Table into Screen
**Work Unit:** 2
**Files to modify:**
- `src/tui/screens/project_list.jl` (verify integration)
- `test/test_tui_screens.jl` (update if needed)

**Changes:**
- Verify `render_project_list()` uses updated table
- Update tests if output format changed

**Tests:**
- Run project list tests
- Manual visual verification

---

### Step 7: Implement Todo Table with Term.jl
**Work Unit:** 3
**Files to modify:**
- `src/tui/components/table.jl`

**Changes:**
- Create `build_todo_table_data()` for visible rows only
- Handle scrolling by slicing data before building table
- Handle selection indicator (► in first column)
- Create new `render_todo_table()` using Term.jl Table
- Handle 5 columns: #, Title, Status, Priority, Due Date

**Complexity:**
- Must handle scroll offset correctly
- Selection indicator must be styled
- Empty state message when no todos

**Tests:**
- Main list tests must pass
- Scroll behavior tests must pass
- Manual visual verification

---

### Step 8: Integrate Todo Table and Handle Edge Cases
**Work Unit:** 3
**Files to modify:**
- `src/tui/screens/main_list.jl` (verify integration)
- `test/test_tui_screens.jl` (update if needed)

**Changes:**
- Verify scroll indicator shows "Showing X-Y of Z"
- Test with empty list
- Test with list longer than visible rows

**Tests:**
- All main list tests pass
- Manual scroll testing

---

### Step 9: Remove Legacy Table Helpers
**Work Unit:** 3
**Files to modify:**
- `src/tui/components/table.jl`

**Changes:**
- Evaluate `visible_length()` and `styled_rpad()` - may still be needed
- Remove unused functions
- Clean up imports

**Tests:**
- Full test suite pass

---

### Steps 10-15: Layout Operators (SKIPPED)

**Work Units:** 4, 5
**Status:** SKIPPED

**Reason:** The Term.jl `/` operator was spiked and found unsuitable for this use case:
- The `/` operator pads each element to terminal dimensions and creates a layout grid
- This causes repeated headers (4+ duplicates) and huge vertical gaps between rows
- It's designed for full-screen layouts, not immediate-mode rendering with simple vertical concatenation

**Resolution:** Keep existing `join(lines, "\n")` pattern which works correctly.

**Lesson Learned:** Term.jl's layout operators (`/`, `*`) are for full-screen composition where elements fill terminal dimensions. For component-based rendering with variable heights, string concatenation is the appropriate pattern.

---

### Step 16: Enhance Header Panel
**Work Unit:** 6
**Files to modify:**
- `src/tui/components/header.jl`

**Changes:**
- Add `box=:ROUNDED` for visual distinction
- Add proper `title` and `subtitle` using Panel parameters
- Adjust `padding` for better spacing
- Make style configurable (optional)

**Tests:**
- All header-using screens still render correctly
- Visual verification of improved appearance

---

### Step 17: Enhance Form Panels
**Work Unit:** 6
**Files to modify:**
- `src/tui/screens/todo_form.jl`
- `src/tui/screens/project_form.jl`
- `src/tui/screens/category_form.jl`

**Changes:**
- Use `box=:HEAVY` for form panels (visual weight for input areas)
- Add title to form panels ("Add Todo", "Edit Project", etc.)

**Tests:**
- Form tests pass
- Visual verification

---

### Step 18: Final Polish and Documentation
**Work Unit:** 6
**Files to modify:**
- `src/tui/components/table.jl` (final cleanup)
- `CLAUDE.md` (update TUI guidelines if needed)

**Changes:**
- Review all table/screen code for consistency
- Remove any dead code
- Update CLAUDE.md TUI guidelines with Term.jl patterns learned

**Tests:**
- Full test suite pass
- Complete manual testing of all screens

---

## Files Summary

**Modified files (Units 1-3, COMPLETE):**
- `src/tui/components/table.jl` - Major rewrite using Term.jl Table
- `test/test_tui_components.jl` - Test updates for new table format

**Remaining files (Unit 6, PENDING):**
- `src/tui/components/header.jl` - Panel enhancements (box, title, subtitle)
- `src/tui/screens/todo_form.jl` - Panel enhancements
- `src/tui/screens/project_form.jl` - Panel enhancements
- `src/tui/screens/category_form.jl` - Panel enhancements

**Descoped files (Units 4-5, SKIPPED):**
- ~~`src/tui/screens/category_list.jl`~~ - No layout operator changes
- ~~`src/tui/screens/project_list.jl`~~ - No layout operator changes
- ~~`src/tui/screens/main_list.jl`~~ - No layout operator changes
- ~~`src/tui/screens/todo_detail.jl`~~ - No layout operator changes
- ~~`src/tui/screens/filter_menu.jl`~~ - No layout operator changes

**No new files created.**

---

## Risks

1. **Term.jl Table API limitations**
   - Mitigation: Step 1 spikes the API before committing to approach
   - Fallback: Keep manual tables if Term.jl Table doesn't work well

2. **Styled content in Table cells**
   - Risk: Markup tags may not render correctly in Table
   - Mitigation: Test early in Step 1-2
   - Fallback: Pre-render styled strings before passing to Table

3. **Selection indicator in Table**
   - Risk: May not align properly
   - Mitigation: Use separate first column for indicator
   - Alternative: Render selected row differently (background color)

4. **Layout operator type compatibility** ⚠️ MATERIALIZED
   - Risk: `/` may not work with all renderable types
   - Mitigation: Step 10 spikes this before screen refactoring
   - **Outcome:** Risk materialized - `/` operator unsuitable for immediate-mode rendering
   - **Resolution:** Units 4-5 skipped, keep `join(lines, "\n")` pattern

5. **Test failures due to output format changes**
   - Risk: Tests check `contains(output_str, "text")` which may break
   - Mitigation: Update tests incrementally with each unit
   - Note: Tests check content, not format - should be resilient

---

## Acceptance Criteria (Overall)

- [x] All three tables use Term.jl Table component (Units 1-3 MERGED)
- [ ] Enhanced Panel styles applied to headers and forms (Unit 6 PENDING)
- [ ] Full test suite passes (no regressions)
- [ ] Manual verification of all TUI screens completed
- [ ] No increase in code complexity (less manual string manipulation)

**Descoped (Units 4-5 SKIPPED):**
- ~~All list screens use `/` operator for composition~~ - Keep `join(lines, "\n")` pattern

---

## Testing Strategy

### Automated Tests
- Run existing `test/test_tui_screens.jl` after each change
- Update test assertions if output format changes
- Tests verify content presence, not exact formatting

### Manual Testing Checklist
For each unit, verify:
- [ ] Screen renders without errors
- [ ] Content is readable and properly aligned
- [ ] Selection indicator visible and correct
- [ ] Keyboard navigation works
- [ ] Colors/styling appear correctly
- [ ] Scrolling works (for todo table)
- [ ] Empty state displays correctly

### Regression Testing
- Run full test suite before each PR
- `julia --project=. test/runtests.jl`
