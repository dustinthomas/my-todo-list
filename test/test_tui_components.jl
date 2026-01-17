"""
Tests for TUI rendering components.

Tests cover:
- Header component rendering
- Footer component rendering
- Message component rendering

Note: Visual appearance (colors, alignment) requires MANUAL TESTING.
These tests verify content presence and return types.
"""

using Term: Panel

@testset "TUI Component Tests" begin
    @testset "Header Component" begin
        @testset "Basic Header" begin
            output = render_header("Todo List")
            @test output isa Panel
            @test contains(string(output), "Todo List")
        end

        @testset "Header with Subtitle" begin
            output = render_header("Todo List", subtitle="5 items")
            output_str = string(output)
            @test output isa Panel
            @test contains(output_str, "Todo List")
            @test contains(output_str, "5 items")
        end

        @testset "Header with Filter Info" begin
            output = render_header("Todo List", subtitle="[Filter: pending] [3 items]")
            output_str = string(output)
            @test contains(output_str, "Todo List")
            @test contains(output_str, "Filter: pending")
            @test contains(output_str, "3 items")
        end

        @testset "Header with Empty Subtitle" begin
            output = render_header("Projects", subtitle="")
            output_str = string(output)
            @test output isa Panel
            @test contains(output_str, "Projects")
        end

        @testset "Header with Long Title" begin
            long_title = "This Is A Very Long Title That Might Need Truncation"
            output = render_header(long_title)
            @test output isa Panel
            # Should contain at least part of the title
            @test contains(string(output), "This Is A Very Long")
        end
    end

    @testset "Footer Component" begin
        @testset "Basic Footer with Shortcuts" begin
            shortcuts = [("j/k", "Navigate"), ("Enter", "Select"), ("q", "Quit")]
            output = render_footer(shortcuts)
            output_str = string(output)

            # Check all shortcuts are present
            @test contains(output_str, "j/k")
            @test contains(output_str, "Navigate")
            @test contains(output_str, "Enter")
            @test contains(output_str, "Select")
            @test contains(output_str, "q")
            @test contains(output_str, "Quit")
        end

        @testset "Footer with Single Shortcut" begin
            shortcuts = [("Esc", "Back")]
            output = render_footer(shortcuts)
            output_str = string(output)

            @test contains(output_str, "Esc")
            @test contains(output_str, "Back")
        end

        @testset "Footer with Many Shortcuts" begin
            shortcuts = [
                ("j/k", "Navigate"),
                ("Enter", "Select"),
                ("a", "Add"),
                ("e", "Edit"),
                ("d", "Delete"),
                ("f", "Filter"),
                ("q", "Quit")
            ]
            output = render_footer(shortcuts)
            output_str = string(output)

            # All shortcuts should be present
            for (key, action) in shortcuts
                @test contains(output_str, key)
                @test contains(output_str, action)
            end
        end

        @testset "Empty Footer" begin
            shortcuts = Tuple{String,String}[]
            output = render_footer(shortcuts)
            # Should still return valid output
            @test output isa String || output isa Panel
        end
    end

    @testset "Message Component" begin
        @testset "Success Message" begin
            output = render_message("Todo created successfully!", :success)
            output_str = string(output)

            @test contains(output_str, "Todo created successfully!")
            # Note: Color testing requires manual verification
        end

        @testset "Error Message" begin
            output = render_message("Title is required", :error)
            output_str = string(output)

            @test contains(output_str, "Title is required")
        end

        @testset "Info Message" begin
            output = render_message("Press 'a' to add a new todo", :info)
            output_str = string(output)

            @test contains(output_str, "Press 'a' to add a new todo")
        end

        @testset "Warning Message" begin
            output = render_message("This action cannot be undone", :warning)
            output_str = string(output)

            @test contains(output_str, "This action cannot be undone")
        end

        @testset "Message with Special Characters" begin
            output = render_message("Todo 'Buy groceries' deleted", :success)
            output_str = string(output)

            @test contains(output_str, "Buy groceries")
            @test contains(output_str, "deleted")
        end

        @testset "Empty Message" begin
            output = render_message("", :info)
            # Should handle empty message gracefully
            @test output isa String || output isa Panel
        end

        @testset "No Message (Nothing)" begin
            output = render_message(nothing, :info)
            # Should return empty string for no message
            @test output == "" || output === nothing
        end
    end

    @testset "Component Integration" begin
        @testset "Components Return Correct Types" begin
            # All components should return types that can be converted to string
            header = render_header("Test")
            footer = render_footer([("q", "Quit")])
            message = render_message("Test", :success)

            @test string(header) isa String
            @test string(footer) isa String
            @test string(message) isa String
        end
    end
end
