using JuMP, Gurobi
include("Person.jl")
include("Bus.jl")
include("TSPTW.jl")

function bit(nb)
    b = []

    i = 1
    while nb != 0
        push!(b, nb%2)
        nb = trunc(nb/2)
        i += 1
    end
    return b
end

function parties(nb_people)
    Parties = []
    for i in 1:2^nb_people-1
        list = bit(i)
        part = []
        for j in 1:length(list)
            if list[j] == 1
                push!(part, j)
            end
        end
        push!(Parties, part)
    end
    return Parties
end

function printing(y, nb_people)
    for i in 1:nb_people+1
        println("")
        println(string("   ", i))
        print("      ")
        for j in 1:nb_people
            print(string(j, " ", value(y[i, j]), " "))
        end
    end
end

function resolution_mtsptw(nb_people, nb_bus, people, map, id_dep, verbose = false)
    # Pour l'instant un point = un client
    model = Model(Gurobi.Optimizer)

    @variable(model, T[1:nb_people + 1] >= 0)
    @variable(model, x[1:nb_people + 1, 1:nb_people], Bin)

    a, b = get_bound(people, nb_people)
    new_map = people_map(people, nb_people, map)

    @constraint(model, [i in 1:nb_people], T[i] - T[nb_people+1]*x[nb_people+1, i] >= 0)

    @constraint(model, [i in 1:nb_people, j in 1:nb_people], T[i] - T[j] + (b[i] - a[j] + new_map[i, j])*x[i, j] <= b[i] - a[j])
    
    @constraint(model, [i in 1:nb_people], T[i] >= a[i])
    @constraint(model, [i in 1:nb_people], T[i] <= b[i])
    
    @constraint(model, [i in 2:nb_people], sum(x[i, j] for j in 1:nb_people) == 1)
    @constraint(model, [j in 2:nb_people], sum(x[i, j] for i in 1:(nb_people+1)) == 1)
    
    @constraint(model, sum(x[i, 1] for i in 1:nb_people+1) == nb_bus)
    @constraint(model, [i in id_dep], x[nb_people+1, i] == 1)
    @constraint(model, sum(x[nb_people+1, i] for i in 1:nb_people) == nb_bus)

    Parties = parties(nb_people)
    @constraint(model, [party in Parties], sum(x[i, j] for i in party, j in party) <= length(party)-1)



    @objective(model, Max, sum(T[i] for i in 1:nb_people))
    optimize!(model)

    if verbose
        affichage(T, nb_people + 1)
        printing(x, nb_people)
    end

    return x, T   
end


function creation_bus(people, nb_people, x, T)
    Buses =[]
    id = 1
    for i in 1:nb_people
        stops = []
        bus_people = []
        time = []
        if value(x[nb_people + 1, i]) == 1
            pos = i
            push!(stops, people[pos].start_point)
            push!(bus_people, people[pos])
            push!(time, value(T[pos]))
            while pos != 1
                for j in 1:nb_people
                    if value(x[pos, j]) == 1
                        pos = j
                        break
                    end
                end
                push!(stops, people[pos].start_point)
                push!(bus_people, people[pos])
                push!(time, value(T[pos]))
            end
            push!(Buses, Bus(id = id, people = bus_people, stops = stops, time = time))
            id += 1
        end
    end
    return Buses
end
