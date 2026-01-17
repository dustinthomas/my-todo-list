"""
Footer Component.

Renders keyboard shortcuts at the bottom of the screen.
"""

using Term: @style

"""
    render_footer(shortcuts::Vector{Tuple{String,String}})::String

Render the footer with keyboard shortcuts.

# Arguments
- `shortcuts::Vector{Tuple{String,String}}`: List of (key, action) pairs

# Returns
- `String`: Formatted string with styled shortcuts

# Examples
```julia
shortcuts = [("j/k", "Navigate"), ("Enter", "Select"), ("q", "Quit")]
render_footer(shortcuts)
# Output: " j/k Navigate │ Enter Select │ q Quit "
```
"""
function render_footer(shortcuts::Vector{Tuple{String,String}})::String
    if isempty(shortcuts)
        return ""
    end

    # Build shortcut strings with styling
    parts = String[]
    for (key, action) in shortcuts
        push!(parts, "{bold cyan}$key{/bold cyan} {dim}$action{/dim}")
    end

    # Join with separator
    return " " * join(parts, " │ ") * " "
end

# Also accept Vector of any tuple-like type
function render_footer(shortcuts::Vector)::String
    converted = Tuple{String,String}[(string(k), string(a)) for (k, a) in shortcuts]
    return render_footer(converted)
end
