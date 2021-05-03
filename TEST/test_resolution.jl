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
include("../distance.jl")

file_directory = "/home/julien/Padam_Project/Data/uniform/"
client_file_name = joinpath(file_directory, "customer_requests.csv")
driver_file_name = joinpath(file_directory, "driver_shifts.csv")
map_file_name = joinpath(file_directory, "mTSP_matrix.csv")
gamma_file_name = joinpath(file_directory, "gammas.csv")
node_coordinates_file_name = joinpath(file_directory, "node_coordinates.csv")

people = build_people_real_file_only_client(client_file_name, driver_file_name, map_file_name, gamma_file_name, false)
depots, gare = build_drivers_and_gare(driver_file_name)
gare = Person(start_point=gare, start_time=depots[1].end_time, end_time=depots[1].end_time)
map, n = parser_real_file_symetry(map_file_name)


###########################################################
#                       BORNE INF                         #
###########################################################

# println(borne_inf(depots, gare, mappy))
# println(borne_inf_v2(depots, gare, mappy, people, 20))
# tree, time = kruskal(depots, gare, mappy, people)
# println(tree)
# println(degree(tree, 1))
# println(time)

# tree, time = borne_inf_v3(depots, gare, mappy, people)
# println(degree(tree, 1))
# println(tree)
# println(time)
# println(time_tree(tree, mappy))


###########################################################
#                    Creation Clusters                    #
###########################################################

# sol = creation_cluster(people, gare, depots, map, 20, false)
# buses = compute_solution(sol)
# println(buses)
# total_time = get_total_time.(buses)
# println(total_time)
# println(sum(total_time))

sol = creation_cluster_with_metric(people, gare, depots, map, dist_clo, 20)
buses = compute_solution(sol)
println(buses)
total_time = get_total_time.(buses)
println(total_time)
println(sum(total_time))

sol = creation_cluster_with_metric(people, gare, depots, map, dist_mean, 20)
buses = compute_solution(sol)
println(buses)
total_time = get_total_time.(buses)
println(total_time)
println(sum(total_time))


sol = creation_cluster_with_metric(people, gare, depots, map, dist_src_dst, 20)
buses = compute_solution(sol)
println(buses)
total_time = get_total_time.(buses)
println(total_time)
println(sum(total_time))

sol = creation_cluster_with_metric(people, gare, depots, map, 0.5*dist_src_dst+0.5*dist_clo, 20)
buses = compute_solution(sol)
println(buses)
total_time = get_total_time.(buses)
println(total_time)
println(sum(total_time))

# sol = creation_cluster_with_metric(people, gare, depots, mappy, dist_opt, 20)
# buses = compute_solution(sol)
# println(buses)
# total_time = get_total_time.(buses)
# println(total_time)
# println(sum(total_time))


# sol = hierarchical_clustering(people, mappy, gare, depots, 20)
# println(sol)