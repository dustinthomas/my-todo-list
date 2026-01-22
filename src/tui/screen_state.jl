"""
TUI Screen State Management.

This module provides per-screen state storage, enabling screens to maintain
their own state without bloating the central AppState struct.

# Design
Each screen can store arbitrary state in `state.screen_state::Dict{Screen, Any}`.
Helper functions provide type-safe access patterns.

# Usage
```julia
# Define screen-specific state
struct HelpScreenState
    scroll_offset::Int
    search_query::String
end

# Get state with default
help_state = get_screen_state(state, HELP_SCREEN, HelpScreenState(0, ""))

# Set state
set_screen_state!(state, HELP_SCREEN, HelpScreenState(5, "filter"))

# Clear state
clear_screen_state!(state, HELP_SCREEN)
```
"""

# =============================================================================
# Screen State Helpers
# =============================================================================

"""
    get_screen_state(state::AppState, screen::Screen, default::T)::T where T

Get the state for a specific screen, returning default if not set.

# Arguments
- `state::AppState`: Application state containing screen_state dict
- `screen::Screen`: Screen to get state for
- `default::T`: Default value to return if screen has no stored state

# Returns
- The stored screen state, or `default` if none exists

# Type Safety
The returned value is typed as `T` (the type of default). If the stored value
is a different type, it will be returned as-is (caller should handle type mismatch).

# Example
```julia
help_state = get_screen_state(state, HELP_SCREEN, HelpScreenState(0, ""))
```
"""
function get_screen_state(state::AppState, screen::Screen, default::T)::T where T
    return get(state.screen_state, screen, default)::T
end

"""
    get_screen_state(state::AppState, screen::Screen)::Union{Any, Nothing}

Get the state for a specific screen, returning nothing if not set.

# Arguments
- `state::AppState`: Application state containing screen_state dict
- `screen::Screen`: Screen to get state for

# Returns
- The stored screen state, or `nothing` if none exists

# Example
```julia
stored = get_screen_state(state, HELP_SCREEN)
if stored !== nothing
    # Use stored state
end
```
"""
function get_screen_state(state::AppState, screen::Screen)::Union{Any, Nothing}
    return get(state.screen_state, screen, nothing)
end

"""
    set_screen_state!(state::AppState, screen::Screen, value)::Nothing

Set the state for a specific screen.

# Arguments
- `state::AppState`: Application state containing screen_state dict
- `screen::Screen`: Screen to set state for
- `value`: Value to store (can be any type)

# Example
```julia
set_screen_state!(state, HELP_SCREEN, HelpScreenState(5, "search"))
```
"""
function set_screen_state!(state::AppState, screen::Screen, value)::Nothing
    state.screen_state[screen] = value
    return nothing
end

"""
    clear_screen_state!(state::AppState, screen::Screen)::Nothing

Clear the state for a specific screen.

# Arguments
- `state::AppState`: Application state containing screen_state dict
- `screen::Screen`: Screen to clear state for

# Note
This is safe to call even if the screen has no stored state.

# Example
```julia
clear_screen_state!(state, HELP_SCREEN)
```
"""
function clear_screen_state!(state::AppState, screen::Screen)::Nothing
    delete!(state.screen_state, screen)
    return nothing
end

"""
    clear_all_screen_states!(state::AppState)::Nothing

Clear all screen-specific states.

Useful when resetting the application or during major state transitions.

# Arguments
- `state::AppState`: Application state containing screen_state dict

# Example
```julia
clear_all_screen_states!(state)  # Reset all screen states
```
"""
function clear_all_screen_states!(state::AppState)::Nothing
    empty!(state.screen_state)
    return nothing
end

"""
    has_screen_state(state::AppState, screen::Screen)::Bool

Check if a screen has stored state.

# Arguments
- `state::AppState`: Application state containing screen_state dict
- `screen::Screen`: Screen to check

# Returns
- `true` if the screen has stored state, `false` otherwise

# Example
```julia
if has_screen_state(state, HELP_SCREEN)
    # Use existing state
else
    # Initialize state
end
```
"""
function has_screen_state(state::AppState, screen::Screen)::Bool
    return haskey(state.screen_state, screen)
end
