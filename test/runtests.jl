using Test
using TodoList
using SQLite
using DBInterface

@testset "TodoList Tests" begin
    include("test_database.jl")
    include("test_queries.jl")
end

@testset "TUI Tests" begin
    include("test_tui_state.jl")
    include("test_tui_input.jl")
    include("test_tui_components.jl")
    include("test_tui_screens.jl")
end
