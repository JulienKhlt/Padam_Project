using SparseArrays
using LightGraphs

include("Person.jl")
include("Bus.jl")
# include("TSPTW.jl")
# include("mTSPTW.jl")
include("Parsers.jl")
include("Cluster.jl")
include("Resolution.jl")
include("borne_inf.jl")

mappy = parser("Data/large.csv")
people, gare, depots = build_people("Data/people_large.csv")

println(borne_inf(depots, gare, mappy))
println(borne_inf_v2(depots, gare, mappy, people, 20))
tree, time = kruskal(depots, gare, mappy, people)
println(degree(tree, 1))
println(time)

sol = creation_cluster(people, gare, depots, mappy, 20)
buses = compute_solution(sol)
total_time = get_total_time.(buses)
println(total_time)
println(sum(total_time))

sol = creation_cluster_betterbutlonger(people, gare, depots, mappy, 20)
bus = compute_solution(sol)
total_time = get_total_time.(bus)
println(total_time)
println(sum(total_time))

# sol = hierarchical_clustering(people, mappy, gare, depots, 20)
# println(sol)

# sol_Louise = creation_clusters_by_zones(people, gare, depots, mappy, 20)
# bus = compute_solution(sol_Louise)
# total_time = get_total_time.(bus)
# println(total_time)
# println(sum(total_time))