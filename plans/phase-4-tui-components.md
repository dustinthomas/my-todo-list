# Plan: Phase 4 - TUI Components

## Overview

Implement a complete Terminal User Interface (TUI) for the TodoList application using Term.jl for rendering and raw terminal input handling for keyboard navigation. This builds on the existing database layer (Phase 3) to provide an interactive terminal experience with 12 screens as specified in `docs/tui-design.md`.

**Design Reference:** `docs/tui-design.md` (approved 2026-01-17)

**Development Approach:** Test-Driven Development (TDD) - Write tests FIRST, then implement to pass tests.

---

## TUI Testing Best Practices

TUI applications present unique testing challenges. This section establishes patterns for testing TUI code effectively.

### Testing Pyramid for TUI

```
                    ┌─────────────────┐
                    │  Manual Tests   │  ← Visual verification, keyboard feel
                    │   (Required)    │
                    ├─────────────────┤
                    │ Integration     │  ← Screen composition, state flow
                    │ Tests           │
                    ├─────────────────┤
                    │ Input Handler   │  ← State mutations from key presses
                    │ Tests           │
                    ├─────────────────┤
                    │ Component       │  ← Render output content verification
                    │ Tests           │
        ┌───────────┴─────────────────┴───────────┐
        │         State Management Tests          │  ← Pure logic, no IO
        └─────────────────────────────────────────┘
```

### Principle 1: Separate Rendering from IO

**Bad:**
```julia
function render_header(title)
    println(Panel(title))  # Side effect - hard to test
end
```

**Good:**
```julia
function render_header(title)::Panel
    return Panel(title)  # Pure function - returns testable object
end
```

All render functions return objects (Panel, String, etc.) - NEVER print directly. This makes them unit-testable.

### Principle 2: Separate Input Parsing from Action Execution

**Bad:**
```julia
function handle_input!(state)
    key = read_key()  # IO inside handler
    if key == 'q'
        state.running = false
    end
end
```

**Good:**
```julia
function handle_input!(state, key)::Nothing  # Key passed in
    if key == 'q'
        state.running = false
    end
    nothing
end
```

Input handlers receive the key as a parameter, making them testable without mocking IO.

### Principle 3: Content Verification Over Exact Matching

**Bad (brittle):**
```julia
@test render_header("Todo List") == "┌─────────Todo List─────────┐"
```

**Good (robust):**
```julia
output = render_header("Todo List")
@test output isa Panel
@test contains(string(output), "Todo List")
```

Test that output CONTAINS expected content, not exact string matching (which breaks with style changes).

### Principle 4: State Machine Testing

State transitions are pure logic and highly testable:

```julia
@testset "State Transitions" begin
    state = create_test_state()

    # Test: pressing 'a' on main list goes to add screen
    state.current_screen = MAIN_LIST
    handle_main_list_input!(state, 'a')
    @test state.current_screen == TODO_ADD
    @test state.previous_screen == MAIN_LIST

    # Test: pressing Escape goes back
    handle_todo_form_input!(state, :escape)
    @test state.current_screen == MAIN_LIST
end
```

### Principle 5: Mock Database for Fast Tests

```julia
function create_test_state()::AppState
    db = connect_database(":memory:")
    init_schema!(db)
    # Optionally seed test data
    return create_initial_state(db)
end
```

All TUI tests use `:memory:` database for speed and isolation.

### Principle 6: Manual Testing is REQUIRED

Some things cannot be automated:
- Visual appearance (colors, alignment, spacing)
- Keyboard responsiveness feel
- Terminal state restoration
- Screen flickering

Document a **Manual Test Checklist** and execute it before PR.

### Test File Organization

```
test/
├── runtests.jl              # Entry point
├── test_database.jl         # Existing
├── test_queries.jl          # Existing
├── test_tui_state.jl        # State management tests
├── test_tui_components.jl   # Component render tests
├── test_tui_input.jl        # Input handler tests
└── test_tui_integration.jl  # Full screen/flow tests
```

### Test Helpers

Create reusable test utilities:

```julia
# test/tui_test_helpers.jl

"""Create a fresh AppState with in-memory database for testing."""
function create_test_state(; with_data::Bool=false)::AppState
    db = connect_database(":memory:")
    init_schema!(db)
    if with_data
        seed_test_data!(db)
    end
    return create_initial_state(db)
end

"""Seed database with standard test data."""
function seed_test_data!(db)
    create_project(db, "Test Project", color="#FF0000")
    create_category(db, "Test Category", color="#00FF00")
    create_todo(db, "Test Todo 1", status="pending", priority=1)
    create_todo(db, "Test Todo 2", status="completed", priority=2)
end

"""Assert that rendered output contains all expected strings."""
function assert_contains_all(output, expected::Vector{String})
    output_str = string(output)
    for s in expected
        @test contains(output_str, s) "Expected '$s' in output"
    end
end
```

---

## Architecture

### Component Structure

