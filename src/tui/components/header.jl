"""
Header Component.

Renders the application header with title and optional subtitle.
"""

using Term: Panel, RenderableText
using Term: @style

"""
    render_header(title::String; subtitle::String="")::Panel

Render the application header panel.

# Arguments
- `title::String`: Main header title (displayed prominently)
- `subtitle::String`: Optional subtitle (e.g., filter info, item count)

# Returns
- `Panel`: Term.jl Panel containing the styled header

# Examples
```julia
# Basic header
render_header("Todo List")

# Header with subtitle
render_header("Todo List", subtitle="5 items")

# Header with filter info
render_header("Todo List", subtitle="[Filter: pending] [3 items]")
```
"""
function render_header(title::String; subtitle::String="")::Panel
    # Build header content
    if isempty(subtitle)
        content = "{bold}$title{/bold}"
    else
        content = "{bold}$title{/bold}\n{dim}$subtitle{/dim}"
    end

    return Panel(
        content;
        style="cyan",
        fit=true,
        justify=:center
    )
end
