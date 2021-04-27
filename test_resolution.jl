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
println(tree)
println(degree(tree, 1))
println(time)

tree, time = borne_inf_v3(depots, gare, mappy, people)
println(degree(tree, 1))
println(tree)
println(time)
println(time_tree(tree, mappy))

sol = creation_cluster(people, gare, depots, mappy, 20, false)
buses = compute_solution(sol)
println(buses)
total_time = get_total_time.(buses)
println(total_time)
println(sum(total_time))


# sol = hierarchical_clustering(people, mappy, gare, depots, 20)
# println(sol)