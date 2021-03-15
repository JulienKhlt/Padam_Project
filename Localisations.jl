struct Bus_stop
    id::Int
    latitude::Float64
    longitude::Float64

    Bus_stop(; id, latitude, longitude) = new(id, latitude, longitude)
end

function Base.show(io::IO, bus_stop::Bus_stop)
    str = "Bus_stop : $(bus_stop.id)\n"
    str *= "   latitude =  $(bus_stop.latitude)\n"
    str *= "   longitude =  $(bus_stop.longitude)\n"
    print(io, str)
end

function create_localisations(nb_point)::Vector{Bus_stop}
    localisations = []
    for i in 1:nb_point
        x = rand(1:100)
        y = rand(1:100)
        bus_stop = Bus_stop(id=i, latitude=x, longitude=y)
        push!(localisations, bus_stop)
    end
    return localisations
end


function test_create_localisations(nb_point)::Vector{Bus_stop}
    loc = create_localisations(nb_point)
    for i in 1:nb_point
        bus_stop = loc[i]
        print(bus_stop)
    end
    return loc
end
