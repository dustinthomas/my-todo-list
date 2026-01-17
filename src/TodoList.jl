"""
TodoList - A simple, maintainable TUI todo list manager

This module provides a complete database layer for managing projects, categories,
and todos with SQLite persistence.
"""
module TodoList

# Import dependencies
using SQLite
using DBInterface
using Dates

# Include source files
include("models.jl")
include("database.jl")
include("queries.jl")

# Export data models
export Project, Category, Todo

# Export database functions
export connect_database, init_schema!, get_database_path

# Export Project CRUD
export create_project, get_project, list_projects, update_project!, delete_project!

# Export Category CRUD
export create_category, get_category, list_categories, update_category!, delete_category!

# Export Todo CRUD
export create_todo, get_todo, list_todos, update_todo!, complete_todo!, delete_todo!

# Export Filtering functions
export filter_todos_by_status, filter_todos_by_project, filter_todos_by_category
export filter_todos_by_date_range, filter_todos

end # module
