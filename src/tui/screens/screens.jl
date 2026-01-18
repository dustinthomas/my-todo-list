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
- filter_menu.jl: Filter menu and filter selection screens
- project_list.jl: Project management list view
- project_form.jl: Add/Edit project form
- category_list.jl: Category management list view
- category_form.jl: Add/Edit category form
"""

# Include screen implementations
include("main_list.jl")
include("todo_detail.jl")
include("todo_form.jl")
include("filter_menu.jl")
include("project_list.jl")
include("project_form.jl")
include("category_list.jl")
include("category_form.jl")
include("delete_confirm.jl")
