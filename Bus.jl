struct Bus
    id::Int
    people::Vector{Person}
    stops::Vector{Int}
    time

    Bus(; id, people, stops, time) = new(id, people, stops, time)
end

function Base.show(io::IO, bus::Bus)
    str = "Bus : $(bus.id)\n"
    str *= "   stops : \n"
    for i in 1:length(bus.stops)
        str *= "       $(bus.stops[i])\n"
    end
    print(io, str)
end

function get_total_time(bus)
    return bus.time[length(bus.time)] - bus.time[1]
end

function compute_total_time(bus, map)
    return sum(map(bus.stops[i], bus.stop[i+1]) for i in 1:length(bus.stop)-1)
end