```
src/
├── TodoList.jl           # Existing module (add TUI exports)
├── tui/
│   ├── tui.jl            # Main TUI module, app entry point
│   ├── state.jl          # AppState struct, state management
│   ├── input.jl          # Raw keyboard input handling
│   ├── render.jl         # Screen rendering coordinator
│   ├── components/
│   │   ├── components.jl # Component module exports
│   │   ├── header.jl     # Header panel component
│   │   ├── footer.jl     # Footer shortcuts component
│   │   ├── table.jl      # Scrollable table component
│   │   ├── form.jl       # Form input components
│   │   ├── dialog.jl     # Confirmation dialogs
│   │   └── message.jl    # Success/error messages
│   └── screens/
│       ├── screens.jl    # Screen module exports
│       ├── main_list.jl  # Main todo list view
│       ├── todo_detail.jl # Todo detail view
│       ├── todo_form.jl  # Add/Edit todo form
│       ├── filter_menu.jl # Filter selection
│       ├── project_list.jl # Project management
│       ├── project_form.jl # Add/Edit project form
│       ├── category_list.jl # Category management
│       ├── category_form.jl # Add/Edit category form
│       └── delete_confirm.jl # Delete confirmation
```

### State Management

```julia
@enum Screen begin
    MAIN_LIST
    TODO_DETAIL
    TODO_ADD
    TODO_EDIT
    FILTER_MENU
    FILTER_STATUS
    FILTER_PROJECT
    FILTER_CATEGORY
    PROJECT_LIST
    PROJECT_ADD
    PROJECT_EDIT
    CATEGORY_LIST
    CATEGORY_ADD
    CATEGORY_EDIT
    DELETE_CONFIRM
end

mutable struct AppState
    # Navigation
    current_screen::Screen
    previous_screen::Union{Screen, Nothing}

    # Selection state
    selected_index::Int
    scroll_offset::Int

    # Data
    todos::Vector{Todo}
    projects::Vector{Project}
    categories::Vector{Category}

    # Current item being viewed/edited
    current_todo::Union{Todo, Nothing}
    current_project::Union{Project, Nothing}
    current_category::Union{Category, Nothing}

    # Delete confirmation target
    delete_type::Union{Symbol, Nothing}  # :todo, :project, :category
    delete_id::Union{Int64, Nothing}
    delete_name::String

    # Filters (AND logic)
    filter_status::Union{String, Nothing}
    filter_project_id::Union{Int64, Nothing}
    filter_category_id::Union{Int64, Nothing}

    # Form state
    form_fields::Dict{Symbol, String}
    form_field_index::Int
    form_errors::Dict{Symbol, String}

    # Messages
    message::Union{String, Nothing}
    message_type::Union{Symbol, Nothing}  # :success, :error

    # Database connection
    db::SQLite.DB

    # Running flag
    running::Bool
end
```

---

## Steps

### Step 1: Create Test Infrastructure and TUI Module Skeleton

**TDD Approach:** Create test files and helpers FIRST, then minimal implementation to make tests pass.

**Files to create:**
- `test/tui_test_helpers.jl` - Test utilities
- `test/test_tui_state.jl` - State management tests
- `src/tui/tui.jl` - Main TUI module (skeleton)
- `src/tui/state.jl` - AppState struct and helpers

**Phase 1: Write Tests First**

Create `test/tui_test_helpers.jl`:
```julia
# Test utilities for TUI testing
using TodoList

function create_test_state(; with_data::Bool=false)::AppState
    db = connect_database(":memory:")
    init_schema!(db)
    if with_data
        seed_test_data!(db)
    end
    return create_initial_state(db)
end

function seed_test_data!(db)
    # Create test data
end

function assert_contains_all(output, expected::Vector{String})
    output_str = string(output)
    for s in expected
        @test contains(output_str, s)
    end
end
```

Create `test/test_tui_state.jl`:
```julia
@testset "TUI State Tests" begin
    @testset "AppState Initialization" begin
        state = create_test_state()
        @test state.current_screen == MAIN_LIST
        @test state.running == true
        @test state.selected_index == 1
        @test state.filter_status === nothing
        @test state.todos isa Vector{Todo}
    end

    @testset "Screen Transitions" begin
        state = create_test_state()

        # go_to_screen! saves previous
        go_to_screen!(state, TODO_ADD)
        @test state.current_screen == TODO_ADD
        @test state.previous_screen == MAIN_LIST

        # go_back! restores previous
        go_back!(state)
        @test state.current_screen == MAIN_LIST
    end

    @testset "Data Refresh" begin
        state = create_test_state()
        @test length(state.todos) == 0

        # Add data directly to DB
        create_todo(state.db, "New Todo")

        # Refresh should pick it up
        refresh_data!(state)
        @test length(state.todos) == 1
    end
end
```

**Phase 2: Implement to Pass Tests**

Create `src/tui/state.jl` with:
- `Screen` enum
- `AppState` struct
- `create_initial_state(db)`
- `go_to_screen!(state, screen)`
- `go_back!(state)`
- `refresh_data!(state)`

Create `src/tui/tui.jl` with module structure.

**Phase 3: Run Tests**
```bash
julia --project=. test/runtests.jl
```

**Success Criteria:**
- [ ] All state tests pass
- [ ] AppState has all required fields
- [ ] Screen transitions work correctly

---

### Step 2: Input Handler Infrastructure (TDD)

**Files to create:**
- `test/test_tui_input.jl` - Input handler tests
- `src/tui/input.jl` - Keyboard input handling

