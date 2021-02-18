using SparseArrays
using LightGraphs

include("Person.jl")
include("Bus.jl")
include("TSPTW.jl")
include("mTSPTW.jl")

struct TimeTable
    people::Vector{Person}
    map

    TimeTable(; people, map) = new(people, map)
end

function parser(file_name)
    data = open(file_name) do file
        readlines(file)
    end
    n = parse(Int, data[1])
    map = spzeros(n, n)
    for i in 1:n
        for j in 1:n
            D = rsplit(data[1+n*(i-1)+j], " ")
            map[i, parse(Int, D[2])] = parse(Float64, D[3])
        end
    end
    return map
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

function resolution(timetable)
    resolution_tsptw(length(timetable.people), timetable.people, timetable.map, 10000)
end

function resolution_mbus(timetable, nb_bus, verbose = false)
    x = resolution_mtsptw(length(timetable.people), nb_bus, timetable.people, timetable.map, verbose)
    return creation_bus(timetable.people, length(timetable.people), x)
end

# people = build_people("Data/people_huge.csv")
# map = parser("Data/huge.csv")
# timetable = TimeTable(people = people, map = map)
# for i in 1:1
#     resolution(timetable)
# end

people = build_people("Data/people_large.csv")
map = parser("Data/large.csv")
timetable = TimeTable(people = people, map = map)
# resolution_mtsptw(length(people), 2, people, map)
resolution_mbus(timetable, 5, true)