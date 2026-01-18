"""
Main List Screen.

The primary view showing the todo list with filtering and navigation.
"""

# =============================================================================
# Constants
# =============================================================================

"""Visible rows for todo table (excluding header/footer)."""
const MAIN_LIST_VISIBLE_ROWS = 15

"""Keyboard shortcuts for main list screen."""
const MAIN_LIST_SHORTCUTS = [
    ("j/k", "Navigate"),
    ("Enter", "View"),
    ("a", "Add"),
    ("e", "Edit"),
    ("c", "Complete"),
    ("d", "Delete"),
    ("f", "Filter"),
    ("p", "Projects"),
    ("g", "Categories"),
    ("q", "Quit")
]

# =============================================================================
# Helper Functions
# =============================================================================

"""
    build_main_list_shortcuts()::Vector{Tuple{String,String}}

Get the list of keyboard shortcuts for the main list screen.
"""
build_main_list_shortcuts()::Vector{Tuple{String,String}} = MAIN_LIST_SHORTCUTS

"""
    find_entity_name(entities, id)::String

Find entity name by ID, returns "Unknown" if not found.
"""
function find_entity_name(entities, id)::String
    for entity in entities
        if entity.id == id
            return entity.name
        end
    end
    return "Unknown"
end

"""
    build_filter_subtitle(state::AppState)::String

Build the subtitle string showing active filters and item count.

# Arguments
- `state::AppState`: Current application state

# Returns
- String with filter info and item count
"""
function build_filter_subtitle(state::AppState)::String
    parts = String[]

    # Filter info
    filters = String[]
    if state.filter_status !== nothing
        push!(filters, "Status: $(state.filter_status)")
    end
    if state.filter_project_id !== nothing
        project_name = find_entity_name(state.projects, state.filter_project_id)
        push!(filters, "Project: $project_name")
    end
    if state.filter_category_id !== nothing
        category_name = find_entity_name(state.categories, state.filter_category_id)
        push!(filters, "Category: $category_name")
    end

    if !isempty(filters)
        push!(parts, "[Filter: $(join(filters, ", "))]")
    end

    # Item count
    count = length(state.todos)
    item_word = count == 1 ? "item" : "items"
    push!(parts, "[$count $item_word]")

    return join(parts, " ")
end

# =============================================================================
# Render Function
# =============================================================================

"""
    render_main_list(state::AppState)::String

Render the main list screen with header, todo table, and footer.

# Arguments
- `state::AppState`: Current application state

# Returns
- String containing the complete screen output

# Components
- Header with title and filter/count info
- Message (if any)
- Todo table with selection
- Footer with keyboard shortcuts
"""
function render_main_list(state::AppState)::String
    lines = String[]

    # Header
    subtitle = build_filter_subtitle(state)
    header = render_header("Todo List", subtitle=subtitle)
    push!(lines, string(header))

    # Message (if any)
    if state.message !== nothing && state.message_type !== nothing
        message = render_message(state.message, state.message_type)
        push!(lines, string(message))
    end

    # Todo table
    table = render_todo_table(
        state.todos,
        state.selected_index,
        state.scroll_offset,
        MAIN_LIST_VISIBLE_ROWS
    )
    push!(lines, table)

    # Footer
    shortcuts = build_main_list_shortcuts()
    footer = render_footer(shortcuts)
    push!(lines, "")
    push!(lines, footer)

    return join(lines, "\n")
end

# =============================================================================
# Input Handler
# =============================================================================

