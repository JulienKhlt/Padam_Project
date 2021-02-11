using JuMP, Gurobi
include("Person.jl")

function get_bound(people, nb_people)
    return collect(people[u].start_time for u in 1:nb_people), collect(people[u].end_time for u in 1:nb_people)
end

function affichage(T, nb_people)
    for i in 1:nb_people
        println(string(i, " ", value(T[i])))
    end
end

function resolution_tsptw(nb_people, people, map, M)
    # Pour l'instant un point = un client
    model = Model(Gurobi.Optimizer)

    @variable(model, T[1:nb_people] >= 0)
    @variable(model, y[1:nb_people, 1:nb_people], Bin)

    a, b = get_bound(people, nb_people)
    new_map = people_map(people, nb_people, map)

    @constraint(model, [i in 1:nb_people, j in 1:nb_people], T[i] - T[j] + M*y[i, j] >= new_map[i, j])
    @constraint(model, [i in 1:nb_people, j in 1:nb_people], T[j] - T[i] - M*y[i, j] >= new_map[i, j] - M)
    @constraint(model, [i in 1:nb_people], T[i] >= a[i])
    @constraint(model, [i in 1:nb_people], T[i] <= b[i])

    @objective(model, Min, T[nb_people])
    optimize!(model)

    affichage(T, nb_people)
end
