using SparseArrays
using LightGraphs

include("Person.jl")
include("Bus.jl")

struct TimeTable
    people::Vector{Person}
    bus::Bus
    map::SparseMatrixCSC{Int,Int}

    TimeTable(; people, bus, map) = new(people, bus, map)
end

function parser(file_name)
    data = open(file_name) do file
        readlines(file)
    end
    n = parse(Int, data[1])
    map = spzeros(n, n)
    for i in 1:n
        for j in 1:n
            map[i, parse(Int,data[1+n*(i-1)+j][3])] = parse(Float64, data[1+n*(i-1)+j][5:length(data[1+n*(i-1)+j])])
        end
    end
    return map
end

function add_people(start_time, end_time, start_point, people)
    push!(people,Person(start_point = start_point, start_time = start_time, end_time = end_time))
    return people
end

function init_people(train_index, train_departure)
    people = []
    push!(people,Person(start_point = train_index, start_time = train_departure, end_time = train_departure))
    return people
end
