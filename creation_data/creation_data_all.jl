include("creation_data_circles.jl")
include("creation_data_villages.jl")
include("creation_data_uniform.jl")
include("creation_data_lines.jl")


function dist(points, i, j)
    return sqrt((points[i][2]-points[j][2])^2 + (points[i][1]-points[j][1])^2)
end

function creation_data(file_name::String, file_loc_name::String, file_people_name::String, file_driver_name::String, nb_villages, nb_line, nb_cercle, rayons, nb_point, nb_people, nb_bus, len, part) #nb_point = tableau de nombre de points pour chaque cercle
    open(file_name, "w") do file
        open(file_loc_name, "w") do file_loc
            open(file_people_name, "w") do file_people
                open(file_driver_name, "w") do file_driver
                    push_all!(file, file_people, file_driver, file_loc, nb_villages, nb_line, nb_cercle, rayons, nb_point, nb_people, nb_bus, len, part)
                end
            end
        end
    end
end

function push_all!(file, file_people, file_driver, file_loc, nb_villages, nb_line, nb_cercle, rayons, nb_point, nb_people, nb_bus, len, part)
    write(file_people, "Pickup node index;Dropoff node index", "\n")
    write(file_driver, "ID;Start node index;End node index;Start hour;Arrival hour", "\n")
    points1, drivers_index1 = creation_point_villages([ceil(nb_point*part[1]/nb_villages) for i in 1:nb_villages], nb_villages, len[1])
    points2, drivers_index2 = creation_point_lines(nb_line, [ceil(nb_point*part[2]/nb_line) for i in 1:nb_line], len[2])
    points3, drivers_index3 = creation_point_uniform(nb_point*part[3], nb_bus, len[3])
    points4, drivers_index4 = creation_point_circles(nb_cercle, rayons, [ceil(nb_point*part[4]/nb_cercle) for i in 1:nb_cercle], len[4])
    add_drivers!(drivers_index2, nb_point*part[1])
    add_drivers!(drivers_index3, nb_point*part[2]+nb_point*part[1])
    add_drivers!(drivers_index4, nb_point*part[3]+nb_point*part[2]+nb_point*part[1])
    points = vcat(points1, points2, points3, points4)
    drivers_index = vcat(drivers_index1, drivers_index2, drivers_index3, drivers_index4)
    write(file_loc,"node_index;latitude;longitude", "\n")
    for i in 1:length(points)
        write(file_loc, string(i, ";", points[i][1], ";", points[i][2], "\n"))
        for j in 1:length(points)
            write(file, string(round(dist(points, i, j), digits=3), ";"))
        end
        write(file, "\n")
    end
    depot_index = []
    for i in 1:nb_bus+nb_line+nb_villages
        depot = rand(drivers_index)
        write(file_driver, string(i,";",depot, ";", 1, ";06:00:00;08:00:00", "\n"))
        push!(depot_index, depot)
    end
    people_index = [i for i in 2:length(points) if !(i in depot_index)]
    for i in 1:nb_people
        write(file_people, string(rand(people_index), ";", 1, "\n"))
    end
end

function add_drivers!(drivers, nb)
    for i in 1:length(drivers)
        drivers[i] += nb
    end
end

creation_data("Data/Instances/Instance1/mTSP_matrix.csv", "Data/Instances/Instance1/node_coordinates.csv","Data/Instances/Instance1/customer_requests.csv", "Data/Instances/Instance1/driver_shifts.csv", 3, 1, 1, [1], 40, 30, 3, [500, 500, 500, 100], [0.4, 0.1, 0.1, 0.4])