**Phase 1: Write Tests First**

Create `test/test_tui_input.jl`:
```julia
@testset "TUI Input Tests" begin
    @testset "Key Constants" begin
        @test KEY_QUIT == 'q'
        @test KEY_ADD == 'a'
        @test KEY_EDIT == 'e'
        @test KEY_DELETE == 'd'
        @test KEY_COMPLETE == 'c'
        @test KEY_BACK == 'b'
        @test KEY_NAV_UP == 'k'
        @test KEY_NAV_DOWN == 'j'
    end

    @testset "is_navigation_key" begin
        @test is_navigation_key('j') == true
        @test is_navigation_key('k') == true
        @test is_navigation_key(:up) == true
        @test is_navigation_key(:down) == true
        @test is_navigation_key('x') == false
    end

    @testset "is_quit_key" begin
        @test is_quit_key('q') == true
        @test is_quit_key(:ctrl_c) == true
        @test is_quit_key('a') == false
    end
end
```

**Note:** Raw terminal input (`read_key()`, `setup_terminal()`, `restore_terminal()`) requires MANUAL TESTING - cannot be unit tested.

**Phase 2: Implement**

Create `src/tui/input.jl`:
- Key constants
- Helper functions (testable)
- Raw terminal functions (manual test only)

**Phase 3: Run Tests + Manual Verification**

Manual test checklist for input:
- [ ] Arrow keys detected
- [ ] j/k navigation works
- [ ] Ctrl+C triggers quit signal
- [ ] Enter/Escape/Tab work
- [ ] Terminal restores properly on exit

**Success Criteria:**
- [ ] Key constant tests pass
- [ ] Helper function tests pass
- [ ] Manual input verification complete

---

### Step 3: Base Rendering Components (TDD)

**Files to create:**
- `test/test_tui_components.jl` - Component tests
- `src/tui/components/components.jl` - Module
- `src/tui/components/header.jl`
- `src/tui/components/footer.jl`
- `src/tui/components/message.jl`

**Phase 1: Write Tests First**

Create `test/test_tui_components.jl`:
```julia
@testset "TUI Component Tests" begin
    @testset "Header Component" begin
        # Test basic header
        output = render_header("Todo List")
        @test output isa Panel
        @test contains(string(output), "Todo List")

        # Test header with subtitle
        output = render_header("Todo List", subtitle="[Filter: pending] [5 items]")
        output_str = string(output)
        @test contains(output_str, "Todo List")
        @test contains(output_str, "Filter: pending")
        @test contains(output_str, "5 items")
    end

    @testset "Footer Component" begin
        shortcuts = [("j/k", "Navigate"), ("Enter", "Select"), ("q", "Quit")]
        output = render_footer(shortcuts)
        output_str = string(output)

        @test contains(output_str, "j/k")
        @test contains(output_str, "Navigate")
        @test contains(output_str, "Enter")
        @test contains(output_str, "Quit")
    end

    @testset "Message Component" begin
        # Success message
        output = render_message("Todo created!", :success)
        output_str = string(output)
        @test contains(output_str, "Todo created!")
        # Note: Color testing is manual

        # Error message
        output = render_message("Title required", :error)
        @test contains(string(output), "Title required")
    end
end
```

**Phase 2: Implement Components**

Each component:
- Returns Panel or String (no printing)
- Has docstring
- Handles edge cases (empty input, long text)

**Phase 3: Run Tests**

```bash
julia --project=. test/runtests.jl
```

**Success Criteria:**
- [ ] Header tests pass
- [ ] Footer tests pass
- [ ] Message tests pass
- [ ] Components return proper types (no IO side effects)

---

### Step 4: Table Component (TDD)

**Files to create:**
- Add to `test/test_tui_components.jl`
- `src/tui/components/table.jl`

**Phase 1: Write Tests First**

Add to `test/test_tui_components.jl`:
```julia
@testset "Table Component" begin
    @testset "Todo Table - Empty" begin
        output = render_todo_table(Todo[], 1, 0, 20)
        @test contains(string(output), "No todos")
    end

    @testset "Todo Table - With Data" begin
        todos = [
            Todo(1, "First todo", nothing, "pending", 1, nothing, nothing,
                 nothing, "2026-01-20", nothing, nothing, nothing),
            Todo(2, "Second todo", nothing, "completed", 2, nothing, nothing,
                 nothing, nothing, nothing, nothing, nothing),
        ]

        output = render_todo_table(todos, 1, 0, 20)
        output_str = string(output)

        # Contains expected columns
        @test contains(output_str, "First todo")
        @test contains(output_str, "Second todo")
        @test contains(output_str, "pending")
        @test contains(output_str, "completed")
        @test contains(output_str, "2026-01-20")

        # Selected row indicator (first row selected)
        @test contains(output_str, ">") || contains(output_str, "►")
    end

    @testset "Todo Table - Scrolling" begin
        # Create 50 todos
        todos = [Todo(i, "Todo $i", nothing, "pending", 2, nothing, nothing,
                      nothing, nothing, nothing, nothing, nothing) for i in 1:50]

        # Visible window is 20 lines, scroll offset 30
        output = render_todo_table(todos, 35, 30, 20)
        output_str = string(output)

        # Should show todos around index 35, not todo 1
        @test contains(output_str, "Todo 35")
        @test !contains(output_str, "Todo 1")
    end

    @testset "Format Status" begin
        # These return styled strings
        @test contains(format_status("pending"), "pending")
        @test contains(format_status("completed"), "completed")
    end

    @testset "Format Priority" begin
        @test contains(format_priority(1), "HIGH")
        @test contains(format_priority(2), "MEDIUM")
        @test contains(format_priority(3), "LOW")
    end

    @testset "Project Table" begin
        projects = [
            Project(1, "Project A", "Description", "#FF0000", nothing, nothing)
        ]
        output = render_project_table(projects, 1, Dict(1 => 5))
        output_str = string(output)

        @test contains(output_str, "Project A")
        @test contains(output_str, "Description")
    end

    @testset "Category Table" begin
        categories = [
            Category(1, "Category A", "#00FF00", nothing)
        ]
        output = render_category_table(categories, 1, Dict(1 => 3))
        @test contains(string(output), "Category A")
    end
end
```

