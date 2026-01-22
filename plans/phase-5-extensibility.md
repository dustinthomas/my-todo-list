# Plan: Phase 5 - Extensibility Foundation

## Overview

Refactor the TUI architecture to enable extensibility without modifying core code. This phase introduces:
- **Screen state management** for per-screen data isolation
- **Abstract screen types** with multiple dispatch for rendering/input
- **Layout composition primitives** for building complex UIs
- **Event-driven architecture** with non-blocking input and timers

These changes enable future features (custom screens, plugins, async operations) without touching core TUI code.

**Work Units:** See `docs/features/phase-5-extensibility-units.md` for PR-sized breakdown

## Current Architecture

The TUI currently uses:
- **Monolithic state**: `AppState` struct in `src/tui/state.jl` with all fields
- **If-else routing**: `render_screen()` and `handle_input!()` in `src/tui/render.jl` use large if-else chains
- **Blocking input**: Main loop in `src/tui/tui.jl` blocks on `read_key()`
- **No timers**: Messages persist until next user action

## Steps

### Step 1: Add screen_state Field to AppState
**Work Unit:** 1
**Files to modify:**
- `src/tui/state.jl` (modify - add field if not present, already added)

**Changes:**
- Verify `screen_state::Dict{Screen, Any}` field exists in AppState
- Verify initialization in `create_initial_state()`

**Tests:**
- Verify field exists and is initialized to empty Dict

---

### Step 2: Create Screen State Helper Functions
**Work Unit:** 1
**Files to create:**
- `src/tui/screen_state.jl` (new)

**Changes:**
- `get_screen_state(state::AppState, screen::Screen, default=nothing)` - retrieve screen state
- `set_screen_state!(state::AppState, screen::Screen, value)` - set screen state
- `clear_screen_state!(state::AppState, screen::Screen)` - remove screen state

**Tests:**
- Test get with no existing state returns default
- Test set followed by get returns value
- Test clear removes state
- Test different screens have isolated state

---

### Step 3: Include screen_state.jl in TUI Module
**Work Unit:** 1
**Files to modify:**
- `src/tui/tui.jl` (modify - add include)

**Changes:**
- Add `include("screen_state.jl")` after `include("state.jl")`

**Tests:**
- Verify module loads without errors
- Verify functions are accessible

---

### Step 4: Create Test File for Screen State
**Work Unit:** 1
**Files to create:**
- `test/test_screen_state.jl` (new)

**Changes:**
- Test all helper functions
- Test isolation between screens
- Test default values

**Tests:**
- All new tests pass
- Existing tests unaffected

---

### Step 5: Define AbstractScreen Type
**Work Unit:** 2
**Files to create:**
- `src/tui/screen_types.jl` (new)

**Changes:**
- Define `abstract type AbstractScreen end`
- Define singleton concrete types for each screen:
  - `struct MainListScreen <: AbstractScreen end`
  - `struct TodoDetailScreen <: AbstractScreen end`
  - `struct TodoAddScreen <: AbstractScreen end`
  - `struct TodoEditScreen <: AbstractScreen end`
  - `struct FilterMenuScreen <: AbstractScreen end`
  - `struct FilterStatusScreen <: AbstractScreen end`
  - `struct FilterProjectScreen <: AbstractScreen end`
  - `struct FilterCategoryScreen <: AbstractScreen end`
  - `struct ProjectListScreen <: AbstractScreen end`
  - `struct ProjectAddScreen <: AbstractScreen end`
  - `struct ProjectEditScreen <: AbstractScreen end`
  - `struct CategoryListScreen <: AbstractScreen end`
  - `struct CategoryAddScreen <: AbstractScreen end`
  - `struct CategoryEditScreen <: AbstractScreen end`
  - `struct DeleteConfirmScreen <: AbstractScreen end`

**Tests:**
- Verify types are defined
- Verify inheritance

---

### Step 6: Create Screen Registry
**Work Unit:** 2
**Files to modify:**
- `src/tui/screen_types.jl` (modify)

**Changes:**
- Create `const SCREEN_REGISTRY = Dict{Screen, AbstractScreen}()` mapping enum → singleton
- Populate registry with all screens
- Create `get_screen_handler(screen::Screen)::AbstractScreen` function

