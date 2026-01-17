"""
CRUD operations and query functions for TodoList database.

This module provides functions for creating, reading, updating, and deleting
projects, categories, and todos. All queries use parameterized statements to
prevent SQL injection.
"""

using SQLite
using DBInterface
using Dates

# Note: models.jl is included by TodoList.jl
# We just use the types here (Project, Category, Todo)

# ============================================================================
# Project CRUD Operations
# ============================================================================

"""
    create_project(db::SQLite.DB, name::String; description=nothing, color=nothing)::Int64

Create a new project in the database.

# Arguments
- `db::SQLite.DB`: Database connection
- `name::String`: Project name (required, must be unique)
- `description::Union{String,Nothing}`: Optional project description
- `color::Union{String,Nothing}`: Optional hex color code (e.g., "#FF6B6B")

# Returns
- `Int64`: The ID of the newly created project

# Throws
- `ErrorException`: If project name already exists

# Examples
```julia
db = connect_database(":memory:")
init_schema!(db)

# Create project with name only
proj_id = create_project(db, "My Project")

# Create project with all fields
proj_id = create_project(db, "Home Renovation",
                         description="Kitchen remodel",
                         color="#FF6B6B")
```
"""
function create_project(db::SQLite.DB, name::String;
                       description::Union{String,Nothing}=nothing,
                       color::Union{String,Nothing}=nothing)::Int64
    try
        stmt = DBInterface.prepare(db, """
            INSERT INTO projects (name, description, color)
            VALUES (?, ?, ?)
        """)
        result = DBInterface.execute(stmt, [name, description, color])
        return DBInterface.lastrowid(result)
    catch e
        if occursin("UNIQUE constraint failed", string(e))
            error("Project with name '$name' already exists")
        else
            rethrow(e)
        end
    end
end

"""
    get_project(db::SQLite.DB, id::Int64)::Union{Project, Nothing}

Retrieve a project by its ID.

# Arguments
- `db::SQLite.DB`: Database connection
- `id::Int64`: Project ID

# Returns
- `Project`: The project if found
- `Nothing`: If no project with the given ID exists

# Examples
```julia
proj = get_project(db, 1)
if proj !== nothing
    println("Found project: ", proj.name)
end
```
"""
function get_project(db::SQLite.DB, id::Int64)::Union{Project, Nothing}
    stmt = DBInterface.prepare(db, """
        SELECT id, name, description, color, created_at, updated_at
        FROM projects
        WHERE id = ?
    """)
    result = DBInterface.execute(stmt, [id])

    for row in result
        return Project(
            row[:id],
            row[:name],
            ismissing(row[:description]) ? nothing : row[:description],
            ismissing(row[:color]) ? nothing : row[:color],
            ismissing(row[:created_at]) ? nothing : row[:created_at],
            ismissing(row[:updated_at]) ? nothing : row[:updated_at]
        )
    end

    return nothing
end

"""
    list_projects(db::SQLite.DB)::Vector{Project}

Retrieve all projects from the database.

# Arguments
- `db::SQLite.DB`: Database connection

# Returns
- `Vector{Project}`: Array of all projects (empty array if none exist)

# Examples
```julia
projects = list_projects(db)
for proj in projects
    println(proj.name)
end
```
"""
function list_projects(db::SQLite.DB)::Vector{Project}
    result = DBInterface.execute(db, """
        SELECT id, name, description, color, created_at, updated_at
        FROM projects
        ORDER BY name
    """)

    projects = Project[]
    for row in result
        push!(projects, Project(
            row[:id],
            row[:name],
            ismissing(row[:description]) ? nothing : row[:description],
            ismissing(row[:color]) ? nothing : row[:color],
            ismissing(row[:created_at]) ? nothing : row[:created_at],
            ismissing(row[:updated_at]) ? nothing : row[:updated_at]
        ))
    end

    return projects
end