**Phase 2: Implement**

Create `src/tui/components/table.jl` with:
- `render_todo_table(todos, selected_index, scroll_offset, visible_rows)`
- `render_project_table(projects, selected_index, todo_counts)`
- `render_category_table(categories, selected_index, todo_counts)`
- `format_status(status)` - Apply Term.jl colors
- `format_priority(priority)` - Apply Term.jl colors
- `truncate_string(s, max_len)`

**Phase 3: Run Tests**

**Success Criteria:**
- [ ] Empty table tests pass
- [ ] Data table tests pass
- [ ] Scrolling tests pass
- [ ] Format helpers tests pass

---

### Step 5: Form Components (TDD)

**Files to create:**
- Add to `test/test_tui_components.jl`
- `src/tui/components/form.jl`

**Phase 1: Write Tests First**

Add to `test/test_tui_components.jl`:
```julia
@testset "Form Components" begin
    @testset "Text Field" begin
        output = render_text_field("Title*", "My Todo", true)
        output_str = string(output)
        @test contains(output_str, "Title*")
        @test contains(output_str, "My Todo")

        # With error
        output = render_text_field("Title*", "", true, "Title is required")
        @test contains(string(output), "Title is required")
    end

    @testset "Radio Group" begin
        options = ["pending", "in_progress", "completed"]
        output = render_radio_group("Status", options, "pending", true)
        output_str = string(output)

        @test contains(output_str, "Status")
        @test contains(output_str, "pending")
        @test contains(output_str, "in_progress")
    end

    @testset "Dropdown" begin
        options = [("1", "Project A"), ("2", "Project B")]
        output = render_dropdown("Project", options, "1", true, false)
        @test contains(string(output), "Project A")
    end

    @testset "Full Form Rendering" begin
        fields = Dict(:title => "Test", :description => "")
        errors = Dict{Symbol,String}()

        output = render_todo_form_fields(fields, 1, errors)
        output_str = string(output)

        @test contains(output_str, "Title")
        @test contains(output_str, "Description")
        @test contains(output_str, "Test")
    end
end
```

**Phase 2: Implement**

**Phase 3: Run Tests**

**Success Criteria:**
- [ ] Text field tests pass
- [ ] Radio group tests pass
- [ ] Dropdown tests pass
- [ ] Form composition tests pass

---

### Step 6: Dialog Component (TDD)

**Files to create:**
- Add to `test/test_tui_components.jl`
- `src/tui/components/dialog.jl`

**Phase 1: Write Tests First**

```julia
@testset "Dialog Components" begin
    @testset "Delete Confirmation" begin
        output = render_delete_dialog(:todo, "Buy groceries")
        output_str = string(output)

        @test contains(output_str, "todo")
        @test contains(output_str, "Buy groceries")
        @test contains(output_str, "Delete")
        @test contains(output_str, "Cancel")
        @test contains(output_str, "cannot be undone")
    end

    @testset "Filter Menu" begin
        filters = (status="pending", project_id=nothing, category_id=1)
        output = render_filter_summary(filters)
        output_str = string(output)

        @test contains(output_str, "pending")
    end
end
```

**Phase 2: Implement**

**Phase 3: Run Tests**

**Success Criteria:**
- [ ] Delete dialog tests pass
- [ ] Filter menu tests pass

---

### Step 7: Main List Screen - Rendering (TDD)

**Files to create:**
- `test/test_tui_screens.jl` - Screen tests
- `src/tui/screens/screens.jl`
- `src/tui/screens/main_list.jl`

**Phase 1: Write Tests First**

Create `test/test_tui_screens.jl`:
```julia
@testset "TUI Screen Tests" begin
    include("tui_test_helpers.jl")

    @testset "Main List Screen" begin
        @testset "Rendering - Empty" begin
            state = create_test_state(with_data=false)
            output = render_main_list(state)
            output_str = string(output)

            @test contains(output_str, "Todo List")
            @test contains(output_str, "No todos")
            @test contains(output_str, "Press 'a'")
        end

        @testset "Rendering - With Data" begin
            state = create_test_state(with_data=true)
            output = render_main_list(state)
            output_str = string(output)

            @test contains(output_str, "Todo List")
            @test contains(output_str, "Test Todo")
            # Footer shortcuts
            @test contains(output_str, "Navigate")
            @test contains(output_str, "Add")
            @test contains(output_str, "Quit")
        end

        @testset "Rendering - With Filters" begin
            state = create_test_state(with_data=true)
            state.filter_status = "pending"
            refresh_data!(state)  # Apply filter

            output = render_main_list(state)
            @test contains(string(output), "Filter")
            @test contains(string(output), "pending")
        end
    end
end
```

