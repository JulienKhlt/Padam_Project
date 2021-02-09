struct Person 
    start_point::Int
    start_time::Int
    end_time::Int

    Person(; start_point, start_time, end_time) = new(start_point, start_time, end_time)
end