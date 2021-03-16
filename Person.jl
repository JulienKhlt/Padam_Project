struct Person
    start_point::Int
    start_time::Float64
    end_time::Float64

    Person(; start_point, start_time, end_time) = new(start_point, start_time, end_time)
end

function add_person(start_point, start_time, end_time, people)
    push!(people, Person(start_point = start_point, start_time = start_time, end_time = end_time))
    return people
end

function init_people(train_index, train_departure)
    people = []
    push!(people, Person(start_point = train_index, start_time = train_departure, end_time = train_departure))
    return people
end

function build_people(file_name)
    data = open(file_name) do file
        readlines(file)
    end
    train_index, train_departure = split(data[1], " ")
    train_index =  parse(Int,train_index)
    train_departure = parse(Int, train_departure)
    gare = Person(start_point = train_index, start_time = train_departure, end_time = train_departure)
    nb_client =  parse(Int, data[2])
    people = []

    for i in 1:nb_client
        start_point, start_time, end_time = split(data[2+i], " ")
        start_point =  parse(Int, start_point)
        start_time =  parse(Int, start_time)
        end_time =  parse(Int, end_time)
        add_person(start_point, start_time, end_time, people)
    end

    nb_depot =  parse(Int, data[2 + nb_client])
    depots = []

    for i in 1:nb_depots
        start_point, start_time, end_time = split(data[2+ nb_people + i], " ")
        start_point =  parse(Int, start_point)
        start_time =  parse(Int, start_time)
        end_time =  parse(Int, end_time)
        add_person(start_point, start_time, end_time, depots)
    end

    return people, gare, depots
end

function find_people(cluster, all_people)
    return [i for i in all_people if i.start_point in cluster.points]
end

function new_people(people, gare, depot)
    new_people = people[:]
    push!(new_people, gare)
    append!(new_people, depot)
    return new_people
end