**Phase 2: Implement Rendering**

Create `src/tui/screens/main_list.jl`:
- `render_main_list(state::AppState)::String`
- Composes header + table + footer
- Handles empty state

**Phase 3: Run Tests**

**Success Criteria:**
- [ ] Empty state render tests pass
- [ ] Data render tests pass
- [ ] Filter indicator tests pass

---

### Step 8: Main List Screen - Input Handling (TDD)

**Phase 1: Write Tests First**

Add to `test/test_tui_screens.jl`:
```julia
@testset "Main List Input Handling" begin
    @testset "Navigation" begin
        state = create_test_state(with_data=true)
        state.selected_index = 1

        # Down navigation
        handle_main_list_input!(state, 'j')
        @test state.selected_index == 2

        # Up navigation
        handle_main_list_input!(state, 'k')
        @test state.selected_index == 1

        # Arrow keys
        handle_main_list_input!(state, :down)
        @test state.selected_index == 2
    end

    @testset "Screen Transitions" begin
        state = create_test_state(with_data=true)

        # 'a' goes to add
        handle_main_list_input!(state, 'a')
        @test state.current_screen == TODO_ADD

        state.current_screen = MAIN_LIST

        # Enter goes to detail
        handle_main_list_input!(state, :enter)
        @test state.current_screen == TODO_DETAIL
        @test state.current_todo !== nothing

        state.current_screen = MAIN_LIST

        # 'f' goes to filter
        handle_main_list_input!(state, 'f')
        @test state.current_screen == FILTER_MENU

        state.current_screen = MAIN_LIST

        # 'p' goes to projects
        handle_main_list_input!(state, 'p')
        @test state.current_screen == PROJECT_LIST

        state.current_screen = MAIN_LIST

        # 'g' goes to categories
        handle_main_list_input!(state, 'g')
        @test state.current_screen == CATEGORY_LIST
    end

    @testset "Actions" begin
        state = create_test_state(with_data=true)
        initial_status = state.todos[1].status

        # 'c' toggles completion
        handle_main_list_input!(state, 'c')
        refresh_data!(state)
        @test state.todos[1].status != initial_status

        # 'q' sets running = false
        handle_main_list_input!(state, 'q')
        @test state.running == false
    end

    @testset "Delete Setup" begin
        state = create_test_state(with_data=true)

        handle_main_list_input!(state, 'd')
        @test state.current_screen == DELETE_CONFIRM
        @test state.delete_type == :todo
        @test state.delete_id !== nothing
    end
end
```

**Phase 2: Implement Input Handler**

Add to `src/tui/screens/main_list.jl`:
- `handle_main_list_input!(state::AppState, key)::Nothing`

**Phase 3: Run Tests**

**Success Criteria:**
- [ ] Navigation tests pass
- [ ] Screen transition tests pass
- [ ] Action tests pass (complete toggle)
- [ ] Quit test passes

---

### Step 9: Todo Detail Screen (TDD)

**Phase 1: Write Tests First**

Add to `test/test_tui_screens.jl`:
```julia
@testset "Todo Detail Screen" begin
    @testset "Rendering" begin
        state = create_test_state(with_data=true)
        state.current_todo = state.todos[1]

        output = render_todo_detail(state)
        output_str = string(output)

        # All fields present
        @test contains(output_str, "Title")
        @test contains(output_str, "Status")
        @test contains(output_str, "Priority")
        @test contains(output_str, "Test Todo")

        # Footer shortcuts
        @test contains(output_str, "Back")
        @test contains(output_str, "Edit")
    end

    @testset "Input Handling" begin
        state = create_test_state(with_data=true)
        state.current_screen = TODO_DETAIL
        state.current_todo = state.todos[1]

        # 'b' goes back
        handle_todo_detail_input!(state, 'b')
        @test state.current_screen == MAIN_LIST

        state.current_screen = TODO_DETAIL

        # 'e' goes to edit
        handle_todo_detail_input!(state, 'e')
        @test state.current_screen == TODO_EDIT

        state.current_screen = TODO_DETAIL

        # Escape goes back
        handle_todo_detail_input!(state, :escape)
        @test state.current_screen == MAIN_LIST
    end
end
```

**Phase 2: Implement**

Create `src/tui/screens/todo_detail.jl`

**Phase 3: Run Tests**

**Success Criteria:**
- [ ] Detail render tests pass
- [ ] Input handler tests pass

---

### Step 10: Todo Form Screens (TDD)

**Phase 1: Write Tests First**

