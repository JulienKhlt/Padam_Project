function creation_data(file_name::String, nb_people, train_departure)
    open(file_name, "w") do file
        write(file, string(1, " ", train_departure, "\npeople = build_people("C:/Users/gache/Documents/ENPC/2A/semestre_2/Projet_IMI/git/Data/people.csv")
"))
        write(file, string(nb_people, "\n"))
        for i in 1:nb_people
            index = rand(2:nb_people)
            start_time = rand(0:train_departure)
            end_time = rand(start_time:train_departure)
            write(file, string(index, " ", start_time, " ", end_time, "\n"))
        end
    end
end

creation_data("C:/Users/gache/Documents/ENPC/2A/semestre_2/Projet_IMI/git/Data/people.csv", 10, 1000)
