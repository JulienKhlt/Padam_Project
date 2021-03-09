struct Cluster
    points::Vector{Int}
end

struct Solution
    clusters::Vector{Cluster}
end

function dist(point, map, Cluster)
    return minimum([map[point, i] for i in Cluster.points])
end

function closest(point, map, Solution)
    return argmin([dist(point, map, i) for i in Solution.clusters])
end

function closest_convex(point, Solution)
end