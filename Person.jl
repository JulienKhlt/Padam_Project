struct Person 
    start_point::Int
    start_time::Float64
    end_time::Float64

    Person(; start_point, start_time, end_time) = new(start_point, start_time, end_time)
end