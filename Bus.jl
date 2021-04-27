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
    """Calcule le temps sur la matrice des temps symétrique"""
    return bus.time[length(bus.time)] - bus.time[1]
end

function compute_total_time(bus, map)
    """Calcule le temps réel sur la matrice des temps non symétrique"""
    return sum([map[bus.stops[i], bus.stops[i+1]] for i in 1:length(bus.stops)-1])
end

function remove_point_bus!(bus, point)
    """Fonction that remove a point from the path of the bus"""
    remove!(bus.stops, point)
    for person in bus.people
        if person.start_point == point
            remove!(bus.people, person)
        end
    end
end

function add_point_bus!(bus, point, people)
    """Fonction that add a point to the path of the bus but without any logic"""
    for person in people
        if person.start_point == point
            push!(bus.people, person)
        end
    end
    remove!(bus.stops, 1)
    push!(bus.stops, point)
    push!(bus.stops, 1)
end

function rearrangement_2opt(bus, map)
    """Fonction that reorganise the path of the bus, it's way faster that any other method but only give a local minima"""
    improvement = true
    while improvement
        improvement = false
        for i in 2:(length(bus.stops)-2)
            for j in i+1:length(bus.stops)-1
                if map[bus.stops[i], bus.stops[i+1]] + map[bus.stops[j], bus.stops[j+1]] > map[bus.stops[i], bus.stops[j]] + map[bus.stops[i+1], bus.stops[j+1]]
                    improvement = true
                    bus.stops[i+1], bus.stops[j] = bus.stops[j], bus.stops[i+1]
                    break
                end
            end
        end
    end
end

