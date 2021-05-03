using SparseArrays
using LightGraphs
using SimpleWeightedGraphs

include("../Person.jl")
include("../Bus.jl")
#include("../TSPTW.jl")
#include("../mTSPTW.jl")
include("../Parsers.jl")
include("../Cluster.jl")
include("../Resolution_clusters.jl")
include("../plot.jl")
include("../borne_inf.jl")
include("../distance_cluster.jl")
include("../distance.jl")

file_directory = "/Users/gache/Documents/ENPC/2A/semestre_2/Projet_IMI/git/Data/Villages/"
client_file_name = joinpath(file_directory, "customer_requests.csv")
driver_file_name = joinpath(file_directory, "driver_shifts.csv")
map_file_name = joinpath(file_directory, "mTSP_matrix.csv")
gamma_file_name = joinpath(file_directory, "gammas.csv")
node_coordinates_file_name = joinpath(file_directory, "node_coordinates.csv")

loc = build_localisations(node_coordinates_file_name)
depots, gare = build_drivers_and_gare(driver_file_name)

people = build_people_real_file_only_client(client_file_name, driver_file_name, map_file_name, gamma_file_name, false)
gare_type_pers = Person(start_point = gare, start_time = 0.0, end_time = 28800.0)
mappy,n = parser_real_file(map_file_name)
nb_buses = length(depots)

metric = ward_dist
sol = hierarchical_clustering(people, mappy, gare_type_pers, depots, 20, nb_buses, metric)
println(sol)
pl = plot_terminus(loc, depots, gare)
p_hierarchical_clustering = plot_clusters(sol, loc, pl, true)


metric = dist_max
sol = hierarchical_clustering(people, mappy, gare_type_pers, depots, 20, nb_buses, metric)
println(sol)
pl = plot_terminus(loc, depots, gare)
p_hierarchical_clustering = plot_clusters(sol, loc, pl, true)


metric = dist_min
sol = hierarchical_clustering(people, mappy, gare_type_pers, depots, 20, nb_buses, metric)
println(sol)
pl = plot_terminus(loc, depots, gare)
p_hierarchical_clustering = plot_clusters(sol, loc, pl, true)


metric = sum_dist_point_mean
sol = hierarchical_clustering(people, mappy, gare_type_pers, depots, 20, nb_buses, metric)
println(sol)
pl = plot_terminus(loc, depots, gare)
p_hierarchical_clustering = plot_clusters(sol, loc, pl, true)


metric = angle_min
sol = hierarchical_clustering(people, mappy, gare_type_pers, depots, 20, nb_buses, metric)
println(sol)
pl = plot_terminus(loc, depots, gare)
p_hierarchical_clustering = plot_clusters(sol, loc, pl, true)

metric = angle_max
sol = hierarchical_clustering(people, mappy, gare_type_pers, depots, 20, nb_buses, metric)
println(sol)
pl = plot_terminus(loc, depots, gare)
p_hierarchical_clustering = plot_clusters(sol, loc, pl, true)

buses = compute_solution(sol)
println(buses)
total_time = get_total_time.(buses)
println(total_time)
println(sum(total_time))
