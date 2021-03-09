using SparseArrays
using LightGraphs

# include("Person.jl")
# include("Bus.jl")
# include("TSPTW.jl")
# include("mTSPTW.jl")
include("Parsers.jl")
include("Cluster.jl")

map = parser("Data/small.csv")
cluster = Cluster([2, 3])
cluster2 = Cluster([4, 5])
sol = Solution([cluster, cluster2])

# println(dist(1, map, cluster2))
# println(map[1, 4])
# println(map[1, 5])

print(closest(1, map, sol))