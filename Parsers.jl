using SparseArrays
using LightGraphs

include("Person.jl")
include("Localisations")

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

function parser_real_file(file_name)
    data = open(file_name) do file
        readlines(file)
    end
    n = length(data)
    map = spzeros(n, n)
    for i in 1:n
        for j in 1:n
            D = rsplit(data[i], ";")
            map[i, j] = parse(Float64, D[j])
        end
    end
    return map,n
end

function parser_real_file_symetry(file_name)
    map,n = parser_real_file(file_name)
    for i in 1:n
        for j in 1:n
            map[i,j] = (map[i,j]+map[j,i])/2
        end
    end
    return map,n
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

function convert_time_str_int(time)
    #conversion from format h:m:s to seconds
    time_str = split(time, ":")
    time_int = parse(Int,time_str[3]) + 60*parse(Int,time_str[2]) + 3600*parse(Int,time_str[1])
    return time_int
end

function acceptable_max_time(gamma_file_name, map, start_point, end_point)
    gamma_data = open(gamma_file_name) do file
        readlines(file)
    end
    time = 0
    for i in 2:length(gamma_data)-1
        gamma = split(gamma_data[i], ";")
        time += parse(Float64, gamma[3])*(parse(Float64, gamma[1])<= map[start_point, end_point] &&
         map[start_point, end_point] <= parse(Float64, gamma[2]))*map[start_point, end_point]
    end
    time += (time==0) * parse(Float64, split(gamma_data[length(gamma_data)], ";")[3])*map[start_point, end_point]
    return time
end

function build_people_real_file(client_file_name, driver_file_name, map_file_name, gamma_file_name, sym=false)
    if sym
        map = parser_real_file_symetry(map_file_name)[1]
    else
        map = parser_real_file(map_file_name)[1]
    end
    data_driver = open(driver_file_name) do file
        readlines(file)
    end
    data_client = open(client_file_name) do file
        readlines(file)
    end

    train_index = parse(Int,split(data_driver[2], ";")[3])
    train_departure = convert_time_str_int(split(data_driver[2], ";")[5])
    people = init_people(train_index, train_departure)

    nb_driver =  length(data_driver)-1

    for i in 1:nb_driver
        driver = split(data_driver[1+i], ";")
        start_point = parse(Int, driver[2])
        end_point = parse(Int, driver[3])
        start_time =  convert_time_str_int(driver[4])
        end_time =  start_time
        add_person(start_point, start_time, end_time, people)
    end

    nb_client =  length(data_client)-1

    for i in 1:nb_client
        customer = split(data_client[1+i], ";")
        start_point = parse(Int, customer[1])
        end_point = parse(Int, customer[2])
        start_time =  train_departure - acceptable_max_time(gamma_file_name, map, start_point, end_point)
        end_time =  train_departure
        add_person(start_point, start_time, end_time, people)
    end
    return people
end


function build_people_real_file_only_client(client_file_name, driver_file_name, map_file_name, gamma_file_name, sym=false)
    if sym
        map = parser_real_file_symetry(map_file_name)[1]
    else
        map = parser_real_file(map_file_name)[1]
    end
    data_client = open(client_file_name) do file
        readlines(file)
    end

    people = []

    nb_client =  length(data_client)-1

    for i in 1:nb_client
        customer = split(data_client[1+i], ";")
        start_point = parse(Int, customer[1])
        end_point = parse(Int, customer[2])
        start_time =  train_departure - acceptable_max_time(gamma_file_name, map, start_point, end_point)
        end_time =  train_departure
        add_person(start_point, start_time, end_time, people)
    end
    return people
end


function build_localisations(node_coordinates_file_name)
    data_coord = open(node_coordinates_file_nam) do file
        readlines(file)
    end

    nb_points =  length(data_coord)-1

    localisations = []
    for i in 1:nb_points
        points = split(data_coord[1+i], ";")
        latitude = parse(Float64, points[2])
        longitude = parse(Float64, points[3])
        bus_stop = Bus_stop(id=i, latitude=latitude, longitude=longitude)
        push!(localisations, bus_stop)
    end
    return localisations
end
