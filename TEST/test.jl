using SparseArrays
using LightGraphs

include("../Person.jl")
include("../Bus.jl")
# include("TSPTW.jl")
# include("mTSPTW.jl")
include("../Parsers.jl")
include("../Cluster.jl")
include("../Resolution.jl")
include("../borne_inf.jl")

mappy = parser("Data/small.csv")

people, gare, depots = build_people("Data/people_small.csv")

sol = creation_cluster(people, gare, depots, mappy, 20, false)
buses = compute_solution(sol)
println(buses)
println(buses[1].people)

remove_point_bus!(buses[1], 4)

println(buses)
println(buses[1].people)

add_point_bus!(buses[1], 4, people)
rearrangement_2opt(buses[1], mappy)

println(buses)
println(buses[1].people)

total_time = get_total_time.(buses)
println(total_time)
println(sum(total_time))