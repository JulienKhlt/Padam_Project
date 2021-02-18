struct Bus
    id::Int
    people::Vector{Person}
    stops::Vector{Int}

    Bus(; id, people, stops) = new(id, people, stops)
end

function Base.show(io::IO, bus::Bus)
    str = "Bus : $(bus.id)\n"
    str *= "   stops : \n"
    for i in 1:length(bus.stops)
        str *= "       $(bus.stops[i])\n"
    end
    print(io, str)
end
