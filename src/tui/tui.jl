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
include("screens/screens.jl")
include("render.jl")

# Note: Exports are defined in the parent module (TodoList.jl).
# Export statements in included files have no effect.

"""
    run_tui(db_path::Union{String, Nothing}=nothing)

Start the TUI application.

Runs the interactive terminal UI main loop. Handles:
- Screen rendering based on current state
- Keyboard input handling
- Screen transitions
- Data operations (CRUD)

# Arguments
- `db_path::Union{String, Nothing}`: Database path (default: user's TodoList database).
  Use ":memory:" for in-memory database (testing).

# Example
```julia
run_tui()  # Use default database
run_tui(":memory:")  # Use in-memory database
```

# Terminal Behavior
- Switches terminal to raw mode for immediate key detection
- Restores terminal to normal mode on exit (including Ctrl+C)
- Clears screen on start and restores on exit
"""
function run_tui(db_path::Union{String, Nothing}=nothing)
    # Determine database path
    actual_path = db_path === nothing ? get_database_path() : db_path

    # Connect and initialize database
    db = connect_database(actual_path)
    init_schema!(db)

    # Create initial state
    state = create_initial_state(db)

    # Run main loop with terminal setup/restore
    run_main_loop!(state)

    return state
end

"""
    run_main_loop!(state::AppState)::Nothing

Execute the main TUI event loop.

# Arguments
- `state::AppState`: Application state (modified in place)

# Loop Behavior
1. Render current screen
2. Wait for key input
3. Handle input (may change state)
4. Repeat until state.running == false
"""
function run_main_loop!(state::AppState)::Nothing
    # Setup terminal for raw input
    original_terminal_state = setup_raw_terminal()

    try
        # Main event loop
        while state.running
            # Render current screen
            clear_and_render(state)

            # Read and handle input
            key = read_key()
            handle_input!(state, key)
        end
    catch e
        if !(e isa InterruptException)
            # Re-throw non-interrupt exceptions after restoring terminal
            restore_raw_terminal(original_terminal_state)
            rethrow(e)
        end
        # InterruptException (Ctrl+C) - just exit gracefully
    finally
        # Always restore terminal
        restore_raw_terminal(original_terminal_state)

        # Clear screen on exit
        clear_screen()
        println("Goodbye!")
    end

    return nothing
end

"""
    has_tty()::Bool

Check if stdin is connected to a TTY.

Uses the POSIX isatty() function via ccall for reliable detection,
especially in Docker containers where `stdin isa Base.TTY` may fail.
"""
function has_tty()::Bool
    # Method 1: Try POSIX isatty() - most reliable for Docker/containers
    try
        fd = ccall(:fileno, Cint, (Ptr{Cvoid},), stdin.handle)
        if fd >= 0
            result = ccall(:isatty, Cint, (Cint,), fd)
            if result == 1
                return true
            end
        end
    catch
        # ccall failed, try fallback methods
    end

    # Method 2: Julia's built-in TTY check (works for native terminals)
    if stdin isa Base.TTY
        return true
    end

    # Method 3: Check if we can run stty (indicates TTY availability)
    try
        run(pipeline(`stty -g`, devnull, stderr=devnull))
        return true
    catch
        # stty failed, no TTY
    end

    return false
end

"""
    setup_raw_terminal()

Configure terminal for raw input mode.

# Returns
The original terminal state for restoration, or `nothing` if setup fails.

# Effects
- Disables echo (typed characters not shown)
- Disables canonical mode (characters available immediately)
- Hides cursor

# Notes
Uses /dev/tty directly to ensure terminal settings are applied to the
controlling terminal, which works reliably in Docker containers.
"""
function setup_raw_terminal()
    try
        # Use /dev/tty directly - this is the controlling terminal
        # This works more reliably than stdin in Docker
        original_settings = read(`sh -c "stty -g < /dev/tty"`, String) |> strip

        # Set raw mode on /dev/tty
        run(`sh -c "stty raw -echo < /dev/tty"`)

        # Hide cursor
        print("\e[?25l")
        flush(stdout)

        return original_settings
    catch e
        @warn "Failed to setup raw terminal: $e\n" *
              "TUI requires an interactive terminal.\n" *
              "If running in Docker, use: docker run -it ...\n" *
              "Or in docker-compose, set stdin_open: true and tty: true"
        return nothing
    end
end

"""
    restore_raw_terminal(original_state)

Restore terminal to normal mode.

# Arguments
- `original_state`: The state returned by setup_raw_terminal(), or `nothing`

# Effects
- Restores echo
- Restores canonical mode
- Shows cursor
"""
function restore_raw_terminal(original_state)
    # Show cursor (safe even without TTY)
    print("\e[?25h")
    flush(stdout)

    # If no original state, nothing to restore
    if original_state === nothing
        return nothing
    end

    # Restore original terminal settings using /dev/tty
    try
        run(`sh -c "stty $original_state < /dev/tty"`)
    catch
        # Fallback: try to set reasonable defaults
        try
            run(`sh -c "stty sane < /dev/tty"`)
        catch
            # Silently ignore - terminal may not support stty
        end
    end

    return nothing
end
