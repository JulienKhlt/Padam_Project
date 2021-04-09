include("TSPTW.jl")

mutable struct Cluster
    points::Vector{Int}
    gare
    depot
    len
end

function Base.show(io::IO, cluster::Cluster)
    str = "Points : \n"
    for i in 1:length(cluster.points)
        str *= "       $(cluster.points[i])\n"
    end
    str *= "Depot : $(cluster.depot.start_point)"
    print(io, str)
end

struct Solution
    clusters::Vector{Cluster}
    length_max
    map
    all_people
end

function Base.show(io::IO, solution::Solution)
    str = "Cluster : \n"
    for i in 1:length(solution.clusters)
        str *= "    id : $(i)\n"
        str *= "    $(solution.clusters[i])\n"
    end
    print(io, str)
end

function add_point!(point, cluster::Cluster, nb_point)
    push!(cluster.points, point)
    cluster.len += nb_point
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

function dist_clo(point, map, Cluster)
    return minimum([map[point, i] for i in Cluster.points])
end

function dist_mean(point, map, Cluster)
    return 0
end

function closest_pers(point, map, people)
    return people[argmin([map[point, i.start_point] for i in people])]
end

function closest(point, Solution, list=false)
    # if list==false, return the closest cluster to point
    # if list==true, return a list of the order of clusters for the point
    if list
        list = [dist_clo(point, Solution.map, i) for i in Solution.clusters]
        println(length(list))
        return sortperm(list)
        #return sortperm([dist_clo(point, Solution.map, i) for i in Solution.clusters])
    else
        return argmin([dist_clo(point, Solution.map, i) for i in Solution.clusters])
    end
end

function best_cluster(point, sol, size, check = true)
    id_clusters = closest(point, sol, true)
    for c in id_clusters
        if sol.clusters[c].len + size < sol.length_max
            if check
                cluster = Cluster(sol.clusters[c].points, sol.clusters[c].gare, sol.clusters[c].depot, sol.clusters[c].len)
                add_point!(point, cluster, size)
                if check_cluster(cluster, sol.map, sol.all_people, sol.length_max)
                    return c
                end
            else
                return c
            end
        end
    end
    throw(ErrorException("Tous les clusters sont pleins ou on ne peut insérer le point nul part"))
end

function closest_mean(point, Solution, list=false)
    # if list==true, return the closest cluster to point
    # if list==false, return a list of the order of clusters for the point
    if list
        return sortperm([dist_mean(point, Solution.map, i) for i in Solution.clusters])
    else
        return argmin([dist_mean(point, Solution.map, i) for i in Solution.clusters])
    end
end

function nbre_people(point, people)
    return [people[i] for i in 1:length(people) if people[i].start_point == point]
end

function closest_convex(point, Solution)
end

function creation_bus(cluster, id, map, all_people)
    people = find_people(cluster, all_people)
    people = new_people_cluster(people, cluster.gare, cluster.depot)
    stops, time = order_point(resolution_tsptw(length(people), people, map, 10000), people)
    return Bus(id=id, people=people, stops=stops, time=time)
end

function compute_solution(solution)
    return [creation_bus(solution.clusters[i], i, solution.map, solution.all_people) for i in 1:length(solution.clusters)]
end

function check_cluster(cluster, map, all_people, length_max)
    people = find_people(cluster, all_people)
    people = new_people_cluster(people, cluster.gare, cluster.depot)
    try
        resolution_tsptw(length(people), people, map, 10000)
        return length(cluster.points) <= length_max
    catch
        return false
    end
end

function add_point!(point, sol::Solution)
    cluster = sol.clusters[closest(point, sol)]
    nb_point = length(nbre_people(point, sol.all_people))
    if cluster.len <= sol.length_max - nb_point
        add_point!(point, cluster, nb_point)
    else
        println("Impossible")
    end
end

function update!(cluster, people)
    for i in cluster.points
        cluster.len += length(nbre_people(i, people))
    end
end

function get_points(clusters)
    points = []
    for c in clusters
        append!(points, c.points)
    end
    return fastuniq(points)
end

function already_in(person, clusters)
    return person.start_point in get_points(clusters)
end

function points_left(all_people)
    return fastuniq([p.start_point for p in all_people])
end
