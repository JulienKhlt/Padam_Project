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
include("../plot.jl")

mappy = parser("Data/Villages/mTSP_matrix.csv")
people = build_people_real_file_only_client("Data/Villages/customers_request.csv", "Data/Villages/driver_shifts", "Data/Villages/mTSP_matrix.csv", "Data/Villages/gammas.csv", false)
gare, depots = build_drivers_and_gare("Data/Villages/driver_shifts")
length_max = 20
sol = creation_cluster(people, gare, depots, mappy, length_max)
buses = compute_solution(sol) # liste des bus de la solutoin de type Bus
loc = build_localisations("Data/Villages/node_coordinates.csv")

pl = plot_bus_stops(loc, depots, gare)
pl = plot_terminus(loc, depots, gare, pl)
pl = plot_bus_routes(buses,loc, pl)