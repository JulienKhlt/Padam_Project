using SparseArrays
using LightGraphs

include("Person.jl")
include("Bus.jl")
include("TSPTW.jl")
include("mTSPTW.jl")
include("Parsers.jl")
include("Cluster.jl")
include("Resolution.jl")
include("plot.jl")

file_directory = "/Users/gache/Documents/ENPC/2A/semestre_2/Projet_IMI/git/Data/"
client_file_name = joinpath(file_directory, "customer_requests.csv")
driver_file_name = joinpath(file_directory, "driver_shifts.csv")
map_file_name = joinpath(file_directory, "mTSP_matrix.csv")
gamma_file_name = joinpath(file_directory, "gammas.csv")
node_coordinates_file_name = joinpath(file_directory, "node_coordinates.csv")

loc = build_localisations(node_coordinates_file_name)
depots, gare = build_drivers_and_gare(driver_file_name)

pl = plot_bus_stops(loc, depots, gare)
people = build_people_real_file_only_client(client_file_name, driver_file_name, map_file_name, gamma_file_name, false)
gare_type_pers = Person(start_point = gare, start_time = 0.0, end_time = 28800.0)
map,n = parser_real_file(map_file_name)
nb_buses = length(depots)
sol = hierarchical_clustering(people, map, gare_type_pers, depots, 15, nb_buses)
println(sol)
println(length(people))
p_hierarchical_clustering = plot_clusters(sol, loc, pl, true)

buses_heuristics = compute_solution(sol)
