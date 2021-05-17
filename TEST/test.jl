using SparseArrays
using LightGraphs

include("../Person.jl")
include("../Bus.jl")
# include("TSPTW.jl")
# include("mTSPTW.jl")
include("../Parsers.jl")
include("../Cluster.jl")
include("../Resolution.jl")
include("../Algo_en_ligne.jl")

file_dir = "/home/julien/Padam_Project/Data/Villages/"

loc, depots, gare, map, n, clients = read_data(file_dir)
sol = creation_cluster_with_metric(clients[1:38], gare, depots, map, dist_src_dst, 20, true)
println(sol)
println(clients[38].start_point)
# println(best_cluster(clients[38].start_point, sol, 1, dist_src_dst, true))
# add_point!(clients[38].start_point, sol.clusters[2], 1)
# println(check_cluster(sol.clusters[2], sol.map, sol.all_people, 20))

for clu in 1:length(sol.clusters)
    println(clu)
    println(sol.clusters[clu].len)
    println(check_cluster(sol.clusters[clu], sol.map, sol.all_people, 20))
end
println("a")

for i ∈ 1:length(sol.clusters)
    println(i)
    try
        println(creation_bus(sol.clusters[i], i, sol.map, sol.all_people))
    catch
        println("b")
    end
end

buses = compute_solution(sol)
println(buses)