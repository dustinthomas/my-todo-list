# Phase 5: Extensibility Foundation - Work Units

## Overview

Refactor TUI architecture to enable extensibility without core changes.

**Plan file:** `plans/phase-5-extensibility.md`
**Branch:** `refactor/tui-extensibility`

## Work Units

### Unit 1: Screen State Module
**Status:** MERGED (PR #21)
**Scope:** Add `screen_state` field to AppState + helper functions

**Files:**
- `src/tui/screen_state.jl` (new)
- `src/tui/state.jl` (modify)
- `src/tui/tui.jl` (modify - include)
- `test/test_screen_state.jl` (new)

**Acceptance Criteria:**
- [x] `screen_state::Dict{Screen, Any}` field in AppState
- [x] `get_screen_state(state, screen, default)` helper
- [x] `set_screen_state!(state, screen, value)` helper
- [x] `clear_screen_state!(state, screen)` helper
- [x] All existing tests pass
- [x] New tests for screen state helpers

---

### Unit 2: Abstract Screen Types
**Status:** PENDING
**Scope:** Type hierarchy + screen registry

**Files:**
- `src/tui/screen_types.jl` (new)
- `src/tui/tui.jl` (modify - include)
- `test/test_screen_types.jl` (new)

**Acceptance Criteria:**
- [ ] `AbstractScreen` abstract type
- [ ] Concrete singleton types for each screen (MainListScreen, etc.)
- [ ] `SCREEN_REGISTRY::Dict{Screen, AbstractScreen}`
- [ ] `get_screen_handler(screen)` returns AbstractScreen instance
- [ ] All existing tests pass
- [ ] New tests for registry completeness

---

### Unit 3: Dispatch-Based Render
**Status:** PENDING
**Scope:** Replace if-else in render_screen() with multiple dispatch

**Files:**
- `src/tui/render.jl` (modify)
- `src/tui/screen_types.jl` (modify - add render methods)

**Acceptance Criteria:**
- [ ] `render(::AbstractScreen, state)` method for each screen type
- [ ] `render_screen(state)` uses dispatch via registry
- [ ] No if-else chain in render_screen()
- [ ] All existing tests pass
- [ ] Visual verification: all screens render correctly

**Dependencies:** Units 1, 2

---

### Unit 4: Dispatch-Based Input
**Status:** PENDING
**Scope:** Replace if-else in handle_input!() with multiple dispatch

**Files:**
- `src/tui/render.jl` (modify)
- `src/tui/screen_types.jl` (modify - add input methods)

**Acceptance Criteria:**
- [ ] `handle_input!(::AbstractScreen, state, key)` method for each screen type
- [ ] `handle_input!(state, key)` uses dispatch via registry
- [ ] No if-else chain in handle_input!()
- [ ] All existing tests pass
- [ ] Manual verification: all keyboard inputs work

**Dependencies:** Units 1, 2

---

### Unit 5: Layout Module
**Status:** PENDING
**Scope:** Layout composition primitives

**Files:**
- `src/tui/layout.jl` (new)
- `src/tui/tui.jl` (modify - include)
- `test/test_tui_layout.jl` (new)

**Acceptance Criteria:**
- [ ] `vstack(parts...)` - vertical composition (join with \n)
- [ ] `hstack(left, right; sep)` - horizontal side-by-side
- [ ] `grid(cells::Matrix; widths)` - grid layout
- [ ] All existing tests pass
- [ ] New tests for layout primitives

**Dependencies:** Units 3, 4

---

### Unit 6: Event Types
**Status:** PENDING
**Scope:** Event type hierarchy for event-driven loop

**Files:**
- `src/tui/events.jl` (new)
- `src/tui/tui.jl` (modify - include)
- `test/test_tui_events.jl` (new)

**Acceptance Criteria:**
- [ ] `AbstractEvent` abstract type
- [ ] `KeyEvent` wrapping key input
- [ ] `TickEvent` for periodic updates
- [ ] `TimerEvent` for scheduled callbacks
- [ ] All existing tests pass
- [ ] New tests for event types

---

### Unit 7: Non-Blocking Loop
**Status:** PENDING
**Scope:** Event-driven main loop with non-blocking input

**Files:**
- `src/tui/tui.jl` (modify - new run_main_loop!)
- `src/tui/events.jl` (modify - event handling)

**Acceptance Criteria:**
- [ ] `bytesavailable(stdin)` check for non-blocking input
- [ ] `handle_event!(state, event)` dispatcher
- [ ] `needs_render` flag for efficient rendering
- [ ] Tick events every ~100ms
- [ ] All existing tests pass
- [ ] Manual verification: responsive feel

**Dependencies:** Unit 6

---

### Unit 8: Timer Infrastructure
**Status:** PENDING
**Scope:** Timer registration and auto-dismiss messages

**Files:**
- `src/tui/events.jl` (modify - timer management)
- `src/tui/state.jl` (modify - timer list)
- `test/test_tui_events.jl` (modify - timer tests)

**Acceptance Criteria:**
- [ ] `register_timer!(state, delay, callback)` function
- [ ] `process_timers!(state)` in event loop
- [ ] Auto-dismiss success messages after 3 seconds
- [ ] All existing tests pass
- [ ] Manual verification: messages auto-dismiss

**Dependencies:** Unit 7

---

## Session Log

| Date | Unit | Action | Notes |
|------|------|--------|-------|
| 2026-01-20 | Setup | Created units file | Starting Phase 5 implementation |
| 2026-01-22 | 1 | MERGED | PR #21 merged - screen state management complete |

## Dependency Graph

```
[1] Screen State ──┐
                   ├──> [3] Render ──┐
[2] Screen Types ──┘                 ├──> [5] Layout
                   ┌──> [4] Input ───┘
                   │
[6] Events ────────┴──> [7] Loop ──> [8] Timers
```

**Recommended order:** 1 → 2 → 3 → 4 → 6 → 7 → 8 → 5
