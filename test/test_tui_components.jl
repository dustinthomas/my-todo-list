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

    @testset "Table Component" begin
        include("tui_test_helpers.jl")

        @testset "Todo Table - Empty" begin
            output = render_todo_table(Todo[], 1, 0, 20)
            output_str = string(output)
            @test contains(output_str, "No todos")
        end

        @testset "Todo Table - With Data" begin
            todos = [
                Todo(1, "First todo", nothing, "pending", 1, nothing, nothing,
                     nothing, "2026-01-20", nothing, nothing, nothing),
                Todo(2, "Second todo", nothing, "completed", 2, nothing, nothing,
                     nothing, nothing, nothing, nothing, nothing),
            ]

            output = render_todo_table(todos, 1, 0, 20)
            output_str = string(output)

            # Contains expected content
            @test contains(output_str, "First todo")
            @test contains(output_str, "Second todo")
            @test contains(output_str, "pending")
            @test contains(output_str, "completed")
            @test contains(output_str, "2026-01-20")

            # Selected row indicator (first row selected)
            @test contains(output_str, ">") || contains(output_str, "►") || contains(output_str, "→")
        end

        @testset "Todo Table - Selection" begin
            todos = [
                Todo(1, "Todo One", nothing, "pending", 1, nothing, nothing,
                     nothing, nothing, nothing, nothing, nothing),
                Todo(2, "Todo Two", nothing, "pending", 2, nothing, nothing,
                     nothing, nothing, nothing, nothing, nothing),
            ]

            # Select second item
            output = render_todo_table(todos, 2, 0, 20)
            output_str = string(output)

            # Both todos should be present
            @test contains(output_str, "Todo One")
            @test contains(output_str, "Todo Two")
        end

        @testset "Todo Table - Scrolling" begin
            # Create 50 todos
            todos = [Todo(i, "Todo $i", nothing, "pending", 2, nothing, nothing,
                          nothing, nothing, nothing, nothing, nothing) for i in 1:50]

            # Visible window is 20 lines, scroll offset 30, selection at 35
            output = render_todo_table(todos, 35, 30, 20)
            output_str = string(output)

            # Should show todos around the visible range
            @test contains(output_str, "Todo 35")
            # First item should not be visible
            @test !contains(output_str, "Todo 1 ")  # Space to avoid matching Todo 10, 11, etc.
        end

        @testset "Format Status" begin
            # These return styled strings
            @test contains(format_status("pending"), "pending")
            @test contains(format_status("completed"), "completed")
            @test contains(format_status("in_progress"), "in_progress")
            @test contains(format_status("blocked"), "blocked")
        end

        @testset "Format Priority" begin
            @test contains(format_priority(1), "HIGH") || contains(format_priority(1), "1")
            @test contains(format_priority(2), "MEDIUM") || contains(format_priority(2), "2")
            @test contains(format_priority(3), "LOW") || contains(format_priority(3), "3")
        end

        @testset "Truncate String" begin
            # Short string unchanged
            @test truncate_string("Hello", 10) == "Hello"

            # Long string truncated with ellipsis
            long_str = "This is a very long string that needs truncation"
            truncated = truncate_string(long_str, 20)
            @test length(truncated) <= 20
            @test endswith(truncated, "…") || endswith(truncated, "...")

            # Empty string
            @test truncate_string("", 10) == ""
        end

        @testset "Project Table" begin
            projects = [
                Project(1, "Project A", "Description A", "#FF0000", nothing, nothing),
                Project(2, "Project B", nothing, "#00FF00", nothing, nothing)
            ]
            # todo_counts maps project_id to count
            output = render_project_table(projects, 1, Dict(1 => 5, 2 => 3))
            output_str = string(output)

            @test contains(output_str, "Project A")
            @test contains(output_str, "Project B")
            @test contains(output_str, "5") || contains(output_str, "Description A")
        end

        @testset "Project Table - Empty" begin
            output = render_project_table(Project[], 1, Dict{Int64,Int}())
            output_str = string(output)
            @test contains(output_str, "No projects") || contains(output_str, "empty")
        end

        @testset "Category Table" begin
            categories = [
                Category(1, "Category A", "#00FF00", nothing),
                Category(2, "Category B", "#0000FF", nothing)
            ]
            output = render_category_table(categories, 1, Dict(1 => 3, 2 => 7))
            output_str = string(output)

            @test contains(output_str, "Category A")
            @test contains(output_str, "Category B")
        end

        @testset "Category Table - Empty" begin
            output = render_category_table(Category[], 1, Dict{Int64,Int}())
            output_str = string(output)
            @test contains(output_str, "No categories") || contains(output_str, "empty")
        end
    end

    @testset "Form Components" begin
        @testset "Text Field - Basic" begin
            output = render_text_field("Title", "My Todo", true)
            output_str = string(output)

            @test contains(output_str, "Title")
            @test contains(output_str, "My Todo")
        end

        @testset "Text Field - Required Indicator" begin
            output = render_text_field("Title*", "My Todo", true)
            output_str = string(output)

            @test contains(output_str, "Title")
            @test contains(output_str, "*") || contains(output_str, "required")
        end

        @testset "Text Field - Empty Value" begin
            output = render_text_field("Title", "", true)
            output_str = string(output)

            @test contains(output_str, "Title")
        end

        @testset "Text Field - With Error" begin
            output = render_text_field("Title*", "", true, "Title is required")
            output_str = string(output)

            @test contains(output_str, "Title")
            @test contains(output_str, "Title is required")
        end

        @testset "Text Field - Not Focused" begin
            output = render_text_field("Description", "Some text", false)
            output_str = string(output)

            @test contains(output_str, "Description")
            @test contains(output_str, "Some text")
        end

        @testset "Radio Group - Basic" begin
            options = ["pending", "in_progress", "completed"]
            output = render_radio_group("Status", options, "pending", true)
            output_str = string(output)

            @test contains(output_str, "Status")
            @test contains(output_str, "pending")
            @test contains(output_str, "in_progress")
            @test contains(output_str, "completed")
        end

        @testset "Radio Group - Selected Option" begin
            options = ["pending", "in_progress", "completed"]
            output = render_radio_group("Status", options, "in_progress", true)
            output_str = string(output)

            # Selected option should have indicator
            @test contains(output_str, "in_progress")
            # Check for selection marker (various possible indicators)
            @test contains(output_str, "●") || contains(output_str, "◉") ||
                  contains(output_str, "(*)") || contains(output_str, "[x]") ||
                  contains(output_str, "✓")
        end

        @testset "Radio Group - Not Focused" begin
            options = ["low", "medium", "high"]
            output = render_radio_group("Priority", options, "medium", false)
            output_str = string(output)

            @test contains(output_str, "Priority")
            @test contains(output_str, "medium")
        end

        @testset "Dropdown - Basic" begin
            options = [("1", "Project A"), ("2", "Project B"), ("", "None")]
            output = render_dropdown("Project", options, "1", true, false)
            output_str = string(output)

            @test contains(output_str, "Project")
            @test contains(output_str, "Project A")
        end

        @testset "Dropdown - Expanded" begin
            options = [("1", "Project A"), ("2", "Project B"), ("", "None")]
            output = render_dropdown("Project", options, "1", true, true)
            output_str = string(output)

            @test contains(output_str, "Project")
            # When expanded, all options should be visible
            @test contains(output_str, "Project A")
            @test contains(output_str, "Project B")
            @test contains(output_str, "None")
        end

        @testset "Dropdown - None Selected" begin
            options = [("1", "Project A"), ("2", "Project B"), ("", "None")]
            output = render_dropdown("Project", options, "", true, false)
            output_str = string(output)

            @test contains(output_str, "Project")
            @test contains(output_str, "None") || contains(output_str, "—")
        end

        @testset "Date Field - With Value" begin
            output = render_date_field("Due Date", "2026-01-20", true)
            output_str = string(output)

            @test contains(output_str, "Due Date")
            @test contains(output_str, "2026-01-20")
        end

        @testset "Date Field - Empty" begin
            output = render_date_field("Start Date", "", false)
            output_str = string(output)

            @test contains(output_str, "Start Date")
        end

        @testset "Date Field - With Error" begin
            output = render_date_field("Due Date", "invalid", true, "Invalid date format")
            output_str = string(output)

            @test contains(output_str, "Due Date")
            @test contains(output_str, "Invalid date format")
        end

        @testset "Full Form - Todo Fields" begin
            fields = Dict(
                :title => "Test Todo",
                :description => "A test description",
                :status => "pending",
                :priority => "2"
            )
            errors = Dict{Symbol,String}()

            output = render_todo_form_fields(fields, 1, errors)
            output_str = string(output)

            @test contains(output_str, "Title")
            @test contains(output_str, "Test Todo")
            @test contains(output_str, "Description")
            @test contains(output_str, "Status")
        end

        @testset "Full Form - With Errors" begin
            fields = Dict(
                :title => "",
                :description => ""
            )
            errors = Dict(:title => "Title is required")

            output = render_todo_form_fields(fields, 1, errors)
            output_str = string(output)

            @test contains(output_str, "Title")
            @test contains(output_str, "Title is required")
        end

        @testset "Project Form Fields" begin
            fields = Dict(
                :name => "My Project",
                :description => "Project description",
                :color => "#FF0000"
            )
            errors = Dict{Symbol,String}()

            output = render_project_form_fields(fields, 1, errors)
            output_str = string(output)

            @test contains(output_str, "Name")
            @test contains(output_str, "My Project")
            @test contains(output_str, "Description")
            @test contains(output_str, "Color")
        end

        @testset "Category Form Fields" begin
            fields = Dict(
                :name => "My Category",
                :color => "#00FF00"
            )
            errors = Dict{Symbol,String}()

            output = render_category_form_fields(fields, 1, errors)
            output_str = string(output)

            @test contains(output_str, "Name")
            @test contains(output_str, "My Category")
            @test contains(output_str, "Color")
        end
    end

    @testset "Dialog Components" begin
        @testset "Delete Confirmation - Todo" begin
            output = render_delete_dialog(:todo, "Buy groceries")
            output_str = string(output)

            @test contains(output_str, "todo") || contains(output_str, "Todo")
            @test contains(output_str, "Buy groceries")
            @test contains(output_str, "Delete") || contains(output_str, "delete")
            @test contains(output_str, "Cancel") || contains(output_str, "cancel") ||
                  contains(output_str, "No") || contains(output_str, "n")
            @test contains(output_str, "cannot be undone") || contains(output_str, "permanent")
        end

        @testset "Delete Confirmation - Project" begin
            output = render_delete_dialog(:project, "Work Tasks")
            output_str = string(output)

            @test contains(output_str, "project") || contains(output_str, "Project")
            @test contains(output_str, "Work Tasks")
        end

        @testset "Delete Confirmation - Category" begin
            output = render_delete_dialog(:category, "Urgent")
            output_str = string(output)

            @test contains(output_str, "category") || contains(output_str, "Category")
            @test contains(output_str, "Urgent")
        end

        @testset "Delete Dialog - Yes/No Options" begin
            output = render_delete_dialog(:todo, "Test Item")
            output_str = string(output)

            # Should show confirmation options
            @test (contains(output_str, "y") && contains(output_str, "n")) ||
                  (contains(output_str, "Yes") && contains(output_str, "No"))
        end

        @testset "Filter Summary - No Filters" begin
            output = render_filter_summary(nothing, nothing, nothing, Project[], Category[])
            output_str = string(output)

            @test contains(output_str, "No filters") || contains(output_str, "All") ||
                  contains(output_str, "none") || isempty(strip(output_str))
        end

        @testset "Filter Summary - Status Filter" begin
            output = render_filter_summary("pending", nothing, nothing, Project[], Category[])
            output_str = string(output)

            @test contains(output_str, "pending")
            @test contains(output_str, "Status") || contains(output_str, "status")
        end

        @testset "Filter Summary - Project Filter" begin
            projects = [Project(1, "Work", nothing, nothing, nothing, nothing)]
            output = render_filter_summary(nothing, 1, nothing, projects, Category[])
            output_str = string(output)

            @test contains(output_str, "Work")
            @test contains(output_str, "Project") || contains(output_str, "project")
        end

        @testset "Filter Summary - Category Filter" begin
            categories = [Category(1, "Urgent", nothing, nothing)]
            output = render_filter_summary(nothing, nothing, 1, Project[], categories)
            output_str = string(output)

            @test contains(output_str, "Urgent")
            @test contains(output_str, "Category") || contains(output_str, "category")
        end

        @testset "Filter Summary - Multiple Filters" begin
            projects = [Project(1, "Work", nothing, nothing, nothing, nothing)]
            categories = [Category(2, "Important", nothing, nothing)]
            output = render_filter_summary("completed", 1, 2, projects, categories)
            output_str = string(output)

            @test contains(output_str, "completed")
            @test contains(output_str, "Work")
            @test contains(output_str, "Important")
        end

        @testset "Filter Menu Options" begin
            output = render_filter_menu_options(1)
            output_str = string(output)

            @test contains(output_str, "Status")
            @test contains(output_str, "Project")
            @test contains(output_str, "Category")
            @test contains(output_str, "Clear") || contains(output_str, "clear")
        end

        @testset "Filter Menu - Selection" begin
            # First option selected
            output1 = render_filter_menu_options(1)
            output1_str = string(output1)
            @test contains(output1_str, "►") || contains(output1_str, ">")

            # Third option selected
            output3 = render_filter_menu_options(3)
            output3_str = string(output3)
            @test contains(output3_str, "Category")
        end

        @testset "Status Filter Options" begin
            output = render_status_filter_options("pending", 2)
            output_str = string(output)

            @test contains(output_str, "All") || contains(output_str, "all")
            @test contains(output_str, "pending")
            @test contains(output_str, "in_progress")
            @test contains(output_str, "completed")
            @test contains(output_str, "blocked")
        end
    end
end
