"""
Delete Confirmation Screen.

Displays a confirmation dialog before deleting todos, projects, or categories.
"""

# =============================================================================
# Constants
# =============================================================================

"""Keyboard shortcuts for delete confirmation screen."""
const DELETE_CONFIRM_SHORTCUTS = [
    ("y", "Yes, Delete"),
    ("n", "No, Cancel")
]

# =============================================================================
# Render Function
# =============================================================================

"""
    render_delete_confirm(state::AppState)::String

Render the delete confirmation screen.

# Arguments
- `state::AppState`: Current application state (uses delete_type, delete_name)

# Returns
- `String`: Rendered confirmation dialog

# Example
```julia
state.delete_type = :todo
state.delete_name = "Buy groceries"
output = render_delete_confirm(state)
```
"""
function render_delete_confirm(state::AppState)::String
    lines = String[]

    # Header
    header = render_header("Delete Confirmation")
    push!(lines, string(header))

    # Delete dialog from components
    dialog = render_delete_dialog(state.delete_type, state.delete_name)
    push!(lines, dialog)

    # Footer
    footer = render_footer(DELETE_CONFIRM_SHORTCUTS)
    push!(lines, "")
    push!(lines, footer)

    return join(lines, "\n")
end

# =============================================================================
# Input Handler
# =============================================================================

"""
    handle_delete_confirm_input!(state::AppState, key)::Nothing

Handle keyboard input on the delete confirmation screen.

# Arguments
- `state::AppState`: Current application state (modified in place)
- `key`: The key pressed (Char or Symbol)

# Handled Keys
- y, Enter: Confirm deletion
- n, Escape, b: Cancel and go back

# Side Effects
- On confirm: Deletes the item, sets success message, returns to appropriate screen
- On cancel: Returns to previous screen without deleting
"""
function handle_delete_confirm_input!(state::AppState, key)::Nothing
    # Confirm deletion
    if key == KEY_YES || key == KEY_ENTER
        perform_delete!(state)
        return nothing
    end

    # Cancel deletion
    if key == KEY_NO || key == KEY_ESCAPE || key == KEY_BACK
        clear_delete!(state)
        go_back!(state)
        return nothing
    end

    # Quit
    if key == KEY_QUIT || key == KEY_CTRL_C
        state.running = false
        return nothing
    end

    # Unhandled key - do nothing
    return nothing
end

# =============================================================================
# Delete Execution
# =============================================================================

"""
    perform_delete!(state::AppState)::Nothing

Execute the deletion based on delete_type and delete_id.

# Arguments
- `state::AppState`: Current application state

# Side Effects
- Deletes the item from database
- Sets success message
- Clears delete state
- Navigates back to appropriate list screen
"""
function perform_delete!(state::AppState)::Nothing
    if state.delete_type === nothing || state.delete_id === nothing
        # Nothing to delete
        go_back!(state)
        return nothing
    end

    item_name = state.delete_name
    delete_type = state.delete_type

    try
        if delete_type == :todo
            delete_todo!(state.db, state.delete_id)
            set_message!(state, "Todo \"$item_name\" deleted", :success)
            state.current_screen = MAIN_LIST
            state.previous_screen = nothing
        elseif delete_type == :project
            delete_project!(state.db, state.delete_id)
            set_message!(state, "Project \"$item_name\" deleted", :success)
            state.current_screen = PROJECT_LIST
            state.previous_screen = nothing
        elseif delete_type == :category
            delete_category!(state.db, state.delete_id)
            set_message!(state, "Category \"$item_name\" deleted", :success)
            state.current_screen = CATEGORY_LIST
            state.previous_screen = nothing
        end

        # Refresh data and clear delete state
        refresh_data!(state)
        clear_delete!(state)

        # Clear current item if it was deleted
        if delete_type == :todo
            state.current_todo = nothing
        elseif delete_type == :project
            state.current_project = nothing
        elseif delete_type == :category
            state.current_category = nothing
        end
    catch e
        set_message!(state, "Failed to delete: $(string(e))", :error)
        go_back!(state)
    end

    return nothing
end
