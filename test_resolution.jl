using SparseArrays
using LightGraphs

include("Person.jl")
include("Bus.jl")
# include("TSPTW.jl")
# include("mTSPTW.jl")
include("Parsers.jl")
include("Cluster.jl")
include("Resolution.jl")

map = parser("Data/medium.csv")
people, gare, depots = build_people("Data/people.csv")
sol = creation_cluster(people, gare, depots, map, 20)
println(sol)
