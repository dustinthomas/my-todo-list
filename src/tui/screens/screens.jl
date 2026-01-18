"""
TUI Screens Module.

This module contains all screen rendering and input handling functions.
Each screen has:
- A render function that returns a string
- An input handler that modifies state

Screens:
- main_list.jl: Main todo list view
- todo_detail.jl: Todo detail view
- todo_form.jl: Add/Edit todo form
"""

# Include screen implementations
include("main_list.jl")
include("todo_detail.jl")
include("todo_form.jl")
