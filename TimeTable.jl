using SparseArrays
using LightGraphs

include("Person.jl")
include("Bus.jl")
include("TSPTW.jl")
include("mTSPTW.jl")
include("Parsers.jl")

struct TimeTable
    people::Vector{Person}
    map

    TimeTable(; people, map) = new(people, map)
end


function resolution(timetable)
    resolution_tsptw(length(timetable.people), timetable.people, timetable.map, 10000)
end

function resolution_mbus(timetable, nb_bus, verbose = false)
    x, T = resolution_mtsptw(length(timetable.people), nb_bus, timetable.people, timetable.map, verbose)
    return creation_bus(timetable.people, length(timetable.people), x, T)
end

# people = build_people("Data/people_huge.csv")
# map = parser("Data/huge.csv")
# timetable = TimeTable(people = people, map = map)
# for i in 1:1
#     resolution(timetable)
# end

people = build_people("Data/people_small.csv")
map = parser("Data/small.csv")
# map = parser_real_file("Data/mTSP_matrix.csv")
# people = build_people_real_file("Data/customer_requests.csv", "Data/driver_shifts.csv", "Data/mTSP_matrix.csv", "Data/gammas.csv")
print(people)
# timetable = TimeTable(people = people, map = map)
x, T = resolution_mtsptw(length(people), 2, people, map)
buses = creation_bus(people, length(people), x, T)
println(buses)
println(get_total_time(buses[1]))
println(get_total_time(buses[2]))

# resolution(timetable)
# resolution_mbus(timetable, 1, true)
