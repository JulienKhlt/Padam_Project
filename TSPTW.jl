using JuMP, GLPK
include("Person.jl")
include("TimeTable.jl")

function get_bound(people, n)
    # TODO : reordonner
    return collect(people[u].start_time for u in 1:n), collect(people[u].end_time for u in 1:n)
end

function affichage(T, n)
    for i in 1:n
        println(string(i, " ", value(T[i])))
    end    
end

function resolution_tsptw(n, people, map, M)
    # Pour l'instant un point = un client
    model = Model(GLPK.Optimizer)

    @variable(model, T[1:n] >= 0)
    @variable(model, y[1:n, 1:n], Bin)
    

    a, b = get_bound(people, n)
    # le client part dans un intervalle [a, b]

    @constraint(model, [i in 1:n, j in 1:n], T[i] - T[j] + M*y[i, j] >= map[i, j])
    @constraint(model, [i in 1:n, j in 1:n], T[j] - T[i] - M*y[i, j] >= map[i, j] - M)
    @constraint(model, [i in 1:n], T[i] >= a[i])
    @constraint(model, [i in 1:n], T[i] <= b[i])

    @objective(model, Min, T[n])
    optimize!(model)

    affichage(T, n)
end

Person(start_point = 5, start_time = 1000, end_time = 1000)

people = [Person(start_point = 1, start_time = 0, end_time = 1000), 
    Person(start_point = 2, start_time = 0, end_time = 1000),
    Person(start_point = 3, start_time = 0, end_time = 1000),
    Person(start_point = 4, start_time = 0, end_time = 1000),
    Person(start_point = 5, start_time = 1000, end_time = 1000)]

map = parser("Data/small.csv")

resolution_tsptw(5, people, map, 10000)
