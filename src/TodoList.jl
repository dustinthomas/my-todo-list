"""
TodoList - A simple, maintainable TUI todo list manager

This module provides a complete database layer for managing projects, categories,
and todos with SQLite persistence.
"""
module TodoList

# Import dependencies
using SQLite
using DBInterface
using Dates

# Include source files
include("models.jl")
include("database.jl")
include("queries.jl")
include("tui/tui.jl")

# Export data models
export Project, Category, Todo

# Export database functions
export connect_database, init_schema!, get_database_path

# Export Project CRUD
export create_project, get_project, list_projects, update_project!, delete_project!

# Export Category CRUD
export create_category, get_category, list_categories, update_category!, delete_category!

# Export Todo CRUD
export create_todo, get_todo, list_todos, update_todo!, complete_todo!, delete_todo!

# Export Filtering functions
export filter_todos_by_status, filter_todos_by_project, filter_todos_by_category
export filter_todos_by_date_range, filter_todos

# Export TUI Screen enum and instances
export Screen
export MAIN_LIST, TODO_DETAIL, TODO_ADD, TODO_EDIT
export FILTER_MENU, FILTER_STATUS, FILTER_PROJECT, FILTER_CATEGORY
export PROJECT_LIST, PROJECT_ADD, PROJECT_EDIT
export CATEGORY_LIST, CATEGORY_ADD, CATEGORY_EDIT
export DELETE_CONFIRM

# Export TUI state management
export AppState
export create_initial_state
export go_to_screen!, go_back!
export refresh_data!
export reset_form!
export set_message!, clear_message!
export setup_delete!, clear_delete!

# Export TUI entry point
export run_tui

# Export key constants - character keys
export KEY_QUIT, KEY_ADD, KEY_EDIT, KEY_DELETE, KEY_COMPLETE
export KEY_BACK, KEY_FILTER, KEY_PROJECTS, KEY_CATEGORIES, KEY_HELP
export KEY_NAV_UP, KEY_NAV_DOWN, KEY_YES, KEY_NO

# Export key constants - special keys (symbols)
export KEY_ENTER, KEY_ESCAPE, KEY_TAB, KEY_SHIFT_TAB
export KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT, KEY_CTRL_C

# Export key helper functions
export is_navigation_key, is_quit_key, is_confirm_key, is_cancel_key
export is_up_key, is_down_key, get_navigation_direction, key_to_string

# Export terminal functions
export setup_terminal, restore_terminal, read_key

# Export rendering components
export render_header, render_footer, render_message, get_message_style

# Export table components
export render_todo_table, render_project_table, render_category_table
export format_status, format_priority, truncate_string

# Export form components
export render_text_field, render_radio_group, render_dropdown, render_date_field
export render_todo_form_fields, render_project_form_fields, render_category_form_fields

# Export dialog components
export render_delete_dialog, render_filter_summary
export render_filter_menu_options, render_status_filter_options
export render_project_filter_options, render_category_filter_options

# Export screen functions - Main List
export render_main_list, handle_main_list_input!
export build_main_list_shortcuts, build_filter_subtitle
export MAIN_LIST_VISIBLE_ROWS, MAIN_LIST_SHORTCUTS

end # module
