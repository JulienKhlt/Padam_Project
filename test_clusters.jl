using SparseArrays
using LightGraphs

include("Person.jl")
include("Bus.jl")
# include("TSPTW.jl")
# include("mTSPTW.jl")
include("Parsers.jl")
include("Cluster.jl")

map = parser("Data/small.csv")
people = build_people("Data/people_small.csv")

cluster = Cluster([1, 2, 3])
cluster2 = Cluster([1, 5])
println(check_cluster(cluster, map, people))
sol = Solution([cluster, cluster2], 3, map)
add_point!(4, sol)
println(sol)
# bus = creation_bus(cluster, 1, map, people)
buses = compute_solution(sol, people)
println(buses)
println(get_total_time.(buses))
# println(cluster)
# add_cluster!(cluster2, sol)
# println(sol)

# println(dist(1, map, cluster2))
# println(map[1, 4])
# println(map[1, 5])
