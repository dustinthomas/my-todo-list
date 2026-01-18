"""
Category List Screen.

The category management view showing all categories with their todo counts.
"""

# =============================================================================
# Constants
# =============================================================================

"""Keyboard shortcuts for category list screen."""
const CATEGORY_LIST_SHORTCUTS = [
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
    get_category_todo_counts(state::AppState)::Dict{Int64,Int}

Get the number of todos for each category.

# Arguments
- `state::AppState`: Current application state

# Returns
- Dict mapping category_id => todo count
"""
function get_category_todo_counts(state::AppState)::Dict{Int64,Int}
    counts = Dict{Int64,Int}()

    # Count all todos (not filtered) for each category
    all_todos = list_todos(state.db)
    for todo in all_todos
        if todo.category_id !== nothing
            counts[todo.category_id] = get(counts, todo.category_id, 0) + 1
        end
    end

    return counts
end

# =============================================================================
# Render Function
# =============================================================================

"""
    render_category_list(state::AppState)::String

Render the category list screen with header, category table, and footer.

# Arguments
- `state::AppState`: Current application state

# Returns
- String containing the complete screen output

# Components
- Header with title
- Message (if any)
- Category table with selection and todo counts
- Footer with keyboard shortcuts
"""
function render_category_list(state::AppState)::String
    lines = String[]

    # Header
    count = length(state.categories)
    item_word = count == 1 ? "category" : "categories"
    subtitle = "[$count $item_word]"
    header = render_header("Categories", subtitle=subtitle)
    push!(lines, string(header))

    # Message (if any)
    if state.message !== nothing && state.message_type !== nothing
        message = render_message(state.message, state.message_type)
        push!(lines, string(message))
    end

    # Category table
    todo_counts = get_category_todo_counts(state)
    table = render_category_table(
        state.categories,
        state.selected_index,
        todo_counts
    )
    push!(lines, table)

    # Footer
    footer = render_footer(CATEGORY_LIST_SHORTCUTS)
    push!(lines, "")
    push!(lines, footer)

    return join(lines, "\n")
end

# =============================================================================
# Input Handler
# =============================================================================

"""
    handle_category_list_input!(state::AppState, key)::Nothing

Handle keyboard input on the category list screen.

# Arguments
- `state::AppState`: Current application state (modified in place)
- `key`: The key pressed (Char or Symbol)

# Handled Keys
- j/k, ↑/↓: Navigate up/down
- Enter: View todos filtered by selected category
- a: Add new category
- e: Edit selected category
- d: Delete selected category
- b, Escape: Go back to main list
- q: Quit
"""
function handle_category_list_input!(state::AppState, key)::Nothing
    # Clear message on any input (before processing)
    if key != KEY_QUIT && key != KEY_CTRL_C
        clear_message!(state)
    end

    # Navigation - Down
    if is_down_key(key)
        if !isempty(state.categories) && state.selected_index < length(state.categories)
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

    # Add category
    if key == KEY_ADD
        reset_form!(state)
        state.form_fields[:name] = ""
        state.form_fields[:color] = ""
        go_to_screen!(state, CATEGORY_ADD)
        return nothing
    end

    # View todos filtered by category (Enter)
    if key == KEY_ENTER
        if !isempty(state.categories)
            category = state.categories[state.selected_index]
            state.filter_category_id = category.id
            state.selected_index = 1
            state.scroll_offset = 0
            refresh_data!(state)
            go_to_screen!(state, MAIN_LIST)
        end
        return nothing
    end

    # Edit category
    if key == KEY_EDIT
        if !isempty(state.categories)
            state.current_category = state.categories[state.selected_index]
            reset_form!(state)
            # Initialize form fields from category
            category = state.current_category
            state.form_fields[:name] = category.name
            state.form_fields[:color] = category.color !== nothing ? category.color : ""
            go_to_screen!(state, CATEGORY_EDIT)
        end
        return nothing
    end

    # Delete category
    if key == KEY_DELETE
        if !isempty(state.categories)
            category = state.categories[state.selected_index]
            setup_delete!(state, :category, category.id, category.name)
            go_to_screen!(state, DELETE_CONFIRM)
        end
        return nothing
    end

    # Unhandled key - do nothing
    return nothing
end
