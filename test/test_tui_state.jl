"""
Tests for TUI state management.

Tests cover:
- AppState initialization
- Screen transitions
- Data refresh
"""

include("tui_test_helpers.jl")

@testset "TUI State Tests" begin
    @testset "Screen Enum" begin
        # Verify all required screens exist
        @test isdefined(TodoList, :MAIN_LIST)
        @test isdefined(TodoList, :TODO_DETAIL)
        @test isdefined(TodoList, :TODO_ADD)
        @test isdefined(TodoList, :TODO_EDIT)
        @test isdefined(TodoList, :FILTER_MENU)
        @test isdefined(TodoList, :FILTER_STATUS)
        @test isdefined(TodoList, :FILTER_PROJECT)
        @test isdefined(TodoList, :FILTER_CATEGORY)
        @test isdefined(TodoList, :PROJECT_LIST)
        @test isdefined(TodoList, :PROJECT_ADD)
        @test isdefined(TodoList, :PROJECT_EDIT)
        @test isdefined(TodoList, :CATEGORY_LIST)
        @test isdefined(TodoList, :CATEGORY_ADD)
        @test isdefined(TodoList, :CATEGORY_EDIT)
        @test isdefined(TodoList, :DELETE_CONFIRM)
    end

    @testset "AppState Initialization" begin
        state = create_test_state()

        # Check initial screen
        @test state.current_screen == MAIN_LIST

        # Check initial running state
        @test state.running == true

        # Check initial selection
        @test state.selected_index == 1
        @test state.scroll_offset == 0

        # Check filters are empty
        @test state.filter_status === nothing
        @test state.filter_project_id === nothing
        @test state.filter_category_id === nothing

        # Check data lists exist
        @test state.todos isa Vector{Todo}
        @test state.projects isa Vector{Project}
        @test state.categories isa Vector{Category}

        # Check current item fields
        @test state.current_todo === nothing
        @test state.current_project === nothing
        @test state.current_category === nothing

        # Check delete state
        @test state.delete_type === nothing
        @test state.delete_id === nothing
        @test state.delete_name == ""

        # Check form state
        @test state.form_fields isa Dict{Symbol, String}
        @test state.form_field_index == 1
        @test state.form_errors isa Dict{Symbol, String}

        # Check message state
        @test state.message === nothing
        @test state.message_type === nothing

        # Check database connection
        @test state.db isa SQLite.DB
    end

    @testset "AppState with Data" begin
        state = create_test_state(with_data=true)

        # Should have seeded data
        @test length(state.todos) == 2
        @test length(state.projects) == 1
        @test length(state.categories) == 1

        # Check todo data
        @test state.todos[1].title == "Test Todo 1"
        @test state.todos[1].status == "pending"
        @test state.todos[2].title == "Test Todo 2"
        @test state.todos[2].status == "completed"
    end

    @testset "Screen Transitions" begin
        state = create_test_state()

        # Initial state
        @test state.current_screen == MAIN_LIST
        @test state.previous_screen === nothing

        # go_to_screen! saves previous
        go_to_screen!(state, TODO_ADD)
        @test state.current_screen == TODO_ADD
        @test state.previous_screen == MAIN_LIST

        # Another transition
        go_to_screen!(state, DELETE_CONFIRM)
        @test state.current_screen == DELETE_CONFIRM
        @test state.previous_screen == TODO_ADD

        # go_back! restores previous
        go_back!(state)
        @test state.current_screen == TODO_ADD

        # go_back! from initial screen stays
        state = create_test_state()
        go_back!(state)
        @test state.current_screen == MAIN_LIST
    end

    @testset "Data Refresh" begin
        state = create_test_state()

        # Initially empty
        @test length(state.todos) == 0
        @test length(state.projects) == 0
        @test length(state.categories) == 0

        # Add data directly to DB
        create_todo(state.db, "New Todo")
        create_project(state.db, "New Project")
        create_category(state.db, "New Category")

        # Refresh should pick it up
        refresh_data!(state)
        @test length(state.todos) == 1
        @test length(state.projects) == 1
        @test length(state.categories) == 1
        @test state.todos[1].title == "New Todo"
    end

    @testset "Data Refresh with Filters" begin
        state = create_test_state(with_data=true)

        # Initially has 2 todos
        @test length(state.todos) == 2

        # Apply status filter
        state.filter_status = "pending"
        refresh_data!(state)

        # Should only have pending todos
        @test length(state.todos) == 1
        @test state.todos[1].status == "pending"

        # Clear filter
        state.filter_status = nothing
        refresh_data!(state)
        @test length(state.todos) == 2
    end

    @testset "Selection Bounds" begin
        state = create_test_state(with_data=true)

        # Selected index should be within bounds
        @test state.selected_index >= 1

        # After refresh with data, should still be valid
        @test state.selected_index <= length(state.todos) || length(state.todos) == 0
    end

    @testset "Form Reset" begin
        state = create_test_state()

        # Set some form state
        state.form_fields[:title] = "Test"
        state.form_field_index = 3
        state.form_errors[:title] = "Error"

        # Reset form
        reset_form!(state)

        # Should be cleared
        @test isempty(state.form_fields)
        @test state.form_field_index == 1
        @test isempty(state.form_errors)
    end

    @testset "Message Management" begin
        state = create_test_state()

        # Set success message
        set_message!(state, "Todo created!", :success)
        @test state.message == "Todo created!"
        @test state.message_type == :success

        # Set error message
        set_message!(state, "Title required", :error)
        @test state.message == "Title required"
        @test state.message_type == :error

        # Clear message
        clear_message!(state)
        @test state.message === nothing
        @test state.message_type === nothing
    end

    @testset "Delete State Setup" begin
        state = create_test_state(with_data=true)

        # Setup delete for todo
        setup_delete!(state, :todo, state.todos[1].id, state.todos[1].title)
        @test state.delete_type == :todo
        @test state.delete_id == state.todos[1].id
        @test state.delete_name == state.todos[1].title

        # Clear delete state
        clear_delete!(state)
        @test state.delete_type === nothing
        @test state.delete_id === nothing
        @test state.delete_name == ""
    end
end
