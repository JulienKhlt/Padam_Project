function dist(points, i, j)
    return sqrt((points[i][2]-points[j][2])^2 + (points[i][1]-points[j][1])^2)
end

function creation_data(file_name::String, file_loc_name::String, file_people_name::String, file_driver_name::String, nb_point, nb_bus, nb_people, len)
    open(file_name, "w") do file
        open(file_loc_name, "w") do file_loc
            open(file_people_name, "w") do file_people
                open(file_driver_name, "w") do file_driver
                    push_uniform!(file, file_people, file_driver, file_loc, nb_point, nb_bus, nb_people, len)
                end
            end
        end
    end
end

function push_uniform!(file, file_people, file_driver, file_loc, nb_point, nb_bus, nb_people, len)
    write(file_people, "Pickup node index;Dropoff node index", "\n")
    write(file_driver, "ID;Start node index;End node index;Start hour;Arrival hour", "\n")
    points, drivers_index = creation_point_uniform(nb_point, nb_bus, len)
    write(file_loc,"node_index;latitude;longitude", "\n")
    for i in 1:length(points)
        write(file_loc, string(i, ";", points[i][1], ";", points[i][2], "\n"))
        for j in 1:length(points)
            write(file, string(round(dist(points, i, j), digits=3), ";"))
        end
        write(file, "\n")
    end
    depot_index = []
    for i in 1:nb_bus
        depot = rand(drivers_index)
        write(file_driver, string(i, ";", depot, ";", 1, ";06:00:00;08:00:00", "\n"))
        push!(depot_index, depot)
    end
    people_index = [i for i in 2:length(points) if !(i in depot_index)]
    for i in 1:nb_people
        write(file_people, string(rand(people_index), ";", 1, "\n"))
    end
end

function creation_point_uniform(nb_point, nb_bus, len)
    drivers_index = [1]
    points = []
    center_x = 0
    center_y = 0
    push!(points, [center_x, center_y])
    for i in 1:nb_point
        x = len * rand(-500:500)/1000
        y = len * rand(-500:500)/1000
        push!(points, [x, y])
    end
    for i in 1:nb_bus
        push!(drivers_index, rand(1:length(points)))
    end
    return points, drivers_index
end

creation_data("Data/uniform/mTSP_matrix.csv", "Data/uniform/node_coordinates.csv","Data/uniform/customer_requests.csv", "Data/uniform/driver_shifts.csv", 10, 2, 10, 1)
