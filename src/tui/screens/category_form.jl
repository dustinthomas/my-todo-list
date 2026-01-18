"""
Category Form Screen.

Handles add and edit forms for categories with validation and save logic.
"""

# =============================================================================
# Constants
# =============================================================================

"""Total number of form fields in category form."""
const CATEGORY_FORM_FIELD_COUNT = 2

"""Field index for Save button (after all form fields)."""
const CATEGORY_FORM_SAVE_INDEX = 3

"""Keyboard shortcuts for category form screen."""
const CATEGORY_FORM_SHORTCUTS = [
    ("Tab/j", "Next Field"),
    ("Shift+Tab/k", "Prev Field"),
    ("Enter", "Save"),
    ("Esc", "Cancel")
]

# =============================================================================
# Validation Functions
# =============================================================================

"""
    validate_category_form!(state::AppState)::Bool

Validate the category form fields and populate form_errors.

# Arguments
- `state::AppState`: Application state with form_fields to validate

# Returns
- `true` if form is valid, `false` otherwise

# Side Effects
- Clears and populates state.form_errors with any validation errors
"""
function validate_category_form!(state::AppState)::Bool
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
    init_form_from_category!(state::AppState, category::Category)::Nothing

Initialize form fields from an existing category for editing.

# Arguments
- `state::AppState`: Application state to update
- `category::Category`: The category to copy values from

# Side Effects
- Populates state.form_fields with category values
- Resets form_field_index to 1
- Clears form_errors
"""
function init_form_from_category!(state::AppState, category::Category)::Nothing
    reset_form!(state)

    state.form_fields[:name] = category.name
    state.form_fields[:color] = category.color !== nothing ? category.color : ""

    return nothing
end

# =============================================================================
# Save Function
# =============================================================================

"""
    save_category_form!(state::AppState, mode::Symbol)::Nothing

Save the category form, creating or updating based on mode.

# Arguments
- `state::AppState`: Application state with form_fields
- `mode::Symbol`: Either :add or :edit

# Side Effects
- Validates form first, returns early if invalid
- Creates or updates category in database
- Sets success/error message
- Refreshes data
- Returns to previous screen on success
"""
function save_category_form!(state::AppState, mode::Symbol)::Nothing
    # Validate first
    if !validate_category_form!(state)
        return nothing
    end

    # Extract values from form (use String() to convert SubString to String)
    name = String(strip(state.form_fields[:name]))
    color = let c = get(state.form_fields, :color, "")
        stripped = strip(c)
        isempty(stripped) ? nothing : String(stripped)
    end

    try
        if mode == :add
            create_category(state.db, name; color=color)
            set_message!(state, "Category created successfully!", :success)
        else  # :edit
            update_category!(
                state.db, state.current_category.id;
                name=name,
                color=color
            )
            set_message!(state, "Category updated successfully!", :success)
        end

        refresh_data!(state)
        go_back!(state)
    catch e
        if occursin("already exists", string(e))
            set_message!(state, "A category with that name already exists", :error)
        else
            set_message!(state, "Error saving category: $(e)", :error)
        end
    end

    return nothing
end

# =============================================================================
# Render Function
# =============================================================================

"""
    render_category_form(state::AppState, mode::Symbol)::String

Render the category add/edit form screen.

# Arguments
- `state::AppState`: Current application state
- `mode::Symbol`: Either :add or :edit

# Returns
- String containing the complete screen output

# Components
- Header with "Add New Category" or "Edit Category"
- Form fields with current focus
- Validation errors if any
- Footer with keyboard shortcuts
"""
function render_category_form(state::AppState, mode::Symbol)::String
    lines = String[]

    # Header
    title = mode == :add ? "Add New Category" : "Edit Category"
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
    form_output = render_category_form_fields(
        state.form_fields,
        state.form_field_index,
        state.form_errors
    )
    push!(lines, form_output)
    push!(lines, "")

    # Save/Cancel buttons indicator
    if state.form_field_index == CATEGORY_FORM_SAVE_INDEX
        push!(lines, "{cyan bold}► [Save]{/cyan bold}    [Cancel]")
    else
        push!(lines, "  {dim}[Save]    [Cancel]{/dim}")
    end
    push!(lines, "")

    # Footer
    footer = render_footer(CATEGORY_FORM_SHORTCUTS)
    push!(lines, footer)

    return join(lines, "\n")
end

# =============================================================================
# Input Handler
# =============================================================================

"""
    handle_category_form_input!(state::AppState, key)::Nothing

Handle keyboard input on the category form screen.

# Arguments
- `state::AppState`: Current application state (modified in place)
- `key`: The key pressed (Char or Symbol)

# Handled Keys
- Tab, j, Down: Move to next field
- Shift+Tab, k, Up: Move to previous field
- Enter: Save (if on save button or any field)
- Escape: Cancel and go back
"""
function handle_category_form_input!(state::AppState, key)::Nothing
    # Cancel - go back
    if key == KEY_ESCAPE
        go_back!(state)
        return nothing
    end

    # Navigate to next field
    if key == KEY_TAB || key == 'j' || key == KEY_DOWN
        if state.form_field_index < CATEGORY_FORM_SAVE_INDEX
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
        mode = state.current_screen == CATEGORY_ADD ? :add : :edit
        save_category_form!(state, mode)
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