"""
    update_project!(db::SQLite.DB, id::Int64; name=nothing, description=nothing, color=nothing)::Bool

Update a project's fields.

Only provided fields will be updated. The `updated_at` timestamp is automatically set.

# Arguments
- `db::SQLite.DB`: Database connection
- `id::Int64`: Project ID to update
- `name::Union{String,Nothing}`: New name (optional)
- `description::Union{String,Nothing}`: New description (optional)
- `color::Union{String,Nothing}`: New color (optional)

# Returns
- `Bool`: `true` if project was updated, `false` if project not found

# Examples
```julia
# Update single field
updated = update_project!(db, 1, name="New Name")

# Update multiple fields
updated = update_project!(db, 1, description="New desc", color="#00FF00")
```
"""
function update_project!(db::SQLite.DB, id::Int64;
                        name::Union{String,Nothing}=nothing,
                        description::Union{String,Nothing}=nothing,
                        color::Union{String,Nothing}=nothing)::Bool
    # Build dynamic UPDATE query for provided fields
    updates = String[]
    params = []

    if name !== nothing
        push!(updates, "name = ?")
        push!(params, name)
    end
    if description !== nothing
        push!(updates, "description = ?")
        push!(params, description)
    end
    if color !== nothing
        push!(updates, "color = ?")
        push!(params, color)
    end

    # Always update the timestamp
    push!(updates, "updated_at = ?")
    push!(params, Dates.format(now(), "yyyy-mm-dd HH:MM:SS"))

    # Add id for WHERE clause
    push!(params, id)

    if isempty(updates)
        return false  # Nothing to update
    end

    query = "UPDATE projects SET " * join(updates, ", ") * " WHERE id = ?"
    stmt = DBInterface.prepare(db, query)
    DBInterface.execute(stmt, params)

    # Verify the row exists
    return get_project(db, id) !== nothing
end

"""
    delete_project!(db::SQLite.DB, id::Int64)::Bool

Delete a project from the database.

When a project is deleted, all todos associated with it will have their
`project_id` set to NULL (due to ON DELETE SET NULL constraint).

# Arguments
- `db::SQLite.DB`: Database connection
- `id::Int64`: Project ID to delete

# Returns
- `Bool`: `true` if project was deleted, `false` if project not found

# Examples
```julia
deleted = delete_project!(db, 1)
if deleted
    println("Project deleted successfully")
end
```
"""
function delete_project!(db::SQLite.DB, id::Int64)::Bool
    # Check if project exists before deleting
    if get_project(db, id) === nothing
        return false
    end

    stmt = DBInterface.prepare(db, "DELETE FROM projects WHERE id = ?")
    DBInterface.execute(stmt, [id])
    return true
end

# ============================================================================
# Category CRUD Operations
# ============================================================================

"""
    create_category(db::SQLite.DB, name::String; color=nothing)::Int64

Create a new category in the database.

# Arguments
- `db::SQLite.DB`: Database connection
- `name::String`: Category name (required, must be unique)
- `color::Union{String,Nothing}`: Optional hex color code (e.g., "#E74C3C")

# Returns
- `Int64`: The ID of the newly created category

# Throws
- `ErrorException`: If category name already exists

# Examples
```julia
db = connect_database(":memory:")
init_schema!(db)

# Create category with name only
cat_id = create_category(db, "Urgent")

# Create category with color
cat_id = create_category(db, "Planning", color="#3498DB")
```
"""
function create_category(db::SQLite.DB, name::String;
                        color::Union{String,Nothing}=nothing)::Int64
    try
        stmt = DBInterface.prepare(db, """
            INSERT INTO categories (name, color)
            VALUES (?, ?)
        """)
        result = DBInterface.execute(stmt, [name, color])
        return DBInterface.lastrowid(result)
    catch e
        if occursin("UNIQUE constraint failed", string(e))
            error("Category with name '$name' already exists")
        else
            rethrow(e)
        end
    end
end

"""
    get_category(db::SQLite.DB, id::Int64)::Union{Category, Nothing}

Retrieve a category by its ID.

# Arguments
- `db::SQLite.DB`: Database connection
- `id::Int64`: Category ID

# Returns
- `Category`: The category if found
- `Nothing`: If no category with the given ID exists

# Examples
```julia
cat = get_category(db, 1)
if cat !== nothing
    println("Found category: ", cat.name)
end
```
"""
function get_category(db::SQLite.DB, id::Int64)::Union{Category, Nothing}
    stmt = DBInterface.prepare(db, """
        SELECT id, name, color, created_at
        FROM categories
        WHERE id = ?
    """)
    result = DBInterface.execute(stmt, [id])

    for row in result
        return Category(
            row[:id],
            row[:name],
            ismissing(row[:color]) ? nothing : row[:color],
            ismissing(row[:created_at]) ? nothing : row[:created_at]
        )
    end

    return nothing
end

