function dist(points, i, j)
    return sqrt((points[i][2]-points[j][2])^2 + (points[i][1]-points[j][1])^2)
end

function creation_data(file_name::String, nb_point)
    open(file_name, "w") do file
        write(file, string(nb_point, "\n"))
        points = []
        for i in 1:nb_point
            x = rand(1:100)
            y = rand(1:100)
            push!(points, [x, y])
        end

        for i in 1:nb_point
            for j in 1:nb_point
                write(file, string(i, " ", j, " ", round(dist(points, i, j), digits=3), "\n"))
            end
        end
    end
end

creation_data("Data/medium2.csv", 13)