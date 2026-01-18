"""
TUI Input Handling.

This module provides:
- Key constants for actions and navigation
- Helper functions for key classification
- Raw terminal input functions (for main loop)

# Key Types
- Character keys: 'a', 'q', etc. (Char type)
- Special keys: :enter, :escape, etc. (Symbol type)

# Usage
```julia
key = read_key()  # Returns Char or Symbol
if is_quit_key(key)
    # Exit application
end
```
"""

# =============================================================================
# Key Constants - Character Keys
# =============================================================================

"""Quit the application."""
const KEY_QUIT = 'q'

"""Add a new item."""
const KEY_ADD = 'a'

"""Edit the selected item."""
const KEY_EDIT = 'e'

"""Delete the selected item."""
const KEY_DELETE = 'd'

"""Toggle completion status."""
const KEY_COMPLETE = 'c'

"""Go back to previous screen."""
const KEY_BACK = 'b'

"""Open filter menu."""
const KEY_FILTER = 'f'

"""Open projects list."""
const KEY_PROJECTS = 'p'

"""Open categories list."""
const KEY_CATEGORIES = 'g'

"""Show help."""
const KEY_HELP = '?'

"""Vim-style navigation up."""
const KEY_NAV_UP = 'k'

"""Vim-style navigation down."""
const KEY_NAV_DOWN = 'j'

"""Confirm action."""
const KEY_YES = 'y'

"""Cancel/decline action."""
const KEY_NO = 'n'

# =============================================================================
# Key Constants - Special Keys (Symbols)
# =============================================================================

"""Enter/Return key."""
const KEY_ENTER = :enter

"""Escape key."""
const KEY_ESCAPE = :escape

"""Tab key."""
const KEY_TAB = :tab

"""Shift+Tab key combination."""
const KEY_SHIFT_TAB = :shift_tab

"""Up arrow key."""
const KEY_UP = :up

"""Down arrow key."""
const KEY_DOWN = :down

"""Left arrow key."""
const KEY_LEFT = :left

"""Right arrow key."""
const KEY_RIGHT = :right

"""Ctrl+C key combination."""
const KEY_CTRL_C = :ctrl_c

"""Backspace key."""
const KEY_BACKSPACE = :backspace

"""Delete key."""
const KEY_DEL = :delete

# =============================================================================
# Key Classification Functions
# =============================================================================

"""
    is_navigation_key(key)::Bool

Check if a key is a navigation key (up/down movement).

# Arguments
- `key`: Character or Symbol representing a key press

# Returns
- `true` if key is j, k, up arrow, or down arrow
"""
function is_navigation_key(key)::Bool
    return key == KEY_NAV_UP || key == KEY_NAV_DOWN ||
           key == KEY_UP || key == KEY_DOWN
end

"""
    is_quit_key(key)::Bool

Check if a key should quit the application.

# Arguments
- `key`: Character or Symbol representing a key press

# Returns
- `true` if key is 'q' or Ctrl+C
"""
function is_quit_key(key)::Bool
    return key == KEY_QUIT || key == KEY_CTRL_C
end

"""
    is_confirm_key(key)::Bool

Check if a key confirms an action.

# Arguments
- `key`: Character or Symbol representing a key press

# Returns
- `true` if key is Enter or 'y'
"""
function is_confirm_key(key)::Bool
    return key == KEY_ENTER || key == KEY_YES
end

"""
    is_cancel_key(key)::Bool

Check if a key cancels an action.

# Arguments
- `key`: Character or Symbol representing a key press

# Returns
- `true` if key is Escape, 'n', or 'b'
"""
function is_cancel_key(key)::Bool
    return key == KEY_ESCAPE || key == KEY_NO || key == KEY_BACK
end

"""
    is_printable_char(key)::Bool

Check if a key is a printable character that can be typed into text fields.

# Arguments
- `key`: Character or Symbol representing a key press

# Returns
- `true` if key is a printable ASCII character (space through tilde)
"""
function is_printable_char(key)::Bool
    return key isa Char && key >= ' ' && key <= '~'
end

"""
    is_up_key(key)::Bool

Check if a key moves selection up.

# Arguments
- `key`: Character or Symbol representing a key press

# Returns
- `true` if key is 'k' or up arrow
"""
function is_up_key(key)::Bool
    return key == KEY_NAV_UP || key == KEY_UP
end

"""
    is_down_key(key)::Bool

Check if a key moves selection down.

# Arguments
- `key`: Character or Symbol representing a key press

# Returns
- `true` if key is 'j' or down arrow
"""
function is_down_key(key)::Bool
    return key == KEY_NAV_DOWN || key == KEY_DOWN
