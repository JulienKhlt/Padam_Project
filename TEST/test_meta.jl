using SparseArrays
using LightGraphs

include("../Person.jl")
include("../Bus.jl")
# include("TSPTW.jl")
# include("mTSPTW.jl")
include("../Parsers.jl")
include("../Cluster.jl")
include("../Resolution.jl")
include("../distance.jl")

mappy = parser("Data/Instances Tests/large.csv")
people, gare, depots = build_people("Data/Instances Tests/people_large.csv")
length_max = 20
sol = creation_cluster(people, gare, depots, mappy, length_max)
buses = compute_solution(sol) # liste des bus de la solutoin de type Bus
time1 = sum([(bus.time[end]-bus.time[2]) for bus in buses])

#println(b.stops for b in buses)

maxIter = 3
maxTabuSize = 3
margeFrontiere = 8/10
metric = dist_clo
autre_sol = metaheuristique_tabou(buses, maxIter, maxTabuSize, metric, people, gare, depots, mappy, length_max, margeFrontiere)

time2 = sum([(bus.time[end]-bus.time[2]) for bus in autre_sol])