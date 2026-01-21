@testset "Screen State" begin
    # Setup: create a test state with in-memory database
    db = connect_database(":memory:")
    init_schema!(db)
    state = create_initial_state(db)

    @testset "Initial state" begin
        @test state.screen_state isa Dict{Screen, Any}
        @test isempty(state.screen_state)
    end

    @testset "get_screen_state with default" begin
        # Define a simple test state struct
        default_val = (scroll_offset=0, query="")

        # Getting non-existent state returns default
        result = get_screen_state(state, MAIN_LIST, default_val)
        @test result == default_val

        # State should still be empty (get doesn't create entry)
        @test isempty(state.screen_state)
    end

    @testset "get_screen_state without default" begin
        # Getting non-existent state returns nothing
        result = get_screen_state(state, TODO_DETAIL)
        @test result === nothing
    end

    @testset "set_screen_state!" begin
        test_state = (value=42, name="test")

        # Set state for a screen
        set_screen_state!(state, FILTER_MENU, test_state)

        # Verify it was stored
        @test haskey(state.screen_state, FILTER_MENU)
        @test state.screen_state[FILTER_MENU] == test_state

        # Get it back
        result = get_screen_state(state, FILTER_MENU, (value=0, name=""))
        @test result == test_state
    end

    @testset "has_screen_state" begin
        # Clear and test
        empty!(state.screen_state)

        @test !has_screen_state(state, PROJECT_LIST)

        set_screen_state!(state, PROJECT_LIST, "test_value")
        @test has_screen_state(state, PROJECT_LIST)
    end

    @testset "clear_screen_state!" begin
        # Set some state
        set_screen_state!(state, CATEGORY_LIST, "to_be_cleared")
        @test has_screen_state(state, CATEGORY_LIST)

        # Clear it
        clear_screen_state!(state, CATEGORY_LIST)
        @test !has_screen_state(state, CATEGORY_LIST)

        # Clearing non-existent state is safe
        clear_screen_state!(state, DELETE_CONFIRM)  # Should not error
    end

    @testset "clear_all_screen_states!" begin
        # Clear any leftover state from previous tests
        empty!(state.screen_state)

        # Set multiple screen states
        set_screen_state!(state, MAIN_LIST, "state1")
        set_screen_state!(state, TODO_DETAIL, "state2")
        set_screen_state!(state, FILTER_MENU, "state3")

        @test length(state.screen_state) == 3

        # Clear all
        clear_all_screen_states!(state)

        @test isempty(state.screen_state)
    end

    @testset "Different types per screen" begin
        # Each screen can store different types
        set_screen_state!(state, MAIN_LIST, 42)
        set_screen_state!(state, TODO_DETAIL, "string_value")
        set_screen_state!(state, FILTER_MENU, [1, 2, 3])
        set_screen_state!(state, PROJECT_LIST, (a=1, b=2))

        @test get_screen_state(state, MAIN_LIST, 0) == 42
        @test get_screen_state(state, TODO_DETAIL, "") == "string_value"
        @test get_screen_state(state, FILTER_MENU, Int[]) == [1, 2, 3]
        @test get_screen_state(state, PROJECT_LIST, (a=0, b=0)) == (a=1, b=2)
    end

    @testset "Overwriting state" begin
        set_screen_state!(state, TODO_ADD, "first")
        @test get_screen_state(state, TODO_ADD, "") == "first"

        set_screen_state!(state, TODO_ADD, "second")
        @test get_screen_state(state, TODO_ADD, "") == "second"
    end
end