end

"""
    get_navigation_direction(key)::Int

Get the direction of navigation from a key.

# Arguments
- `key`: Character or Symbol representing a key press

# Returns
- `-1` for up movement
- `1` for down movement
- `0` for non-navigation keys
"""
function get_navigation_direction(key)::Int
    if is_up_key(key)
        return -1
    elseif is_down_key(key)
        return 1
    else
        return 0
    end
end

"""
    key_to_string(key)::String

Convert a key to its display string representation.

# Arguments
- `key`: Character or Symbol representing a key press

# Returns
- Human-readable string for the key

# Examples
```julia
key_to_string('a')       # => "a"
key_to_string(:enter)    # => "Enter"
key_to_string(:ctrl_c)   # => "Ctrl+C"
```
"""
function key_to_string(key)::String
    if key isa Char
        return string(key)
    elseif key == KEY_ENTER
        return "Enter"
    elseif key == KEY_ESCAPE
        return "Escape"
    elseif key == KEY_TAB
        return "Tab"
    elseif key == KEY_SHIFT_TAB
        return "Shift+Tab"
    elseif key == KEY_UP
        return "Up"
    elseif key == KEY_DOWN
        return "Down"
    elseif key == KEY_LEFT
        return "Left"
    elseif key == KEY_RIGHT
        return "Right"
    elseif key == KEY_CTRL_C
        return "Ctrl+C"
    else
        return string(key)
    end
end

# =============================================================================
# Raw Terminal Input Functions
# =============================================================================
# NOTE: These functions require MANUAL TESTING as they interact with the terminal.
# They cannot be unit tested effectively.

"""
    setup_terminal()::Nothing

Configure terminal for raw input mode.

Disables:
- Line buffering (characters available immediately)
- Echo (typed characters not displayed)
- Canonical mode (special characters not processed)

Call `restore_terminal()` before exiting to restore normal terminal state.

# Warning
Always use in a try/finally block to ensure terminal is restored on errors.
"""
function setup_terminal()::Nothing
    # Use REPL.Terminals or direct stty for raw mode
    # Implementation depends on Term.jl capabilities
    # For now, this is a placeholder that will be implemented
    # when integrating with the main loop
    return nothing
end

"""
    restore_terminal()::Nothing

Restore terminal to normal mode after raw input.

Restores:
- Line buffering
- Echo
- Canonical mode

# Warning
Must be called after `setup_terminal()` to prevent terminal corruption.
"""
function restore_terminal()::Nothing
    # Restore normal terminal settings
    # Implementation depends on Term.jl capabilities
    return nothing
end

"""
    read_key()::Union{Char, Symbol}

Read a single key press from the terminal.

Blocks until a key is pressed. Handles:
- Regular character keys (returned as Char)
- Special keys like arrows, Enter, Escape (returned as Symbol)
- Escape sequences for special keys

# Returns
- `Char` for regular character keys
- `Symbol` for special keys (:enter, :escape, :up, :down, etc.)

# Note
Terminal must be in raw mode (`setup_terminal()` called first).
This function requires MANUAL TESTING.
"""
function read_key()::Union{Char, Symbol}
    # Read a byte from stdin
    byte = read(stdin, UInt8)

    # Handle escape sequences
    if byte == 0x1B  # ESC
        # Check if more bytes available (escape sequence)
        if bytesavailable(stdin) > 0
            byte2 = read(stdin, UInt8)
            if byte2 == 0x5B  # [
                if bytesavailable(stdin) > 0
                    byte3 = read(stdin, UInt8)
                    # Arrow keys
                    if byte3 == 0x41  # A
                        return KEY_UP
                    elseif byte3 == 0x42  # B
                        return KEY_DOWN
                    elseif byte3 == 0x43  # C
                        return KEY_RIGHT
                    elseif byte3 == 0x44  # D
                        return KEY_LEFT
                    elseif byte3 == 0x5A  # Z (Shift+Tab)
                        return KEY_SHIFT_TAB
                    end
                end
            end
        end
        return KEY_ESCAPE
    elseif byte == 0x0D || byte == 0x0A  # CR or LF
        return KEY_ENTER
    elseif byte == 0x09  # Tab
        return KEY_TAB
    elseif byte == 0x03  # Ctrl+C
        return KEY_CTRL_C
    elseif byte == 0x7F || byte == 0x08  # Backspace (DEL or BS)
        return KEY_BACKSPACE
    else
        return Char(byte)
    end
end