**Tests:**
- Verify all Screen enum values have registry entries
- Verify get_screen_handler returns correct type

---

### Step 7: Include screen_types.jl in TUI Module
**Work Unit:** 2
**Files to modify:**
- `src/tui/tui.jl` (modify)

**Changes:**
- Add `include("screen_types.jl")` before `include("render.jl")`

**Tests:**
- Module loads without errors
- Registry is populated

---

### Step 8: Create Test File for Screen Types
**Work Unit:** 2
**Files to create:**
- `test/test_screen_types.jl` (new)

**Changes:**
- Test type hierarchy
- Test registry completeness
- Test get_screen_handler

**Tests:**
- All new tests pass
- All Screen enum values covered

---

### Step 9: Add render() Methods to AbstractScreen Types
**Work Unit:** 3
**Files to modify:**
- `src/tui/screen_types.jl` (modify)

**Changes:**
- Define `render(::AbstractScreen, state::AppState)::String` generic function
- Add render method for each concrete screen type that delegates to existing render functions:
  - `render(::MainListScreen, state) = render_main_list(state)`
  - etc. for all screens

**Tests:**
- Each render method produces output
- Output matches existing render function output

---

### Step 10: Refactor render_screen() to Use Dispatch
**Work Unit:** 3
**Files to modify:**
- `src/tui/render.jl` (modify)

**Changes:**
- Replace if-else chain with:
```julia
function render_screen(state::AppState)::String
    handler = get_screen_handler(state.current_screen)
    return render(handler, state)
end
```

**Tests:**
- All existing rendering tests pass
- Visual verification: all screens render correctly

---

### Step 11: Add handle_input!() Methods to AbstractScreen Types
**Work Unit:** 4
**Files to modify:**
- `src/tui/screen_types.jl` (modify)

**Changes:**
- Define `handle_input!(::AbstractScreen, state::AppState, key)::Nothing` generic function
- Add handle_input! method for each concrete screen type that delegates to existing handlers:
  - `handle_input!(::MainListScreen, state, key) = handle_main_list_input!(state, key)`
  - etc. for all screens

**Tests:**
- Each handler processes input correctly
- Behavior matches existing handlers

---

### Step 12: Refactor handle_input!() to Use Dispatch
**Work Unit:** 4
**Files to modify:**
- `src/tui/render.jl` (modify)

**Changes:**
- Replace if-else chain with:
```julia
function handle_input!(state::AppState, key)::Nothing
    handler = get_screen_handler(state.current_screen)
    handle_input!(handler, state, key)
    return nothing
end
```

**Tests:**
- All existing input handling tests pass
- Manual verification: all keyboard inputs work

---

### Step 13: Create Layout Module
**Work Unit:** 5
**Files to create:**
- `src/tui/layout.jl` (new)

**Changes:**
- `vstack(parts...)` - join parts with newlines (vertical composition)
- `hstack(left, right; sep=" ")` - place parts side-by-side (horizontal composition)
- `grid(cells::Matrix; widths=nothing)` - arrange cells in grid layout

**Implementation notes:**
- `vstack` uses `join(filter(!isempty, parts), "\n")`
- `hstack` pads left to max width, then concatenates
- `grid` uses fixed column widths or auto-calculates

**Tests:**
- vstack joins correctly
- hstack aligns correctly
- grid handles various sizes

---

### Step 14: Include layout.jl in TUI Module
**Work Unit:** 5
**Files to modify:**
- `src/tui/tui.jl` (modify)

**Changes:**
- Add `include("layout.jl")` after components

**Tests:**
- Module loads without errors
- Functions are accessible

---

### Step 15: Create Test File for Layout
**Work Unit:** 5
**Files to create:**
- `test/test_tui_layout.jl` (new)

**Changes:**
- Test vstack with various inputs
- Test hstack alignment
- Test grid layouts

**Tests:**
- All layout tests pass

---

### Step 16: Define Event Type Hierarchy
**Work Unit:** 6
**Files to create:**
- `src/tui/events.jl` (new)

**Changes:**
- `abstract type AbstractEvent end`
- `struct KeyEvent <: AbstractEvent; key::Union{Char, Symbol}; end`
- `struct TickEvent <: AbstractEvent end`
- `struct TimerEvent <: AbstractEvent; callback::Function; end`

**Tests:**
- Types are defined
- Can construct events

