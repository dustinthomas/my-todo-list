"""
Form Components.

Renders form input elements for todo, project, and category forms.
"""

using Term: @style, Panel

# =============================================================================
# Text Field Component
# =============================================================================

"""
    render_text_field(label::String, value::String, focused::Bool, error::Union{String,Nothing}=nothing)::String

Render a text input field.

# Arguments
- `label::String`: Field label
- `value::String`: Current field value
- `focused::Bool`: Whether the field is currently focused
- `error::Union{String,Nothing}`: Optional error message

# Returns
- `String`: Rendered text field

# Examples
```julia
render_text_field("Title*", "My Todo", true)
render_text_field("Title*", "", true, "Title is required")
```
"""
function render_text_field(label::String, value::String, focused::Bool, error::Union{String,Nothing}=nothing)::String
    lines = String[]

    # Label with focus indicator
    if focused
        push!(lines, "{cyan bold}► $label{/cyan bold}")
    else
        push!(lines, "{dim}  $label{/dim}")
    end

    # Value box
    display_value = isempty(value) ? "{dim}(empty){/dim}" : value
    if focused
        push!(lines, "  ┌────────────────────────────────────────────┐")
        push!(lines, "  │ $display_value")
        push!(lines, "  └────────────────────────────────────────────┘")
    else
        push!(lines, "  │ $display_value")
    end

    # Error message if present
    if error !== nothing && !isempty(error)
        push!(lines, "  {red}✗ $error{/red}")
    end

    return join(lines, "\n")
end

# =============================================================================
# Radio Group Component
# =============================================================================

"""
    render_radio_group(label::String, options::Vector{String}, selected::String, focused::Bool)::String

Render a radio button group for single selection.

# Arguments
- `label::String`: Group label
- `options::Vector{String}`: Available options
- `selected::String`: Currently selected option value
- `focused::Bool`: Whether the group is currently focused

# Returns
- `String`: Rendered radio group

# Examples
```julia
render_radio_group("Status", ["pending", "in_progress", "completed"], "pending", true)
```
"""
function render_radio_group(label::String, options::Vector{String}, selected::String, focused::Bool)::String
    lines = String[]

    # Label with focus indicator
    if focused
        push!(lines, "{cyan bold}► $label{/cyan bold}")
    else
        push!(lines, "{dim}  $label{/dim}")
    end

    # Options
    for opt in options
        if opt == selected
            # Selected option
            if focused
                push!(lines, "  {cyan}● $opt{/cyan}")
            else
                push!(lines, "  {green}● $opt{/green}")
            end
        else
            # Unselected option
            push!(lines, "  {dim}○ $opt{/dim}")
        end
    end

    return join(lines, "\n")
end

# =============================================================================
# Dropdown Component
# =============================================================================

"""
    render_dropdown(label::String, options::Vector{Tuple{String,String}}, selected::String, focused::Bool, expanded::Bool)::String

Render a dropdown selection field.

# Arguments
- `label::String`: Field label
- `options::Vector{Tuple{String,String}}`: List of (value, display) pairs
- `selected::String`: Currently selected value
- `focused::Bool`: Whether the field is currently focused
- `expanded::Bool`: Whether the dropdown is expanded

# Returns
- `String`: Rendered dropdown

# Examples
```julia
options = [("1", "Project A"), ("2", "Project B"), ("", "None")]
render_dropdown("Project", options, "1", true, false)
```
"""
function render_dropdown(label::String, options::Vector{Tuple{String,String}}, selected::String, focused::Bool, expanded::Bool)::String
    lines = String[]

    # Find selected display text
    selected_display = "—"
    for (val, display) in options
        if val == selected
            selected_display = display
            break
        end
    end

    # Label with focus indicator
    if focused
        push!(lines, "{cyan bold}► $label{/cyan bold}")
    else
        push!(lines, "{dim}  $label{/dim}")
    end

    if expanded
        # Show all options when expanded
        for (val, display) in options
            if val == selected
                push!(lines, "  {cyan}► $display{/cyan}")
            else
                push!(lines, "    {dim}$display{/dim}")
            end
        end
    else
        # Show only selected value when collapsed
        arrow = focused ? "▼" : " "
        push!(lines, "  │ $selected_display $arrow")
    end

    return join(lines, "\n")