"""
    list_categories(db::SQLite.DB)::Vector{Category}

Retrieve all categories from the database.

# Arguments
- `db::SQLite.DB`: Database connection

# Returns
- `Vector{Category}`: Array of all categories (empty array if none exist)

# Examples
```julia
categories = list_categories(db)
for cat in categories
    println(cat.name)
end
```
"""
function list_categories(db::SQLite.DB)::Vector{Category}
    result = DBInterface.execute(db, """
        SELECT id, name, color, created_at
        FROM categories
        ORDER BY name
    """)

    categories = Category[]
    for row in result
        push!(categories, Category(
            row[:id],
            row[:name],
            ismissing(row[:color]) ? nothing : row[:color],
            ismissing(row[:created_at]) ? nothing : row[:created_at]
        ))
    end

    return categories
end

"""
    update_category!(db::SQLite.DB, id::Int64; name=nothing, color=nothing)::Bool

Update a category's fields.

Only provided fields will be updated.

# Arguments
- `db::SQLite.DB`: Database connection
- `id::Int64`: Category ID to update
- `name::Union{String,Nothing}`: New name (optional)
- `color::Union{String,Nothing}`: New color (optional)

# Returns
- `Bool`: `true` if category was updated, `false` if category not found

# Examples
```julia
# Update single field
updated = update_category!(db, 1, name="New Name")

# Update color
updated = update_category!(db, 1, color="#FF0000")
```
"""
function update_category!(db::SQLite.DB, id::Int64;
                         name::Union{String,Nothing}=nothing,
                         color::Union{String,Nothing}=nothing)::Bool
    # Build dynamic UPDATE query for provided fields
    updates = String[]
    params = []

    if name !== nothing
        push!(updates, "name = ?")
        push!(params, name)
    end
    if color !== nothing
        push!(updates, "color = ?")
        push!(params, color)
    end

    # Add id for WHERE clause
    push!(params, id)

    if isempty(updates)
        return false  # Nothing to update
    end

    query = "UPDATE categories SET " * join(updates, ", ") * " WHERE id = ?"
    stmt = DBInterface.prepare(db, query)
    DBInterface.execute(stmt, params)

    # Verify the row exists
    return get_category(db, id) !== nothing
end

"""
    delete_category!(db::SQLite.DB, id::Int64)::Bool

Delete a category from the database.

When a category is deleted, all todos associated with it will have their
`category_id` set to NULL (due to ON DELETE SET NULL constraint).

# Arguments
- `db::SQLite.DB`: Database connection
- `id::Int64`: Category ID to delete

# Returns
- `Bool`: `true` if category was deleted, `false` if category not found

# Examples
```julia
deleted = delete_category!(db, 1)
if deleted
    println("Category deleted successfully")
end
```
"""
function delete_category!(db::SQLite.DB, id::Int64)::Bool
    # Check if category exists before deleting
    if get_category(db, id) === nothing
        return false
    end

    stmt = DBInterface.prepare(db, "DELETE FROM categories WHERE id = ?")
    DBInterface.execute(stmt, [id])
    return true
end

# ============================================================================
# Todo CRUD Operations
# ============================================================================

