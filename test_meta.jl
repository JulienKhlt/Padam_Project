using SparseArrays
using LightGraphs

include("Person.jl")
include("Bus.jl")
# include("TSPTW.jl")
# include("mTSPTW.jl")
include("Parsers.jl")
include("Cluster.jl")
include("Resolution.jl")

mappy = parser("Data/small.csv")
people, gare, depots = build_people("Data/people_small.csv")
sol = creation_cluster(people, gare, depots, mappy, 20)
println(sol)

maxIter = 10
maxTabuSize = 10
autre_sol = metaheuristique_tabou(sol, maxIter, maxTabuSize)
println(autre_sol)