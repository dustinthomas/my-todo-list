"""
Filter Menu Screen.

Handles filter selection screens for status, project, and category filters.
"""

# =============================================================================
# Constants
# =============================================================================

"""Number of options in the main filter menu."""
const FILTER_MENU_OPTION_COUNT = 4

"""Number of status filter options (All + 4 statuses)."""
const FILTER_STATUS_OPTION_COUNT = 5

"""Status values in order (first is nothing for "All")."""
const STATUS_OPTIONS = [nothing, "pending", "in_progress", "completed", "blocked"]

"""Keyboard shortcuts for filter screens."""
const FILTER_SHORTCUTS = [
    ("j/k", "Navigate"),
    ("Enter", "Select"),
    ("Esc", "Cancel")
]

# =============================================================================
# Filter Menu Screen
# =============================================================================

"""
    render_filter_menu(state::AppState)::String

Render the main filter menu screen.

# Arguments
- `state::AppState`: Current application state

# Returns
- String containing the complete screen output

# Components
- Header with "Filter Todos"
- Current filter summary
- Filter type options (Status, Project, Category, Clear All)
- Footer with keyboard shortcuts
"""
function render_filter_menu(state::AppState)::String
    lines = String[]

    # Header
    header = render_header("Filter Todos")
    push!(lines, string(header))
    push!(lines, "")

    # Current filter summary
    filter_summary = render_filter_summary(
        state.filter_status,
        state.filter_project_id,
        state.filter_category_id,
        state.projects,
        state.categories
    )
    push!(lines, "{bold}Active Filters:{/bold}")
    push!(lines, filter_summary)
    push!(lines, "")
    push!(lines, "─────────────────────────────────────────")
    push!(lines, "")

    # Menu options
    menu_options = render_filter_menu_options(state.selected_index)
    push!(lines, menu_options)

    # Footer
    push!(lines, "")
    footer = render_footer(FILTER_SHORTCUTS)
    push!(lines, footer)

    return join(lines, "\n")
end

"""
    handle_filter_menu_input!(state::AppState, key)::Nothing

Handle keyboard input on the filter menu screen.

# Arguments
- `state::AppState`: Current application state (modified in place)
- `key`: The key pressed (Char or Symbol)

# Handled Keys
- j/k, ↑/↓: Navigate up/down
- Enter: Select filter type
- Escape/b: Go back
- q: Quit
"""
function handle_filter_menu_input!(state::AppState, key)::Nothing
    # Quit
    if key == KEY_QUIT || key == KEY_CTRL_C
        state.running = false
        return nothing
    end

    # Cancel/Back
    if key == KEY_ESCAPE || key == KEY_BACK
        go_back!(state)
        return nothing
    end

    # Navigation down
    if is_down_key(key)
        if state.selected_index < FILTER_MENU_OPTION_COUNT
            state.selected_index += 1
        end
        return nothing
    end

    # Navigation up
    if is_up_key(key)
        if state.selected_index > 1
            state.selected_index -= 1
        end
        return nothing
    end

    # Select option
    if key == KEY_ENTER
        if state.selected_index == 1
            # Status filter
            state.selected_index = 1  # Reset for status menu
            go_to_screen!(state, FILTER_STATUS)
        elseif state.selected_index == 2
            # Project filter
            state.selected_index = 1  # Reset for project menu
            go_to_screen!(state, FILTER_PROJECT)
        elseif state.selected_index == 3
            # Category filter
            state.selected_index = 1  # Reset for category menu
            go_to_screen!(state, FILTER_CATEGORY)
        elseif state.selected_index == 4
            # Clear all filters
            clear_all_filters!(state)
            refresh_data!(state)
            set_message!(state, "All filters cleared", :success)
            state.current_screen = MAIN_LIST
            state.previous_screen = nothing
        end
        return nothing
    end

    return nothing
end

# =============================================================================
# Filter Status Screen
# =============================================================================

"""
    render_filter_status(state::AppState)::String

Render the status filter selection screen.

# Arguments
- `state::AppState`: Current application state

# Returns
- String containing the complete screen output
"""
function render_filter_status(state::AppState)::String
    lines = String[]

    # Header
    header = render_header("Filter by Status")
    push!(lines, string(header))
    push!(lines, "")

    # Status options
    status_options = render_status_filter_options(state.filter_status, state.selected_index)
    push!(lines, status_options)

    # Footer
    push!(lines, "")
    footer = render_footer(FILTER_SHORTCUTS)
    push!(lines, footer)

    return join(lines, "\n")
end