"""
    create_todo(db::SQLite.DB, title::String; kwargs...)::Int64

Create a new todo in the database.

# Arguments
- `db::SQLite.DB`: Database connection
- `title::String`: Todo title (required)
- `description::Union{String,Nothing}`: Optional description
- `status::String`: Status (default: "pending"). Must be one of: pending, in_progress, completed, blocked
- `priority::Int`: Priority 1-3 (default: 2). 1=high, 2=medium, 3=low
- `project_id::Union{Int64,Nothing}`: Optional project ID (must exist)
- `category_id::Union{Int64,Nothing}`: Optional category ID (must exist)
- `start_date::Union{String,Nothing}`: Optional start date (YYYY-MM-DD format)
- `due_date::Union{String,Nothing}`: Optional due date (YYYY-MM-DD format)

# Returns
- `Int64`: The ID of the newly created todo

# Throws
- `ErrorException`: If validation fails (invalid status, priority, date format, or foreign keys)

# Examples
```julia
db = connect_database(":memory:")
init_schema!(db)

# Create simple todo
todo_id = create_todo(db, "Buy groceries")

# Create todo with all fields
proj_id = create_project(db, "Home")
cat_id = create_category(db, "Urgent")
todo_id = create_todo(db, "Fix leak",
                     description="Kitchen sink leaking",
                     status="in_progress",
                     priority=1,
                     project_id=proj_id,
                     category_id=cat_id,
                     due_date="2026-01-20")
```
"""
function create_todo(db::SQLite.DB, title::String;
                    description::Union{String,Nothing}=nothing,
                    status::String="pending",
                    priority::Int=2,
                    project_id::Union{Int64,Nothing}=nothing,
                    category_id::Union{Int64,Nothing}=nothing,
                    start_date::Union{String,Nothing}=nothing,
                    due_date::Union{String,Nothing}=nothing)::Int64
    # Validate status
    valid_statuses = ["pending", "in_progress", "completed", "blocked"]
    if !(status in valid_statuses)
        error("Invalid status '$status'. Must be one of: $(join(valid_statuses, ", "))")
    end

    # Validate priority
    if !(priority in [1, 2, 3])
        error("Invalid priority $priority. Must be 1 (high), 2 (medium), or 3 (low)")
    end

    # Validate date formats
    if start_date !== nothing
        try
            Date(start_date, "yyyy-mm-dd")
        catch e
            error("Invalid start_date format '$start_date'. Must be YYYY-MM-DD")
        end
    end

    if due_date !== nothing
        try
            Date(due_date, "yyyy-mm-dd")
        catch e
            error("Invalid due_date format '$due_date'. Must be YYYY-MM-DD")
        end
    end

    try
        stmt = DBInterface.prepare(db, """
            INSERT INTO todos (title, description, status, priority,
                             project_id, category_id, start_date, due_date)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """)
        result = DBInterface.execute(stmt, [title, description, status, priority,
                                           project_id, category_id, start_date, due_date])
        return DBInterface.lastrowid(result)
    catch e
        if occursin("FOREIGN KEY constraint failed", string(e))
            if project_id !== nothing
                error("Invalid project_id $project_id. Project does not exist")
            elseif category_id !== nothing
                error("Invalid category_id $category_id. Category does not exist")
            else
                error("Foreign key constraint failed")
            end
        else
            rethrow(e)
        end
    end
end

"""
    get_todo(db::SQLite.DB, id::Int64)::Union{Todo, Nothing}

Retrieve a todo by its ID.

# Arguments
- `db::SQLite.DB`: Database connection
- `id::Int64`: Todo ID

# Returns
- `Todo`: The todo if found
- `Nothing`: If no todo with the given ID exists

# Examples
```julia
todo = get_todo(db, 1)
if todo !== nothing
    println("Found todo: ", todo.title)
end
```
"""
function get_todo(db::SQLite.DB, id::Int64)::Union{Todo, Nothing}
    stmt = DBInterface.prepare(db, """
        SELECT id, title, description, status, priority,
               project_id, category_id, start_date, due_date,
               completed_at, created_at, updated_at
        FROM todos
        WHERE id = ?
    """)
    result = DBInterface.execute(stmt, [id])

    for row in result
        return Todo(
            row[:id],
            row[:title],
            ismissing(row[:description]) ? nothing : row[:description],
            row[:status],
            row[:priority],
            ismissing(row[:project_id]) ? nothing : row[:project_id],
            ismissing(row[:category_id]) ? nothing : row[:category_id],
            ismissing(row[:start_date]) ? nothing : row[:start_date],
            ismissing(row[:due_date]) ? nothing : row[:due_date],
            ismissing(row[:completed_at]) ? nothing : row[:completed_at],
            ismissing(row[:created_at]) ? nothing : row[:created_at],
            ismissing(row[:updated_at]) ? nothing : row[:updated_at]
        )
    end

    return nothing
end

"""
    list_todos(db::SQLite.DB)::Vector{Todo}

Retrieve all todos from the database.

# Arguments
- `db::SQLite.DB`: Database connection

# Returns
- `Vector{Todo}`: Array of all todos (empty array if none exist)

# Examples
```julia
todos = list_todos(db)
for todo in todos
    println(todo.title)
end
```
"""
function list_todos(db::SQLite.DB)::Vector{Todo}
    result = DBInterface.execute(db, """
        SELECT id, title, description, status, priority,
               project_id, category_id, start_date, due_date,
               completed_at, created_at, updated_at
        FROM todos
        ORDER BY created_at DESC
    """)

    todos = Todo[]
    for row in result
        push!(todos, Todo(
            row[:id],
            row[:title],
            ismissing(row[:description]) ? nothing : row[:description],
            row[:status],
            row[:priority],
            ismissing(row[:project_id]) ? nothing : row[:project_id],
            ismissing(row[:category_id]) ? nothing : row[:category_id],
            ismissing(row[:start_date]) ? nothing : row[:start_date],
            ismissing(row[:due_date]) ? nothing : row[:due_date],
            ismissing(row[:completed_at]) ? nothing : row[:completed_at],
            ismissing(row[:created_at]) ? nothing : row[:created_at],
            ismissing(row[:updated_at]) ? nothing : row[:updated_at]
        ))
    end

    return todos
