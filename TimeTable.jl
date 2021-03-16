using SparseArrays
using LightGraphs

include("Person.jl")
include("Bus.jl")
include("TSPTW.jl")
include("mTSPTW.jl")
include("Parsers.jl")

struct TimeTable
    people::Vector{Person}
    gare
    depots
    map
    id_dep

    TimeTable(; people, map, gare, depots, id_dep) = new(people, map, gare, depots, id_dep)
end


function resolution(timetable)
    people = new_people(timetable.people, timetable.gare, timetable.depots)
    resolution_tsptw(length(timetable.people), timetable.people, timetable.map, 10000)
end

function resolution_mbus(timetable, nb_bus, verbose = false)
    people = new_people(timetable.people, timetable.gare, timetable.depots)
    x, T = resolution_mtsptw(length(people), nb_bus, people, timetable.map, timetable.id_dep, verbose)
    return creation_bus(people, length(people), x, T)
end


people, gare, depots = build_people("Data/people_small.csv")
map = parser("Data/small.csv")
people = new_people(people, gare, depots)
# map = parser_real_file("Data/mTSP_matrix.csv")
# people = build_people_real_file("Data/customer_requests.csv", "Data/driver_shifts.csv", "Data/mTSP_matrix.csv", "Data/gammas.csv")
println(people)


x, T = resolution_mtsptw(length(people), 1, people, map, [6])
buses = creation_bus(people, length(people), x, T)
println(buses)
println(get_total_time(buses[1]))
println(compute_total_time(buses[1], map))
# println(get_total_time(buses[2]))

# resolution(timetable)
# resolution_mbus(timetable, 1, true)