---

### Step 17: Include events.jl in TUI Module
**Work Unit:** 6
**Files to modify:**
- `src/tui/tui.jl` (modify)

**Changes:**
- Add `include("events.jl")` after input.jl

**Tests:**
- Module loads without errors
- Event types accessible

---

### Step 18: Create Test File for Events
**Work Unit:** 6
**Files to create:**
- `test/test_tui_events.jl` (new)

**Changes:**
- Test event construction
- Test type hierarchy

**Tests:**
- All event tests pass

---

### Step 19: Add Non-Blocking Input Check
**Work Unit:** 7
**Files to modify:**
- `src/tui/tui.jl` (modify)

**Changes:**
- Add `has_input_available()::Bool` function using `bytesavailable(stdin) > 0`
- Modify main loop to check for input availability

**Tests:**
- Manual verification: loop responsive

---

### Step 20: Create Event-Driven Main Loop
**Work Unit:** 7
**Files to modify:**
- `src/tui/tui.jl` (modify)

**Changes:**
- Rename current `run_main_loop!` to `run_blocking_loop!` (keep as fallback)
- Create new `run_main_loop!` that:
  1. Polls for input with `bytesavailable(stdin)`
  2. Generates TickEvent every ~100ms when idle
  3. Generates KeyEvent when input available
  4. Tracks `needs_render` flag to avoid redundant renders

**Tests:**
- Manual verification: responsive feel
- Existing tests pass

---

### Step 21: Add handle_event!() Dispatcher
**Work Unit:** 7
**Files to modify:**
- `src/tui/events.jl` (modify)

**Changes:**
- `handle_event!(state::AppState, event::AbstractEvent)::Nothing` dispatcher
- `handle_event!(state, event::KeyEvent)` - delegates to handle_input!
- `handle_event!(state, event::TickEvent)` - no-op for now
- `handle_event!(state, event::TimerEvent)` - execute callback

**Tests:**
- Manual verification: events processed correctly

---

### Step 22: Add Timer List to AppState
**Work Unit:** 8
**Files to modify:**
- `src/tui/state.jl` (modify)

**Changes:**
- Add `timers::Vector{Tuple{Float64, Function}}` field (deadline, callback)
- Initialize as empty vector in `create_initial_state()`

**Tests:**
- Field exists
- Initialization correct

---

### Step 23: Create Timer Registration Functions
**Work Unit:** 8
**Files to modify:**
- `src/tui/events.jl` (modify)

**Changes:**
- `register_timer!(state::AppState, delay_seconds::Float64, callback::Function)` - add timer
- `process_timers!(state::AppState)` - check and fire expired timers
- `clear_timers!(state::AppState)` - remove all timers

**Tests:**
- Timer registration works
- Timer fires at correct time
- Multiple timers handled

---

### Step 24: Integrate Timers into Event Loop
**Work Unit:** 8
**Files to modify:**
- `src/tui/tui.jl` (modify)

**Changes:**
- Call `process_timers!(state)` each loop iteration
- Generate TimerEvent for expired timers

**Tests:**
- Timers fire in loop
- Manual verification

---

### Step 25: Add Auto-Dismiss for Success Messages
**Work Unit:** 8
**Files to modify:**
- `src/tui/state.jl` (modify)

**Changes:**
- Modify `set_message!` to register timer for success messages:
```julia
function set_message!(state, msg, type)
    state.message = msg
    state.message_type = type
    if type == :success
        register_timer!(state, 3.0, () -> clear_message!(state))
    end
end
```

**Tests:**
- Success messages auto-dismiss after 3 seconds
- Error messages persist
- Manual verification

---

## Files

**New files:**
- `src/tui/screen_state.jl` - Screen state helper functions
- `src/tui/screen_types.jl` - Abstract types + registry
- `src/tui/layout.jl` - Layout composition primitives
- `src/tui/events.jl` - Event type hierarchy + timer handling
- `test/test_screen_state.jl` - Screen state tests
- `test/test_screen_types.jl` - Screen type tests
- `test/test_tui_layout.jl` - Layout tests
- `test/test_tui_events.jl` - Event tests

**Modified files:**
- `src/tui/state.jl` - Add timers field
- `src/tui/tui.jl` - Include new modules, event-driven loop
- `src/tui/render.jl` - Dispatch-based routing

