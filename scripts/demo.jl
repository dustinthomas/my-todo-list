#!/usr/bin/env julia

# Demo data generation script
# Populates database with sample projects, categories, and todos

# Activate project environment
using Pkg
Pkg.activate(joinpath(@__DIR__, ".."))

using TodoList

function main()
    println("TodoList Demo Data Generator")
    println("=" ^ 50)

    db = connect_database()

    # Check if data already exists
    existing_projects = list_projects(db)
    existing_categories = list_categories(db)
    existing_todos = list_todos(db)

    if !isempty(existing_projects) || !isempty(existing_categories) || !isempty(existing_todos)
        println("\nWarning: Database already contains data!")
        println("  Projects: $(length(existing_projects))")
        println("  Categories: $(length(existing_categories))")
        println("  Todos: $(length(existing_todos))")
        print("\nAdd demo data anyway? (y/N): ")
        response = readline()
        if lowercase(strip(response)) != "y"
            println("Demo data generation cancelled.")
            return
        end
    end

    # Create sample projects
    println("\nCreating projects...")
    proj1_id = create_project(db, "Home Renovation",
                              description="Kitchen and bathroom updates",
                              color="#FF6B6B")
    proj2_id = create_project(db, "Work Tasks",
                              description="Q1 deliverables",
                              color="#4ECDC4")
    println("  Created 2 projects")

    # Create sample categories
    println("\nCreating categories...")
    cat1_id = create_category(db, "Urgent", color="#E74C3C")
    cat2_id = create_category(db, "Planning", color="#3498DB")
    println("  Created 2 categories")

    # Create sample todos
    println("\nCreating todos...")

    # Home Renovation todos
    create_todo(db, "Design new kitchen layout",
               project_id=proj1_id,
               category_id=cat2_id,
               priority=1,
               status="in_progress",
               description="Work with architect to finalize cabinet and appliance placement",
               start_date="2026-01-15",
               due_date="2026-02-15")

    create_todo(db, "Get contractor quotes",
               project_id=proj1_id,
               category_id=cat1_id,
               priority=1,
               description="Need at least 3 quotes for comparison",
               due_date="2026-01-30")

    create_todo(db, "Select bathroom tiles",
               project_id=proj1_id,
               category_id=cat2_id,
               priority=2,
               status="pending",
               description="Visit tile showroom and pick samples",
               due_date="2026-02-28")

    create_todo(db, "Order appliances",
               project_id=proj1_id,
               category_id=cat1_id,
               priority=2,
               status="blocked",
               description="Waiting for kitchen layout approval before ordering")

    create_todo(db, "Schedule plumber inspection",
               project_id=proj1_id,
               priority=3,
               status="pending",
               due_date="2026-03-01")

    # Work Tasks todos
    create_todo(db, "Finish Q1 report",
               project_id=proj2_id,
               category_id=cat1_id,
               priority=1,
               status="in_progress",
               description="Compile metrics and write executive summary",
               start_date="2026-01-20",
               due_date="2026-01-31")

    create_todo(db, "Review team performance",
               project_id=proj2_id,
               category_id=cat2_id,
               priority=2,
               status="pending",
               description="Prepare for quarterly reviews",
               due_date="2026-02-15")

    create_todo(db, "Update project documentation",
               project_id=proj2_id,
               priority=3,
               status="pending",
               description="Ensure all READMEs are current")

    # Miscellaneous todos (no project)
    create_todo(db, "Schedule dentist appointment",
               category_id=cat1_id,
               priority=2,
               status="pending",
               description="Overdue for regular checkup")

    create_todo(db, "Learn Julia TUI development",
               category_id=cat2_id,
               priority=3,
               status="in_progress",
               description="Read Term.jl documentation and build examples",
               start_date="2026-01-01")

    println("  Created 10 todos")

    println("\n" * "=" ^ 50)
    println("Demo data loaded successfully!")
    println("\nSummary:")
    println("  Projects: $(length(list_projects(db)))")
    println("  Categories: $(length(list_categories(db)))")
    println("  Todos: $(length(list_todos(db)))")

    println("\nTodo status breakdown:")
    for status in ["pending", "in_progress", "completed", "blocked"]
        count = length(filter_todos_by_status(db, status))
        println("  $status: $count")
    end
end

main()
