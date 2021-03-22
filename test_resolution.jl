using SparseArrays
using LightGraphs

include("Person.jl")
include("Bus.jl")
# include("TSPTW.jl")
# include("mTSPTW.jl")
include("Parsers.jl")
include("Cluster.jl")
include("Resolution.jl")

mappy = parser("Data/huge.csv")
people, gare, depots = build_people("Data/people_huge.csv")
sol = creation_cluster(people, gare, depots, mappy, 20)
println(sol)

sol = hierarchical_clustering(people, mappy, gare, depots, 20)
println(sol)