end

"""
    update_todo!(db::SQLite.DB, id::Int64; kwargs...)::Bool

Update a todo's fields.

Only provided fields will be updated. The `updated_at` timestamp is automatically set.

# Arguments
- `db::SQLite.DB`: Database connection
- `id::Int64`: Todo ID to update
- `title::Union{String,Nothing}`: New title (optional)
- `description::Union{String,Nothing}`: New description (optional)
- `status::Union{String,Nothing}`: New status (optional, must be valid)
- `priority::Union{Int,Nothing}`: New priority (optional, must be 1-3)
- `project_id::Union{Int64,Nothing}`: New project ID (optional)
- `category_id::Union{Int64,Nothing}`: New category ID (optional)
- `start_date::Union{String,Nothing}`: New start date (optional, YYYY-MM-DD)
- `due_date::Union{String,Nothing}`: New due date (optional, YYYY-MM-DD)

# Returns
- `Bool`: `true` if todo was updated, `false` if todo not found

# Throws
- `ErrorException`: If validation fails for status, priority, or date formats

# Examples
```julia
# Update single field
updated = update_todo!(db, 1, title="New title")

# Update multiple fields
updated = update_todo!(db, 1, status="completed", priority=1)
```
"""
function update_todo!(db::SQLite.DB, id::Int64;
                     title::Union{String,Nothing}=nothing,
                     description::Union{String,Nothing}=nothing,
                     status::Union{String,Nothing}=nothing,
                     priority::Union{Int,Nothing}=nothing,
                     project_id::Union{Int64,Nothing}=nothing,
                     category_id::Union{Int64,Nothing}=nothing,
                     start_date::Union{String,Nothing}=nothing,
                     due_date::Union{String,Nothing}=nothing)::Bool
    # Validate status if provided
    if status !== nothing
        valid_statuses = ["pending", "in_progress", "completed", "blocked"]
        if !(status in valid_statuses)
            error("Invalid status '$status'. Must be one of: $(join(valid_statuses, ", "))")
        end
    end

    # Validate priority if provided
    if priority !== nothing
        if !(priority in [1, 2, 3])
            error("Invalid priority $priority. Must be 1 (high), 2 (medium), or 3 (low)")
        end
    end

    # Validate date formats if provided
    if start_date !== nothing
        try
            Date(start_date, "yyyy-mm-dd")
        catch e
            error("Invalid start_date format '$start_date'. Must be YYYY-MM-DD")
        end
    end

    if due_date !== nothing
        try
            Date(due_date, "yyyy-mm-dd")
        catch e
            error("Invalid due_date format '$due_date'. Must be YYYY-MM-DD")
        end
    end

    # Build dynamic UPDATE query for provided fields
    updates = String[]
    params = []

    if title !== nothing
        push!(updates, "title = ?")
        push!(params, title)
    end
    if description !== nothing
        push!(updates, "description = ?")
        push!(params, description)
    end
    if status !== nothing
        push!(updates, "status = ?")
        push!(params, status)
    end
    if priority !== nothing
        push!(updates, "priority = ?")
        push!(params, priority)
    end
    if project_id !== nothing
        push!(updates, "project_id = ?")
        push!(params, project_id)
    end
    if category_id !== nothing
        push!(updates, "category_id = ?")
        push!(params, category_id)
    end
    if start_date !== nothing
        push!(updates, "start_date = ?")
        push!(params, start_date)
    end
    if due_date !== nothing
        push!(updates, "due_date = ?")
        push!(params, due_date)
    end

    # Always update the timestamp
    push!(updates, "updated_at = ?")
    push!(params, Dates.format(now(), "yyyy-mm-dd HH:MM:SS"))

    # Add id for WHERE clause
    push!(params, id)

    if isempty(updates)
        return false  # Nothing to update
    end

    query = "UPDATE todos SET " * join(updates, ", ") * " WHERE id = ?"
    stmt = DBInterface.prepare(db, query)
    DBInterface.execute(stmt, params)

    # Verify the row exists
    return get_todo(db, id) !== nothing
