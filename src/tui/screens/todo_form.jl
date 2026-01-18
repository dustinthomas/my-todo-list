"""
Todo Form Screen.

Handles add and edit forms for todos with validation and save logic.
"""

using Dates

# =============================================================================
# Constants
# =============================================================================

"""Total number of form fields in todo form."""
const TODO_FORM_FIELD_COUNT = 6

"""Field index for Save button (after all form fields)."""
const TODO_FORM_SAVE_INDEX = 7

"""Keyboard shortcuts for todo form screen."""
const TODO_FORM_SHORTCUTS = [
    ("Tab/j", "Next Field"),
    ("Shift+Tab/k", "Prev Field"),
    ("Enter", "Save"),
    ("Esc", "Cancel")
]

# =============================================================================
# Validation Functions
# =============================================================================

"""
    is_valid_date(date_str::String)::Bool

Check if a date string is in valid YYYY-MM-DD format and represents a valid date.
Empty strings are considered valid (optional field).

# Arguments
- `date_str::String`: The date string to validate

# Returns
- `true` if empty or valid date format, `false` otherwise
"""
function is_valid_date(date_str::String)::Bool
    if isempty(date_str)
        return true
    end

    # Check format with regex
    if !occursin(r"^\d{4}-\d{2}-\d{2}$", date_str)
        return false
    end

    # Try to parse as date
    try
        Date(date_str, dateformat"yyyy-mm-dd")
        return true
    catch
        return false
    end
end

"""
    validate_todo_form!(state::AppState)::Bool

Validate the todo form fields and populate form_errors.

# Arguments
- `state::AppState`: Application state with form_fields to validate

# Returns
- `true` if form is valid, `false` otherwise

# Side Effects
- Clears and populates state.form_errors with any validation errors
"""
function validate_todo_form!(state::AppState)::Bool
    empty!(state.form_errors)

    # Title is required
    title = get(state.form_fields, :title, "")
    if isempty(strip(title))
        state.form_errors[:title] = "Title is required"
    end

    # Validate date formats
    start_date = get(state.form_fields, :start_date, "")
    if !is_valid_date(start_date)
        state.form_errors[:start_date] = "Invalid date format (use YYYY-MM-DD)"
    end

    due_date = get(state.form_fields, :due_date, "")
    if !is_valid_date(due_date)
        state.form_errors[:due_date] = "Invalid date format (use YYYY-MM-DD)"
    end

    return isempty(state.form_errors)
end

# =============================================================================
# Form Initialization
# =============================================================================

"""
    init_form_from_todo!(state::AppState, todo::Todo)::Nothing

Initialize form fields from an existing todo for editing.

# Arguments
- `state::AppState`: Application state to update
- `todo::Todo`: The todo to copy values from

# Side Effects
- Populates state.form_fields with todo values
- Resets form_field_index to 1
- Clears form_errors
"""
function init_form_from_todo!(state::AppState, todo::Todo)::Nothing
    reset_form!(state)

    state.form_fields[:title] = todo.title
    state.form_fields[:description] = todo.description !== nothing ? todo.description : ""
    state.form_fields[:status] = todo.status
    state.form_fields[:priority] = string(todo.priority)
    state.form_fields[:start_date] = todo.start_date !== nothing ? todo.start_date : ""
    state.form_fields[:due_date] = todo.due_date !== nothing ? todo.due_date : ""
    state.form_fields[:project_id] = todo.project_id !== nothing ? string(todo.project_id) : ""
    state.form_fields[:category_id] = todo.category_id !== nothing ? string(todo.category_id) : ""

    return nothing
end

# =============================================================================
# Save Function
# =============================================================================

