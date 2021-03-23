function borne_inf(depots, gare, map)
    return sum([map[d.start_point, gare.start_point] for d in depots])
end

function borne_inf_v2(depots, gare, map, people, length_max)
    size = min(length_max, length(people))
    return (sum([map[d.start_point, gare.start_point] for d in depots]) + sum([map[p.start_point, gare.start_point] for p in people]))/size
end