end

"""
    complete_todo!(db::SQLite.DB, id::Int64)::Bool

Mark a todo as completed.

This is a convenience function that sets the status to "completed" and records
the completion timestamp.

# Arguments
- `db::SQLite.DB`: Database connection
- `id::Int64`: Todo ID to complete

# Returns
- `Bool`: `true` if todo was completed, `false` if todo not found

# Examples
```julia
completed = complete_todo!(db, 1)
if completed
    println("Todo marked as completed")
end
```
"""
function complete_todo!(db::SQLite.DB, id::Int64)::Bool
    # Check if todo exists
    if get_todo(db, id) === nothing
        return false
    end

    timestamp = Dates.format(now(), "yyyy-mm-dd HH:MM:SS")

    stmt = DBInterface.prepare(db, """
        UPDATE todos
        SET status = 'completed',
            completed_at = ?,
            updated_at = ?
        WHERE id = ?
    """)
    DBInterface.execute(stmt, [timestamp, timestamp, id])
    return true
end

"""
    delete_todo!(db::SQLite.DB, id::Int64)::Bool

Delete a todo from the database.

# Arguments
- `db::SQLite.DB`: Database connection
- `id::Int64`: Todo ID to delete

# Returns
- `Bool`: `true` if todo was deleted, `false` if todo not found

# Examples
```julia
deleted = delete_todo!(db, 1)
if deleted
    println("Todo deleted successfully")
end
```
"""
function delete_todo!(db::SQLite.DB, id::Int64)::Bool
    # Check if todo exists before deleting
    if get_todo(db, id) === nothing
        return false
    end

    stmt = DBInterface.prepare(db, "DELETE FROM todos WHERE id = ?")
    DBInterface.execute(stmt, [id])
    return true
end

# ============================================================================
# Filtering Functions
# ============================================================================

"""
    filter_todos_by_status(db::SQLite.DB, status::String)::Vector{Todo}

Filter todos by their status.

# Arguments
- `db::SQLite.DB`: Database connection
- `status::String`: Status to filter by (pending, in_progress, completed, blocked)

# Returns
- `Vector{Todo}`: Array of todos matching the status (empty array if none match)

# Examples
```julia
pending_todos = filter_todos_by_status(db, "pending")
completed_todos = filter_todos_by_status(db, "completed")
```
"""
function filter_todos_by_status(db::SQLite.DB, status::String)::Vector{Todo}
    stmt = DBInterface.prepare(db, """
        SELECT id, title, description, status, priority,
               project_id, category_id, start_date, due_date,
               completed_at, created_at, updated_at
        FROM todos
        WHERE status = ?
        ORDER BY created_at DESC
    """)
    result = DBInterface.execute(stmt, [status])

    todos = Todo[]
    for row in result
        push!(todos, Todo(
            row[:id],
            row[:title],
            ismissing(row[:description]) ? nothing : row[:description],
            row[:status],
            row[:priority],
            ismissing(row[:project_id]) ? nothing : row[:project_id],
            ismissing(row[:category_id]) ? nothing : row[:category_id],
            ismissing(row[:start_date]) ? nothing : row[:start_date],
            ismissing(row[:due_date]) ? nothing : row[:due_date],
            ismissing(row[:completed_at]) ? nothing : row[:completed_at],
            ismissing(row[:created_at]) ? nothing : row[:created_at],
            ismissing(row[:updated_at]) ? nothing : row[:updated_at]
        ))
    end

    return todos
end

