function dist(points, i, j)
    return sqrt((points[i][2]-points[j][2])^2 + (points[i][1]-points[j][1])^2)
end

function creation_data(file_name::String, file_loc_name::String, file_people_name::String, file_driver_name::String, nb_villages, nb_point, nb_people, nb_bus, len) #nb_point = tableau de nombre de points pour chaque cercle
    open(file_name, "w") do file
        open(file_loc_name, "w") do file_loc
            open(file_people_name, "w") do file_people
                open(file_driver_name, "w") do file_driver
                    push_villages!(file, file_people, file_driver, file_loc, nb_villages, nb_point, nb_people, nb_bus, len)
                end
            end
        end
    end
end

function push_villages!(file, file_people, file_driver, file_loc, nb_villages, nb_point, nb_people, nb_bus, len)
    write(file_people, "Pickup node index;Dropoff node index", "\n")
    write(file_driver, "ID;Start node index;End node index;Start hour;Arrival hour", "\n")
    points, drivers_index = creation_point_villages(nb_point, nb_villages, len)
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
        write(file_driver, string(i,";",depot, ";", 1, ";06:00:00;08:00:00", "\n"))
        push!(depot_index, depot)
    end
    people_index = [i for i in 2:length(points) if !(i in depot_index)]
    for i in 1:nb_people
        write(file_people, string(rand(people_index), ";", 1, "\n"))
    end
end

function creation_point_villages(nb_point, nb_villages, len)
    drivers_index = [1]
    points = []
    center_x = 0
    center_y = 0
    push!(points, [center_x, center_y])
    for n in 1:nb_villages
        mod = 1/1000*rand(0:500)
        angle = rand(1:360)/360*2*pi
        index_start = length(points)
        for i in 1:nb_point[n]
            sigma = 0.2
            epsilon_x = sigma^2*randn(Float64)
            epsilon_y = sigma^2*randn(Float64)
            x = (mod*cos(angle)+epsilon_x) * len
            y = (mod*sin(angle)+epsilon_y) * len
            push!(points, [x, y])
        end
        push!(drivers_index, rand(index_start:length(points)))
    end
    return points, drivers_index

end

creation_data("Data/plots/mTSP_matrix.csv", "Data/plots/node_coordinates.csv","Data/plots/customer_requests.csv", "Data/plots/driver_shifts.csv", 1, [5], 5, 1, 100)
