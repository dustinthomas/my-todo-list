"""
Dialog Components.

Renders confirmation dialogs and filter menus.
"""

using Term: Panel, @style

# =============================================================================
# Delete Confirmation Dialog
# =============================================================================

"""
    render_delete_dialog(item_type::Symbol, item_name::String)::String

Render a delete confirmation dialog.

# Arguments
- `item_type::Symbol`: Type of item to delete (:todo, :project, :category)
- `item_name::String`: Name/title of item to delete

# Returns
- `String`: Rendered confirmation dialog

# Examples
```julia
render_delete_dialog(:todo, "Buy groceries")
render_delete_dialog(:project, "Work Tasks")
```
"""
function render_delete_dialog(item_type::Symbol, item_name::String)::String
    type_str = string(item_type)

    lines = String[]

    push!(lines, "")
    push!(lines, "{bold red}⚠ Delete Confirmation{/bold red}")
    push!(lines, "")
    push!(lines, "Are you sure you want to delete this $type_str?")
    push!(lines, "")
    push!(lines, "  {bold}\"$item_name\"{/bold}")
    push!(lines, "")
    push!(lines, "{yellow}This action cannot be undone.{/yellow}")
    push!(lines, "")
    push!(lines, "─────────────────────────────────────────")
    push!(lines, "")
    push!(lines, "  {green bold}y{/green bold} - Yes, delete")
    push!(lines, "  {red bold}n{/red bold} - No, cancel")
    push!(lines, "")

    return join(lines, "\n")
end

# =============================================================================
# Filter Summary
# =============================================================================

"""
    render_filter_summary(status::Union{String,Nothing}, project_id::Union{Int64,Nothing}, category_id::Union{Int64,Nothing}, projects::Vector{Project}, categories::Vector{Category})::String

Render a summary of active filters.

# Arguments
- `status::Union{String,Nothing}`: Active status filter
- `project_id::Union{Int64,Nothing}`: Active project filter ID
- `category_id::Union{Int64,Nothing}`: Active category filter ID
- `projects::Vector{Project}`: List of projects for name lookup
- `categories::Vector{Category}`: List of categories for name lookup

# Returns
- `String`: Rendered filter summary

# Examples
```julia
render_filter_summary("pending", nothing, nothing, [], [])
render_filter_summary(nothing, 1, nothing, projects, [])
```
"""
function render_filter_summary(
    status::Union{String,Nothing},
    project_id::Union{Int64,Nothing},
    category_id::Union{Int64,Nothing},
    projects::Vector{Project},
    categories::Vector{Category}
)::String
    filters = String[]

    # Status filter
    if status !== nothing
        push!(filters, "{cyan}Status:{/cyan} $status")
    end

    # Project filter
    if project_id !== nothing
        project_name = "Unknown"
        for p in projects
            if p.id == project_id
                project_name = p.name
                break
            end
        end
        push!(filters, "{cyan}Project:{/cyan} $project_name")
    end

    # Category filter
    if category_id !== nothing
        category_name = "Unknown"
        for c in categories
            if c.id == category_id
                category_name = c.name
                break
            end
        end
        push!(filters, "{cyan}Category:{/cyan} $category_name")
    end

    if isempty(filters)
        return "{dim}No filters active{/dim}"
    end

    return join(filters, " │ ")
end

# =============================================================================
# Filter Menu Options
# =============================================================================

"""
    render_filter_menu_options(selected_index::Int)::String

Render the filter menu options.

# Arguments
- `selected_index::Int`: Currently selected option (1-based)

# Returns
- `String`: Rendered menu options

# Menu Options
1. Filter by Status
2. Filter by Project
3. Filter by Category
4. Clear All Filters
"""
function render_filter_menu_options(selected_index::Int)::String
    options = [
        ("Status", "Filter todos by status"),
        ("Project", "Filter todos by project"),
        ("Category", "Filter todos by category"),
        ("Clear All", "Remove all active filters")
    ]

    lines = String[]
    push!(lines, "{bold}Select Filter Type{/bold}")
    push!(lines, "")

    for (i, (name, desc)) in enumerate(options)
        if i == selected_index
            push!(lines, "{cyan bold}► $name{/cyan bold}")
            push!(lines, "  {dim}$desc{/dim}")
        else
            push!(lines, "  {dim}$name{/dim}")
        end
    end

    push!(lines, "")
    push!(lines, "{dim}Use j/k to navigate, Enter to select, Esc to cancel{/dim}")

    return join(lines, "\n")
end

# =============================================================================
# Status Filter Options
# =============================================================================

