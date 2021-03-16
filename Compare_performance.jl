include("mTSPTW.jl")
include("Resolution.jl")
include("Cluster.jl")
include("Bus.jl")
include("Person.jl")
include("Parsers.jl")

using Statistics

function print_performance(bus_time)
    println("Temps pour chaque bus :", bus_time)
    println("Temps total :", sum(bus_time))
    println("Temps moyen :", mean(bus_time))
end

function compare_performance(file_people, file_map, length_max, exact = false)
    map = parser(file_map)
    people, gare, depots = build_people(file_people)
    sol = creation_cluster(people, gare, depots, map, length_max)
    buses_heuristics = compute_solution(sol)
    
    people = new_people(people, gare, depots)
    x, T = resolution_mtsptw(length(people), length(depots), people, map, length(people)-length(depots):length(people)-1)
    buses_exact = creation_bus_exa(people, length(people), x, T) 

    if exact
        print_performance(compute_total_time.(buses_heuristics, map))
        print_performance(compute_total_time.(buses_exact, map))
    else
        print_performance(get_total_time.(buses_heuristics))
        print_performance(get_total_time.(buses_exact))
    end
end

compare_performance("Data/people.csv", "Data/medium.csv", 20)