"""
    handle_main_list_input!(state::AppState, key)::Nothing

Handle keyboard input on the main list screen.

# Arguments
- `state::AppState`: Current application state (modified in place)
- `key`: The key pressed (Char or Symbol)

# Handled Keys
- j/k, ↑/↓: Navigate up/down
- Enter: View selected todo
- a: Add new todo
- e: Edit selected todo
- c: Toggle completion
- d: Delete selected todo
- f: Open filter menu
- p: Open projects
- g: Open categories
- q: Quit
"""
function handle_main_list_input!(state::AppState, key)::Nothing
    # Clear message on any input (before processing)
    if key != KEY_QUIT && key != KEY_CTRL_C
        clear_message!(state)
    end

    # Navigation
    if is_down_key(key)
        if !isempty(state.todos) && state.selected_index < length(state.todos)
            state.selected_index += 1
            # Adjust scroll if needed
            if state.selected_index > state.scroll_offset + MAIN_LIST_VISIBLE_ROWS
                state.scroll_offset += 1
            end
        end
        return nothing
    end

    if is_up_key(key)
        if state.selected_index > 1
            state.selected_index -= 1
            # Adjust scroll if needed
            if state.selected_index <= state.scroll_offset
                state.scroll_offset = max(0, state.scroll_offset - 1)
            end
        end
        return nothing
    end

    # Quit
    if key == KEY_QUIT || key == KEY_CTRL_C
        state.running = false
        return nothing
    end

    # Add todo
    if key == KEY_ADD
        reset_form!(state)
        # Initialize form fields for new todo
        state.form_fields[:title] = ""
        state.form_fields[:description] = ""
        state.form_fields[:status] = "pending"
        state.form_fields[:priority] = "2"
        state.form_fields[:start_date] = ""
        state.form_fields[:due_date] = ""
        state.form_fields[:project_id] = ""
        state.form_fields[:category_id] = ""
        go_to_screen!(state, TODO_ADD)
        return nothing
    end

    # View detail (Enter)
    if key == KEY_ENTER
        if !isempty(state.todos)
            state.current_todo = state.todos[state.selected_index]
            go_to_screen!(state, TODO_DETAIL)
        end
        return nothing
    end

    # Edit todo
    if key == KEY_EDIT
        if !isempty(state.todos)
            state.current_todo = state.todos[state.selected_index]
            reset_form!(state)
            # Initialize form fields from todo
            todo = state.current_todo
            state.form_fields[:title] = todo.title
            state.form_fields[:description] = todo.description !== nothing ? todo.description : ""
            state.form_fields[:status] = todo.status
            state.form_fields[:priority] = string(todo.priority)
            state.form_fields[:start_date] = todo.start_date !== nothing ? todo.start_date : ""
            state.form_fields[:due_date] = todo.due_date !== nothing ? todo.due_date : ""
            state.form_fields[:project_id] = todo.project_id !== nothing ? string(todo.project_id) : ""
            state.form_fields[:category_id] = todo.category_id !== nothing ? string(todo.category_id) : ""
            go_to_screen!(state, TODO_EDIT)
        end
        return nothing
    end

    # Delete todo
    if key == KEY_DELETE
        if !isempty(state.todos)
            todo = state.todos[state.selected_index]
            setup_delete!(state, :todo, todo.id, todo.title)
            go_to_screen!(state, DELETE_CONFIRM)
        end
        return nothing
    end

    # Toggle completion
    if key == KEY_COMPLETE
        if !isempty(state.todos)
            todo = state.todos[state.selected_index]
            new_status = todo.status == "completed" ? "pending" : "completed"
            update_todo!(state.db, todo.id; status=new_status)
            refresh_data!(state)
            set_message!(state, "Todo marked as $new_status", :success)
        end
        return nothing
    end

    # Filter menu
    if key == KEY_FILTER
        state.selected_index = 1  # Reset selection for filter menu
        go_to_screen!(state, FILTER_MENU)
        return nothing
    end

    # Projects
    if key == KEY_PROJECTS
        state.selected_index = 1  # Reset selection for project list
        go_to_screen!(state, PROJECT_LIST)
        return nothing
    end

    # Categories
    if key == KEY_CATEGORIES
        state.selected_index = 1  # Reset selection for category list
        go_to_screen!(state, CATEGORY_LIST)
        return nothing
    end

    # Unhandled key - do nothing
    return nothing
end
