"""
TUI Render Coordinator.

This module coordinates rendering and input handling across all screens.
It routes to the appropriate screen based on the current_screen in AppState.

# Functions
- `render_screen(state)`: Route to correct screen render function
- `handle_input!(state, key)`: Route to correct screen input handler
- `clear_and_render(output)`: Clear screen and display output
"""

using Term: tprint, tprintln

# =============================================================================
# Screen Rendering Coordinator
# =============================================================================

"""
    render_screen(state::AppState)::String

Route to the correct screen rendering function based on current_screen.

# Arguments
- `state::AppState`: Current application state

# Returns
- `String`: Rendered screen output

# Example
```julia
state.current_screen = MAIN_LIST
output = render_screen(state)
println(output)  # Shows main list screen
```
"""
function render_screen(state::AppState)::String
    screen = state.current_screen

    if screen == MAIN_LIST
        return render_main_list(state)
    elseif screen == TODO_DETAIL
        return render_todo_detail(state)
    elseif screen == TODO_ADD
        return render_todo_form(state, :add)
    elseif screen == TODO_EDIT
        return render_todo_form(state, :edit)
    elseif screen == FILTER_MENU
        return render_filter_menu(state)
    elseif screen == FILTER_STATUS
        return render_filter_status(state)
    elseif screen == FILTER_PROJECT
        return render_filter_project(state)
    elseif screen == FILTER_CATEGORY
        return render_filter_category(state)
    elseif screen == PROJECT_LIST
        return render_project_list(state)
    elseif screen == PROJECT_ADD
        return render_project_form(state, :add)
    elseif screen == PROJECT_EDIT
        return render_project_form(state, :edit)
    elseif screen == CATEGORY_LIST
        return render_category_list(state)
    elseif screen == CATEGORY_ADD
        return render_category_form(state, :add)
    elseif screen == CATEGORY_EDIT
        return render_category_form(state, :edit)
    elseif screen == DELETE_CONFIRM
        return render_delete_confirm(state)
    else
        # Fallback - should never happen
        return "Unknown screen: $screen"
    end
end

# =============================================================================
# Input Handling Coordinator
# =============================================================================

"""
    handle_input!(state::AppState, key)::Nothing

Route to the correct screen input handler based on current_screen.

# Arguments
- `state::AppState`: Current application state (modified in place)
- `key`: The key pressed (Char or Symbol)

# Example
```julia
state.current_screen = MAIN_LIST
handle_input!(state, 'j')  # Navigate down in main list
```
"""
function handle_input!(state::AppState, key)::Nothing
    screen = state.current_screen

    if screen == MAIN_LIST
        handle_main_list_input!(state, key)
    elseif screen == TODO_DETAIL
        handle_todo_detail_input!(state, key)
    elseif screen == TODO_ADD || screen == TODO_EDIT
        handle_todo_form_input!(state, key)
    elseif screen == FILTER_MENU
        handle_filter_menu_input!(state, key)
    elseif screen == FILTER_STATUS
        handle_filter_status_input!(state, key)
    elseif screen == FILTER_PROJECT
        handle_filter_project_input!(state, key)
    elseif screen == FILTER_CATEGORY
        handle_filter_category_input!(state, key)
    elseif screen == PROJECT_LIST
        handle_project_list_input!(state, key)
    elseif screen == PROJECT_ADD || screen == PROJECT_EDIT
        handle_project_form_input!(state, key)
    elseif screen == CATEGORY_LIST
        handle_category_list_input!(state, key)
    elseif screen == CATEGORY_ADD || screen == CATEGORY_EDIT
        handle_category_form_input!(state, key)
    elseif screen == DELETE_CONFIRM
        handle_delete_confirm_input!(state, key)
    end

    return nothing
end

# =============================================================================
# Screen Display Utilities
# =============================================================================

"""
    clear_screen()::Nothing

Clear the terminal screen using ANSI escape codes.
"""
function clear_screen()::Nothing
    # ANSI escape: clear screen and move cursor to top-left
    print("\e[2J\e[H")
    flush(stdout)
    return nothing
end

"""
    fix_newlines_for_raw_mode(s::String)::String

Convert \\n to \\r\\n for proper display in raw terminal mode.

In raw mode, \\n moves down but doesn't return to column 0.
We need \\r\\n to get proper line breaks.
"""
function fix_newlines_for_raw_mode(s::String)::String
    # Replace \n with \r\n, but avoid doubling if \r\n already exists
    return replace(s, r"(?<!\r)\n" => "\r\n")
end

"""
    clear_and_render(state::AppState)::Nothing

Clear the screen and render the current state.

# Arguments
- `state::AppState`: Current application state

# Side Effects
- Clears the terminal
- Prints the rendered screen
"""
function clear_and_render(state::AppState)::Nothing
    clear_screen()
    output = render_screen(state)
    # Use Term.jl's tprint to process markup, capturing to string
    # Then fix newlines for raw terminal mode
    rendered = sprint(io -> tprint(io, output))
    rendered = fix_newlines_for_raw_mode(rendered)
    print(rendered)
    flush(stdout)
    return nothing
end
