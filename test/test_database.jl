@testset "Database Tests" begin

    @testset "Connection" begin
        @testset "connect to memory database" begin
            db = connect_database(":memory:")
            @test db isa SQLite.DB
        end

        @testset "foreign keys enabled" begin
            db = connect_database(":memory:")
            result = DBInterface.execute(db, "PRAGMA foreign_keys")
            row = first(result)
            @test row[:foreign_keys] == 1
        end

        @testset "database path contains .todo-list" begin
            path = get_database_path()
            @test occursin(".todo-list", path)
            @test occursin("todos.db", path)
        end
    end

    @testset "Schema Creation" begin
        @testset "init_schema creates tables" begin
            db = connect_database(":memory:")
            init_schema!(db)

            # Get table names
            tables = String[]
            for row in DBInterface.execute(db, "SELECT name FROM sqlite_master WHERE type='table' AND name != 'sqlite_sequence'")
                push!(tables, row[:name])
            end

            @test "projects" in tables
            @test "categories" in tables
            @test "todos" in tables
        end

        @testset "projects table structure" begin
            db = connect_database(":memory:")
            init_schema!(db)

            columns = String[]
            for row in DBInterface.execute(db, "PRAGMA table_info(projects)")
                push!(columns, row[:name])
            end

            @test "id" in columns
            @test "name" in columns
            @test "description" in columns
            @test "color" in columns
            @test "created_at" in columns
            @test "updated_at" in columns
        end

        @testset "categories table structure" begin
            db = connect_database(":memory:")
            init_schema!(db)

            columns = String[]
            for row in DBInterface.execute(db, "PRAGMA table_info(categories)")
                push!(columns, row[:name])
            end

            @test "id" in columns
            @test "name" in columns
            @test "color" in columns
            @test "created_at" in columns
        end

        @testset "todos table structure" begin
            db = connect_database(":memory:")
            init_schema!(db)

            columns = String[]
            for row in DBInterface.execute(db, "PRAGMA table_info(todos)")
                push!(columns, row[:name])
            end

            @test "id" in columns
            @test "title" in columns
            @test "description" in columns
            @test "status" in columns
            @test "priority" in columns
            @test "project_id" in columns
            @test "category_id" in columns
            @test "start_date" in columns
            @test "due_date" in columns
            @test "completed_at" in columns
            @test "created_at" in columns
            @test "updated_at" in columns
        end

        @testset "indexes created" begin
            db = connect_database(":memory:")
            init_schema!(db)

            indexes = String[]
            for row in DBInterface.execute(db, "SELECT name FROM sqlite_master WHERE type='index' AND name LIKE 'idx_%'")
                push!(indexes, row[:name])
            end

            @test "idx_todos_status" in indexes
            @test "idx_todos_project" in indexes
            @test "idx_todos_category" in indexes
            @test "idx_todos_due_date" in indexes
        end
    end

    @testset "Constraints" begin
        @testset "unique constraint on project name" begin
            db = connect_database(":memory:")
            init_schema!(db)

            DBInterface.execute(db, "INSERT INTO projects (name) VALUES ('Test')")
            @test_throws Exception DBInterface.execute(db, "INSERT INTO projects (name) VALUES ('Test')")
        end

        @testset "unique constraint on category name" begin
            db = connect_database(":memory:")
            init_schema!(db)

            DBInterface.execute(db, "INSERT INTO categories (name) VALUES ('Test')")
            @test_throws Exception DBInterface.execute(db, "INSERT INTO categories (name) VALUES ('Test')")
        end

        @testset "check constraint on status" begin
            db = connect_database(":memory:")
            init_schema!(db)

            @test_throws Exception DBInterface.execute(db, "INSERT INTO todos (title, status) VALUES ('Test', 'invalid')")
        end

        @testset "check constraint on priority" begin
            db = connect_database(":memory:")
            init_schema!(db)

            @test_throws Exception DBInterface.execute(db, "INSERT INTO todos (title, priority) VALUES ('Test', 99)")
        end

        @testset "foreign key constraint on project_id" begin
            db = connect_database(":memory:")
            init_schema!(db)

            @test_throws Exception DBInterface.execute(db, "INSERT INTO todos (title, project_id) VALUES ('Test', 9999)")
        end

        @testset "foreign key constraint on category_id" begin
            db = connect_database(":memory:")
            init_schema!(db)

            @test_throws Exception DBInterface.execute(db, "INSERT INTO todos (title, category_id) VALUES ('Test', 9999)")
        end
    end
end
