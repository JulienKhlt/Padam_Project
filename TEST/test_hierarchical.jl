using SparseArrays
using LightGraphs

include("../Person.jl")
include("../Bus.jl")
include("../TSPTW.jl")
include("../mTSPTW.jl")
include("../Parsers.jl")
include("../Cluster.jl")
include("../Resolution.jl")
include("../plot.jl")

file_directory = "/Users/gache/Documents/ENPC/2A/semestre_2/Projet_IMI/git/Data/"
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
sol = hierarchical_clustering(people, mappy, gare_type_pers, depots, 20, nb_buses)
println(sol)
pl = plot_terminus(loc, depots, gare)
p_hierarchical_clustering = plot_clusters(sol, loc, pl, true)

"""for i in 1:length(sol.clusters)
    if length(sol.clusters[i].points)<20
        print(i, " ", sol.clusters[i].len, "   ")
    end
end"""
sol_test = creation_cluster(people, gare_type_pers, depots, map, 20)
pl_test = plot_terminus(loc, depots, gare)
p_test = plot_clusters(sol_test, loc, pl_test, true)


id=1
for cluster in sol.clusters[1:nb_buses]
    print(cluster)
    people = find_people(cluster, sol.all_people)
    people = new_people_cluster(people, cluster.gare, cluster.depot)
    stops, time = order_point(resolution_tsptw(length(people), people, sol.map, 10000), people)
    print(Bus(id=id, people=people, stops=stops, time=time))
    id+=1
end
