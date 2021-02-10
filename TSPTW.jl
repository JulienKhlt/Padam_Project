using JuMP, GLPK
include("Person.jl")
include("TimeTable.jl")

function get_bound(people, nb_people)
    # TODO : reordonner
    return collect(people[u].start_time for u in 1:nb_people), collect(people[u].end_time for u in 1:nb_people)
end

function people_map(people, nb_people, map)
    new_map = spzeros(nb_people, nb_people)
    for i in 1:nb_people
        for j in 1:nb_people
            new_map[i, j] = map[people[i].start_point, people[j].start_point]
        end
    end
    return new_map
end

function affichage(T, nb_people)
    for i in 1:nb_people
        println(string(i, " ", value(T[i])))
    end
end

function resolution_tsptw(nb_people, people, map, M)
    # Pour l'instant un point = un client
    model = Model(GLPK.Optimizer)

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


map = parser("C:/Users/gache/Documents/ENPC/2A/semestre_2/Projet_IMI/git/Data/small.csv")

people = build_people("C:/Users/gache/Documents/ENPC/2A/semestre_2/Projet_IMI/git/Data/people.csv")

resolution_tsptw(4, people, map, 10000)
