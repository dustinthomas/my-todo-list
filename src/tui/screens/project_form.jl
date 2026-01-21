"""
Project Form Screen.

Handles add and edit forms for projects with validation and save logic.
"""

# =============================================================================
# Constants
# =============================================================================

"""Total number of form fields in project form."""
const PROJECT_FORM_FIELD_COUNT = 3

"""Field index for Save button (after all form fields)."""
const PROJECT_FORM_SAVE_INDEX = 4

"""Keyboard shortcuts for project form screen."""
const PROJECT_FORM_SHORTCUTS = [
    ("Tab/↓", "Next Field"),
    ("Shift+Tab/↑", "Prev Field"),
    ("Enter", "Save"),
    ("Esc", "Cancel")
]

# =============================================================================
# Validation Functions
# =============================================================================

"""
    validate_project_form!(state::AppState)::Bool

Validate the project form fields and populate form_errors.

# Arguments
- `state::AppState`: Application state with form_fields to validate

# Returns
- `true` if form is valid, `false` otherwise

# Side Effects
- Clears and populates state.form_errors with any validation errors
"""
function validate_project_form!(state::AppState)::Bool
    empty!(state.form_errors)

    # Name is required
    name = get(state.form_fields, :name, "")
    if isempty(strip(name))
        state.form_errors[:name] = "Name is required"
    end

    # Color format validation (optional but must be valid if provided)
    color = get(state.form_fields, :color, "")
    if !isempty(strip(color))
        if !occursin(r"^#[0-9A-Fa-f]{6}$", strip(color))
            state.form_errors[:color] = "Invalid color format (use #RRGGBB)"
        end
    end

    return isempty(state.form_errors)
end

# =============================================================================
# Form Initialization
# =============================================================================

"""
    init_form_from_project!(state::AppState, project::Project)::Nothing

Initialize form fields from an existing project for editing.

# Arguments
- `state::AppState`: Application state to update
- `project::Project`: The project to copy values from

# Side Effects
- Populates state.form_fields with project values
- Resets form_field_index to 1
- Clears form_errors
"""
function init_form_from_project!(state::AppState, project::Project)::Nothing
    reset_form!(state)

    state.form_fields[:name] = project.name
    state.form_fields[:description] = project.description !== nothing ? project.description : ""
    state.form_fields[:color] = project.color !== nothing ? project.color : ""

    return nothing
end

# =============================================================================
# Save Function
# =============================================================================

"""
    save_project_form!(state::AppState, mode::Symbol)::Nothing

Save the project form, creating or updating based on mode.

# Arguments
- `state::AppState`: Application state with form_fields
- `mode::Symbol`: Either :add or :edit

# Side Effects
- Validates form first, returns early if invalid
- Creates or updates project in database
- Sets success/error message
- Refreshes data
- Returns to previous screen on success
"""
function save_project_form!(state::AppState, mode::Symbol)::Nothing
    # Validate first
    if !validate_project_form!(state)
        return nothing
    end

    # Extract values from form (use String() to convert SubString to String)
    name = String(strip(state.form_fields[:name]))
    description = let d = get(state.form_fields, :description, "")
        stripped = strip(d)
        isempty(stripped) ? nothing : String(stripped)
    end
    color = let c = get(state.form_fields, :color, "")
        stripped = strip(c)
        isempty(stripped) ? nothing : String(stripped)
    end

    try
        if mode == :add
            create_project(state.db, name; description=description, color=color)
            set_message!(state, "Project created successfully!", :success)
        else  # :edit
            update_project!(
                state.db, state.current_project.id;
                name=name,
                description=description,
                color=color
            )
            set_message!(state, "Project updated successfully!", :success)
        end

        refresh_data!(state)
        go_back!(state)
    catch e
        if occursin("already exists", string(e))
            set_message!(state, "A project with that name already exists", :error)
        else
            set_message!(state, "Error saving project: $(e)", :error)
        end
    end

    return nothing
end

# =============================================================================
# Render Function
# =============================================================================

