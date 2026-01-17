using Test
using TodoList
using SQLite
using DBInterface

@testset "TodoList Tests" begin
    include("test_database.jl")
    include("test_queries.jl")
end
