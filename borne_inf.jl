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

function build_tree(edges)
    tree = []
    for e in edges
        push!(tree, [e.src, e.dst])
    end
    return tree
end

function creation_tree(points, map)
    new_map = restricted_map(map, points)
    graph = create_graph(new_map)
    edges = kruskal_mst(graph)
    tree = build_tree(edges)
    return tree, time_tree(tree, new_map)
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
    new_map = map[:]
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