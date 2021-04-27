using SparseArrays
using SimpleWeightedGraphs

function borne_inf(depots, gare, map)
    return sum([map[d.start_point, gare.start_point] for d in depots])
end

function borne_inf_v2(depots, gare, map, people, length_max)
    size = min(length_max, length(people))
    return (sum([map[d.start_point, gare.start_point] for d in depots]) + sum([map[p.start_point, gare.start_point] for p in people]))/size
end

function time_tree(tree, map)
    time = 0
    for a in tree
        time += map[a[1], a[2]]
    end
    return time
end

function create_graph(map)
    g = SimpleWeightedGraph(size(map)[1])
    for i in 1:size(map)[1]
        for j in i:size(map)[1]
            add_edge!(g, i, j, map[i,j])
        end
    end
    return g
end

function build_tree(edges, points)
    tree = []
    for e in edges
        push!(tree, [points[e.src], points[e.dst]])
    end
    return tree
end

function creation_tree(points, map)
    new_map = restricted_map(map, points)
    graph = create_graph(new_map)
    edges = kruskal_mst(graph)
    tree = build_tree(edges, points)
    return tree, time_tree(tree, map)
end

function kruskal(depots, gare, map, people)
    people = new_people(people, gare, depots)
    points = collect(people[i].start_point for i in 1:length(people))
    points = sort(points)
    points = fastuniq(points)
    tree, time = creation_tree(points, map)
    return tree, time
end

function modified_map(map, μ, i)
    new_map = map[:, :]
    for j in 1:size(map)[1]
        new_map[i, j] += μ
        new_map[j, i] += μ
    end
    return new_map
end

function degree(tree, i)
    deg = 0
    for a in tree
        if i in a
            deg += 1
        end
    end
    return deg
end

function get_the_last_ones(tree, k, i, map, bool=true)
    last_ones = []
    for a in length(tree):-1:1
        if bool
            if !(i in tree[a])
                push!(last_ones, map[tree[a][1], tree[a][2]])
                if length(last_ones) == k
                    return last_ones
                end
            end
        else
            if (i in tree[a])
                push!(last_ones, map[tree[a][1], tree[a][2]])
                if length(last_ones) == k
                    return last_ones
                end
            end
        end
    end
end

function get_the_first_ones(map, i, k, deg)
    cost = collect(map[i, j] for j in 1:size(map)[1])
    return sort(cost)[deg+1:k]
end


function get_by_order(map)
    ordered = sortperm(vec(map))
    return [[(o-1)%size(map)[1] + 1, (o-1)÷size(map)[1] + 1] for o in ordered]
end

function get(map, k, i, val)
    first_ones = []
    ordered = get_by_order(map)
    for o in ordered
        if map[o[1], o[2]] < val && !(i in o)
            push!(first_ones, map[o[1], o[2]])
            if length(first_ones) == k
                return first_ones
            end
        end
    end
end


function borne_inf_v3(depots, gare, map, people)
    tree, time = kruskal(depots, gare, map, people)
    k = length(depots)
    deg = degree(tree, 1)

    people = new_people(people, gare, depots)
    points = collect(people[i].start_point for i in 1:length(people))
    points = sort(points)
    points = fastuniq(points)

    if deg == k
        return tree, time
    elseif deg < k
        A = get_the_last_ones(tree, k-deg, 1, map)
        F = get_the_first_ones(map, 1, k, deg)
        μ = minimum([A[length(A) - i + 1] - F[i] for i in 1:length(A)]) - 0.01
        new_map = modified_map(map, μ, 1)
        return kruskal(depots, gare, new_map, people)
    else 
        A = get_the_last_ones(tree, deg-k, 1, map, false)
        F = get(map, deg - k, 1, A[1, 1])
        μ = minimum([A[i] - F[i] for i in 1:length(A)]) - 0.01
        new_map = modified_map(map, μ, 1)
        return kruskal(depots, gare, new_map, people)
    end
end