"""
    handle_filter_status_input!(state::AppState, key)::Nothing

Handle keyboard input on the status filter screen.

# Arguments
- `state::AppState`: Current application state (modified in place)
- `key`: The key pressed (Char or Symbol)
"""
function handle_filter_status_input!(state::AppState, key)::Nothing
    # Quit
    if key == KEY_QUIT || key == KEY_CTRL_C
        state.running = false
        return nothing
    end

    # Cancel - go back to filter menu
    if key == KEY_ESCAPE || key == KEY_BACK
        go_back!(state)
        return nothing
    end

    # Navigation down
    if is_down_key(key)
        if state.selected_index < FILTER_STATUS_OPTION_COUNT
            state.selected_index += 1
        end
        return nothing
    end

    # Navigation up
    if is_up_key(key)
        if state.selected_index > 1
            state.selected_index -= 1
        end
        return nothing
    end

    # Select status
    if key == KEY_ENTER
        # Get the status value based on selection
        # Index 1 = All (nothing), Index 2 = pending, etc.
        state.filter_status = STATUS_OPTIONS[state.selected_index]
        refresh_data!(state)

        # Go back to main list to see results
        state.selected_index = 1
        state.current_screen = MAIN_LIST
        state.previous_screen = nothing
        return nothing
    end

    return nothing
end

# =============================================================================
# Filter Project Screen
# =============================================================================

"""
    render_filter_project(state::AppState)::String

Render the project filter selection screen.

# Arguments
- `state::AppState`: Current application state

# Returns
- String containing the complete screen output
"""
function render_filter_project(state::AppState)::String
    lines = String[]

    # Header
    header = render_header("Filter by Project")
    push!(lines, string(header))
    push!(lines, "")

    # Project options
    project_options = render_project_filter_options(
        state.projects,
        state.filter_project_id,
        state.selected_index
    )
    push!(lines, project_options)

    # Footer
    push!(lines, "")
    footer = render_footer(FILTER_SHORTCUTS)
    push!(lines, footer)

    return join(lines, "\n")
end

"""
    handle_filter_project_input!(state::AppState, key)::Nothing

Handle keyboard input on the project filter screen.

# Arguments
- `state::AppState`: Current application state (modified in place)
- `key`: The key pressed (Char or Symbol)
"""
function handle_filter_project_input!(state::AppState, key)::Nothing
    # Calculate max index (1 for "All" + number of projects)
    max_index = 1 + length(state.projects)

    # Quit
    if key == KEY_QUIT || key == KEY_CTRL_C
        state.running = false
        return nothing
    end

    # Cancel - go back to filter menu
    if key == KEY_ESCAPE || key == KEY_BACK
        go_back!(state)
        return nothing
    end

    # Navigation down
    if is_down_key(key)
        if state.selected_index < max_index
            state.selected_index += 1
        end
        return nothing
    end

    # Navigation up
    if is_up_key(key)
        if state.selected_index > 1
            state.selected_index -= 1
        end
        return nothing
    end

    # Select project
    if key == KEY_ENTER
        if state.selected_index == 1
            # "All" option - clear filter
            state.filter_project_id = nothing
        else
            # Select specific project
            project_index = state.selected_index - 1
            if project_index <= length(state.projects)
                state.filter_project_id = state.projects[project_index].id
            end
        end

        refresh_data!(state)

        # Go back to main list to see results
        state.selected_index = 1
        state.current_screen = MAIN_LIST
        state.previous_screen = nothing
        return nothing
    end

    return nothing
end

# =============================================================================
# Filter Category Screen
# =============================================================================

"""
    render_filter_category(state::AppState)::String

Render the category filter selection screen.

# Arguments
- `state::AppState`: Current application state

# Returns
- String containing the complete screen output
"""
function render_filter_category(state::AppState)::String
    lines = String[]

    # Header
    header = render_header("Filter by Category")
    push!(lines, string(header))
    push!(lines, "")

    # Category options
    category_options = render_category_filter_options(
        state.categories,
        state.filter_category_id,
        state.selected_index
    )
    push!(lines, category_options)

    # Footer
    push!(lines, "")
    footer = render_footer(FILTER_SHORTCUTS)
    push!(lines, footer)

    return join(lines, "\n")
end

"""
    handle_filter_category_input!(state::AppState, key)::Nothing

Handle keyboard input on the category filter screen.

# Arguments
- `state::AppState`: Current application state (modified in place)
- `key`: The key pressed (Char or Symbol)
"""
function handle_filter_category_input!(state::AppState, key)::Nothing
    # Calculate max index (1 for "All" + number of categories)
    max_index = 1 + length(state.categories)

    # Quit
    if key == KEY_QUIT || key == KEY_CTRL_C
        state.running = false
        return nothing
    end

    # Cancel - go back to filter menu
    if key == KEY_ESCAPE || key == KEY_BACK
        go_back!(state)
        return nothing
    end

    # Navigation down
    if is_down_key(key)
        if state.selected_index < max_index
            state.selected_index += 1
        end
        return nothing
    end

    # Navigation up
    if is_up_key(key)
        if state.selected_index > 1
            state.selected_index -= 1
        end
        return nothing
    end

    # Select category
    if key == KEY_ENTER
        if state.selected_index == 1
            # "All" option - clear filter
            state.filter_category_id = nothing
        else
            # Select specific category
            category_index = state.selected_index - 1
            if category_index <= length(state.categories)
                state.filter_category_id = state.categories[category_index].id
            end
        end

        refresh_data!(state)

        # Go back to main list to see results
        state.selected_index = 1
        state.current_screen = MAIN_LIST
        state.previous_screen = nothing
        return nothing
    end

    return nothing
end
