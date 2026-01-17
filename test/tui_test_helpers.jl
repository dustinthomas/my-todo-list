"""
Test utilities for TUI testing.

This module provides helper functions for creating test states,
seeding test data, and asserting content in rendered output.
"""

using TodoList
using SQLite
using Test

"""
    create_test_state(; with_data::Bool=false)::AppState

Create a fresh AppState with in-memory database for testing.

# Arguments
- `with_data::Bool`: If true, seed database with standard test data

# Examples
```julia
state = create_test_state()  # Empty database
state = create_test_state(with_data=true)  # With test data
```
"""
function create_test_state(; with_data::Bool=false)::AppState
    db = connect_database(":memory:")
    init_schema!(db)
    if with_data
        seed_test_data!(db)
    end
    return create_initial_state(db)
end

"""
    seed_test_data!(db::SQLite.DB)::Nothing

Seed database with standard test data for TUI testing.

Creates:
- 1 project: "Test Project"
- 1 category: "Test Category"
- 2 todos: "Test Todo 1" (pending), "Test Todo 2" (completed)
"""
function seed_test_data!(db::SQLite.DB)::Nothing
    # Create test project
    create_project(db, "Test Project", description="A test project", color="#FF0000")

    # Create test category
    create_category(db, "Test Category", color="#00FF00")

    # Create test todos
    create_todo(db, "Test Todo 1", status="pending", priority=1, project_id=1, category_id=1)
    create_todo(db, "Test Todo 2", status="completed", priority=2)

    return nothing
end

"""
    assert_contains_all(output, expected::Vector{String})

Assert that rendered output contains all expected strings.

# Arguments
- `output`: The rendered output (will be converted to string)
- `expected::Vector{String}`: List of strings that must all be present

# Examples
```julia
output = render_header("Todo List")
assert_contains_all(output, ["Todo", "List"])
```
"""
function assert_contains_all(output, expected::Vector{String})
    output_str = string(output)
    for s in expected
        @test contains(output_str, s)
    end
end
