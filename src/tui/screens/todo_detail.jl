"""
Todo Detail Screen.

Shows a single todo's details with options to edit or delete.
"""

# =============================================================================
# Constants
# =============================================================================

"""Keyboard shortcuts for todo detail screen."""
const TODO_DETAIL_SHORTCUTS = [
    ("b/Esc", "Back"),
    ("e", "Edit"),
    ("d", "Delete"),
    ("c", "Complete"),
    ("q", "Quit")
]

# =============================================================================
# Helper Functions
# =============================================================================

"""
    format_detail_value(value)::String

Format a value for display in detail view.
Returns "(none)" for nothing/empty values.
"""
function format_detail_value(value)::String
    if value === nothing || (value isa String && isempty(value))
        return "{dim}(none){/dim}"
    else
        return string(value)
    end
end

"""
    format_detail_priority(priority::Int)::String

Format priority for detail display with color.
"""
function format_detail_priority(priority::Int)::String
    if priority == 1
        return "{red bold}HIGH{/red bold}"
    elseif priority == 2
        return "{yellow}MEDIUM{/yellow}"
    else
        return "{dim}LOW{/dim}"
    end
end

"""
    format_detail_status(status::String)::String

Format status for detail display with color.
"""
function format_detail_status(status::String)::String
    if status == "completed"
        return "{green bold}completed{/green bold}"
    elseif status == "in_progress"
        return "{blue}in_progress{/blue}"
    elseif status == "blocked"
        return "{red}blocked{/red}"
    else  # pending
        return "{yellow}pending{/yellow}"
    end
end

# =============================================================================
# Render Function
# =============================================================================

"""
    render_todo_detail(state::AppState)::String

Render the todo detail screen.

# Arguments
- `state::AppState`: Current application state (must have current_todo set)

# Returns
- String containing the complete screen output

# Components
- Header with "Todo Detail" title
- Todo fields in a formatted layout
- Footer with keyboard shortcuts
"""
function render_todo_detail(state::AppState)::String
    lines = String[]
    todo = state.current_todo

    # Header
    header = render_header("Todo Detail")
    push!(lines, string(header))
    push!(lines, "")

    # Message (if any)
    if state.message !== nothing && state.message_type !== nothing
        message = render_message(state.message, state.message_type)
        push!(lines, string(message))
        push!(lines, "")
    end

    # Title section
    push!(lines, "{bold}Title:{/bold}")
    push!(lines, "  $(todo.title)")
    push!(lines, "")

    # Status and Priority on same section
    push!(lines, "{bold}Status:{/bold} $(format_detail_status(todo.status))")
    push!(lines, "{bold}Priority:{/bold} $(format_detail_priority(todo.priority))")
    push!(lines, "")

    # Description
    push!(lines, "{bold}Description:{/bold}")
    if todo.description !== nothing && !isempty(todo.description)
        push!(lines, "  $(todo.description)")
    else
        push!(lines, "  {dim}(none){/dim}")
    end
    push!(lines, "")

    # Project and Category
    project_name = if todo.project_id !== nothing
        find_entity_name(state.projects, todo.project_id)
    else
        nothing
    end
    category_name = if todo.category_id !== nothing
        find_entity_name(state.categories, todo.category_id)
    else
        nothing
    end

    push!(lines, "{bold}Project:{/bold} $(format_detail_value(project_name))")
    push!(lines, "{bold}Category:{/bold} $(format_detail_value(category_name))")
    push!(lines, "")

    # Dates
    push!(lines, "{bold}Start Date:{/bold} $(format_detail_value(todo.start_date))")
    push!(lines, "{bold}Due Date:{/bold} $(format_detail_value(todo.due_date))")
    push!(lines, "")

    # Completed at (if completed)
    if todo.completed_at !== nothing
        push!(lines, "{bold}Completed At:{/bold} $(todo.completed_at)")
        push!(lines, "")
    end

    # Timestamps
    push!(lines, "{dim}Created: $(format_detail_value(todo.created_at)){/dim}")
    push!(lines, "{dim}Updated: $(format_detail_value(todo.updated_at)){/dim}")

    # Footer
    footer = render_footer(TODO_DETAIL_SHORTCUTS)
    push!(lines, "")
    push!(lines, footer)

    return join(lines, "\n")
end

# =============================================================================
# Input Handler
# =============================================================================

"""
    handle_todo_detail_input!(state::AppState, key)::Nothing

Handle keyboard input on the todo detail screen.

# Arguments
- `state::AppState`: Current application state (modified in place)
- `key`: The key pressed (Char or Symbol)

# Handled Keys
- b, Escape: Go back to previous screen
- e: Edit the todo
- d: Delete the todo (confirmation)
- c: Toggle completion
- q: Quit
"""
function handle_todo_detail_input!(state::AppState, key)::Nothing
    # Clear message on any input (before processing)
    if key != KEY_QUIT && key != KEY_CTRL_C
        clear_message!(state)
    end

    # Back navigation
    if key == KEY_BACK || key == KEY_ESCAPE
        go_back!(state)
        return nothing
    end

    # Quit
    if key == KEY_QUIT || key == KEY_CTRL_C
        state.running = false
        return nothing
    end

    # Edit todo
    if key == KEY_EDIT
        reset_form!(state)
        init_form_from_todo!(state, state.current_todo)
        go_to_screen!(state, TODO_EDIT)
        return nothing
    end

    # Delete todo
    if key == KEY_DELETE
        setup_delete!(state, :todo, state.current_todo.id, state.current_todo.title)
        go_to_screen!(state, DELETE_CONFIRM)
        return nothing
    end

    # Toggle completion
    if key == KEY_COMPLETE
        todo = state.current_todo
        new_status = todo.status == "completed" ? "pending" : "completed"
        update_todo!(state.db, todo.id; status=new_status)
        refresh_data!(state)
        # Update current_todo reference
        state.current_todo = get_todo(state.db, todo.id)
        set_message!(state, "Todo marked as $new_status", :success)
        return nothing
    end

    # Unhandled key - do nothing
    return nothing
end
