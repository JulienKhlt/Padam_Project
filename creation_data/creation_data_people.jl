function creation_data(file_name::String, nb_people, train_departure, depots)
    open(file_name, "w") do file
        write(file, string(1, " ", train_departure, "\n"))
        write(file, string(nb_people, "\n"))
        for i in 1:nb_people
            index = rand(depots+2:nb_people)
            start_time = 0 #rand(0:train_departure)
            end_time = train_departure #rand(start_time:train_departure)
            write(file, string(index, " ", start_time, " ", end_time, "\n"))
        end
        write(file, string(depots, "\n"))
        for i in 2:depots+1
            index = i
            start_time = 0 
            end_time = train_departure
            write(file, string(index, " ", start_time, " ", end_time, "\n"))
        end
    end
end

creation_data("Data/people_small.csv", 5, 1000, 1)
