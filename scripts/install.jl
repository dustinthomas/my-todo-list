#!/usr/bin/env julia

# Database installation script
# Creates ~/.todo-list/todos.db and initializes schema

# Activate project environment
using Pkg
Pkg.activate(joinpath(@__DIR__, ".."))

using TodoList

function main()
    println("TodoList Database Installation")
    println("=" ^ 50)

    db_path = get_database_path()
    println("\nDatabase path: $db_path")

    if isfile(db_path)
        print("Database already exists. Overwrite? (y/N): ")
        response = readline()
        if lowercase(strip(response)) != "y"
            println("Installation cancelled.")
            return
        end
        rm(db_path)
        println("Existing database removed.")
    end

    println("\nCreating database and schema...")
    db = connect_database(db_path)
    init_schema!(db)

    println("Database created successfully!")
    println("Schema initialized!")
    println("\nYou can now use the TodoList application.")
    println("\nNext steps:")
    println("  - Load demo data: julia --project=. scripts/demo.jl")
    println("  - Run tests: julia --project=. test/runtests.jl")
end

main()