end

# Also support Vector of any tuple-like type
function render_dropdown(label::String, options::Vector, selected::String, focused::Bool, expanded::Bool)::String
    converted = Tuple{String,String}[(string(v), string(d)) for (v, d) in options]
    return render_dropdown(label, converted, selected, focused, expanded)
end

# =============================================================================
# Date Field Component
# =============================================================================

"""
    render_date_field(label::String, value::String, focused::Bool, error::Union{String,Nothing}=nothing)::String

Render a date input field.

# Arguments
- `label::String`: Field label
- `value::String`: Current date value (YYYY-MM-DD format)
- `focused::Bool`: Whether the field is currently focused
- `error::Union{String,Nothing}`: Optional error message

# Returns
- `String`: Rendered date field

# Examples
```julia
render_date_field("Due Date", "2026-01-20", true)
render_date_field("Due Date", "invalid", true, "Invalid date format")
```
"""
function render_date_field(label::String, value::String, focused::Bool, error::Union{String,Nothing}=nothing)::String
    lines = String[]

    # Label with focus indicator
    if focused
        push!(lines, "{cyan bold}► $label{/cyan bold} {dim}(YYYY-MM-DD){/dim}")
    else
        push!(lines, "{dim}  $label (YYYY-MM-DD){/dim}")
    end

    # Value display
    display_value = isempty(value) ? "{dim}(not set){/dim}" : value
    if focused
        push!(lines, "  ┌──────────────┐")
        push!(lines, "  │ $display_value")
        push!(lines, "  └──────────────┘")
    else
        push!(lines, "  │ $display_value")
    end

    # Error message if present
    if error !== nothing && !isempty(error)
        push!(lines, "  {red}✗ $error{/red}")
    end

    return join(lines, "\n")
end

# =============================================================================
# Complete Form Renderers
# =============================================================================

"""
    render_todo_form_fields(fields::Dict{Symbol,String}, focused_index::Int, errors::Dict{Symbol,String})::String

Render all fields for a todo form.

# Arguments
- `fields::Dict{Symbol,String}`: Current field values
- `focused_index::Int`: Index of the focused field (1-based)
- `errors::Dict{Symbol,String}`: Field validation errors

# Returns
- `String`: Rendered form fields

# Field Order
1. Title* (required)
2. Description
3. Status
4. Priority
5. Project
6. Category
7. Start Date
8. Due Date
"""
function render_todo_form_fields(fields::Dict{Symbol,String}, focused_index::Int, errors::Dict{Symbol,String})::String
    lines = String[]

    # Title field
    push!(lines, render_text_field(
        "Title*",
        get(fields, :title, ""),
        focused_index == 1,
        get(errors, :title, nothing)
    ))
    push!(lines, "")

    # Description field
    push!(lines, render_text_field(
        "Description",
        get(fields, :description, ""),
        focused_index == 2,
        get(errors, :description, nothing)
    ))
    push!(lines, "")

    # Status field
    push!(lines, render_radio_group(
        "Status",
        ["pending", "in_progress", "completed", "blocked"],
        get(fields, :status, "pending"),
        focused_index == 3
    ))
    push!(lines, "")

    # Priority field
    push!(lines, render_radio_group(
        "Priority",
        ["1 - High", "2 - Medium", "3 - Low"],
        get_priority_display(get(fields, :priority, "2")),
        focused_index == 4
    ))
    push!(lines, "")

    # Start Date field
    push!(lines, render_date_field(
        "Start Date",
        get(fields, :start_date, ""),
        focused_index == 5,
        get(errors, :start_date, nothing)
    ))
    push!(lines, "")

    # Due Date field
    push!(lines, render_date_field(
        "Due Date",
        get(fields, :due_date, ""),
        focused_index == 6,
        get(errors, :due_date, nothing)
    ))

    return join(lines, "\n")
