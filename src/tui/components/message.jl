"""
Message Component.

Renders success, error, info, and warning messages.
"""

using Term: Panel
using Term: @style

"""
    render_message(message::Union{String, Nothing}, type::Symbol)::String

Render a message with appropriate styling based on type.

# Arguments
- `message::Union{String, Nothing}`: Message text (or nothing for no message)
- `type::Symbol`: Message type - :success, :error, :info, or :warning

# Returns
- `String`: Styled message string (empty string if message is nothing or empty)

# Message Type Styling
- `:success` - Green with checkmark prefix
- `:error` - Red with X prefix
- `:info` - Blue with info prefix
- `:warning` - Yellow with warning prefix

# Examples
```julia
render_message("Todo created!", :success)
# Output: " ✓ Todo created! " (green)

render_message("Title is required", :error)
# Output: " ✗ Title is required " (red)

render_message(nothing, :info)
# Output: ""
```
"""
function render_message(message::Union{String, Nothing}, type::Symbol)::String
    # Handle nothing or empty message
    if message === nothing || isempty(message)
        return ""
    end

    # Determine prefix and color based on type
    prefix, color = get_message_style(type)

    # Return styled message
    return "{$color}$prefix $message{/$color}"
end

"""
    get_message_style(type::Symbol)::Tuple{String, String}

Get the prefix and color for a message type.

# Arguments
- `type::Symbol`: Message type

# Returns
- `Tuple{String, String}`: (prefix, color) pair
"""
function get_message_style(type::Symbol)::Tuple{String, String}
    if type == :success
        return ("✓", "green")
    elseif type == :error
        return ("✗", "red")
    elseif type == :warning
        return ("⚠", "yellow")
    else  # :info or unknown
        return ("ℹ", "blue")
    end
end
