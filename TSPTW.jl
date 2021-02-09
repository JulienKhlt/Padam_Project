using JuMP, GLPK
include("Person.jl")
include("TimeTable.jl")

function get_bound(people, n)
    # TODO : reordonner
    return collect(people[u].start_time for u in 1:n), collect(people[u].end_time for u in 1:n)
end

function resolution_tsptw(n, people, map)
    # Pour l'instant un point = un client
    model = Model(GLPK.Optimizer)

    @variable(model, T[1:n] >= 0)

    a, b = get_bound(people, n)

    @constraint(model, [i in 1:n, j in 1:n], T[i] - T[j] >= map[i, j])
    @constraint(model, [i in 1:n, j in 1:n], T[j] - T[i] >= map[i, j])
    @constraint(model, [i in 1:n], T[i] >= a[i])
    @constraint(model, [i in 1:n], T[i] <= b[i])

    @objective(model, Min, T[n])
    optimize!(model)
end

Person(start_point = 5, start_time = 1000, end_time = 1000)

people = [Person(start_point = 1, start_time = 0, end_time = 1000), 
    Person(start_point = 2, start_time = 0, end_time = 1000),
    Person(start_point = 3, start_time = 0, end_time = 1000),
    Person(start_point = 4, start_time = 0, end_time = 1000),
    Person(start_point = 5, start_time = 1000, end_time = 1000)]

map = parser("Data/small.csv")

resolution_tsptw(5, people, map)