"""
    render_status_filter_options(current_status::Union{String,Nothing}, selected_index::Int)::String

Render the status filter selection options.

# Arguments
- `current_status::Union{String,Nothing}`: Currently active status filter
- `selected_index::Int`: Currently selected option (1-based)

# Returns
- `String`: Rendered status options

# Options
1. All (clear filter)
2. pending
3. in_progress
4. completed
5. blocked
"""
function render_status_filter_options(current_status::Union{String,Nothing}, selected_index::Int)::String
    statuses = [
        (nothing, "All", "Show all todos"),
        ("pending", "pending", "Not yet started"),
        ("in_progress", "in_progress", "Currently in progress"),
        ("completed", "completed", "Finished todos"),
        ("blocked", "blocked", "Blocked/waiting")
    ]

    lines = String[]
    push!(lines, "{bold}Filter by Status{/bold}")
    push!(lines, "")

    for (i, (value, name, desc)) in enumerate(statuses)
        # Check if this is the current filter
        is_current = (value === current_status) ||
                     (value === nothing && current_status === nothing)

        current_marker = is_current ? " {green}✓{/green}" : ""

        if i == selected_index
            push!(lines, "{cyan bold}► $name$current_marker{/cyan bold}")
            push!(lines, "  {dim}$desc{/dim}")
        else
            push!(lines, "  {dim}$name$current_marker{/dim}")
        end
    end

    push!(lines, "")
    push!(lines, "{dim}Use j/k to navigate, Enter to select, Esc to cancel{/dim}")

    return join(lines, "\n")
end

# =============================================================================
# Project Filter Options
# =============================================================================

"""
    render_project_filter_options(projects::Vector{Project}, current_id::Union{Int64,Nothing}, selected_index::Int)::String

Render the project filter selection options.

# Arguments
- `projects::Vector{Project}`: Available projects
- `current_id::Union{Int64,Nothing}`: Currently active project filter ID
- `selected_index::Int`: Currently selected option (1-based)

# Returns
- `String`: Rendered project options
"""
function render_project_filter_options(projects::Vector{Project}, current_id::Union{Int64,Nothing}, selected_index::Int)::String
    lines = String[]
    push!(lines, "{bold}Filter by Project{/bold}")
    push!(lines, "")

    # First option is "All" (clear filter)
    is_current = current_id === nothing
    current_marker = is_current ? " {green}✓{/green}" : ""

    if selected_index == 1
        push!(lines, "{cyan bold}► All Projects$current_marker{/cyan bold}")
        push!(lines, "  {dim}Show todos from all projects{/dim}")
    else
        push!(lines, "  {dim}All Projects$current_marker{/dim}")
    end

    # Project options
    for (i, project) in enumerate(projects)
        opt_index = i + 1  # +1 because "All" is index 1
        is_current = project.id == current_id
        current_marker = is_current ? " {green}✓{/green}" : ""

        if opt_index == selected_index
            push!(lines, "{cyan bold}► $(project.name)$current_marker{/cyan bold}")
            if project.description !== nothing
                push!(lines, "  {dim}$(project.description){/dim}")
            end
        else
            push!(lines, "  {dim}$(project.name)$current_marker{/dim}")
        end
    end

    if isempty(projects)
        push!(lines, "  {dim}No projects available{/dim}")
    end

    push!(lines, "")
    push!(lines, "{dim}Use j/k to navigate, Enter to select, Esc to cancel{/dim}")

    return join(lines, "\n")
end

# =============================================================================
# Category Filter Options
# =============================================================================

"""
    render_category_filter_options(categories::Vector{Category}, current_id::Union{Int64,Nothing}, selected_index::Int)::String

Render the category filter selection options.

# Arguments
- `categories::Vector{Category}`: Available categories
- `current_id::Union{Int64,Nothing}`: Currently active category filter ID
- `selected_index::Int`: Currently selected option (1-based)

# Returns
- `String`: Rendered category options
"""
function render_category_filter_options(categories::Vector{Category}, current_id::Union{Int64,Nothing}, selected_index::Int)::String
    lines = String[]
    push!(lines, "{bold}Filter by Category{/bold}")
    push!(lines, "")

    # First option is "All" (clear filter)
    is_current = current_id === nothing
    current_marker = is_current ? " {green}✓{/green}" : ""

    if selected_index == 1
        push!(lines, "{cyan bold}► All Categories$current_marker{/cyan bold}")
        push!(lines, "  {dim}Show todos from all categories{/dim}")
    else
        push!(lines, "  {dim}All Categories$current_marker{/dim}")
    end

    # Category options
    for (i, category) in enumerate(categories)
        opt_index = i + 1  # +1 because "All" is index 1
        is_current = category.id == current_id
        current_marker = is_current ? " {green}✓{/green}" : ""

        if opt_index == selected_index
            push!(lines, "{cyan bold}► $(category.name)$current_marker{/cyan bold}")
        else
            push!(lines, "  {dim}$(category.name)$current_marker{/dim}")
        end
    end

    if isempty(categories)
        push!(lines, "  {dim}No categories available{/dim}")
    end

    push!(lines, "")
    push!(lines, "{dim}Use j/k to navigate, Enter to select, Esc to cancel{/dim}")

    return join(lines, "\n")
end
