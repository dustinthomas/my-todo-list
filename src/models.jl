"""
Data models for TodoList application.

This module defines the core data structures that mirror the database schema:
- Project: Represents a project that groups related todos
- Category: Represents a category for organizing todos
- Todo: Represents an individual todo item with status, priority, and dates
"""

"""
    Project

Represents a project in the TodoList system.

# Fields
- `id::Union{Int64, Nothing}`: Primary key (auto-increment in database)
- `name::String`: Project name (required, unique)
- `description::Union{String, Nothing}`: Optional project description
- `color::Union{String, Nothing}`: Hex color code for visualization (e.g., "#FF6B6B")
- `created_at::Union{String, Nothing}`: Creation timestamp (ISO 8601 format)
- `updated_at::Union{String, Nothing}`: Last update timestamp (ISO 8601 format)
"""
struct Project
    id::Union{Int64, Nothing}
    name::String
    description::Union{String, Nothing}
    color::Union{String, Nothing}
    created_at::Union{String, Nothing}
    updated_at::Union{String, Nothing}
end

"""
    Category

Represents a category for organizing todos.

# Fields
- `id::Union{Int64, Nothing}`: Primary key (auto-increment in database)
- `name::String`: Category name (required, unique)
- `color::Union{String, Nothing}`: Hex color code for visualization (e.g., "#E74C3C")
- `created_at::Union{String, Nothing}`: Creation timestamp (ISO 8601 format)
"""
struct Category
    id::Union{Int64, Nothing}
    name::String
    color::Union{String, Nothing}
    created_at::Union{String, Nothing}
end

"""
    Todo

Represents an individual todo item.

# Fields
- `id::Union{Int64, Nothing}`: Primary key (auto-increment in database)
- `title::String`: Todo title (required)
- `description::Union{String, Nothing}`: Optional detailed description
- `status::String`: Current status - one of: "pending", "in_progress", "completed", "blocked"
- `priority::Int`: Priority level - 1 (high), 2 (medium), 3 (low)
- `project_id::Union{Int64, Nothing}`: Foreign key to projects table
- `category_id::Union{Int64, Nothing}`: Foreign key to categories table
- `start_date::Union{String, Nothing}`: Start date in YYYY-MM-DD format
- `due_date::Union{String, Nothing}`: Due date in YYYY-MM-DD format
- `completed_at::Union{String, Nothing}`: Completion timestamp (ISO 8601 format)
- `created_at::Union{String, Nothing}`: Creation timestamp (ISO 8601 format)
- `updated_at::Union{String, Nothing}`: Last update timestamp (ISO 8601 format)
"""
struct Todo
    id::Union{Int64, Nothing}
    title::String
    description::Union{String, Nothing}
    status::String
    priority::Int
    project_id::Union{Int64, Nothing}
    category_id::Union{Int64, Nothing}
    start_date::Union{String, Nothing}
    due_date::Union{String, Nothing}
    completed_at::Union{String, Nothing}
    created_at::Union{String, Nothing}
    updated_at::Union{String, Nothing}
end
