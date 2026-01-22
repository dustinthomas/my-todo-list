# Code Index

> **For Claude:** Read this file to quickly navigate the codebase.

**Last updated:** 2026-01-22
**Total:** ~6,300 source lines, ~4,900 test lines

---

## Quick Navigation

| Purpose | File | Key Function |
|---------|------|--------------|
| Entry point | `src/TodoList.jl` | Module definition |
| TUI start | `src/tui/tui.jl` | `run_tui()` |
| All exports | `src/TodoList.jl:20-151` | Export statements |
| Tests | `test/runtests.jl` | Test suite entry |

---

## Module Structure

```
src/TodoList.jl (151 lines) - Module entry, exports
├── models.jl (82) - Project, Category, Todo structs
├── database.jl (238) - connect_database(), init_schema!()
├── queries.jl (1227) - All CRUD operations
└── tui/
    ├── tui.jl (232) - run_tui(), main loop
    ├── state.jl (392) - Screen enum, AppState
    ├── screen_state.jl (169) - Per-screen state
    ├── input.jl (387) - Key constants, read_key()
    ├── render.jl (178) - render_screen(), handle_input!()
    ├── components/ (948 total)
    │   ├── header.jl (48) - render_header()
    │   ├── footer.jl (46) - render_footer()
    │   ├── message.jl (74) - render_message()
    │   ├── table.jl (300) - render_todo_table(), render_project_table()
    │   ├── form.jl (459) - render_text_field(), render_form_panel()
    │   └── dialog.jl (342) - render_delete_dialog(), render_filter_summary()
    └── screens/ (2698 total)
        ├── main_list.jl (296) - render_main_list(), handle_main_list_input!()
        ├── todo_detail.jl (231) - render_todo_detail()
        ├── todo_form.jl (494) - render_todo_form(), validate_todo_form!()
        ├── filter_menu.jl (452) - render_filter_menu(), 4 filter screens
        ├── project_list.jl (211) - render_project_list()
        ├── project_form.jl (323) - render_project_form()
        ├── category_list.jl (209) - render_category_list()
        ├── category_form.jl (315) - render_category_form()
        └── delete_confirm.jl (167) - render_delete_confirm()
```

---

## Data Layer

### Models (`src/models.jl`)
```julia
struct Project   # id, name, description, color, created_at, updated_at
struct Category  # id, name, color, created_at
struct Todo      # id, title, description, status, priority, project_id, category_id, dates...
```

### Database (`src/database.jl`)
- `connect_database(path)` - Open SQLite connection
- `init_schema!(db)` - Create tables
- `get_database_path()` - Default: ~/.todo-list/todos.db

### Queries (`src/queries.jl`) - 1227 lines
| Entity | Create | Get | List | Update | Delete |
|--------|--------|-----|------|--------|--------|
| Project | `create_project()` | `get_project()` | `list_projects()` | `update_project!()` | `delete_project!()` |
| Category | `create_category()` | `get_category()` | `list_categories()` | `update_category!()` | `delete_category!()` |
| Todo | `create_todo()` | `get_todo()` | `list_todos()` | `update_todo!()` | `delete_todo!()` |

**Filters:** `filter_todos_by_status()`, `filter_todos_by_project()`, `filter_todos_by_category()`, `filter_todos_by_date_range()`, `filter_todos()`

---

## TUI Architecture

### State (`src/tui/state.jl`)
```julia
@enum Screen  # 15 screens: MAIN_LIST, TODO_DETAIL, TODO_ADD, TODO_EDIT, etc.

mutable struct AppState
    db, screen, previous_screens, todos, projects, categories,
    selected_index, filters, form_data, delete_target, message, running
end
```

**Key functions:** `go_to_screen!()`, `go_back!()`, `refresh_data!()`, `set_filter!()`

### Input (`src/tui/input.jl`)
**Key constants:** `KEY_QUIT`, `KEY_ADD`, `KEY_EDIT`, `KEY_DELETE`, `KEY_ENTER`, `KEY_ESCAPE`, `KEY_UP`, `KEY_DOWN`

**Helpers:** `is_quit_key()`, `is_confirm_key()`, `is_navigation_key()`, `read_key()`

### Render Flow (`src/tui/render.jl`)
```
render_screen(state) → dispatches to screen-specific render function
handle_input!(state, key) → dispatches to screen-specific handler
```

### Screen Pattern
Each screen has:
- `render_SCREEN(state)` → Returns String (Term.jl panels joined with \n)
- `handle_SCREEN_input!(state, key)` → Modifies state based on key

---

## Tests

```
test/runtests.jl (18) - Entry point
├── test_database.jl (155) - Schema, connections
├── test_queries.jl (840) - CRUD operations
├── test_tui_state.jl (222) - State transitions
├── test_tui_input.jl (155) - Key helpers
├── test_tui_components.jl (640) - Component rendering
├── test_tui_screens.jl (2034) - Screen render + input
├── test_tui_integration.jl (654) - End-to-end workflows
├── test_screen_state.jl (105) - Per-screen state
└── tui_test_helpers.jl (79) - Shared utilities
```

---

## Patterns

### Rendering
- All output uses Term.jl (Panel, Table)
- `fit=true` for headers, `box=:HEAVY` for forms
- Vertical composition: `join([...], "\n")`

### State Mutation
- Functions ending with `!` modify state
- `AppState` is mutable, passed by reference
- Screen state stored separately in `screen_state.jl`

### Testing
- In-memory SQLite (`:memory:`)
- Type check + content verification: `@test output isa Panel && contains(string(output), "expected")`

---

## Search Shortcuts

```bash
# Find a function definition
grep -n "function FUNCNAME" src/**/*.jl

# Find all exports
grep "^export" src/TodoList.jl

# Find screen handlers
grep -n "handle_.*_input!" src/tui/screens/*.jl

# Find render functions
grep -n "function render_" src/tui/**/*.jl
```
