"""
Table Components.

Renders data tables for todos, projects, and categories.
"""

using Term: Panel, @style

# =============================================================================
# String Formatting Helpers
# =============================================================================

"""
    visible_length(s::String)::Int

Calculate the visible length of a string, excluding Term.jl style tags.

Term.jl uses {style}text{/style} format for styling. This function strips
those tags to calculate how many characters will actually be displayed.

# Arguments
- `s::String`: String possibly containing style tags

# Returns
- `Int`: Number of visible characters

# Examples
```julia
visible_length("hello")                    # => 5
visible_length("{red}hello{/red}")         # => 5
visible_length("{bold}hi{/bold} there")    # => 8
```
"""
function visible_length(s::String)::Int
    # Remove Term.jl style tags: {style} and {/style}
    # Matches {word}, {word word}, {/word}, etc.
    stripped = replace(s, r"\{/?[a-zA-Z_ ]+\}" => "")
    return length(stripped)
end

"""
    styled_rpad(s::String, width::Int)::String

Right-pad a styled string to a given visible width.

Unlike `rpad`, this function accounts for Term.jl style tags when
calculating the current string width.

# Arguments
- `s::String`: String to pad (may contain style tags)
- `width::Int`: Desired visible width

# Returns
- `String`: String padded with spaces to reach visible width

# Examples
```julia
styled_rpad("{red}hi{/red}", 5)  # => "{red}hi{/red}   " (3 spaces added)
styled_rpad("hello", 5)          # => "hello" (no padding needed)
```
"""
function styled_rpad(s::String, width::Int)::String
    current_len = visible_length(s)
    if current_len >= width
        return s
    end
    padding = " " ^ (width - current_len)
    return s * padding
end

"""
    truncate_string(s::String, max_len::Int)::String

Truncate a string to maximum length, adding ellipsis if truncated.

# Arguments
- `s::String`: String to truncate
- `max_len::Int`: Maximum length (including ellipsis)

# Returns
- `String`: Truncated string with "…" suffix if needed

# Examples
```julia
truncate_string("Hello World", 8)  # => "Hello W…"
truncate_string("Hi", 10)          # => "Hi"
```
"""
function truncate_string(s::String, max_len::Int)::String
    if length(s) <= max_len
        return s
    end
    if max_len <= 1
        return "…"
    end
    return s[1:max_len-1] * "…"
end

"""
    format_status(status::String)::String

Format a status string with appropriate styling.

# Arguments
- `status::String`: Status value (pending, in_progress, completed, blocked)

# Returns
- `String`: Styled status string

# Status Colors
- pending: yellow
- in_progress: blue
- completed: green
- blocked: red
"""
function format_status(status::String)::String
    if status == "pending"
        return "{yellow}pending{/yellow}"
    elseif status == "in_progress"
        return "{blue}in_progress{/blue}"
    elseif status == "completed"
        return "{green}completed{/green}"
    elseif status == "blocked"
        return "{red}blocked{/red}"
    else
        return status
    end
end

"""
    format_priority(priority::Int)::String

Format a priority value with label and styling.

# Arguments
- `priority::Int`: Priority level (1=high, 2=medium, 3=low)

# Returns
- `String`: Styled priority string

# Priority Colors
- 1 (HIGH): red
- 2 (MEDIUM): yellow
- 3 (LOW): dim
"""
function format_priority(priority::Int)::String
    if priority == 1
        return "{red bold}HIGH{/red bold}"
    elseif priority == 2
        return "{yellow}MEDIUM{/yellow}"
    elseif priority == 3
        return "{dim}LOW{/dim}"
    else
        return string(priority)
    end
end

# =============================================================================
# Todo Table
# =============================================================================

