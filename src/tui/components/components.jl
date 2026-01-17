"""
TUI Components Module.

This module provides reusable rendering components for the TUI:
- Header: Application title and subtitle
- Footer: Keyboard shortcuts
- Message: Success/error/info/warning messages

All components return renderable objects (Panel, String) without side effects.
They can be composed to build complete screens.

# Usage
```julia
header = render_header("Todo List", subtitle="5 items")
footer = render_footer([("j/k", "Navigate"), ("q", "Quit")])
message = render_message("Todo created!", :success)
```
"""

# Include component files
include("header.jl")
include("footer.jl")
include("message.jl")

# Note: Exports are defined in the parent module (TodoList.jl).
# Export statements in included files have no effect.