"""
    filter_todos_by_project(db::SQLite.DB, project_id::Int64)::Vector{Todo}

Filter todos by their project.

# Arguments
- `db::SQLite.DB`: Database connection
- `project_id::Int64`: Project ID to filter by

# Returns
- `Vector{Todo}`: Array of todos belonging to the project (empty array if none match)

# Examples
```julia
project_todos = filter_todos_by_project(db, 1)
```
"""
function filter_todos_by_project(db::SQLite.DB, project_id::Int64)::Vector{Todo}
    stmt = DBInterface.prepare(db, """
        SELECT id, title, description, status, priority,
               project_id, category_id, start_date, due_date,
               completed_at, created_at, updated_at
        FROM todos
        WHERE project_id = ?
        ORDER BY created_at DESC
    """)
    result = DBInterface.execute(stmt, [project_id])

    todos = Todo[]
    for row in result
        push!(todos, Todo(
            row[:id],
            row[:title],
            ismissing(row[:description]) ? nothing : row[:description],
            row[:status],
            row[:priority],
            ismissing(row[:project_id]) ? nothing : row[:project_id],
            ismissing(row[:category_id]) ? nothing : row[:category_id],
            ismissing(row[:start_date]) ? nothing : row[:start_date],
            ismissing(row[:due_date]) ? nothing : row[:due_date],
            ismissing(row[:completed_at]) ? nothing : row[:completed_at],
            ismissing(row[:created_at]) ? nothing : row[:created_at],
            ismissing(row[:updated_at]) ? nothing : row[:updated_at]
        ))
    end

    return todos
end

"""
    filter_todos_by_category(db::SQLite.DB, category_id::Int64)::Vector{Todo}

Filter todos by their category.

# Arguments
- `db::SQLite.DB`: Database connection
- `category_id::Int64`: Category ID to filter by

# Returns
- `Vector{Todo}`: Array of todos in the category (empty array if none match)

# Examples
```julia
urgent_todos = filter_todos_by_category(db, urgent_category_id)
```
"""
function filter_todos_by_category(db::SQLite.DB, category_id::Int64)::Vector{Todo}
    stmt = DBInterface.prepare(db, """
        SELECT id, title, description, status, priority,
               project_id, category_id, start_date, due_date,
               completed_at, created_at, updated_at
        FROM todos
        WHERE category_id = ?
        ORDER BY created_at DESC
    """)
    result = DBInterface.execute(stmt, [category_id])

    todos = Todo[]
    for row in result
        push!(todos, Todo(
            row[:id],
            row[:title],
            ismissing(row[:description]) ? nothing : row[:description],
            row[:status],
            row[:priority],
            ismissing(row[:project_id]) ? nothing : row[:project_id],
            ismissing(row[:category_id]) ? nothing : row[:category_id],
            ismissing(row[:start_date]) ? nothing : row[:start_date],
            ismissing(row[:due_date]) ? nothing : row[:due_date],
            ismissing(row[:completed_at]) ? nothing : row[:completed_at],
            ismissing(row[:created_at]) ? nothing : row[:created_at],
            ismissing(row[:updated_at]) ? nothing : row[:updated_at]
        ))
    end

    return todos
end

"""
    filter_todos_by_date_range(db::SQLite.DB; start_date=nothing, due_date=nothing)::Vector{Todo}

Filter todos by date range.

- If `start_date` is provided, returns todos with start_date >= the given date
- If `due_date` is provided, returns todos with due_date <= the given date
- If both are provided, both conditions must be met
- Todos with NULL dates are excluded when filtering by that date field

# Arguments
- `db::SQLite.DB`: Database connection
- `start_date::Union{String,Nothing}`: Minimum start date (YYYY-MM-DD format, optional)
- `due_date::Union{String,Nothing}`: Maximum due date (YYYY-MM-DD format, optional)

# Returns
- `Vector{Todo}`: Array of todos within the date range (empty array if none match)

# Examples
```julia
# Todos starting after Jan 1, 2026
future_todos = filter_todos_by_date_range(db, start_date="2026-01-01")

# Todos due before Feb 1, 2026
upcoming_todos = filter_todos_by_date_range(db, due_date="2026-02-01")

# Todos in a specific range
range_todos = filter_todos_by_date_range(db, start_date="2026-01-01", due_date="2026-01-31")
```
"""
function filter_todos_by_date_range(db::SQLite.DB;
                                   start_date::Union{String,Nothing}=nothing,
                                   due_date::Union{String,Nothing}=nothing)::Vector{Todo}
    # Build dynamic WHERE clause
    conditions = String[]
    params = []

    if start_date !== nothing
        push!(conditions, "start_date IS NOT NULL AND start_date >= ?")
        push!(params, start_date)
    end

    if due_date !== nothing
        push!(conditions, "due_date IS NOT NULL AND due_date <= ?")
        push!(params, due_date)
    end

    # If no filters provided, return empty (or should return all? Plan says filter)
    if isempty(conditions)
        return list_todos(db)
    end

    query = """
        SELECT id, title, description, status, priority,
               project_id, category_id, start_date, due_date,
               completed_at, created_at, updated_at
        FROM todos
        WHERE """ * join(conditions, " AND ") * """
        ORDER BY created_at DESC
    """

    stmt = DBInterface.prepare(db, query)
    result = DBInterface.execute(stmt, params)

    todos = Todo[]
    for row in result
        push!(todos, Todo(
            row[:id],
            row[:title],
            ismissing(row[:description]) ? nothing : row[:description],
            row[:status],
            row[:priority],
            ismissing(row[:project_id]) ? nothing : row[:project_id],
            ismissing(row[:category_id]) ? nothing : row[:category_id],
            ismissing(row[:start_date]) ? nothing : row[:start_date],
            ismissing(row[:due_date]) ? nothing : row[:due_date],
            ismissing(row[:completed_at]) ? nothing : row[:completed_at],
            ismissing(row[:created_at]) ? nothing : row[:created_at],
            ismissing(row[:updated_at]) ? nothing : row[:updated_at]
        ))
    end

    return todos
