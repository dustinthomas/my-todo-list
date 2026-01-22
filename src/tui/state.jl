"""
TUI State Management.

This module defines the application state for the TUI, including:
- Screen enum for navigation
- AppState struct for all UI state
- State transition functions
- Data refresh functions
"""

using SQLite

"""
Screen enum representing all TUI screens.

Screens:
- MAIN_LIST: Primary todo list view
- TODO_DETAIL: Single todo detail view
- TODO_ADD: Add new todo form
- TODO_EDIT: Edit existing todo form
- FILTER_MENU: Filter options menu
- FILTER_STATUS: Status filter selection
- FILTER_PROJECT: Project filter selection
- FILTER_CATEGORY: Category filter selection
- PROJECT_LIST: Project management list
- PROJECT_ADD: Add new project form
- PROJECT_EDIT: Edit project form
- CATEGORY_LIST: Category management list
- CATEGORY_ADD: Add new category form
- CATEGORY_EDIT: Edit category form
- DELETE_CONFIRM: Delete confirmation dialog
"""
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

"""
    AppState

Mutable struct holding all TUI application state.

# Fields
## Navigation
- `current_screen::Screen`: Currently displayed screen
- `previous_screen::Union{Screen, Nothing}`: Previous screen for back navigation

## Selection
- `selected_index::Int`: Currently selected item index (1-based)
- `scroll_offset::Int`: Scroll offset for long lists

## Data
- `todos::Vector{Todo}`: List of todos (filtered if filters active)
- `projects::Vector{Project}`: List of all projects
- `categories::Vector{Category}`: List of all categories

## Current Item
- `current_todo::Union{Todo, Nothing}`: Todo being viewed/edited
- `current_project::Union{Project, Nothing}`: Project being viewed/edited
- `current_category::Union{Category, Nothing}`: Category being viewed/edited

## Delete State
- `delete_type::Union{Symbol, Nothing}`: Type of item to delete (:todo, :project, :category)
- `delete_id::Union{Int64, Nothing}`: ID of item to delete
- `delete_name::String`: Name of item to delete (for display)

## Filters
- `filter_status::Union{String, Nothing}`: Status filter value
- `filter_project_id::Union{Int64, Nothing}`: Project filter value
- `filter_category_id::Union{Int64, Nothing}`: Category filter value

## Form State
- `form_fields::Dict{Symbol, String}`: Current form field values
- `form_field_index::Int`: Currently focused form field
- `form_errors::Dict{Symbol, String}`: Form validation errors

## Messages
- `message::Union{String, Nothing}`: Current message to display
- `message_type::Union{Symbol, Nothing}`: Message type (:success, :error)

## Database
- `db::SQLite.DB`: Database connection

## Control
- `running::Bool`: Whether the TUI is running

## Per-Screen State
- `screen_state::Dict{Screen, Any}`: Screen-specific state storage
"""
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
    delete_type::Union{Symbol, Nothing}
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
    message_type::Union{Symbol, Nothing}

    # Database connection
    db::SQLite.DB

    # Running flag
    running::Bool

    # Per-screen state storage (extensibility)
    screen_state::Dict{Screen, Any}
end

"""
    create_initial_state(db::SQLite.DB)::AppState

Create a new AppState with default values and load initial data.

# Arguments
- `db::SQLite.DB`: Database connection

# Returns
- `AppState`: Initialized application state

# Example
```julia
db = connect_database(":memory:")
init_schema!(db)
state = create_initial_state(db)
```
"""
function create_initial_state(db::SQLite.DB)::AppState
    state = AppState(
        # Navigation
        MAIN_LIST,          # current_screen
        nothing,            # previous_screen

        # Selection
        1,                  # selected_index
        0,                  # scroll_offset

        # Data (will be populated by refresh)
        Todo[],             # todos
        Project[],          # projects
        Category[],         # categories

        # Current items
        nothing,            # current_todo
        nothing,            # current_project
        nothing,            # current_category

        # Delete state
        nothing,            # delete_type
        nothing,            # delete_id
        "",                 # delete_name

        # Filters
        nothing,            # filter_status
        nothing,            # filter_project_id
        nothing,            # filter_category_id

        # Form state
        Dict{Symbol, String}(),    # form_fields
        1,                         # form_field_index
        Dict{Symbol, String}(),    # form_errors

        # Messages
        nothing,            # message
        nothing,            # message_type

        # Database
        db,                 # db

        # Running
        true,               # running

        # Per-screen state
        Dict{Screen, Any}() # screen_state
    )

    # Load initial data
    refresh_data!(state)

    return state
