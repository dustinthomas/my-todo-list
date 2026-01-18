"""
Tests for TUI screens.

Tests cover:
- Main list screen rendering and input handling
- Todo detail screen rendering and input handling
- Todo form screen rendering, validation, save, and input handling
- Navigation and screen transitions

Note: Visual appearance (colors, alignment) requires MANUAL TESTING.
These tests verify content presence, state changes, and return types.
"""

# Include test helpers
include("tui_test_helpers.jl")

@testset "TUI Screen Tests" begin
    @testset "Main List Screen" begin
        @testset "Rendering - Empty State" begin
            state = create_test_state(with_data=false)
            output = render_main_list(state)
            output_str = string(output)

            # Should have header
            @test contains(output_str, "Todo List") || contains(output_str, "Todos")

            # Should show empty state message
            @test contains(output_str, "No todos") || contains(output_str, "empty")
            @test contains(output_str, "'a'") || contains(output_str, "add")

            # Should have footer with shortcuts
            @test contains(output_str, "Quit") || contains(output_str, "q")
        end

        @testset "Rendering - With Data" begin
            state = create_test_state(with_data=true)
            output = render_main_list(state)
            output_str = string(output)

            # Should have header
            @test contains(output_str, "Todo List") || contains(output_str, "Todos")

            # Should show todo data
            @test contains(output_str, "Test Todo")

            # Footer shortcuts should be present
            @test contains(output_str, "Navigate") || contains(output_str, "j/k")
            @test contains(output_str, "Add") || contains(output_str, "a")
            @test contains(output_str, "Quit") || contains(output_str, "q")
        end

        @testset "Rendering - With Active Filters" begin
            state = create_test_state(with_data=true)
            state.filter_status = "pending"
            refresh_data!(state)

            output = render_main_list(state)
            output_str = string(output)

            # Filter indicator should appear in header/subtitle
            @test contains(output_str, "Filter") || contains(output_str, "pending")
        end

        @testset "Rendering - Item Count Display" begin
            state = create_test_state(with_data=true)
            output = render_main_list(state)
            output_str = string(output)

            # Should show item count or "items"
            @test contains(output_str, "item") || contains(output_str, string(length(state.todos)))
        end

        @testset "Rendering - With Message" begin
            state = create_test_state(with_data=true)
            state.message = "Todo created successfully!"
            state.message_type = :success

            output = render_main_list(state)
            output_str = string(output)

            # Message should appear
            @test contains(output_str, "Todo created successfully!")
        end
    end

    @testset "Main List Input Handling" begin
        @testset "Navigation - Down" begin
            state = create_test_state(with_data=true)
            state.selected_index = 1

            # 'j' key moves down
            handle_main_list_input!(state, 'j')
            @test state.selected_index == 2

            # Reset and test arrow key
            state.selected_index = 1
            handle_main_list_input!(state, :down)
            @test state.selected_index == 2
        end

        @testset "Navigation - Up" begin
            state = create_test_state(with_data=true)
            state.selected_index = 2

            # 'k' key moves up
            handle_main_list_input!(state, 'k')
            @test state.selected_index == 1

            # Reset and test arrow key
            state.selected_index = 2
            handle_main_list_input!(state, :up)
            @test state.selected_index == 1
        end

        @testset "Navigation - Bounds Checking" begin
            state = create_test_state(with_data=true)

            # Can't go above first item
            state.selected_index = 1
            handle_main_list_input!(state, 'k')
            @test state.selected_index == 1

            # Can't go below last item
            state.selected_index = length(state.todos)
            handle_main_list_input!(state, 'j')
            @test state.selected_index == length(state.todos)
        end

        @testset "Navigation - Empty List" begin
            state = create_test_state(with_data=false)
            state.selected_index = 1

            # Navigation should not error on empty list
            handle_main_list_input!(state, 'j')
            @test state.selected_index == 1

            handle_main_list_input!(state, 'k')
            @test state.selected_index == 1
        end

        @testset "Screen Transition - Add Todo" begin
            state = create_test_state(with_data=true)
            @test state.current_screen == MAIN_LIST

            handle_main_list_input!(state, 'a')
            @test state.current_screen == TODO_ADD
            @test state.previous_screen == MAIN_LIST
        end

        @testset "Screen Transition - View Detail" begin
            state = create_test_state(with_data=true)

            handle_main_list_input!(state, :enter)
            @test state.current_screen == TODO_DETAIL
            @test state.current_todo !== nothing
            @test state.current_todo.id == state.todos[1].id
        end

        @testset "Screen Transition - Edit Todo" begin
            state = create_test_state(with_data=true)

            handle_main_list_input!(state, 'e')
            @test state.current_screen == TODO_EDIT
            @test state.current_todo !== nothing
        end

        @testset "Screen Transition - Delete Confirm" begin
            state = create_test_state(with_data=true)

            handle_main_list_input!(state, 'd')
            @test state.current_screen == DELETE_CONFIRM
            @test state.delete_type == :todo
            @test state.delete_id !== nothing
            @test state.delete_name == state.todos[1].title
        end

        @testset "Screen Transition - Filter Menu" begin
            state = create_test_state(with_data=true)

            handle_main_list_input!(state, 'f')
            @test state.current_screen == FILTER_MENU
            @test state.previous_screen == MAIN_LIST
        end

        @testset "Screen Transition - Projects" begin
            state = create_test_state(with_data=true)

            handle_main_list_input!(state, 'p')
            @test state.current_screen == PROJECT_LIST
            @test state.previous_screen == MAIN_LIST
        end

        @testset "Screen Transition - Categories" begin
            state = create_test_state(with_data=true)

            handle_main_list_input!(state, 'g')
            @test state.current_screen == CATEGORY_LIST
            @test state.previous_screen == MAIN_LIST
        end

        @testset "Action - Quick Complete Toggle" begin
            state = create_test_state(with_data=true)
            initial_status = state.todos[1].status
            @test initial_status == "pending"

            # Toggle completion
            handle_main_list_input!(state, 'c')
            refresh_data!(state)

            # Status should have changed
            @test state.todos[1].status == "completed"

            # Toggle again
            handle_main_list_input!(state, 'c')
            refresh_data!(state)

            # Should be back to pending
            @test state.todos[1].status == "pending"
        end

        @testset "Action - Quit" begin
            state = create_test_state(with_data=true)
            @test state.running == true

            handle_main_list_input!(state, 'q')
            @test state.running == false
        end

        @testset "Action - Message Cleared on Input" begin
            state = create_test_state(with_data=true)
            state.message = "Some message"
            state.message_type = :success

            # Any input should clear message (except quit)
            handle_main_list_input!(state, 'j')
            @test state.message === nothing
        end

        @testset "No Action on Invalid Key" begin
            state = create_test_state(with_data=true)
            initial_screen = state.current_screen
            initial_index = state.selected_index

            # Invalid key should not change state
            handle_main_list_input!(state, 'x')
            @test state.current_screen == initial_screen
            @test state.selected_index == initial_index
        end

        @testset "No Action on Empty List - Edit/Delete/View" begin
            state = create_test_state(with_data=false)

            # These should not change screen when list is empty
            handle_main_list_input!(state, 'e')
            @test state.current_screen == MAIN_LIST

            handle_main_list_input!(state, 'd')
            @test state.current_screen == MAIN_LIST

            handle_main_list_input!(state, :enter)
            @test state.current_screen == MAIN_LIST

            handle_main_list_input!(state, 'c')
            @test state.current_screen == MAIN_LIST
        end
    end

    @testset "Main List Helpers" begin
        @testset "build_main_list_shortcuts" begin
            shortcuts = build_main_list_shortcuts()

            # Should be a vector of tuples
            @test shortcuts isa Vector
            @test length(shortcuts) > 0

            # Convert to strings for checking
            all_keys = join([s[1] for s in shortcuts], " ")
            all_actions = join([s[2] for s in shortcuts], " ")

            # Essential shortcuts should be present
            @test contains(all_keys, "j") || contains(all_keys, "↑")
            @test contains(all_actions, "Navigate") || contains(all_actions, "nav")
            @test contains(all_keys, "a")
            @test contains(all_actions, "Add")
            @test contains(all_keys, "q")
            @test contains(all_actions, "Quit")
        end

        @testset "build_filter_subtitle" begin
            state = create_test_state(with_data=true)

            # No filters
            subtitle = build_filter_subtitle(state)
            @test contains(subtitle, string(length(state.todos))) || contains(subtitle, "item")

            # With filter
            state.filter_status = "pending"
            subtitle = build_filter_subtitle(state)
            @test contains(subtitle, "pending") || contains(subtitle, "Filter")
        end
    end

    # =========================================================================
    # Todo Detail Screen Tests
    # =========================================================================

    @testset "Todo Detail Screen" begin
        @testset "Rendering - Basic" begin
            state = create_test_state(with_data=true)
            state.current_screen = TODO_DETAIL
            state.current_todo = state.todos[1]

            output = render_todo_detail(state)
            output_str = string(output)

            # Should have header with title
            @test contains(output_str, "Todo Detail") || contains(output_str, "Detail")

            # Should show todo title
            @test contains(output_str, state.current_todo.title)

            # Should show status field
            @test contains(output_str, "Status")
            @test contains(output_str, state.current_todo.status)

            # Should show priority field
            @test contains(output_str, "Priority")

            # Footer shortcuts should be present
            @test contains(output_str, "Back") || contains(output_str, "b")
            @test contains(output_str, "Edit") || contains(output_str, "e")
        end

        @testset "Rendering - All Fields Present" begin
            state = create_test_state(with_data=true)
            state.current_todo = state.todos[1]

            output = render_todo_detail(state)
            output_str = string(output)

            # Required fields
            @test contains(output_str, "Title")
            @test contains(output_str, "Status")
            @test contains(output_str, "Priority")

            # Optional fields (labels should be present even if empty)
            @test contains(output_str, "Description") || contains(output_str, "description")
            @test contains(output_str, "Project") || contains(output_str, "project")
            @test contains(output_str, "Category") || contains(output_str, "category")
        end

        @testset "Rendering - With All Data" begin
            state = create_test_state(with_data=true)
            # Use the first todo which has project and category assigned
            state.current_todo = state.todos[1]

            output = render_todo_detail(state)
            output_str = string(output)

            # Should show project name if assigned
            if state.current_todo.project_id !== nothing
                @test contains(output_str, "Test Project")
            end

            # Should show category name if assigned
            if state.current_todo.category_id !== nothing
                @test contains(output_str, "Test Category")
            end
        end

        @testset "Input Handler - Back Navigation" begin
            state = create_test_state(with_data=true)
            state.current_screen = TODO_DETAIL
            state.previous_screen = MAIN_LIST
            state.current_todo = state.todos[1]

            # 'b' key goes back
            handle_todo_detail_input!(state, 'b')
            @test state.current_screen == MAIN_LIST

            # Reset state
            state.current_screen = TODO_DETAIL
            state.previous_screen = MAIN_LIST

            # Escape key also goes back
            handle_todo_detail_input!(state, :escape)
            @test state.current_screen == MAIN_LIST
        end

        @testset "Input Handler - Edit Transition" begin
            state = create_test_state(with_data=true)
            state.current_screen = TODO_DETAIL
            state.current_todo = state.todos[1]

            # 'e' key goes to edit
            handle_todo_detail_input!(state, 'e')
            @test state.current_screen == TODO_EDIT
            @test state.previous_screen == TODO_DETAIL
            # Form should be initialized with todo data
            @test state.form_fields[:title] == state.current_todo.title
        end

        @testset "Input Handler - Delete Transition" begin
            state = create_test_state(with_data=true)
            state.current_screen = TODO_DETAIL
            state.current_todo = state.todos[1]
            todo_title = state.current_todo.title
            todo_id = state.current_todo.id

            # 'd' key goes to delete confirmation
            handle_todo_detail_input!(state, 'd')
            @test state.current_screen == DELETE_CONFIRM
            @test state.delete_type == :todo
            @test state.delete_id == todo_id
            @test state.delete_name == todo_title
        end

        @testset "Input Handler - Quit" begin
            state = create_test_state(with_data=true)
            state.current_screen = TODO_DETAIL
            state.current_todo = state.todos[1]

            # 'q' quits
            handle_todo_detail_input!(state, 'q')
            @test state.running == false
        end

        @testset "Input Handler - Invalid Key" begin
            state = create_test_state(with_data=true)
            state.current_screen = TODO_DETAIL
            state.current_todo = state.todos[1]

            # Invalid key should not change screen
            handle_todo_detail_input!(state, 'x')
            @test state.current_screen == TODO_DETAIL
        end
    end

    # =========================================================================
    # Todo Form Screen Tests
    # =========================================================================

    @testset "Todo Form Screen" begin
        @testset "Add Form Rendering" begin
            state = create_test_state()
            state.current_screen = TODO_ADD
            reset_form!(state)
            state.form_fields[:title] = ""
            state.form_fields[:description] = ""
            state.form_fields[:status] = "pending"
            state.form_fields[:priority] = "2"
            state.form_fields[:start_date] = ""
            state.form_fields[:due_date] = ""

            output = render_todo_form(state, :add)
            output_str = string(output)

            # Header should indicate add mode
            @test contains(output_str, "Add") || contains(output_str, "New")

            # Should have form fields
            @test contains(output_str, "Title")
            @test contains(output_str, "Description")
            @test contains(output_str, "Status")
            @test contains(output_str, "Priority")

            # Footer should have save/cancel
            @test contains(output_str, "Save") || contains(output_str, "Enter")
            @test contains(output_str, "Cancel") || contains(output_str, "Esc")
        end

        @testset "Edit Form Rendering" begin
            state = create_test_state(with_data=true)
            state.current_screen = TODO_EDIT
            state.current_todo = state.todos[1]
            init_form_from_todo!(state, state.current_todo)

            output = render_todo_form(state, :edit)
            output_str = string(output)

            # Header should indicate edit mode
            @test contains(output_str, "Edit")

            # Should show existing values
            @test contains(output_str, state.current_todo.title)
        end

        @testset "Form Rendering - With Validation Errors" begin
            state = create_test_state()
            state.current_screen = TODO_ADD
            state.form_fields[:title] = ""
            state.form_errors[:title] = "Title is required"

            output = render_todo_form(state, :add)
            output_str = string(output)

            # Error message should appear
            @test contains(output_str, "Title is required") || contains(output_str, "required")
        end

        @testset "Form Validation - Empty Title" begin
            state = create_test_state()
            state.form_fields = Dict{Symbol,String}(
                :title => "",
                :description => "",
                :status => "pending",
                :priority => "2",
                :start_date => "",
                :due_date => ""
            )
            state.form_errors = Dict{Symbol,String}()

            valid = validate_todo_form!(state)
            @test valid == false
            @test haskey(state.form_errors, :title)
        end

        @testset "Form Validation - Valid Title" begin
            state = create_test_state()
            state.form_fields = Dict{Symbol,String}(
                :title => "Valid Title",
                :description => "",
                :status => "pending",
                :priority => "2",
                :start_date => "",
                :due_date => ""
            )
            state.form_errors = Dict{Symbol,String}()

            valid = validate_todo_form!(state)
            @test valid == true
            @test !haskey(state.form_errors, :title)
        end

        @testset "Form Validation - Invalid Date Format" begin
            state = create_test_state()
            state.form_fields = Dict{Symbol,String}(
                :title => "Valid Title",
                :description => "",
                :status => "pending",
                :priority => "2",
                :start_date => "invalid-date",
                :due_date => ""
            )
            state.form_errors = Dict{Symbol,String}()

            valid = validate_todo_form!(state)
            @test valid == false
            @test haskey(state.form_errors, :start_date)
        end

        @testset "Form Validation - Valid Date Format" begin
            state = create_test_state()
            state.form_fields = Dict{Symbol,String}(
                :title => "Valid Title",
                :description => "",
                :status => "pending",
                :priority => "2",
                :start_date => "2026-01-20",
                :due_date => "2026-02-01"
            )
            state.form_errors = Dict{Symbol,String}()

            valid = validate_todo_form!(state)
            @test valid == true
            @test !haskey(state.form_errors, :start_date)
            @test !haskey(state.form_errors, :due_date)
        end

        @testset "Form Input - Field Navigation Tab" begin
            state = create_test_state()
            state.current_screen = TODO_ADD
            state.form_field_index = 1

            # Tab moves to next field
            handle_todo_form_input!(state, :tab)
            @test state.form_field_index == 2

            handle_todo_form_input!(state, :tab)
            @test state.form_field_index == 3
        end

        @testset "Form Input - Field Navigation Shift+Tab" begin
            state = create_test_state()
            state.current_screen = TODO_ADD
            state.form_field_index = 3

            # Shift+Tab moves to previous field
            handle_todo_form_input!(state, :shift_tab)
            @test state.form_field_index == 2

            handle_todo_form_input!(state, :shift_tab)
            @test state.form_field_index == 1

            # Can't go below 1
            handle_todo_form_input!(state, :shift_tab)
            @test state.form_field_index == 1
        end

        @testset "Form Input - Navigation with j/k" begin
            state = create_test_state()
            state.current_screen = TODO_ADD
            state.form_field_index = 1

            # 'j' moves to next field
            handle_todo_form_input!(state, 'j')
            @test state.form_field_index == 2

            # 'k' moves to previous field
            handle_todo_form_input!(state, 'k')
            @test state.form_field_index == 1
        end

        @testset "Form Save - Add Mode" begin
            state = create_test_state()
            state.current_screen = TODO_ADD
            state.previous_screen = MAIN_LIST
            state.form_fields = Dict{Symbol,String}(
                :title => "New Todo from Test",
                :description => "Test description",
                :status => "pending",
                :priority => "2",
                :start_date => "",
                :due_date => "",
                :project_id => "",
                :category_id => ""
            )
            state.form_errors = Dict{Symbol,String}()

            initial_count = length(list_todos(state.db))
            save_todo_form!(state, :add)

            # Should create new todo
            @test length(list_todos(state.db)) == initial_count + 1

            # Should have success message
            @test state.message !== nothing
            @test state.message_type == :success

            # Should go back to previous screen
            @test state.current_screen == MAIN_LIST
        end

        @testset "Form Save - Edit Mode" begin
            state = create_test_state(with_data=true)
            state.current_screen = TODO_EDIT
            state.previous_screen = MAIN_LIST
            state.current_todo = state.todos[1]
            original_id = state.current_todo.id
            state.form_fields = Dict{Symbol,String}(
                :title => "Updated Todo Title",
                :description => "Updated description",
                :status => "in_progress",
                :priority => "1",
                :start_date => "",
                :due_date => "",
                :project_id => "",
                :category_id => ""
            )
            state.form_errors = Dict{Symbol,String}()

            initial_count = length(list_todos(state.db))
            save_todo_form!(state, :edit)

            # Should not create new todo
            @test length(list_todos(state.db)) == initial_count

            # Should update existing todo
            updated = get_todo(state.db, original_id)
            @test updated.title == "Updated Todo Title"
            @test updated.status == "in_progress"
            @test updated.priority == 1

            # Should have success message
            @test state.message !== nothing
            @test state.message_type == :success

            # Should go back to previous screen
            @test state.current_screen == MAIN_LIST
        end

        @testset "Form Save - Validation Failure" begin
            state = create_test_state()
            state.current_screen = TODO_ADD
            state.form_fields = Dict{Symbol,String}(
                :title => "",  # Empty title - should fail
                :description => "",
                :status => "pending",
                :priority => "2",
                :start_date => "",
                :due_date => "",
                :project_id => "",
                :category_id => ""
            )
            state.form_errors = Dict{Symbol,String}()

            initial_count = length(list_todos(state.db))
            save_todo_form!(state, :add)

            # Should not create todo
            @test length(list_todos(state.db)) == initial_count

            # Should stay on form screen
            @test state.current_screen == TODO_ADD

            # Should have error
            @test haskey(state.form_errors, :title)
        end

        @testset "Form Cancel" begin
            state = create_test_state()
            state.current_screen = TODO_ADD
            state.previous_screen = MAIN_LIST
            state.form_fields[:title] = "Will be cancelled"

            # Escape cancels
            handle_todo_form_input!(state, :escape)
            @test state.current_screen == MAIN_LIST
        end

        @testset "Init Form From Todo" begin
            state = create_test_state(with_data=true)
            todo = state.todos[1]

            init_form_from_todo!(state, todo)

            @test state.form_fields[:title] == todo.title
            @test state.form_fields[:status] == todo.status
            @test state.form_fields[:priority] == string(todo.priority)
        end

        @testset "Form Save with Project and Category" begin
            state = create_test_state(with_data=true)
            state.current_screen = TODO_ADD
            state.previous_screen = MAIN_LIST
            state.form_fields = Dict{Symbol,String}(
                :title => "Todo with relations",
                :description => "",
                :status => "pending",
                :priority => "2",
                :start_date => "",
                :due_date => "",
                :project_id => "1",  # Test Project
                :category_id => "1"  # Test Category
            )
            state.form_errors = Dict{Symbol,String}()

            save_todo_form!(state, :add)

            # Find the created todo
            todos = list_todos(state.db)
            new_todo = findfirst(t -> t.title == "Todo with relations", todos)
            @test new_todo !== nothing
            @test todos[new_todo].project_id == 1
            @test todos[new_todo].category_id == 1
        end

        @testset "Form Input - Enter on Save Button" begin
            state = create_test_state()
            state.current_screen = TODO_ADD
            state.previous_screen = MAIN_LIST
            state.form_field_index = 7  # Assuming 6 fields + Save button position
            state.form_fields = Dict{Symbol,String}(
                :title => "Test via Enter",
                :description => "",
                :status => "pending",
                :priority => "2",
                :start_date => "",
                :due_date => "",
                :project_id => "",
                :category_id => ""
            )
            state.form_errors = Dict{Symbol,String}()

            initial_count = length(list_todos(state.db))

            # Enter should trigger save
            handle_todo_form_input!(state, :enter)

            # Should have created the todo
            @test length(list_todos(state.db)) == initial_count + 1
        end
    end
end