Add to `test/test_tui_screens.jl`:
```julia
@testset "Todo Form Screen" begin
    @testset "Add Form Rendering" begin
        state = create_test_state()
        state.current_screen = TODO_ADD
        state.form_fields = Dict(:title => "", :description => "")

        output = render_todo_form(state, :add)
        output_str = string(output)

        @test contains(output_str, "Add New Todo")
        @test contains(output_str, "Title")
        @test contains(output_str, "Save")
        @test contains(output_str, "Cancel")
    end

    @testset "Edit Form Rendering" begin
        state = create_test_state(with_data=true)
        state.current_screen = TODO_EDIT
        state.current_todo = state.todos[1]
        init_form_from_todo!(state, state.current_todo)

        output = render_todo_form(state, :edit)
        output_str = string(output)

        @test contains(output_str, "Edit Todo")
        @test contains(output_str, state.current_todo.title)
    end

    @testset "Form Validation" begin
        state = create_test_state()
        state.form_fields = Dict(:title => "", :due_date => "invalid")

        valid = validate_todo_form!(state)
        @test valid == false
        @test haskey(state.form_errors, :title)
    end

    @testset "Form Input - Field Navigation" begin
        state = create_test_state()
        state.form_field_index = 1

        # Tab moves to next field
        handle_todo_form_input!(state, :tab)
        @test state.form_field_index == 2

        # Shift+Tab moves back
        handle_todo_form_input!(state, :shift_tab)
        @test state.form_field_index == 1
    end

    @testset "Form Save - Add" begin
        state = create_test_state()
        state.current_screen = TODO_ADD
        state.form_fields = Dict(
            :title => "New Todo",
            :description => "",
            :status => "pending",
            :priority => "2"
        )

        initial_count = length(list_todos(state.db))
        save_todo_form!(state, :add)

        @test length(list_todos(state.db)) == initial_count + 1
        @test state.message !== nothing
        @test state.message_type == :success
    end

    @testset "Form Cancel" begin
        state = create_test_state()
        state.current_screen = TODO_ADD
        state.previous_screen = MAIN_LIST

        handle_todo_form_input!(state, :escape)
        @test state.current_screen == MAIN_LIST
    end
end
```

**Phase 2: Implement**

Create `src/tui/screens/todo_form.jl`:
- `render_todo_form(state, mode)`
- `handle_todo_form_input!(state, key)`
- `validate_todo_form!(state)`
- `save_todo_form!(state, mode)`
- `init_form_from_todo!(state, todo)`

**Phase 3: Run Tests**

**Success Criteria:**
- [ ] Add form render tests pass
- [ ] Edit form render tests pass
- [ ] Validation tests pass
- [ ] Save tests pass
- [ ] Cancel tests pass

---

### Step 11: Filter Menu (TDD)

**Phase 1: Write Tests First**

```julia
@testset "Filter Menu Screen" begin
    @testset "Menu Rendering" begin
        state = create_test_state()
        output = render_filter_menu(state)
        output_str = string(output)

        @test contains(output_str, "Filter")
        @test contains(output_str, "Status")
        @test contains(output_str, "Project")
        @test contains(output_str, "Category")
        @test contains(output_str, "Clear")
    end

    @testset "Status Filter Selection" begin
        state = create_test_state(with_data=true)
        state.current_screen = FILTER_STATUS

        # Select "pending" filter
        state.selected_index = 2  # Assuming 1=All, 2=pending
        handle_filter_status_input!(state, :enter)

        @test state.filter_status == "pending"
        @test state.current_screen == MAIN_LIST
    end

    @testset "Clear All Filters" begin
        state = create_test_state()
        state.filter_status = "pending"
        state.filter_project_id = 1

        clear_all_filters!(state)

        @test state.filter_status === nothing
        @test state.filter_project_id === nothing
    end

    @testset "Filter Application" begin
        state = create_test_state(with_data=true)
        # Seed includes pending and completed todos

        state.filter_status = "pending"
        refresh_data!(state)

        # Only pending todos should be in state
        for todo in state.todos
            @test todo.status == "pending"
        end
    end
end
```

**Phase 2: Implement**

Create `src/tui/screens/filter_menu.jl`

**Phase 3: Run Tests**

**Success Criteria:**
- [ ] Menu render tests pass
- [ ] Filter selection tests pass
- [ ] Clear filters test passes
- [ ] Filter application test passes

---

### Step 12: Project Management Screens (TDD)

**Phase 1: Write Tests First**

```julia
@testset "Project Screens" begin
    @testset "Project List Rendering" begin
        state = create_test_state(with_data=true)
        output = render_project_list(state)
        output_str = string(output)

        @test contains(output_str, "Projects")
        @test contains(output_str, "Test Project")
    end

    @testset "Project List Input" begin
        state = create_test_state(with_data=true)
        state.current_screen = PROJECT_LIST

        # 'a' goes to add
        handle_project_list_input!(state, 'a')
        @test state.current_screen == PROJECT_ADD

        state.current_screen = PROJECT_LIST

        # 'b' goes back
        handle_project_list_input!(state, 'b')
        @test state.current_screen == MAIN_LIST
    end

    @testset "Project Form - Add" begin
        state = create_test_state()
        state.current_screen = PROJECT_ADD
        state.form_fields = Dict(:name => "New Project", :description => "", :color => "#FF0000")

        initial_count = length(list_projects(state.db))
        save_project_form!(state, :add)

        @test length(list_projects(state.db)) == initial_count + 1
    end

    @testset "Project Form - Edit" begin
        state = create_test_state(with_data=true)
        state.current_project = list_projects(state.db)[1]
        state.form_fields = Dict(:name => "Updated Name", :description => "", :color => "")

        save_project_form!(state, :edit)

        updated = get_project(state.db, state.current_project.id)
        @test updated.name == "Updated Name"
    end
end
```