end

"""
    get_priority_display(priority::String)::String

Convert priority value to display string.
"""
function get_priority_display(priority::String)::String
    if priority == "1"
        return "1 - High"
    elseif priority == "2"
        return "2 - Medium"
    elseif priority == "3"
        return "3 - Low"
    else
        return priority
    end
end

"""
    render_project_form_fields(fields::Dict{Symbol,String}, focused_index::Int, errors::Dict{Symbol,String})::String

Render all fields for a project form.

# Arguments
- `fields::Dict{Symbol,String}`: Current field values
- `focused_index::Int`: Index of the focused field (1-based)
- `errors::Dict{Symbol,String}`: Field validation errors

# Returns
- `String`: Rendered form fields

# Field Order
1. Name* (required)
2. Description
3. Color
"""
function render_project_form_fields(fields::Dict{Symbol,String}, focused_index::Int, errors::Dict{Symbol,String})::String
    lines = String[]

    # Name field
    push!(lines, render_text_field(
        "Name*",
        get(fields, :name, ""),
        focused_index == 1,
        get(errors, :name, nothing)
    ))
    push!(lines, "")

    # Description field
    push!(lines, render_text_field(
        "Description",
        get(fields, :description, ""),
        focused_index == 2,
        get(errors, :description, nothing)
    ))
    push!(lines, "")

    # Color field
    push!(lines, render_text_field(
        "Color {dim}(hex, e.g. #FF0000){/dim}",
        get(fields, :color, ""),
        focused_index == 3,
        get(errors, :color, nothing)
    ))

    return join(lines, "\n")
end

"""
    render_category_form_fields(fields::Dict{Symbol,String}, focused_index::Int, errors::Dict{Symbol,String})::String

Render all fields for a category form.

# Arguments
- `fields::Dict{Symbol,String}`: Current field values
- `focused_index::Int`: Index of the focused field (1-based)
- `errors::Dict{Symbol,String}`: Field validation errors

# Returns
- `String`: Rendered form fields

# Field Order
1. Name* (required)
2. Color
"""
function render_category_form_fields(fields::Dict{Symbol,String}, focused_index::Int, errors::Dict{Symbol,String})::String
    lines = String[]

    # Name field
    push!(lines, render_text_field(
        "Name*",
        get(fields, :name, ""),
        focused_index == 1,
        get(errors, :name, nothing)
    ))
    push!(lines, "")

    # Color field
    push!(lines, render_text_field(
        "Color {dim}(hex, e.g. #00FF00){/dim}",
        get(fields, :color, ""),
        focused_index == 2,
        get(errors, :color, nothing)
    ))

    return join(lines, "\n")
end

# =============================================================================
# Form Panel Wrapper
# =============================================================================

"""
    render_form_panel(content::String; title::String="", width::Int=78)::Panel

Wrap form content in a Panel with heavy box style for visual weight.

Uses Term.jl Panel with `:HEAVY` box style to create distinct input areas
for form screens.

# Arguments
- `content::String`: Form content to wrap (fields, buttons, etc.)
- `title::String`: Optional panel title (e.g., "Form Fields")
- `width::Int`: Panel width (default 78, not 80 to avoid tprint wrapping)

# Returns
- `Panel`: Term.jl Panel with heavy box style

# Examples
```julia
fields = render_todo_form_fields(...)
panel = render_form_panel(fields, title="Enter Details")
```

# Notes
Width defaults to 78 (not 80) because Term.jl's tprint wraps lines at console
width (typically 80). A panel at exactly 80 chars causes line-wrapping artifacts
when the output is processed through tprint for markup rendering.
"""
function render_form_panel(content::String; title::String="", width::Int=78)::Panel
    return Panel(
        content;
        title=isempty(title) ? nothing : title,
        style="white",
        box=:HEAVY,
        width=width
    )
end
