"""
TUI Module - Terminal User Interface for TodoList.

This module provides an interactive terminal interface for managing todos,
projects, and categories using Term.jl for rendering.

# Usage
```julia
using TodoList
run_tui()  # Start with user database
run_tui(":memory:")  # Start with in-memory database (for testing)
```
"""

using Term

# Include TUI submodules
include("state.jl")
include("input.jl")
include("components/components.jl")

# Note: Exports are defined in the parent module (TodoList.jl).
# Export statements in included files have no effect.

"""
    run_tui(db_path::Union{String, Nothing}=nothing)

Start the TUI application.

# Arguments
- `db_path::Union{String, Nothing}`: Database path (default: user's TodoList database).
  Use ":memory:" for in-memory database (testing).

# Example
```julia
run_tui()  # Use default database
run_tui(":memory:")  # Use in-memory database
```
"""
function run_tui(db_path::Union{String, Nothing}=nothing)
    # Determine database path
    actual_path = db_path === nothing ? get_database_path() : db_path

    # Connect and initialize database
    db = connect_database(actual_path)
    init_schema!(db)

    # Create initial state
    state = create_initial_state(db)

    # TODO: Implement main loop in later steps
    # For now, just return the state for testing
    println("TUI module loaded. Main loop not yet implemented.")
    return state
end