"""
    render_todo_table(todos::Vector{Todo}, selected_index::Int, scroll_offset::Int, visible_rows::Int)::String

Render a table of todos with selection indicator.

# Arguments
- `todos::Vector{Todo}`: List of todos to display
- `selected_index::Int`: Currently selected row (1-based)
- `scroll_offset::Int`: Number of rows scrolled from top
- `visible_rows::Int`: Maximum number of rows to display

# Returns
- `String`: Rendered table string

# Features
- Selection indicator (►) for current row
- Status and priority formatting
- Due date display
- Empty state message when no todos
"""
function render_todo_table(todos::Vector{Todo}, selected_index::Int, scroll_offset::Int, visible_rows::Int)::String
    if isempty(todos)
        return "{dim}No todos found. Press 'a' to add a new todo.{/dim}"
    end

    # Calculate visible range
    start_idx = scroll_offset + 1
    end_idx = min(scroll_offset + visible_rows, length(todos))

    # Build table rows
    lines = String[]

    # Header row
    # Column widths: selector(1) + space(1) + id(3) = 5, title(30), status(11), priority(8), date(10)
    push!(lines, "{bold}    # │ Title                          │ Status      │ Priority │ Due Date   {/bold}")
    push!(lines, "──────┼────────────────────────────────┼─────────────┼──────────┼────────────")

    for i in start_idx:end_idx
        todo = todos[i]

        # Selection indicator
        selector = i == selected_index ? "{cyan bold}►{/cyan bold}" : " "

        # Format fields
        id_str = lpad(string(todo.id), 3)
        title = truncate_string(todo.title, 30)
        title_padded = rpad(title, 30)
        status = format_status(todo.status)
        priority = format_priority(todo.priority)
        due_date = todo.due_date !== nothing ? todo.due_date : "{dim}—{/dim}"

        # Build row - use styled_rpad for columns with style tags
        status_padded = styled_rpad(status, 11)
        priority_padded = styled_rpad(priority, 8)
        row = "$selector $id_str │ $title_padded │ $status_padded │ $priority_padded │ $due_date"
        push!(lines, row)
    end

    # Show scroll indicator if needed
    if length(todos) > visible_rows
        showing = "$start_idx-$end_idx of $(length(todos))"
        push!(lines, "{dim}Showing $showing{/dim}")
    end

    return join(lines, "\n")
end

# =============================================================================
# Project Table
# =============================================================================

"""
    render_project_table(projects::Vector{Project}, selected_index::Int, todo_counts::Dict)::String

Render a table of projects with selection indicator.

# Arguments
- `projects::Vector{Project}`: List of projects to display
- `selected_index::Int`: Currently selected row (1-based)
- `todo_counts::Dict`: Map of project_id => todo count

# Returns
- `String`: Rendered table string
"""
function render_project_table(projects::Vector{Project}, selected_index::Int, todo_counts::Dict)::String
    if isempty(projects)
        return "{dim}No projects found. Press 'a' to add a new project.{/dim}"
    end

    lines = String[]

    # Header row
    push!(lines, "{bold}   # │ Name                 │ Description              │ Todos │ Color  {/bold}")
    push!(lines, "─────┼──────────────────────┼──────────────────────────┼───────┼────────")

    for (i, project) in enumerate(projects)
        # Selection indicator
        selector = i == selected_index ? "{cyan bold}►{/cyan bold}" : " "

        # Format fields
        id_str = lpad(string(project.id), 3)
        name = truncate_string(project.name, 20)
        name_padded = rpad(name, 20)
        desc = project.description !== nothing ? truncate_string(project.description, 24) : ""
        desc_padded = rpad(desc, 24)
        count = get(todo_counts, project.id, 0)
        count_str = lpad(string(count), 5)
        color = project.color !== nothing ? project.color : "{dim}—{/dim}"

        # Build row
        row = "$selector $id_str │ $name_padded │ $desc_padded │ $count_str │ $color"
        push!(lines, row)
    end

    return join(lines, "\n")
end

# =============================================================================
# Category Table
# =============================================================================

"""
    render_category_table(categories::Vector{Category}, selected_index::Int, todo_counts::Dict)::String

Render a table of categories with selection indicator.

# Arguments
- `categories::Vector{Category}`: List of categories to display
- `selected_index::Int`: Currently selected row (1-based)
- `todo_counts::Dict`: Map of category_id => todo count

# Returns
- `String`: Rendered table string
"""
function render_category_table(categories::Vector{Category}, selected_index::Int, todo_counts::Dict)::String
    if isempty(categories)
        return "{dim}No categories found. Press 'a' to add a new category.{/dim}"
    end

    lines = String[]

    # Header row
    push!(lines, "{bold}   # │ Name                           │ Todos │ Color  {/bold}")
    push!(lines, "─────┼────────────────────────────────┼───────┼────────")

    for (i, category) in enumerate(categories)
        # Selection indicator
        selector = i == selected_index ? "{cyan bold}►{/cyan bold}" : " "

        # Format fields
        id_str = lpad(string(category.id), 3)
        name = truncate_string(category.name, 30)
        name_padded = rpad(name, 30)
        count = get(todo_counts, category.id, 0)
        count_str = lpad(string(count), 5)
        color = category.color !== nothing ? category.color : "{dim}—{/dim}"

        # Build row
        row = "$selector $id_str │ $name_padded │ $count_str │ $color"
        push!(lines, row)
    end

    return join(lines, "\n")
end