## Risks

- **Breaking existing functionality**: All changes are additive or replace if-else with dispatch (same behavior)
  - *Mitigation*: Run full test suite after each unit; visual verification

- **Timer precision**: Julia's event loop may not fire timers exactly at deadline
  - *Mitigation*: Use ~100ms tick rate; acceptable variance for UI feedback

- **Non-blocking input complexity**: Raw terminal input + polling can be tricky
  - *Mitigation*: Keep blocking loop as fallback; test thoroughly in Docker

- **Multiple dispatch performance**: Lookup overhead for every render/input
  - *Mitigation*: Dispatch is optimized in Julia; registry is Dict lookup (O(1))

## Acceptance Criteria (Overall)

- [ ] All work units complete and merged
- [ ] Full test suite passes
- [ ] No if-else chains in render_screen() or handle_input!()
- [ ] Screen state isolated per screen
- [ ] Layout primitives available for future use
- [ ] Event-driven loop with responsive feel
- [ ] Success messages auto-dismiss after 3 seconds
- [ ] Manual verification complete

## Testing Strategy

**Unit Tests:**
- `test/test_screen_state.jl` - Screen state helpers
- `test/test_screen_types.jl` - Type hierarchy, registry
- `test/test_tui_layout.jl` - Layout primitives
- `test/test_tui_events.jl` - Event types, timer functions

**Integration Tests:**
- Existing TUI tests verify dispatch-based routing works
- Run all tests after each unit

**Manual Tests:**
- [ ] All screens render correctly (visual check)
- [ ] All keyboard inputs work on all screens
- [ ] Success messages disappear after ~3 seconds
- [ ] Error messages persist until dismissed
- [ ] TUI feels responsive (no lag on input)
- [ ] Ctrl+C exits cleanly
- [ ] Works in Docker container

## Architecture After Phase 5

```
┌─────────────────────────────────────────────────────────────────┐
│                         run_main_loop!                          │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ Event Loop (non-blocking)                                 │   │
│  │  - Poll for input (bytesavailable)                        │   │
│  │  - Generate TickEvent / KeyEvent                          │   │
│  │  - Process timers → TimerEvent                            │   │
│  │  - handle_event!(state, event)                            │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      handle_event!(state, event)                │
│  KeyEvent → handle_input!(handler, state, key)                  │
│  TickEvent → (no-op / future use)                               │
│  TimerEvent → execute callback                                  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Multiple Dispatch Routing                    │
│  ┌─────────────────────┐    ┌─────────────────────┐            │
│  │ render_screen(state)│    │ handle_input!(s,k)  │            │
│  │  → get_screen_handler   │  → get_screen_handler             │
│  │  → render(handler, s)   │  → handle_input!(h,s,k)           │
│  └─────────────────────┘    └─────────────────────┘            │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                     Screen Type Hierarchy                       │
│  AbstractScreen                                                 │
│    ├── MainListScreen                                           │
│    ├── TodoDetailScreen                                         │
│    ├── TodoAddScreen / TodoEditScreen                           │
│    ├── FilterMenuScreen / FilterStatusScreen / ...              │
│    ├── ProjectListScreen / ProjectAddScreen / ...               │
│    ├── CategoryListScreen / CategoryAddScreen / ...             │
│    └── DeleteConfirmScreen                                      │
│                                                                 │
│  Each has: render(::Type, state) and handle_input!(::Type,s,k)  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                        AppState                                 │
│  - screen_state::Dict{Screen, Any}  (per-screen isolation)      │
│  - timers::Vector{Tuple{Float64, Function}}  (scheduled events) │
│  - ... existing fields ...                                      │
└─────────────────────────────────────────────────────────────────┘
```

## Extensibility Enabled

After Phase 5, adding a new screen requires:
1. Add enum value to `Screen`
2. Create `struct NewScreen <: AbstractScreen end`
3. Add to `SCREEN_REGISTRY`
4. Implement `render(::NewScreen, state)`
5. Implement `handle_input!(::NewScreen, state, key)`

No changes needed to:
- `render_screen()` - uses dispatch
- `handle_input!()` - uses dispatch
- Main loop - event-driven
- Other screens - isolated

This pattern enables plugins, custom screens, and async operations in future phases.