"""
    render_project_form(state::AppState, mode::Symbol)::String

Render the project add/edit form screen.

# Arguments
- `state::AppState`: Current application state
- `mode::Symbol`: Either :add or :edit

# Returns
- String containing the complete screen output

# Components
- Header with "Add New Project" or "Edit Project"
- Form fields with current focus
- Validation errors if any
- Footer with keyboard shortcuts
"""
function render_project_form(state::AppState, mode::Symbol)::String
    lines = String[]

    # Header
    title = mode == :add ? "Add New Project" : "Edit Project"
    header = render_header(title)
    push!(lines, string(header))
    push!(lines, "")

    # Message (if any)
    if state.message !== nothing && state.message_type !== nothing
        message = render_message(state.message, state.message_type)
        push!(lines, string(message))
        push!(lines, "")
    end

    # Form fields wrapped in heavy-bordered panel
    form_output = render_project_form_fields(
        state.form_fields,
        state.form_field_index,
        state.form_errors
    )
    form_panel = render_form_panel(form_output)
    push!(lines, string(form_panel))
    push!(lines, "")

    # Save/Cancel buttons indicator
    if state.form_field_index == PROJECT_FORM_SAVE_INDEX
        push!(lines, "{cyan bold}► [Save]{/cyan bold}    [Cancel]")
    else
        push!(lines, "  {dim}[Save]    [Cancel]{/dim}")
    end
    push!(lines, "")

    # Footer
    footer = render_footer(PROJECT_FORM_SHORTCUTS)
    push!(lines, footer)

    return join(lines, "\n")
end

# =============================================================================
# Field Helpers
# =============================================================================

"""Map project form field index to the corresponding form field symbol."""
function get_project_field_symbol(index::Int)::Union{Symbol, Nothing}
    if index == 1
        return :name
    elseif index == 2
        return :description
    elseif index == 3
        return :color
    else
        return nothing
    end
end

# =============================================================================
# Input Handler
# =============================================================================

"""
    handle_project_form_input!(state::AppState, key)::Nothing

Handle keyboard input on the project form screen.

# Arguments
- `state::AppState`: Current application state (modified in place)
- `key`: The key pressed (Char or Symbol)

# Handled Keys
- Tab, Down: Move to next field
- Shift+Tab, Up: Move to previous field
- Enter: Save form
- Escape: Cancel and go back
- Printable characters: Type into text fields
- Backspace: Delete character from text fields
"""
function handle_project_form_input!(state::AppState, key)::Nothing
    idx = state.form_field_index

    # Cancel - go back
    if key == KEY_ESCAPE
        go_back!(state)
        return nothing
    end

    # Quit - only when on save button (index 4), not in text fields
    if key == KEY_QUIT && idx == PROJECT_FORM_SAVE_INDEX
        state.running = false
        return nothing
    end

    if key == KEY_CTRL_C
        state.running = false
        return nothing
    end

    # Navigate to next field
    if key == KEY_TAB || key == KEY_DOWN
        if idx < PROJECT_FORM_SAVE_INDEX
            state.form_field_index += 1
        end
        return nothing
    end

    # Navigate to previous field
    if key == KEY_SHIFT_TAB || key == KEY_UP
        if idx > 1
            state.form_field_index -= 1
        end
        return nothing
    end

    # Enter - save form (from any field or save button)
    if key == KEY_ENTER
        mode = state.current_screen == PROJECT_ADD ? :add : :edit
        save_project_form!(state, mode)
        return nothing
    end

    # Text field input handling (all project form fields are text fields)
    if idx <= PROJECT_FORM_FIELD_COUNT
        field_sym = get_project_field_symbol(idx)
        if field_sym !== nothing
            # Backspace - delete last character
            if key == KEY_BACKSPACE
                current = get(state.form_fields, field_sym, "")
                if !isempty(current)
                    state.form_fields[field_sym] = current[1:prevind(current, end)]
                end
                return nothing
            end

            # Printable character - append to field
            if is_printable_char(key)
                current = get(state.form_fields, field_sym, "")
                state.form_fields[field_sym] = current * string(key)
                return nothing
            end
        end
    end

    # Unhandled key - do nothing
    return nothing
end
