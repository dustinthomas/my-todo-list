@testset "Query Tests" begin

    @testset "Project CRUD" begin
        @testset "create project with name only" begin
            db = connect_database(":memory:")
            init_schema!(db)

            proj_id = create_project(db, "Test Project")
            @test proj_id == 1
        end

        @testset "create project with all fields" begin
            db = connect_database(":memory:")
            init_schema!(db)

            proj_id = create_project(db, "My Project",
                                    description="Test description",
                                    color="#FF6B6B")
            @test proj_id == 1

            proj = get_project(db, proj_id)
            @test proj.name == "My Project"
            @test proj.description == "Test description"
            @test proj.color == "#FF6B6B"
        end

        @testset "create duplicate project name" begin
            db = connect_database(":memory:")
            init_schema!(db)

            create_project(db, "Duplicate")
            @test_throws ErrorException create_project(db, "Duplicate")
        end

        @testset "get project by id" begin
            db = connect_database(":memory:")
            init_schema!(db)

            proj_id = create_project(db, "Get Test")
            proj = get_project(db, proj_id)

            @test proj isa Project
            @test proj.id == proj_id
            @test proj.name == "Get Test"
        end

        @testset "get nonexistent project returns nothing" begin
            db = connect_database(":memory:")
            init_schema!(db)

            proj = get_project(db, 9999)
            @test proj === nothing
        end

        @testset "list projects empty database" begin
            db = connect_database(":memory:")
            init_schema!(db)

            projects = list_projects(db)
            @test projects == []
        end

        @testset "list projects populated database" begin
            db = connect_database(":memory:")
            init_schema!(db)

            create_project(db, "Project B")
            create_project(db, "Project A")
            create_project(db, "Project C")

            projects = list_projects(db)
            @test length(projects) == 3
            # Should be ordered by name
            @test projects[1].name == "Project A"
            @test projects[2].name == "Project B"
            @test projects[3].name == "Project C"
        end

        @testset "update project single field" begin
            db = connect_database(":memory:")
            init_schema!(db)

            proj_id = create_project(db, "Original Name")
            updated = update_project!(db, proj_id, name="New Name")

            @test updated == true
            proj = get_project(db, proj_id)
            @test proj.name == "New Name"
        end

        @testset "update project multiple fields" begin
            db = connect_database(":memory:")
            init_schema!(db)

            proj_id = create_project(db, "Project")
            updated = update_project!(db, proj_id,
                                     name="Updated",
                                     description="New desc",
                                     color="#00FF00")

            @test updated == true
            proj = get_project(db, proj_id)
            @test proj.name == "Updated"
            @test proj.description == "New desc"
            @test proj.color == "#00FF00"
        end

        @testset "update nonexistent project" begin
            db = connect_database(":memory:")
            init_schema!(db)

            updated = update_project!(db, 9999, name="Nope")
            @test updated == false
        end

        @testset "delete project" begin
            db = connect_database(":memory:")
            init_schema!(db)

            proj_id = create_project(db, "To Delete")
            deleted = delete_project!(db, proj_id)

            @test deleted == true
            proj = get_project(db, proj_id)
            @test proj === nothing
        end

        @testset "delete nonexistent project" begin
            db = connect_database(":memory:")
            init_schema!(db)

            deleted = delete_project!(db, 9999)
            @test deleted == false
        end
    end

    @testset "Category CRUD" begin
        @testset "create category with name only" begin
            db = connect_database(":memory:")
            init_schema!(db)

            cat_id = create_category(db, "Test Category")
            @test cat_id == 1
        end

        @testset "create category with color" begin
            db = connect_database(":memory:")
            init_schema!(db)

            cat_id = create_category(db, "Urgent", color="#E74C3C")
            @test cat_id == 1

            cat = get_category(db, cat_id)
            @test cat.name == "Urgent"
            @test cat.color == "#E74C3C"
        end

        @testset "create duplicate category name" begin
            db = connect_database(":memory:")
            init_schema!(db)

            create_category(db, "Duplicate")
            @test_throws ErrorException create_category(db, "Duplicate")
        end

        @testset "get category by id" begin
            db = connect_database(":memory:")
            init_schema!(db)

            cat_id = create_category(db, "Get Test")
            cat = get_category(db, cat_id)

            @test cat isa Category
            @test cat.id == cat_id
            @test cat.name == "Get Test"
        end

        @testset "get nonexistent category returns nothing" begin
            db = connect_database(":memory:")
            init_schema!(db)

            cat = get_category(db, 9999)
            @test cat === nothing
        end

        @testset "list categories empty database" begin
            db = connect_database(":memory:")
            init_schema!(db)

            categories = list_categories(db)
            @test categories == []
        end

        @testset "list categories populated database" begin
            db = connect_database(":memory:")
            init_schema!(db)

            create_category(db, "Category B")
            create_category(db, "Category A")
            create_category(db, "Category C")

            categories = list_categories(db)
            @test length(categories) == 3
            # Should be ordered by name
            @test categories[1].name == "Category A"
            @test categories[2].name == "Category B"
            @test categories[3].name == "Category C"
        end

        @testset "update category name" begin
            db = connect_database(":memory:")
            init_schema!(db)

            cat_id = create_category(db, "Original")
            updated = update_category!(db, cat_id, name="Updated")

            @test updated == true
            cat = get_category(db, cat_id)
            @test cat.name == "Updated"
        end

        @testset "update category color" begin
            db = connect_database(":memory:")
            init_schema!(db)

            cat_id = create_category(db, "Test")
            updated = update_category!(db, cat_id, color="#FF0000")

            @test updated == true
            cat = get_category(db, cat_id)
            @test cat.color == "#FF0000"
        end

        @testset "update nonexistent category" begin
            db = connect_database(":memory:")
            init_schema!(db)

            updated = update_category!(db, 9999, name="Nope")
            @test updated == false
        end

        @testset "delete category" begin
            db = connect_database(":memory:")
            init_schema!(db)

            cat_id = create_category(db, "To Delete")
            deleted = delete_category!(db, cat_id)

            @test deleted == true
            cat = get_category(db, cat_id)
            @test cat === nothing
        end

        @testset "delete nonexistent category" begin
            db = connect_database(":memory:")
            init_schema!(db)

            deleted = delete_category!(db, 9999)
            @test deleted == false
        end
    end

    @testset "Todo CRUD" begin
        @testset "create todo with title only" begin
            db = connect_database(":memory:")
            init_schema!(db)

            todo_id = create_todo(db, "Test Todo")
            @test todo_id == 1

            todo = get_todo(db, todo_id)
            @test todo.title == "Test Todo"
            @test todo.status == "pending"  # default
            @test todo.priority == 2  # default
        end

        @testset "create todo with all fields" begin
            db = connect_database(":memory:")
            init_schema!(db)

            proj_id = create_project(db, "Test Project")
            cat_id = create_category(db, "Test Category")

            todo_id = create_todo(db, "Full Todo",
                                 description="Detailed description",
                                 status="in_progress",
                                 priority=1,
                                 project_id=proj_id,
                                 category_id=cat_id,
                                 start_date="2026-01-15",
                                 due_date="2026-01-31")
            @test todo_id == 1

            todo = get_todo(db, todo_id)
            @test todo.title == "Full Todo"
            @test todo.description == "Detailed description"
            @test todo.status == "in_progress"
            @test todo.priority == 1
            @test todo.project_id == proj_id
            @test todo.category_id == cat_id
            @test todo.start_date == "2026-01-15"
            @test todo.due_date == "2026-01-31"
        end

        @testset "create todo with valid project_id" begin
            db = connect_database(":memory:")
            init_schema!(db)

            proj_id = create_project(db, "My Project")
            todo_id = create_todo(db, "Project Todo", project_id=proj_id)

            todo = get_todo(db, todo_id)
            @test todo.project_id == proj_id
        end

        @testset "create todo with valid category_id" begin
            db = connect_database(":memory:")
            init_schema!(db)

            cat_id = create_category(db, "Urgent")
            todo_id = create_todo(db, "Urgent Todo", category_id=cat_id)

            todo = get_todo(db, todo_id)
            @test todo.category_id == cat_id
        end

        @testset "create todo with invalid project_id" begin
            db = connect_database(":memory:")
            init_schema!(db)

            @test_throws ErrorException create_todo(db, "Bad Project", project_id=9999)
        end

        @testset "create todo with invalid category_id" begin
            db = connect_database(":memory:")
            init_schema!(db)

            @test_throws ErrorException create_todo(db, "Bad Category", category_id=9999)
        end

        @testset "create todo with invalid status" begin
            db = connect_database(":memory:")
            init_schema!(db)

            @test_throws ErrorException create_todo(db, "Bad Status", status="invalid")
        end

        @testset "create todo with invalid priority" begin
            db = connect_database(":memory:")
            init_schema!(db)

            @test_throws ErrorException create_todo(db, "Bad Priority", priority=0)
            @test_throws ErrorException create_todo(db, "Bad Priority", priority=4)
        end

        @testset "create todo with invalid date format" begin
            db = connect_database(":memory:")
            init_schema!(db)

            @test_throws ErrorException create_todo(db, "Bad Date", due_date="01/31/2026")
            @test_throws ErrorException create_todo(db, "Bad Date", start_date="2026-13-01")
        end

        @testset "get todo by id" begin
            db = connect_database(":memory:")
            init_schema!(db)

            todo_id = create_todo(db, "Get Test")
            todo = get_todo(db, todo_id)

            @test todo isa Todo
            @test todo.id == todo_id
            @test todo.title == "Get Test"
        end

        @testset "get nonexistent todo returns nothing" begin
            db = connect_database(":memory:")
            init_schema!(db)

            todo = get_todo(db, 9999)
            @test todo === nothing
        end

        @testset "list todos empty database" begin
            db = connect_database(":memory:")
            init_schema!(db)

            todos = list_todos(db)
            @test todos == []
        end

        @testset "list todos populated database" begin
            db = connect_database(":memory:")
            init_schema!(db)

            create_todo(db, "Todo C")
            create_todo(db, "Todo A")
            create_todo(db, "Todo B")

            todos = list_todos(db)
            @test length(todos) == 3
        end

        @testset "update todo single field" begin
            db = connect_database(":memory:")
            init_schema!(db)

            todo_id = create_todo(db, "Original Title")
            updated = update_todo!(db, todo_id, title="New Title")

            @test updated == true
            todo = get_todo(db, todo_id)
            @test todo.title == "New Title"
        end

        @testset "update todo multiple fields" begin
            db = connect_database(":memory:")
            init_schema!(db)

            todo_id = create_todo(db, "Todo")
            updated = update_todo!(db, todo_id,
                                  title="Updated",
                                  description="New description",
                                  status="in_progress",
                                  priority=1)

            @test updated == true
            todo = get_todo(db, todo_id)
            @test todo.title == "Updated"
            @test todo.description == "New description"
            @test todo.status == "in_progress"
            @test todo.priority == 1
        end

        @testset "update todo validates status" begin
            db = connect_database(":memory:")
            init_schema!(db)

            todo_id = create_todo(db, "Test")
            @test_throws ErrorException update_todo!(db, todo_id, status="invalid")
        end

        @testset "update todo validates priority" begin
            db = connect_database(":memory:")
            init_schema!(db)

            todo_id = create_todo(db, "Test")
            @test_throws ErrorException update_todo!(db, todo_id, priority=5)
        end

        @testset "update todo validates dates" begin
            db = connect_database(":memory:")
            init_schema!(db)

            todo_id = create_todo(db, "Test")
            @test_throws ErrorException update_todo!(db, todo_id, due_date="invalid-date")
        end

        @testset "update nonexistent todo" begin
            db = connect_database(":memory:")
            init_schema!(db)

            updated = update_todo!(db, 9999, title="Nope")
            @test updated == false
        end

        @testset "complete todo" begin
            db = connect_database(":memory:")
            init_schema!(db)

            todo_id = create_todo(db, "To Complete")
            completed = complete_todo!(db, todo_id)

            @test completed == true
            todo = get_todo(db, todo_id)
            @test todo.status == "completed"
            @test todo.completed_at !== nothing
            @test todo.updated_at !== nothing
        end

        @testset "complete nonexistent todo" begin
            db = connect_database(":memory:")
            init_schema!(db)

            completed = complete_todo!(db, 9999)
            @test completed == false
        end

        @testset "delete todo" begin
            db = connect_database(":memory:")
            init_schema!(db)

            todo_id = create_todo(db, "To Delete")
            deleted = delete_todo!(db, todo_id)

            @test deleted == true
            todo = get_todo(db, todo_id)
            @test todo === nothing
        end

        @testset "delete nonexistent todo" begin
            db = connect_database(":memory:")
            init_schema!(db)

            deleted = delete_todo!(db, 9999)
            @test deleted == false
        end
    end

    @testset "Integration Tests" begin
        @testset "delete project sets todos project_id to null" begin
            db = connect_database(":memory:")
            init_schema!(db)

            proj_id = create_project(db, "Test Project")
            DBInterface.execute(db, "INSERT INTO todos (title, project_id) VALUES (?, ?)",
                              ["Test Todo", proj_id])

            delete_project!(db, proj_id)

            result = DBInterface.execute(db, "SELECT project_id FROM todos WHERE title = 'Test Todo'")
            row = first(result)
            @test ismissing(row[:project_id]) || row[:project_id] === nothing
        end

        @testset "delete category sets todos category_id to null" begin
            db = connect_database(":memory:")
            init_schema!(db)

            cat_id = create_category(db, "Test Category")
            DBInterface.execute(db, "INSERT INTO todos (title, category_id) VALUES (?, ?)",
                              ["Test Todo", cat_id])

            delete_category!(db, cat_id)

            result = DBInterface.execute(db, "SELECT category_id FROM todos WHERE title = 'Test Todo'")
            row = first(result)
            @test ismissing(row[:category_id]) || row[:category_id] === nothing
        end
    end

    @testset "Filtering" begin
        @testset "filter_todos_by_status" begin
            @testset "filter pending todos" begin
                db = connect_database(":memory:")
                init_schema!(db)

                create_todo(db, "Pending 1", status="pending")
                create_todo(db, "Pending 2", status="pending")
                create_todo(db, "In Progress", status="in_progress")
                create_todo(db, "Completed", status="completed")

                results = filter_todos_by_status(db, "pending")
                @test length(results) == 2
                @test all(t -> t.status == "pending", results)
            end

            @testset "filter in_progress todos" begin
                db = connect_database(":memory:")
                init_schema!(db)

                create_todo(db, "Pending", status="pending")
                create_todo(db, "In Progress 1", status="in_progress")
                create_todo(db, "In Progress 2", status="in_progress")

                results = filter_todos_by_status(db, "in_progress")
                @test length(results) == 2
                @test all(t -> t.status == "in_progress", results)
            end

            @testset "filter completed todos" begin
                db = connect_database(":memory:")
                init_schema!(db)

                create_todo(db, "Pending", status="pending")
                create_todo(db, "Completed", status="completed")

                results = filter_todos_by_status(db, "completed")
                @test length(results) == 1
                @test results[1].status == "completed"
            end

            @testset "filter blocked todos" begin
                db = connect_database(":memory:")
                init_schema!(db)

                create_todo(db, "Pending", status="pending")
                create_todo(db, "Blocked", status="blocked")

                results = filter_todos_by_status(db, "blocked")
                @test length(results) == 1
                @test results[1].status == "blocked"
            end

            @testset "filter with no matches returns empty array" begin
                db = connect_database(":memory:")
                init_schema!(db)

                create_todo(db, "Pending", status="pending")

                results = filter_todos_by_status(db, "completed")
                @test results == Todo[]
                @test length(results) == 0
            end

            @testset "filter on empty database returns empty array" begin
                db = connect_database(":memory:")
                init_schema!(db)

                results = filter_todos_by_status(db, "pending")
                @test results == Todo[]
            end
        end

        @testset "filter_todos_by_project" begin
            @testset "filter by project_id" begin
                db = connect_database(":memory:")
                init_schema!(db)

                proj1_id = create_project(db, "Project 1")
                proj2_id = create_project(db, "Project 2")

                create_todo(db, "Todo P1-1", project_id=proj1_id)
                create_todo(db, "Todo P1-2", project_id=proj1_id)
                create_todo(db, "Todo P2", project_id=proj2_id)
                create_todo(db, "Todo No Project")

                results = filter_todos_by_project(db, proj1_id)
                @test length(results) == 2
                @test all(t -> t.project_id == proj1_id, results)
            end

            @testset "filter with no matches returns empty array" begin
                db = connect_database(":memory:")
                init_schema!(db)

                proj_id = create_project(db, "Empty Project")
                create_todo(db, "Unassigned Todo")

                results = filter_todos_by_project(db, proj_id)
                @test results == Todo[]
            end
        end

        @testset "filter_todos_by_category" begin
            @testset "filter by category_id" begin
                db = connect_database(":memory:")
                init_schema!(db)

                cat1_id = create_category(db, "Category 1")
                cat2_id = create_category(db, "Category 2")

                create_todo(db, "Todo C1-1", category_id=cat1_id)
                create_todo(db, "Todo C1-2", category_id=cat1_id)
                create_todo(db, "Todo C2", category_id=cat2_id)
                create_todo(db, "Todo No Category")

                results = filter_todos_by_category(db, cat1_id)
                @test length(results) == 2
                @test all(t -> t.category_id == cat1_id, results)
            end

            @testset "filter with no matches returns empty array" begin
                db = connect_database(":memory:")
                init_schema!(db)

                cat_id = create_category(db, "Empty Category")
                create_todo(db, "Uncategorized Todo")

                results = filter_todos_by_category(db, cat_id)
                @test results == Todo[]
            end
        end

        @testset "filter_todos_by_date_range" begin
            @testset "filter by start_date only" begin
                db = connect_database(":memory:")
                init_schema!(db)

                create_todo(db, "Early", start_date="2026-01-01")
                create_todo(db, "Middle", start_date="2026-01-15")
                create_todo(db, "Late", start_date="2026-02-01")
                create_todo(db, "No Date")

                # Get todos starting on or after 2026-01-10
                results = filter_todos_by_date_range(db, start_date="2026-01-10")
                @test length(results) == 2
                @test all(t -> t.start_date !== nothing && t.start_date >= "2026-01-10", results)
            end

            @testset "filter by due_date only" begin
                db = connect_database(":memory:")
                init_schema!(db)

                create_todo(db, "Early", due_date="2026-01-10")
                create_todo(db, "Middle", due_date="2026-01-20")
                create_todo(db, "Late", due_date="2026-02-01")
                create_todo(db, "No Date")

                # Get todos due on or before 2026-01-20
                results = filter_todos_by_date_range(db, due_date="2026-01-20")
                @test length(results) == 2
                @test all(t -> t.due_date !== nothing && t.due_date <= "2026-01-20", results)
            end

            @testset "filter by both start_date and due_date" begin
                db = connect_database(":memory:")
                init_schema!(db)

                create_todo(db, "Before Range", start_date="2025-12-01", due_date="2025-12-31")
                create_todo(db, "In Range", start_date="2026-01-15", due_date="2026-01-30")
                create_todo(db, "After Range", start_date="2026-03-01", due_date="2026-03-15")
                create_todo(db, "No Dates")

                # Get todos that start >= 2026-01-01 AND are due <= 2026-02-28
                results = filter_todos_by_date_range(db, start_date="2026-01-01", due_date="2026-02-28")
                @test length(results) == 1
                @test results[1].title == "In Range"
            end

            @testset "filter with no matches returns empty array" begin
                db = connect_database(":memory:")
                init_schema!(db)

                create_todo(db, "Early", due_date="2025-01-01")

                results = filter_todos_by_date_range(db, start_date="2026-01-01")
                @test results == Todo[]
            end
        end

        @testset "filter_todos (combined)" begin
            @testset "filter with single parameter (status)" begin
                db = connect_database(":memory:")
                init_schema!(db)

                create_todo(db, "Pending", status="pending")
                create_todo(db, "Completed", status="completed")

                results = filter_todos(db, status="pending")
                @test length(results) == 1
                @test results[1].status == "pending"
            end

            @testset "filter with two parameters (status + project)" begin
                db = connect_database(":memory:")
                init_schema!(db)

                proj_id = create_project(db, "Test Project")
                create_todo(db, "Pending P1", status="pending", project_id=proj_id)
                create_todo(db, "Completed P1", status="completed", project_id=proj_id)
                create_todo(db, "Pending No Project", status="pending")

                results = filter_todos(db, status="pending", project_id=proj_id)
                @test length(results) == 1
                @test results[1].title == "Pending P1"
            end

            @testset "filter with three parameters (status + project + category)" begin
                db = connect_database(":memory:")
                init_schema!(db)

                proj_id = create_project(db, "Test Project")
                cat_id = create_category(db, "Test Category")
                create_todo(db, "Match All", status="pending", project_id=proj_id, category_id=cat_id)
                create_todo(db, "Wrong Status", status="completed", project_id=proj_id, category_id=cat_id)
                create_todo(db, "Wrong Project", status="pending", category_id=cat_id)
                create_todo(db, "Wrong Category", status="pending", project_id=proj_id)

                results = filter_todos(db, status="pending", project_id=proj_id, category_id=cat_id)
                @test length(results) == 1
                @test results[1].title == "Match All"
            end

            @testset "filter with all parameters" begin
                db = connect_database(":memory:")
                init_schema!(db)

                proj_id = create_project(db, "Test Project")
                cat_id = create_category(db, "Test Category")

                create_todo(db, "Perfect Match",
                           status="in_progress",
                           project_id=proj_id,
                           category_id=cat_id,
                           start_date="2026-01-15",
                           due_date="2026-01-30")
                create_todo(db, "Wrong Date",
                           status="in_progress",
                           project_id=proj_id,
                           category_id=cat_id,
                           start_date="2025-01-01",
                           due_date="2025-01-15")
                create_todo(db, "No Dates",
                           status="in_progress",
                           project_id=proj_id,
                           category_id=cat_id)

                results = filter_todos(db,
                                       status="in_progress",
                                       project_id=proj_id,
                                       category_id=cat_id,
                                       start_date="2026-01-01",
                                       due_date="2026-02-28")
                @test length(results) == 1
                @test results[1].title == "Perfect Match"
            end

            @testset "filter with no parameters returns all todos" begin
                db = connect_database(":memory:")
                init_schema!(db)

                create_todo(db, "Todo 1")
                create_todo(db, "Todo 2")
                create_todo(db, "Todo 3")

                results = filter_todos(db)
                @test length(results) == 3
            end

            @testset "filter with no matches returns empty array" begin
                db = connect_database(":memory:")
                init_schema!(db)

                create_todo(db, "Pending", status="pending")

                results = filter_todos(db, status="completed")
                @test results == Todo[]
            end

            @testset "filter on empty database returns empty array" begin
                db = connect_database(":memory:")
                init_schema!(db)

                results = filter_todos(db, status="pending")
                @test results == Todo[]
            end
        end
    end
end
