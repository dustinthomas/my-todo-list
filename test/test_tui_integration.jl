"""
TUI Integration Tests.

Tests the complete TUI system including:
- Screen routing (render_screen)
- Input routing (handle_input!)
- Delete confirmation flow
- Full workflows (create todo, edit todo, delete todo)

Note: Terminal setup/restore functions require MANUAL TESTING.
These tests verify the non-IO parts of the integration.
"""

# Include test helpers
include("tui_test_helpers.jl")

@testset "TUI Integration Tests" begin
    # =========================================================================
    # Delete Confirmation Screen Tests
    # =========================================================================

    @testset "Delete Confirmation Screen" begin
        @testset "Rendering - Todo" begin
            state = create_test_state(with_data=true)
            state.current_screen = DELETE_CONFIRM
            state.delete_type = :todo
            state.delete_id = state.todos[1].id
            state.delete_name = "Test Todo"

            output = render_delete_confirm(state)
            output_str = string(output)

            # Should have header
            @test contains(output_str, "Delete") || contains(output_str, "Confirm")

            # Should show item type and name
            @test contains(output_str, "todo")
            @test contains(output_str, "Test Todo")

            # Should show warning
            @test contains(output_str, "cannot be undone") || contains(output_str, "undo")

            # Should show y/n options
            @test contains(output_str, "y") || contains(output_str, "Yes")
            @test contains(output_str, "n") || contains(output_str, "No") || contains(output_str, "Cancel")
        end

        @testset "Rendering - Project" begin
            state = create_test_state(with_data=true)
            state.current_screen = DELETE_CONFIRM
            state.delete_type = :project
            state.delete_id = state.projects[1].id
            state.delete_name = "Test Project"

            output = render_delete_confirm(state)
            output_str = string(output)

            @test contains(output_str, "project")
            @test contains(output_str, "Test Project")
        end

        @testset "Rendering - Category" begin
            state = create_test_state(with_data=true)
            state.current_screen = DELETE_CONFIRM
            state.delete_type = :category
            state.delete_id = state.categories[1].id
            state.delete_name = "Test Category"

            output = render_delete_confirm(state)
            output_str = string(output)

            @test contains(output_str, "category")
            @test contains(output_str, "Test Category")
        end

        @testset "Confirm Delete - Todo" begin
            state = create_test_state(with_data=true)
            state.current_screen = DELETE_CONFIRM
            state.previous_screen = MAIN_LIST
            todo_id = state.todos[1].id
            state.delete_type = :todo
            state.delete_id = todo_id
            state.delete_name = "Test Todo"

            initial_count = length(list_todos(state.db))
            handle_delete_confirm_input!(state, 'y')

            # Todo should be deleted
            @test length(list_todos(state.db)) == initial_count - 1

            # Should have success message
            @test state.message !== nothing
            @test state.message_type == :success
            @test contains(state.message, "deleted")

            # Should go back to main list
            @test state.current_screen == MAIN_LIST

            # Delete state should be cleared
            @test state.delete_type === nothing
            @test state.delete_id === nothing
        end

        @testset "Confirm Delete - Project" begin
            state = create_test_state(with_data=true)
            state.current_screen = DELETE_CONFIRM
            state.previous_screen = PROJECT_LIST
            project_id = state.projects[1].id
            state.delete_type = :project
            state.delete_id = project_id
            state.delete_name = "Test Project"

            initial_count = length(list_projects(state.db))
            handle_delete_confirm_input!(state, 'y')

            # Project should be deleted
            @test length(list_projects(state.db)) == initial_count - 1

            # Should go to project list
            @test state.current_screen == PROJECT_LIST
        end

        @testset "Confirm Delete - Category" begin
            state = create_test_state(with_data=true)
            state.current_screen = DELETE_CONFIRM
            state.previous_screen = CATEGORY_LIST
            category_id = state.categories[1].id
            state.delete_type = :category
            state.delete_id = category_id
            state.delete_name = "Test Category"

            initial_count = length(list_categories(state.db))
            handle_delete_confirm_input!(state, 'y')

            # Category should be deleted
            @test length(list_categories(state.db)) == initial_count - 1

            # Should go to category list
            @test state.current_screen == CATEGORY_LIST
        end

        @testset "Confirm Delete with Enter Key" begin
            state = create_test_state(with_data=true)
            state.current_screen = DELETE_CONFIRM
            state.previous_screen = MAIN_LIST
            todo_id = state.todos[1].id
            state.delete_type = :todo
            state.delete_id = todo_id
            state.delete_name = "Test Todo"

            initial_count = length(list_todos(state.db))
            handle_delete_confirm_input!(state, :enter)

            # Enter should also confirm deletion
            @test length(list_todos(state.db)) == initial_count - 1
        end

        @testset "Cancel Delete - n Key" begin
            state = create_test_state(with_data=true)
            state.current_screen = DELETE_CONFIRM
            state.previous_screen = MAIN_LIST
            todo_id = state.todos[1].id
            state.delete_type = :todo
            state.delete_id = todo_id
            state.delete_name = "Test Todo"

            initial_count = length(list_todos(state.db))
            handle_delete_confirm_input!(state, 'n')

            # Nothing should be deleted
            @test length(list_todos(state.db)) == initial_count

            # Should go back
            @test state.current_screen == MAIN_LIST

            # Delete state should be cleared
            @test state.delete_type === nothing
        end

        @testset "Cancel Delete - Escape Key" begin
            state = create_test_state(with_data=true)
            state.current_screen = DELETE_CONFIRM
            state.previous_screen = MAIN_LIST
            state.delete_type = :todo
            state.delete_id = state.todos[1].id
            state.delete_name = "Test Todo"

            initial_count = length(list_todos(state.db))
            handle_delete_confirm_input!(state, :escape)

            # Nothing deleted
            @test length(list_todos(state.db)) == initial_count
            @test state.current_screen == MAIN_LIST
        end

        @testset "Cancel Delete - b Key" begin
            state = create_test_state(with_data=true)
            state.current_screen = DELETE_CONFIRM
            state.previous_screen = MAIN_LIST
            state.delete_type = :todo
            state.delete_id = state.todos[1].id
            state.delete_name = "Test Todo"

            initial_count = length(list_todos(state.db))
            handle_delete_confirm_input!(state, 'b')

            # Nothing deleted
            @test length(list_todos(state.db)) == initial_count
            @test state.current_screen == MAIN_LIST
        end

        @testset "Quit from Delete Confirm" begin
            state = create_test_state(with_data=true)
            state.current_screen = DELETE_CONFIRM
            state.delete_type = :todo
            state.delete_id = state.todos[1].id
            state.delete_name = "Test Todo"

            handle_delete_confirm_input!(state, 'q')
            @test state.running == false
        end

        @testset "Invalid Key Does Nothing" begin
            state = create_test_state(with_data=true)
            state.current_screen = DELETE_CONFIRM
            state.previous_screen = MAIN_LIST
            state.delete_type = :todo
            state.delete_id = state.todos[1].id
            state.delete_name = "Test Todo"

            initial_count = length(list_todos(state.db))
            handle_delete_confirm_input!(state, 'x')

            # Nothing should change
            @test length(list_todos(state.db)) == initial_count
            @test state.current_screen == DELETE_CONFIRM
        end
    end

    # =========================================================================
    # Screen Routing Tests
    # =========================================================================

    @testset "Screen Routing - render_screen" begin
        @testset "Routes to All Screens Without Error" begin
            state = create_test_state(with_data=true)

            # Setup state for screens that need it
            state.current_todo = state.todos[1]
            state.current_project = state.projects[1]
            state.current_category = state.categories[1]
            state.delete_type = :todo
            state.delete_id = state.todos[1].id
            state.delete_name = "Test Todo"

            # Initialize form fields for form screens
            state.form_fields[:title] = "Test"
            state.form_fields[:description] = ""
            state.form_fields[:status] = "pending"
            state.form_fields[:priority] = "2"
            state.form_fields[:start_date] = ""
            state.form_fields[:due_date] = ""
            state.form_fields[:project_id] = ""
            state.form_fields[:category_id] = ""
            state.form_fields[:name] = "Test"
            state.form_fields[:color] = ""

            # Test each screen
            for screen in instances(Screen)
                state.current_screen = screen
                output = render_screen(state)

                @test output isa String
                @test length(output) > 0

                # Each screen should produce some output
                @test !isempty(strip(output))
            end
        end

        @testset "MAIN_LIST Routes Correctly" begin
            state = create_test_state(with_data=true)
            state.current_screen = MAIN_LIST

            output = render_screen(state)
            @test contains(output, "Todo List") || contains(output, "Todos")
        end

        @testset "TODO_DETAIL Routes Correctly" begin
            state = create_test_state(with_data=true)
            state.current_screen = TODO_DETAIL
            state.current_todo = state.todos[1]

            output = render_screen(state)
            @test contains(output, "Detail") || contains(output, state.current_todo.title)
        end

        @testset "DELETE_CONFIRM Routes Correctly" begin
            state = create_test_state(with_data=true)
            state.current_screen = DELETE_CONFIRM
            state.delete_type = :todo
            state.delete_id = 1
            state.delete_name = "Test Item"

            output = render_screen(state)
            @test contains(output, "Delete") || contains(output, "Confirm")
        end
    end

    # =========================================================================
    # Input Routing Tests
    # =========================================================================

    @testset "Input Routing - handle_input!" begin
        @testset "Routes to MAIN_LIST Handler" begin
            state = create_test_state(with_data=true)
            state.current_screen = MAIN_LIST

            # 'q' should quit
            handle_input!(state, 'q')
            @test state.running == false
        end

        @testset "Routes to TODO_DETAIL Handler" begin
            state = create_test_state(with_data=true)
            state.current_screen = TODO_DETAIL
            state.previous_screen = MAIN_LIST
            state.current_todo = state.todos[1]

            # 'b' should go back
            handle_input!(state, 'b')
            @test state.current_screen == MAIN_LIST
        end

        @testset "Routes to TODO_ADD Handler" begin
            state = create_test_state(with_data=true)
            state.current_screen = TODO_ADD
            state.previous_screen = MAIN_LIST
            state.form_field_index = 1

            # Tab should navigate fields
            handle_input!(state, :tab)
            @test state.form_field_index == 2
        end

        @testset "Routes to TODO_EDIT Handler" begin
            state = create_test_state(with_data=true)
            state.current_screen = TODO_EDIT
            state.previous_screen = MAIN_LIST
            state.current_todo = state.todos[1]
            state.form_field_index = 2

            # Shift+Tab should navigate fields
            handle_input!(state, :shift_tab)
            @test state.form_field_index == 1
        end

        @testset "Routes to FILTER_MENU Handler" begin
            state = create_test_state(with_data=true)
            state.current_screen = FILTER_MENU
            state.selected_index = 1

            # 'j' should navigate
            handle_input!(state, 'j')
            @test state.selected_index == 2
        end

        @testset "Routes to PROJECT_LIST Handler" begin
            state = create_test_state(with_data=true)
            state.current_screen = PROJECT_LIST
            state.previous_screen = MAIN_LIST

            # 'b' should go back
            handle_input!(state, 'b')
            @test state.current_screen == MAIN_LIST
        end

        @testset "Routes to CATEGORY_LIST Handler" begin
            state = create_test_state(with_data=true)
            state.current_screen = CATEGORY_LIST
            state.previous_screen = MAIN_LIST

            # 'b' should go back
            handle_input!(state, 'b')
            @test state.current_screen == MAIN_LIST
        end

        @testset "Routes to DELETE_CONFIRM Handler" begin
            state = create_test_state(with_data=true)
            state.current_screen = DELETE_CONFIRM
            state.previous_screen = MAIN_LIST
            state.delete_type = :todo
            state.delete_id = state.todos[1].id
            state.delete_name = "Test"

            initial_count = length(list_todos(state.db))

            # 'n' should cancel
            handle_input!(state, 'n')
            @test state.current_screen == MAIN_LIST
            @test length(list_todos(state.db)) == initial_count
        end
    end

    # =========================================================================
    # Full Workflow Tests
    # =========================================================================

    @testset "Full Workflow - Create Todo" begin
        state = create_test_state(with_data=false)

        # Start at main list
        @test state.current_screen == MAIN_LIST

        # Press 'a' to add todo
        handle_input!(state, 'a')
        @test state.current_screen == TODO_ADD

        # Fill in form fields
        state.form_fields[:title] = "Integration Test Todo"
        state.form_fields[:description] = "Created during integration test"
        state.form_fields[:status] = "pending"
        state.form_fields[:priority] = "1"
        state.form_fields[:start_date] = ""
        state.form_fields[:due_date] = ""
        state.form_fields[:project_id] = ""
        state.form_fields[:category_id] = ""

        # Navigate to save button area (index 7) and save
        state.form_field_index = 7
        handle_input!(state, :enter)

        # Should have created todo and returned to main list
        @test state.current_screen == MAIN_LIST
        refresh_data!(state)
        @test any(t -> t.title == "Integration Test Todo", state.todos)
        @test state.message !== nothing
        @test state.message_type == :success
    end

    @testset "Full Workflow - Edit Todo" begin
        state = create_test_state(with_data=true)
        original_title = state.todos[1].title

        # From main list, press 'e' to edit
        handle_input!(state, 'e')
        @test state.current_screen == TODO_EDIT
        @test state.current_todo !== nothing

        # Modify title
        state.form_fields[:title] = "Modified Title"

        # Save
        state.form_field_index = 7
        handle_input!(state, :enter)

        # Verify
        @test state.current_screen == MAIN_LIST
        refresh_data!(state)
        @test any(t -> t.title == "Modified Title", state.todos)
        @test !any(t -> t.title == original_title, state.todos)
    end

    @testset "Full Workflow - Delete Todo" begin
        state = create_test_state(with_data=true)
        initial_count = length(state.todos)
        todo_to_delete = state.todos[1].title

        # From main list, press 'd' to delete
        handle_input!(state, 'd')
        @test state.current_screen == DELETE_CONFIRM
        @test state.delete_type == :todo

        # Confirm deletion
        handle_input!(state, 'y')

        # Verify
        @test state.current_screen == MAIN_LIST
        refresh_data!(state)
        @test length(state.todos) == initial_count - 1
        @test !any(t -> t.title == todo_to_delete, state.todos)
    end

    @testset "Full Workflow - Cancel Delete" begin
        state = create_test_state(with_data=true)
        initial_count = length(state.todos)
        todo_title = state.todos[1].title

        # Start delete flow
        handle_input!(state, 'd')
        @test state.current_screen == DELETE_CONFIRM

        # Cancel with 'n'
        handle_input!(state, 'n')

        # Verify nothing deleted
        @test state.current_screen == MAIN_LIST
        refresh_data!(state)
        @test length(state.todos) == initial_count
        @test any(t -> t.title == todo_title, state.todos)
    end

    @testset "Full Workflow - Filter and Navigate" begin
        state = create_test_state(with_data=true)

        # Create additional todos with different statuses
        create_todo(state.db, "Pending Todo 1", status="pending")
        create_todo(state.db, "Completed Todo 1", status="completed")
        refresh_data!(state)

        all_count = length(state.todos)

        # Open filter menu
        handle_input!(state, 'f')
        @test state.current_screen == FILTER_MENU

        # Select status filter (option 1)
        state.selected_index = 1
        handle_input!(state, :enter)
        @test state.current_screen == FILTER_STATUS

        # Select "pending" (option 2)
        state.selected_index = 2
        handle_input!(state, :enter)

        # Should be back at main list with filter applied
        @test state.current_screen == MAIN_LIST
        @test state.filter_status == "pending"
        refresh_data!(state)
        @test length(state.todos) < all_count
        @test all(t -> t.status == "pending", state.todos)
    end

    @testset "Full Workflow - Project Management" begin
        state = create_test_state(with_data=false)

        # Go to projects
        handle_input!(state, 'p')
        @test state.current_screen == PROJECT_LIST

        # Add project
        handle_input!(state, 'a')
        @test state.current_screen == PROJECT_ADD

        # Fill in project form
        state.form_fields[:name] = "New Project"
        state.form_fields[:description] = "Test project"
        state.form_fields[:color] = "#FF0000"

        # Save
        state.form_field_index = 4  # Save button position
        handle_input!(state, :enter)

        # Verify
        @test state.current_screen == PROJECT_LIST
        refresh_data!(state)
        @test any(p -> p.name == "New Project", state.projects)
    end

    @testset "Full Workflow - Category Management" begin
        state = create_test_state(with_data=false)

        # Go to categories
        handle_input!(state, 'g')
        @test state.current_screen == CATEGORY_LIST

        # Add category
        handle_input!(state, 'a')
        @test state.current_screen == CATEGORY_ADD

        # Fill in category form
        state.form_fields[:name] = "New Category"
        state.form_fields[:color] = "#00FF00"

        # Save
        state.form_field_index = 3  # Save button position
        handle_input!(state, :enter)

        # Verify
        @test state.current_screen == CATEGORY_LIST
        refresh_data!(state)
        @test any(c -> c.name == "New Category", state.categories)
    end

    @testset "Full Workflow - Toggle Todo Completion" begin
        state = create_test_state(with_data=true)

        # Get initial status
        initial_status = state.todos[1].status
        @test initial_status == "pending"

        # Toggle completion
        handle_input!(state, 'c')
        refresh_data!(state)
        @test state.todos[1].status == "completed"

        # Toggle again
        handle_input!(state, 'c')
        refresh_data!(state)
        @test state.todos[1].status == "pending"
    end

    @testset "Full Workflow - View Todo Detail and Edit" begin
        state = create_test_state(with_data=true)

        # View detail
        handle_input!(state, :enter)
        @test state.current_screen == TODO_DETAIL
        @test state.current_todo !== nothing

        # Edit from detail
        handle_input!(state, 'e')
        @test state.current_screen == TODO_EDIT

        # Cancel edit - goes back to TODO_DETAIL (the previous screen when edit was initiated)
        handle_input!(state, :escape)
        @test state.current_screen == TODO_DETAIL

        # Go back to main list - need to press 'b' to go back from detail
        # Note: after cancel, previous_screen was cleared/set by the form handler
        # We need to go back through normal flow
        state.previous_screen = MAIN_LIST  # Reset for test continuity
        handle_input!(state, 'b')
        @test state.current_screen == MAIN_LIST
    end

    @testset "Navigation - Quick Key Actions Work Consistently" begin
        state = create_test_state(with_data=true)

        # From main list, 'p' goes to projects
        handle_input!(state, 'p')
        @test state.current_screen == PROJECT_LIST

        # 'b' goes back
        handle_input!(state, 'b')
        @test state.current_screen == MAIN_LIST

        # 'g' goes to categories
        handle_input!(state, 'g')
        @test state.current_screen == CATEGORY_LIST

        # 'b' goes back
        handle_input!(state, 'b')
        @test state.current_screen == MAIN_LIST

        # 'f' goes to filter
        handle_input!(state, 'f')
        @test state.current_screen == FILTER_MENU

        # 'b' goes back
        handle_input!(state, 'b')
        @test state.current_screen == MAIN_LIST
    end
end
