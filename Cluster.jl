include("TSPTW.jl")

struct Cluster
    points::Vector{Int}
    len
end

function Base.show(io::IO, cluster::Cluster)
    str = "Points : \n"
    for i in 1:length(cluster.points)
        str *= "       $(cluster.points[i])\n"
    end
    print(io, str)
end

struct Solution
    clusters::Vector{Cluster}
    length_max
    map
end

function Base.show(io::IO, solution::Solution)
    str = "Cluster : \n"
    for i in 1:length(solution.clusters)
        str *= "    id : $(i)\n"
        str *= "    $(solution.clusters[i])\n"
    end
    print(io, str)
end

function add_point!(point, cluster::Cluster)
    push!(cluster.points, point)
end

function remove_point!(id_point, cluster::Cluster)
    deleteat!(cluster.points, id_point)
end

function add_cluster!(cluster, solution)
    push!(solution.clusters, cluster)
end

function remove_cluster!(id_cluster, solution)
    deleteat!(solution.clusters, id_cluster)
end

function dist(point, map, Cluster)
    return minimum([map[point, i] for i in Cluster.points])
end

function closest(point, Solution, list=false)
    # if list==true, return the closest cluster to point
    # if list==false, return a list of the order of clusters for the point
    if list
        return sortperm([dist(point, Solution.map, i) for i in Solution.clusters])
    else
        return argmin([dist(point, Solution.map, i) for i in Solution.clusters])
    end
end

function nbre_people(point, people)
    return [people[i] for i in 1:length(people) if people[i].first_point == point]
end

function closest_convex(point, Solution)
end

function creation_bus(cluster, id, map, all_people)
    people = find_people(cluster, all_people)
    stops, time = order_point(resolution_tsptw(length(people), people, map, 10000), people)
    return Bus(id=id, people=people, stops=stops, time=time)
end

function compute_solution(solution, all_people)
    return [creation_bus(solution.clusters[i], i, solution.map, all_people) for i in 1:length(solution.clusters)]
end

function check_cluster(cluster, map, all_people)
    people = find_people(cluster, all_people)
    try
        resolution_tsptw(length(people), people, map, 10000)
        return true
    catch
        return false
    end
end

function add_point!(point, sol::Solution, nb_point)
    cluster = sol.clusters[closest(point, sol)]
    if cluster.len <= sol.length_max - nb_point
        add_point!(point, cluster)
        cluster.len += nb_point-
    else
        println("Impossible")
    end
end