**Phase 2: Implement**

Create `src/tui/screens/project_list.jl` and `src/tui/screens/project_form.jl`

**Phase 3: Run Tests**

**Success Criteria:**
- [ ] List render tests pass
- [ ] Input handler tests pass
- [ ] Add form tests pass
- [ ] Edit form tests pass

---

### Step 13: Category Management Screens (TDD)

**Phase 1: Write Tests First**

```julia
@testset "Category Screens" begin
    # Similar structure to Project tests
    @testset "Category List Rendering" begin
        state = create_test_state(with_data=true)
        output = render_category_list(state)
        @test contains(string(output), "Categories")
        @test contains(string(output), "Test Category")
    end

    @testset "Category CRUD" begin
        state = create_test_state()
        state.form_fields = Dict(:name => "New Category", :color => "#00FF00")

        save_category_form!(state, :add)
        @test length(list_categories(state.db)) == 1
    end
end
```

**Phase 2: Implement**

Create `src/tui/screens/category_list.jl` and `src/tui/screens/category_form.jl`

**Phase 3: Run Tests**

**Success Criteria:**
- [ ] Category tests pass

---

### Step 14: Delete Confirmation Screen (TDD)

**Phase 1: Write Tests First**

```julia
@testset "Delete Confirmation Screen" begin
    @testset "Rendering" begin
        state = create_test_state(with_data=true)
        state.delete_type = :todo
        state.delete_id = 1
        state.delete_name = "Test Todo"

        output = render_delete_confirm(state)
        output_str = string(output)

        @test contains(output_str, "todo")
        @test contains(output_str, "Test Todo")
        @test contains(output_str, "Yes")
        @test contains(output_str, "Cancel")
    end

    @testset "Confirm Delete" begin
        state = create_test_state(with_data=true)
        state.current_screen = DELETE_CONFIRM
        state.delete_type = :todo
        todo_id = state.todos[1].id
        state.delete_id = todo_id

        initial_count = length(list_todos(state.db))
        handle_delete_confirm_input!(state, 'y')

        @test length(list_todos(state.db)) == initial_count - 1
        @test state.current_screen != DELETE_CONFIRM
        @test state.message_type == :success
    end

    @testset "Cancel Delete" begin
        state = create_test_state(with_data=true)
        state.current_screen = DELETE_CONFIRM
        state.delete_type = :todo
        state.delete_id = state.todos[1].id

        initial_count = length(list_todos(state.db))
        handle_delete_confirm_input!(state, 'n')

        # Nothing deleted
        @test length(list_todos(state.db)) == initial_count
        @test state.current_screen != DELETE_CONFIRM
    end
end
```

**Phase 2: Implement**

Create `src/tui/screens/delete_confirm.jl`

**Phase 3: Run Tests**

**Success Criteria:**
- [ ] Render tests pass
- [ ] Confirm delete tests pass
- [ ] Cancel delete tests pass

---

### Step 15: Render Coordinator and Main Loop (TDD)

**Phase 1: Write Tests First**

Create `test/test_tui_integration.jl`:
```julia
@testset "TUI Integration Tests" begin
    include("tui_test_helpers.jl")

    @testset "Screen Routing" begin
        state = create_test_state(with_data=true)

        # Each screen should render without error
        for screen in instances(Screen)
            state.current_screen = screen
            # Setup any required state for that screen
            if screen in [TODO_DETAIL, TODO_EDIT]
                state.current_todo = state.todos[1]
            end
            if screen in [PROJECT_EDIT]
                state.current_project = list_projects(state.db)[1]
            end
            if screen == DELETE_CONFIRM
                state.delete_type = :todo
                state.delete_id = 1
                state.delete_name = "Test"
            end

            output = render_screen(state)
            @test output isa String
            @test length(output) > 0
        end
    end

    @testset "Input Routing" begin
        state = create_test_state(with_data=true)

        # Main list 'q' quits
        state.current_screen = MAIN_LIST
        handle_input!(state, 'q')
        @test state.running == false
    end

    @testset "Full Workflow - Create Todo" begin
        state = create_test_state()

        # Start at main list
        @test state.current_screen == MAIN_LIST

        # Press 'a' to add
        handle_input!(state, 'a')
        @test state.current_screen == TODO_ADD

        # Fill form and save
        state.form_fields[:title] = "Integration Test Todo"
        handle_input!(state, :enter)  # Assuming Enter saves

        # Back at main list with new todo
        refresh_data!(state)
        @test any(t -> t.title == "Integration Test Todo", state.todos)
    end
end
```

**Phase 2: Implement**

Create `src/tui/render.jl`:
- `render_screen(state)::String`
- `handle_input!(state, key)::Nothing`
- `clear_and_render(output)`

Complete `src/tui/tui.jl`:
- `run_tui(db_path=nothing)` main entry point

**Phase 3: Run Tests**

