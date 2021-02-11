using SparseArrays
using LightGraphs

include("Person.jl")
include("Bus.jl")
include("TSPTW.jl")

struct TimeTable
    people::Vector{Person}
    # bus::Bus
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

function add_person(start_point,start_time, end_time, people)
    push!(people, Person(start_point = start_point, start_time = start_time, end_time = end_time))
    return people
end

function init_people(train_index, train_departure)
    people = []
    push!(people,Person(start_point = train_index, start_time = train_departure, end_time = train_departure))
    return people
end

function build_people(file_name)
    data = open(file_name) do file
        readlines(file)
    end
    train_index, train_departure = split(data[1], " ")
    train_index =  parse(Int,train_index)
    train_departure = parse(Int, train_departure)
    nb_client =  parse(Int, data[2])
    people = init_people(train_index, train_departure)

    for i in 1:nb_client
        start_point, start_time, end_time = split(data[2+i], " ")
        start_point =  parse(Int, start_point)
        start_time =  parse(Int, start_time)
        end_time =  parse(Int, end_time)
        add_person(start_point, start_time, end_time, people)
    end
    return people
end

function resolution(timetable)
    resolution_tsptw(length(timetable.people), timetable.people, timetable.map, 10000)
end

people = build_people("Data/people_huge.csv")
map = parser("Data/huge.csv")
timetable = TimeTable(people = people, map = map)
for i in 1:1
    resolution(timetable)
end