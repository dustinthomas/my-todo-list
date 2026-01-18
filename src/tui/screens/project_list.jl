"""
Project List Screen.

The project management view showing all projects with their todo counts.
"""

# =============================================================================
# Constants
# =============================================================================

"""Keyboard shortcuts for project list screen."""
const PROJECT_LIST_SHORTCUTS = [
    ("j/k", "Navigate"),
    ("Enter", "View Todos"),
    ("a", "Add"),
    ("e", "Edit"),
    ("d", "Delete"),
    ("b/Esc", "Back"),
    ("q", "Quit")
]

# =============================================================================
# Helper Functions
# =============================================================================

"""
    get_project_todo_counts(state::AppState)::Dict{Int64,Int}

Get the number of todos for each project.

# Arguments
- `state::AppState`: Current application state

# Returns
- Dict mapping project_id => todo count
"""
function get_project_todo_counts(state::AppState)::Dict{Int64,Int}
    counts = Dict{Int64,Int}()

    # Count all todos (not filtered) for each project
    all_todos = list_todos(state.db)
    for todo in all_todos
        if todo.project_id !== nothing
            counts[todo.project_id] = get(counts, todo.project_id, 0) + 1
        end
    end

    return counts
end

# =============================================================================
# Render Function
# =============================================================================

"""
    render_project_list(state::AppState)::String

Render the project list screen with header, project table, and footer.

# Arguments
- `state::AppState`: Current application state

# Returns
- String containing the complete screen output

# Components
- Header with title
- Message (if any)
- Project table with selection and todo counts
- Footer with keyboard shortcuts
"""
function render_project_list(state::AppState)::String
    lines = String[]

    # Header
    count = length(state.projects)
    item_word = count == 1 ? "project" : "projects"
    subtitle = "[$count $item_word]"
    header = render_header("Projects", subtitle=subtitle)
    push!(lines, string(header))

    # Message (if any)
    if state.message !== nothing && state.message_type !== nothing
        message = render_message(state.message, state.message_type)
        push!(lines, string(message))
    end

    # Project table
    todo_counts = get_project_todo_counts(state)
    table = render_project_table(
        state.projects,
        state.selected_index,
        todo_counts
    )
    push!(lines, table)

    # Footer
    footer = render_footer(PROJECT_LIST_SHORTCUTS)
    push!(lines, "")
    push!(lines, footer)

    return join(lines, "\n")
end

# =============================================================================
# Input Handler
# =============================================================================

"""
    handle_project_list_input!(state::AppState, key)::Nothing

Handle keyboard input on the project list screen.

# Arguments
- `state::AppState`: Current application state (modified in place)
- `key`: The key pressed (Char or Symbol)

# Handled Keys
- j/k, ↑/↓: Navigate up/down
- Enter: View todos filtered by selected project
- a: Add new project
- e: Edit selected project
- d: Delete selected project
- b, Escape: Go back to main list
- q: Quit
"""
function handle_project_list_input!(state::AppState, key)::Nothing
    # Clear message on any input (before processing)
    if key != KEY_QUIT && key != KEY_CTRL_C
        clear_message!(state)
    end

    # Navigation - Down
    if is_down_key(key)
        if !isempty(state.projects) && state.selected_index < length(state.projects)
            state.selected_index += 1
        end
        return nothing
    end

    # Navigation - Up
    if is_up_key(key)
        if state.selected_index > 1
            state.selected_index -= 1
        end
        return nothing
    end

    # Quit
    if key == KEY_QUIT || key == KEY_CTRL_C
        state.running = false
        return nothing
    end

    # Back to main list
    if key == KEY_BACK || key == KEY_ESCAPE
        go_back!(state)
        return nothing
    end

    # Add project
    if key == KEY_ADD
        reset_form!(state)
        state.form_fields[:name] = ""
        state.form_fields[:description] = ""
        state.form_fields[:color] = ""
        go_to_screen!(state, PROJECT_ADD)
        return nothing
    end

    # View todos filtered by project (Enter)
    if key == KEY_ENTER
        if !isempty(state.projects)
            project = state.projects[state.selected_index]
            state.filter_project_id = project.id
            state.selected_index = 1
            state.scroll_offset = 0
            refresh_data!(state)
            go_to_screen!(state, MAIN_LIST)
        end
        return nothing
    end

    # Edit project
    if key == KEY_EDIT
        if !isempty(state.projects)
            state.current_project = state.projects[state.selected_index]
            reset_form!(state)
            # Initialize form fields from project
            project = state.current_project
            state.form_fields[:name] = project.name
            state.form_fields[:description] = project.description !== nothing ? project.description : ""
            state.form_fields[:color] = project.color !== nothing ? project.color : ""
            go_to_screen!(state, PROJECT_EDIT)
        end
        return nothing
    end

    # Delete project
    if key == KEY_DELETE
        if !isempty(state.projects)
            project = state.projects[state.selected_index]
            setup_delete!(state, :project, project.id, project.name)
            go_to_screen!(state, DELETE_CONFIRM)
        end
        return nothing
    end

    # Unhandled key - do nothing
    return nothing
end
