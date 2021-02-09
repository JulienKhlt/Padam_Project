struct Bus
    people::Vector{Person}
    stops::Vector{Int}

    Bus(; people, stops) = new(people, stops)
end