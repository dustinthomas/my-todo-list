"""
Tests for TUI input handling.

Tests cover:
- Key constants
- Navigation key detection
- Quit key detection
- Action key detection

Note: Raw terminal input (read_key, setup_terminal, restore_terminal)
requires MANUAL TESTING - cannot be unit tested.
"""

@testset "TUI Input Tests" begin
    @testset "Key Constants" begin
        # Action keys
        @test KEY_QUIT == 'q'
        @test KEY_ADD == 'a'
        @test KEY_EDIT == 'e'
        @test KEY_DELETE == 'd'
        @test KEY_COMPLETE == 'c'
        @test KEY_BACK == 'b'
        @test KEY_FILTER == 'f'
        @test KEY_PROJECTS == 'p'
        @test KEY_CATEGORIES == 'g'
        @test KEY_HELP == '?'

        # Vim-style navigation
        @test KEY_NAV_UP == 'k'
        @test KEY_NAV_DOWN == 'j'

        # Confirm/Cancel
        @test KEY_YES == 'y'
        @test KEY_NO == 'n'
    end

    @testset "Special Key Symbols" begin
        # Verify special key symbols are defined
        @test isdefined(TodoList, :KEY_ENTER)
        @test isdefined(TodoList, :KEY_ESCAPE)
        @test isdefined(TodoList, :KEY_TAB)
        @test isdefined(TodoList, :KEY_SHIFT_TAB)
        @test isdefined(TodoList, :KEY_UP)
        @test isdefined(TodoList, :KEY_DOWN)
        @test isdefined(TodoList, :KEY_LEFT)
        @test isdefined(TodoList, :KEY_RIGHT)
        @test isdefined(TodoList, :KEY_CTRL_C)

        # Check they are symbols
        @test KEY_ENTER isa Symbol
        @test KEY_ESCAPE isa Symbol
        @test KEY_UP isa Symbol
        @test KEY_DOWN isa Symbol
    end

    @testset "is_navigation_key" begin
        # Vim-style keys
        @test is_navigation_key('j') == true
        @test is_navigation_key('k') == true

        # Arrow key symbols
        @test is_navigation_key(KEY_UP) == true
        @test is_navigation_key(KEY_DOWN) == true

        # Non-navigation keys
        @test is_navigation_key('a') == false
        @test is_navigation_key('q') == false
        @test is_navigation_key('x') == false
        @test is_navigation_key(KEY_ENTER) == false
    end

    @testset "is_quit_key" begin
        @test is_quit_key('q') == true
        @test is_quit_key(KEY_CTRL_C) == true

        # Non-quit keys
        @test is_quit_key('a') == false
        @test is_quit_key(KEY_ESCAPE) == false
        @test is_quit_key('Q') == false  # Case sensitive
    end

    @testset "is_confirm_key" begin
        @test is_confirm_key(KEY_ENTER) == true
        @test is_confirm_key('y') == true

        # Non-confirm keys
        @test is_confirm_key('n') == false
        @test is_confirm_key(KEY_ESCAPE) == false
    end

    @testset "is_cancel_key" begin
        @test is_cancel_key(KEY_ESCAPE) == true
        @test is_cancel_key('n') == true
        @test is_cancel_key('b') == true

        # Non-cancel keys
        @test is_cancel_key('y') == false
        @test is_cancel_key(KEY_ENTER) == false
    end

    @testset "is_up_key" begin
        @test is_up_key('k') == true
        @test is_up_key(KEY_UP) == true

        @test is_up_key('j') == false
        @test is_up_key(KEY_DOWN) == false
    end

    @testset "is_down_key" begin
        @test is_down_key('j') == true
        @test is_down_key(KEY_DOWN) == true

        @test is_down_key('k') == false
        @test is_down_key(KEY_UP) == false
    end

    @testset "get_navigation_direction" begin
        # Up movement returns -1
        @test get_navigation_direction('k') == -1
        @test get_navigation_direction(KEY_UP) == -1

        # Down movement returns 1
        @test get_navigation_direction('j') == 1
        @test get_navigation_direction(KEY_DOWN) == 1

        # Non-navigation returns 0
        @test get_navigation_direction('a') == 0
        @test get_navigation_direction(KEY_ENTER) == 0
    end

    @testset "key_to_string" begin
        # Character keys
        @test key_to_string('a') == "a"
        @test key_to_string('q') == "q"

        # Special keys
        @test key_to_string(KEY_ENTER) == "Enter"
        @test key_to_string(KEY_ESCAPE) == "Escape"
        @test key_to_string(KEY_TAB) == "Tab"
        @test key_to_string(KEY_UP) == "Up"
        @test key_to_string(KEY_DOWN) == "Down"
        @test key_to_string(KEY_CTRL_C) == "Ctrl+C"
    end
end