**Success Criteria:**
- [ ] Screen routing tests pass
- [ ] Input routing tests pass
- [ ] Integration workflow tests pass

---

### Step 16: Final Integration and Manual Testing

**Files to modify:**
- `src/TodoList.jl` - Export `run_tui`
- `test/runtests.jl` - Include all TUI tests

**Phase 1: Update Exports**

```julia
# In src/TodoList.jl
include("tui/tui.jl")
export run_tui
```

**Phase 2: Run Full Test Suite**

```bash
julia --project=. test/runtests.jl
```

All tests must pass.

**Phase 3: Manual Test Checklist**

Execute each item and mark complete:

**Navigation:**
- [ ] Start TUI: `julia --project=. -e 'using TodoList; run_tui()'`
- [ ] j/k moves selection up/down
- [ ] Arrow keys work for navigation
- [ ] Enter selects/views item
- [ ] Escape/b goes back

**Todo CRUD:**
- [ ] 'a' opens add form
- [ ] Fill all fields in add form
- [ ] Tab navigates between fields
- [ ] Enter saves new todo
- [ ] New todo appears in list
- [ ] Enter on todo shows detail view
- [ ] 'e' opens edit form
- [ ] Edit form pre-populated
- [ ] Save updates todo
- [ ] 'c' toggles completion (pending ↔ completed)
- [ ] 'd' shows delete confirmation
- [ ] 'y' deletes, 'n' cancels

**Filters:**
- [ ] 'f' opens filter menu
- [ ] Can filter by status
- [ ] Can filter by project
- [ ] Can filter by category
- [ ] Multiple filters combine (AND)
- [ ] Clear all filters works
- [ ] Filter indicator shows in header

**Projects:**
- [ ] 'p' opens project list
- [ ] Can add project
- [ ] Can edit project
- [ ] Can delete project
- [ ] Todo count shows correctly

**Categories:**
- [ ] 'g' opens category list
- [ ] Can add category
- [ ] Can edit category
- [ ] Can delete category
- [ ] Todo count shows correctly

**Visual:**
- [ ] Status colors correct (pending=yellow, completed=green, etc.)
- [ ] Priority colors correct (HIGH=red, MEDIUM=yellow, LOW=dim)
- [ ] Selected row highlighted
- [ ] Headers bold
- [ ] Success messages green
- [ ] Error messages red

**Error Handling:**
- [ ] Empty title shows validation error
- [ ] Invalid date format shows error
- [ ] Errors display below form fields

**Terminal:**
- [ ] 'q' quits cleanly
- [ ] Ctrl+C quits and restores terminal
- [ ] No terminal corruption after exit
- [ ] Works in Docker

**Success Criteria:**
- [ ] All automated tests pass
- [ ] All manual tests checked off
- [ ] TUI is usable end-to-end

---

## Files Summary

### New Files
```
test/tui_test_helpers.jl           # Test utilities
test/test_tui_state.jl             # State tests
test/test_tui_input.jl             # Input tests
test/test_tui_components.jl        # Component tests
test/test_tui_screens.jl           # Screen tests
test/test_tui_integration.jl       # Integration tests

src/tui/tui.jl                     # Main module
src/tui/state.jl                   # AppState
src/tui/input.jl                   # Keyboard input
src/tui/render.jl                  # Render coordinator
src/tui/components/components.jl   # Component exports
src/tui/components/header.jl
src/tui/components/footer.jl
src/tui/components/message.jl
src/tui/components/table.jl
src/tui/components/form.jl
src/tui/components/dialog.jl
src/tui/screens/screens.jl         # Screen exports
src/tui/screens/main_list.jl
src/tui/screens/todo_detail.jl
src/tui/screens/todo_form.jl
src/tui/screens/filter_menu.jl
src/tui/screens/project_list.jl
src/tui/screens/project_form.jl
src/tui/screens/category_list.jl
src/tui/screens/category_form.jl
src/tui/screens/delete_confirm.jl
```

### Modified Files
```
src/TodoList.jl       # Add TUI include and exports
test/runtests.jl      # Include TUI test files
```

---

## Risks

### Risk 1: Term.jl API Complexity
**Mitigation:** Start with simple Panel and styled text. Incrementally add complexity.

### Risk 2: Raw Terminal Input Cross-Platform Issues
**Mitigation:** Test on Linux (Docker). Have fallback for Windows.

### Risk 3: State Management Complexity
**Mitigation:** TDD ensures state transitions are correct. Keep mutations localized.

### Risk 4: Form Input Handling
**Mitigation:** Start simple. Use TDD to verify each input type works.

### Risk 5: Terminal Restore on Crash
**Mitigation:** Always use try/finally. Test Ctrl+C handling.

---

## Acceptance Criteria

- [ ] All automated tests pass (state, components, screens, integration)
- [ ] All 12 screens from design document implemented
- [ ] Navigation matches keyboard shortcuts in design
- [ ] CRUD operations work for todos, projects, categories
- [ ] Filters work with AND logic
- [ ] Manual test checklist complete
- [ ] Terminal restores properly on exit

---

**Plan Complete**

This plan follows TDD: each step writes tests FIRST, then implements to pass tests. TUI testing best practices are documented and applied throughout.