end

"""
    go_to_screen!(state::AppState, screen::Screen)::Nothing

Navigate to a new screen, saving the current screen as previous.

# Arguments
- `state::AppState`: Application state
- `screen::Screen`: Target screen

# Example
```julia
go_to_screen!(state, TODO_ADD)  # Navigate to add todo form
```
"""
function go_to_screen!(state::AppState, screen::Screen)::Nothing
    state.previous_screen = state.current_screen
    state.current_screen = screen
    return nothing
end

"""
    go_back!(state::AppState)::Nothing

Navigate back to the previous screen.

If there is no previous screen, stays on current screen.

# Arguments
- `state::AppState`: Application state
"""
function go_back!(state::AppState)::Nothing
    if state.previous_screen !== nothing
        state.current_screen = state.previous_screen
        state.previous_screen = nothing
    end
    return nothing
end

"""
    refresh_data!(state::AppState)::Nothing

Reload data from database, applying any active filters.

Updates `todos`, `projects`, and `categories` in state.
Ensures `selected_index` is within bounds after refresh.

# Arguments
- `state::AppState`: Application state
"""
function refresh_data!(state::AppState)::Nothing
    # Load projects and categories (always all)
    state.projects = list_projects(state.db)
    state.categories = list_categories(state.db)

    # Load todos with filters
    state.todos = filter_todos(
        state.db;
        status=state.filter_status,
        project_id=state.filter_project_id,
        category_id=state.filter_category_id
    )

    # Ensure selected_index is within bounds
    if length(state.todos) == 0
        state.selected_index = 1
    elseif state.selected_index > length(state.todos)
        state.selected_index = length(state.todos)
    end

    return nothing
end

"""
    reset_form!(state::AppState)::Nothing

Clear all form state (fields, index, errors).

# Arguments
- `state::AppState`: Application state
"""
function reset_form!(state::AppState)::Nothing
    empty!(state.form_fields)
    state.form_field_index = 1
    empty!(state.form_errors)
    return nothing
end

"""
    set_message!(state::AppState, message::String, type::Symbol)::Nothing

Set a message to display to the user.

# Arguments
- `state::AppState`: Application state
- `message::String`: Message text
- `type::Symbol`: Message type (:success or :error)
"""
function set_message!(state::AppState, message::String, type::Symbol)::Nothing
    state.message = message
    state.message_type = type
    return nothing
end

"""
    clear_message!(state::AppState)::Nothing

Clear the current message.

# Arguments
- `state::AppState`: Application state
"""
function clear_message!(state::AppState)::Nothing
    state.message = nothing
    state.message_type = nothing
    return nothing
end

"""
    setup_delete!(state::AppState, type::Symbol, id::Int64, name::String)::Nothing

Setup delete confirmation state.

# Arguments
- `state::AppState`: Application state
- `type::Symbol`: Type of item to delete (:todo, :project, :category)
- `id::Int64`: ID of item to delete
- `name::String`: Display name of item
"""
function setup_delete!(state::AppState, type::Symbol, id::Int64, name::String)::Nothing
    state.delete_type = type
    state.delete_id = id
    state.delete_name = name
    return nothing
end

"""
    clear_delete!(state::AppState)::Nothing

Clear delete confirmation state.

# Arguments
- `state::AppState`: Application state
"""
function clear_delete!(state::AppState)::Nothing
    state.delete_type = nothing
    state.delete_id = nothing
    state.delete_name = ""
    return nothing
end

"""
    clear_all_filters!(state::AppState)::Nothing

Clear all active filters (status, project, category).

# Arguments
- `state::AppState`: Application state

# Side Effects
- Sets filter_status to nothing
- Sets filter_project_id to nothing
- Sets filter_category_id to nothing
"""
function clear_all_filters!(state::AppState)::Nothing
    state.filter_status = nothing
    state.filter_project_id = nothing
    state.filter_category_id = nothing
    return nothing
end
