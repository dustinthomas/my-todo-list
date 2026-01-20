"""
Database schema, connection management, and initialization for TodoList.

This module handles:
- Database path configuration (cross-platform)
- Connection management with foreign key enforcement
- Schema creation (tables, constraints, indexes)
"""

using SQLite
using DBInterface

"""
    get_database_path()::String

Get the path to the user's TodoList database file.

Returns the cross-platform path to ~/.todo-list/todos.db, creating the
directory if it doesn't exist.

# Examples
```julia
db_path = get_database_path()
# => "/home/user/.todo-list/todos.db" on Linux
# => "C:\\Users\\user\\.todo-list\\todos.db" on Windows
```
"""
function get_database_path()::String
    # Cross-platform: ~/.todo-list/todos.db
    db_dir = joinpath(homedir(), ".todo-list")
    mkpath(db_dir)  # Create directory if it doesn't exist
    return joinpath(db_dir, "todos.db")
end

"""
    connect_database(db_path::String = get_database_path())::SQLite.DB

Connect to a SQLite database and enable foreign key constraints.

# Arguments
- `db_path::String`: Path to database file (default: user's TodoList database)

# Returns
- `SQLite.DB`: Database connection object

# Examples
```julia
# Connect to user database
db = connect_database()

# Connect to in-memory database for testing
db = connect_database(":memory:")
```

# Important
The following PRAGMA settings are applied for every connection:
- `foreign_keys = ON`: Enables foreign key constraint enforcement (not persistent)
- `busy_timeout = 5000`: Waits up to 5 seconds for locks before failing (helps with Docker)
- `journal_mode = WAL`: Enables Write-Ahead Logging for better concurrency (file DBs only)
"""
function connect_database(db_path::String = get_database_path())::SQLite.DB
    db = SQLite.DB(db_path)
    # CRITICAL: Enable foreign key constraints
    # This is not persistent and must be done for each connection
    DBInterface.execute(db, "PRAGMA foreign_keys = ON")

    # Set busy timeout to wait for locks instead of failing immediately
    # This helps with concurrent access and Docker bind mount issues
    # 5000ms (5 seconds) gives enough time for locks to be released
    DBInterface.execute(db, "PRAGMA busy_timeout = 5000")

    # Enable WAL (Write-Ahead Logging) mode for better concurrency
    # WAL allows readers and writers to operate simultaneously
    # This is especially helpful in Docker environments with bind mounts
    # Note: Only set for file-based databases, not :memory:
    if db_path != ":memory:"
        DBInterface.execute(db, "PRAGMA journal_mode = WAL")
    end

    return db
end

"""
    init_schema!(db::SQLite.DB)::Nothing

Initialize the database schema with all tables, constraints, and indexes.

Creates three tables:
- `projects`: Project metadata with unique names
- `categories`: Category metadata with unique names
- `todos`: Todo items with foreign keys to projects and categories

Also creates indexes on todos table for common query patterns.

# Arguments
- `db::SQLite.DB`: Database connection

# Schema Details

## projects table
- id: Primary key (auto-increment)
- name: Unique, not null
- description: Optional
- color: Hex color for visualization
- created_at, updated_at: Timestamps

## categories table
- id: Primary key (auto-increment)
- name: Unique, not null
- color: Hex color for visualization
- created_at: Timestamp

## todos table
- id: Primary key (auto-increment)
- title: Not null
- description: Optional
- status: CHECK constraint (pending, in_progress, completed, blocked)
- priority: CHECK constraint (1, 2, 3)
- project_id: Foreign key to projects (ON DELETE SET NULL)
- category_id: Foreign key to categories (ON DELETE SET NULL)
- start_date, due_date: ISO 8601 format (YYYY-MM-DD)
- completed_at, created_at, updated_at: Timestamps

## Indexes
- idx_todos_status: On todos.status
- idx_todos_project: On todos.project_id
- idx_todos_category: On todos.category_id
- idx_todos_due_date: On todos.due_date

# Examples
```julia
db = connect_database(":memory:")
init_schema!(db)
```
"""
function init_schema!(db::SQLite.DB)::Nothing
    _create_projects_table!(db)
    _create_categories_table!(db)
    _create_todos_table!(db)
    _create_indexes!(db)
    return nothing
end

"""
    _create_projects_table!(db::SQLite.DB)::Nothing

Internal helper to create the projects table.
"""
function _create_projects_table!(db::SQLite.DB)::Nothing
    DBInterface.execute(db, """
        CREATE TABLE IF NOT EXISTS projects (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL UNIQUE,
            description TEXT,
            color TEXT,
            created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
            updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
    """)
    return nothing
end

"""
    _create_categories_table!(db::SQLite.DB)::Nothing

Internal helper to create the categories table.
"""
function _create_categories_table!(db::SQLite.DB)::Nothing
    DBInterface.execute(db, """
        CREATE TABLE IF NOT EXISTS categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL UNIQUE,
            color TEXT,
            created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
    """)
    return nothing
end

"""
    _create_todos_table!(db::SQLite.DB)::Nothing

Internal helper to create the todos table with foreign keys and constraints.
"""
function _create_todos_table!(db::SQLite.DB)::Nothing
    DBInterface.execute(db, """
        CREATE TABLE IF NOT EXISTS todos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT,
            status TEXT NOT NULL DEFAULT 'pending'
                CHECK(status IN ('pending', 'in_progress', 'completed', 'blocked')),
            priority INTEGER NOT NULL DEFAULT 2
                CHECK(priority IN (1, 2, 3)),
            project_id INTEGER,
            category_id INTEGER,
            start_date TEXT,
            due_date TEXT,
            completed_at TEXT,
            created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
            updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE SET NULL,
            FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
        )
    """)
    return nothing
end

"""
    _create_indexes!(db::SQLite.DB)::Nothing

Internal helper to create indexes for common query patterns.
"""
function _create_indexes!(db::SQLite.DB)::Nothing
    _create_index!(db, "idx_todos_status", "todos", "status")
    _create_index!(db, "idx_todos_project", "todos", "project_id")
    _create_index!(db, "idx_todos_category", "todos", "category_id")
    _create_index!(db, "idx_todos_due_date", "todos", "due_date")
    return nothing
end

"""
    _create_index!(db::SQLite.DB, index_name::String, table::String, column::String)::Nothing

Internal helper to create a database index.

# Arguments
- `db::SQLite.DB`: Database connection
- `index_name::String`: Name of the index
- `table::String`: Table name
- `column::String`: Column name to index
"""
function _create_index!(db::SQLite.DB, index_name::String, table::String, column::String)::Nothing
    DBInterface.execute(db, """
        CREATE INDEX IF NOT EXISTS $index_name ON $table($column)
    """)
    return nothing
end
