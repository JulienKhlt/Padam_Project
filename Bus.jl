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

"""
function add_point_bus!(bus, point, people)
    Fonction that add a point to the path of the bus but without any logic
    for person in people
        if person.start_point == point
            push!(bus.people, person)
        end
    end
    remove!(bus.stops, 1)
    push!(bus.stops, point)
    push!(bus.stops, 1)
end"""

function add_point_bus!(bus, point, person)
    """Fonction that add a point to the path of the bus but without any logic"""
    push!(bus.people, person)
    gare = bus.stops[end]
    pop!(bus.stops)
    push!(bus.stops, point)
    push!(bus.stops, gare)
end

function rearrangement_2opt(bus, map)
    """Fonction that reorganise the path of the bus, it's way faster that any other method but only give a local minima"""
    improvement = true
    nb_iter = 0
    while improvement && nb_iter<100
        improvement = false
        nb_iter += 1
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
    return nb_iter < 100
end

function admissible_bus(bus, map, length_max)
    if length(bus.people) > length_max || length(bus.stops) > length_max
        return false
    end
     # Il reste à vérifier la time window pour les people du bus :
     ordered_people = [] # VOIR SI ON PEUT PAS OPTIMISER CA
     for k in bus.stops
        for person in bus.people
           if person.start_point == k
              push!(ordered_people, person)
           end
        end
     end
     # remarque : est ce que si plusieurs personnes sont au même arrêt elles ont le même star_time ?
     # si non, il faut encore trier ordered_people
     time_table = [ordered_people[end].end_time]
     for k in 1:length(ordered_people)-1
         j = length(ordered_people) - k+1
         push!(time_table,(time_table[k] - map[ordered_people[j-1].start_point, ordered_people[j].start_point]))
     end
     check_bus = true
     for k in 1:length(bus.people)
        j = length(bus.people)-k+1
        if ordered_people[k].start_time > time_table[j] || ordered_people[k].end_time < time_table[j]
            check_bus = false
        end
     end
     return check_bus
end
