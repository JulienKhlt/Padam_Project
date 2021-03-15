struct Bus_stop
    id::Int
    coordx::Int
    coordy::Int

    Bus_stop(; id, coordx, coordy) = new(id, coordx, coordy)
end

function Base.show(io::IO, bus_stop::Bus_stop)
    str = "Bus_stop : $(bus_stop.id)\n"
    str *= "   coordx =  $(bus_stop.coordx)\n"
    str *= "   coordy =  $(bus_stop.coordy)\n"
    print(io, str)
end

function create_localisations(nb_point)::Vector{Bus_stop}
    localisations = []
    for i in 1:nb_point
        x = rand(1:100)
        y = rand(1:100)
        bus_stop = Bus_stop(id=i, coordx=x, coordy=y)
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