end

"""
    filter_todos(db::SQLite.DB; status=nothing, project_id=nothing, category_id=nothing,
                 start_date=nothing, due_date=nothing)::Vector{Todo}

Filter todos by multiple criteria. All provided parameters are combined with AND logic.

# Arguments
- `db::SQLite.DB`: Database connection
- `status::Union{String,Nothing}`: Filter by status (optional)
- `project_id::Union{Int64,Nothing}`: Filter by project (optional)
- `category_id::Union{Int64,Nothing}`: Filter by category (optional)
- `start_date::Union{String,Nothing}`: Minimum start date (optional)
- `due_date::Union{String,Nothing}`: Maximum due date (optional)

# Returns
- `Vector{Todo}`: Array of todos matching all provided criteria (empty array if none match)
- If no parameters provided, returns all todos

# Examples
```julia
# Filter by status only
pending = filter_todos(db, status="pending")

# Filter by status and project
project_pending = filter_todos(db, status="pending", project_id=1)

# Filter with all criteria
results = filter_todos(db, status="in_progress", project_id=1, category_id=2,
                      start_date="2026-01-01", due_date="2026-01-31")
```
"""
function filter_todos(db::SQLite.DB;
                     status::Union{String,Nothing}=nothing,
                     project_id::Union{Int64,Nothing}=nothing,
                     category_id::Union{Int64,Nothing}=nothing,
                     start_date::Union{String,Nothing}=nothing,
                     due_date::Union{String,Nothing}=nothing)::Vector{Todo}
    # Build dynamic WHERE clause
    conditions = String[]
    params = []

    if status !== nothing
        push!(conditions, "status = ?")
        push!(params, status)
    end

    if project_id !== nothing
        push!(conditions, "project_id = ?")
        push!(params, project_id)
    end

    if category_id !== nothing
        push!(conditions, "category_id = ?")
        push!(params, category_id)
    end

    if start_date !== nothing
        push!(conditions, "start_date IS NOT NULL AND start_date >= ?")
        push!(params, start_date)
    end

    if due_date !== nothing
        push!(conditions, "due_date IS NOT NULL AND due_date <= ?")
        push!(params, due_date)
    end

    # Build query
    query = """
        SELECT id, title, description, status, priority,
               project_id, category_id, start_date, due_date,
               completed_at, created_at, updated_at
        FROM todos
    """

    if !isempty(conditions)
        query *= " WHERE " * join(conditions, " AND ")
    end

    query *= " ORDER BY created_at DESC"

    if isempty(params)
        result = DBInterface.execute(db, query)
    else
        stmt = DBInterface.prepare(db, query)
        result = DBInterface.execute(stmt, params)
    end

    todos = Todo[]
    for row in result
        push!(todos, Todo(
            row[:id],
            row[:title],
            ismissing(row[:description]) ? nothing : row[:description],
            row[:status],
            row[:priority],
            ismissing(row[:project_id]) ? nothing : row[:project_id],
            ismissing(row[:category_id]) ? nothing : row[:category_id],
            ismissing(row[:start_date]) ? nothing : row[:start_date],
            ismissing(row[:due_date]) ? nothing : row[:due_date],
            ismissing(row[:completed_at]) ? nothing : row[:completed_at],
            ismissing(row[:created_at]) ? nothing : row[:created_at],
            ismissing(row[:updated_at]) ? nothing : row[:updated_at]
        ))
    end

    return todos
end
