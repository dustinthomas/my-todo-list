"""
Tests for TUI screens.

Tests cover:
- Main list screen rendering
- Main list input handling
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
end