"""
    save_todo_form!(state::AppState, mode::Symbol)::Nothing

Save the todo form, creating or updating based on mode.

# Arguments
- `state::AppState`: Application state with form_fields
- `mode::Symbol`: Either :add or :edit

# Side Effects
- Validates form first, returns early if invalid
- Creates or updates todo in database
- Sets success/error message
- Refreshes data
- Returns to previous screen on success
"""
function save_todo_form!(state::AppState, mode::Symbol)::Nothing
    # Validate first
    if !validate_todo_form!(state)
        return nothing
    end

    # Extract values from form (use String() to convert SubString to String)
    title = String(strip(state.form_fields[:title]))
    description = let d = get(state.form_fields, :description, "")
        stripped = strip(d)
        isempty(stripped) ? nothing : String(stripped)
    end
    status = get(state.form_fields, :status, "pending")
    priority = parse(Int, get(state.form_fields, :priority, "2"))

    start_date = let d = get(state.form_fields, :start_date, "")
        stripped = strip(d)
        isempty(stripped) ? nothing : String(stripped)
    end
    due_date = let d = get(state.form_fields, :due_date, "")
        stripped = strip(d)
        isempty(stripped) ? nothing : String(stripped)
    end

    project_id = let p = get(state.form_fields, :project_id, "")
        stripped = strip(p)
        isempty(stripped) ? nothing : parse(Int64, stripped)
    end
    category_id = let c = get(state.form_fields, :category_id, "")
        stripped = strip(c)
        isempty(stripped) ? nothing : parse(Int64, stripped)
    end

    try
        if mode == :add
            create_todo(
                state.db, title;
                description=description,
                status=status,
                priority=priority,
                project_id=project_id,
                category_id=category_id,
                start_date=start_date,
                due_date=due_date
            )
            set_message!(state, "Todo created successfully!", :success)
        else  # :edit
            update_todo!(
                state.db, state.current_todo.id;
                title=title,
                description=description,
                status=status,
                priority=priority,
                project_id=project_id,
                category_id=category_id,
                start_date=start_date,
                due_date=due_date
            )
            set_message!(state, "Todo updated successfully!", :success)
        end

        refresh_data!(state)
        go_back!(state)
    catch e
        set_message!(state, "Error saving todo: $(e)", :error)
    end

    return nothing
end

# =============================================================================
# Render Function
# =============================================================================

"""
    render_todo_form(state::AppState, mode::Symbol)::String

Render the todo add/edit form screen.

# Arguments
- `state::AppState`: Current application state
- `mode::Symbol`: Either :add or :edit

# Returns
- String containing the complete screen output

# Components
- Header with "Add New Todo" or "Edit Todo"
- Form fields with current focus
- Validation errors if any
- Footer with keyboard shortcuts
"""
function render_todo_form(state::AppState, mode::Symbol)::String
    lines = String[]

    # Header
    title = mode == :add ? "Add New Todo" : "Edit Todo"
    header = render_header(title)
    push!(lines, string(header))
    push!(lines, "")

    # Message (if any)
    if state.message !== nothing && state.message_type !== nothing
        message = render_message(state.message, state.message_type)
        push!(lines, string(message))
        push!(lines, "")
    end

    # Form fields
    form_output = render_todo_form_fields(
        state.form_fields,
        state.form_field_index,
        state.form_errors
    )
    push!(lines, form_output)
    push!(lines, "")

    # Save/Cancel buttons indicator
    if state.form_field_index == TODO_FORM_SAVE_INDEX
        push!(lines, "{cyan bold}► [Save]{/cyan bold}    [Cancel]")
    else
        push!(lines, "  {dim}[Save]    [Cancel]{/dim}")
    end
    push!(lines, "")

    # Footer
    footer = render_footer(TODO_FORM_SHORTCUTS)
    push!(lines, footer)

    return join(lines, "\n")
end

# =============================================================================
# Input Handler
# =============================================================================

"""
    handle_todo_form_input!(state::AppState, key)::Nothing

Handle keyboard input on the todo form screen.

# Arguments
- `state::AppState`: Current application state (modified in place)
- `key`: The key pressed (Char or Symbol)

# Handled Keys
- Tab, j, Down: Move to next field
- Shift+Tab, k, Up: Move to previous field
- Enter: Save (if on save button or any field)
- Escape: Cancel and go back
"""
function handle_todo_form_input!(state::AppState, key)::Nothing
    # Cancel - go back
    if key == KEY_ESCAPE
        go_back!(state)
        return nothing
    end

    # Navigate to next field
    if key == KEY_TAB || key == 'j' || key == KEY_DOWN
        if state.form_field_index < TODO_FORM_SAVE_INDEX
            state.form_field_index += 1
        end
        return nothing
    end

    # Navigate to previous field
    if key == KEY_SHIFT_TAB || key == 'k' || key == KEY_UP
        if state.form_field_index > 1
            state.form_field_index -= 1
        end
        return nothing
    end

    # Enter - save form (from any field or save button)
    if key == KEY_ENTER
        mode = state.current_screen == TODO_ADD ? :add : :edit
        save_todo_form!(state, mode)
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
