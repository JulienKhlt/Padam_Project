using SparseArrays
using LightGraphs

include("Person.jl")
include("Bus.jl")
# include("TSPTW.jl")
# include("mTSPTW.jl")
include("Parsers.jl")
include("Cluster.jl")

# mappy = parser("Data/large.csv")
# people = build_people("Data/people_large.csv")

# len = 10
# train_index = 1

# sol = k_means(people, len, mappy, train_index)
# println(sol)

map = parser("Data/small.csv")
people, gare, depots = build_people("Data/people_small.csv")
people = new_people(people, gare, depots)
length_max = 20
cluster = Cluster([5], gare, depots[1], 0)
cluster2 = Cluster([3], gare, depots[1], 0)
add_point!(4, cluster, 1)
println(cluster)
println(check_cluster(cluster, map, people, length_max))
sol = Solution([cluster, cluster2], 3, map, people)
add_point!(4, sol)

println(sol)
# bus = creation_bus(cluster, 1, map, people)
buses = compute_solution(sol)
println(buses)
println(get_total_time.(buses))
# println(cluster)
# add_cluster!(cluster2, sol)
# println(sol)

# println(dist(1, map, cluster2))
# println(map[1, 4])
# println(map[1, 5])
