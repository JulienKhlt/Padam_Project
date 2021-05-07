include("Parsers.jl")
include("distance.jl")
include("Resolution.jl")
include("Person.jl")
include("Bus.jl")

file_directory = "/home/julien/Padam_Project/Data/uniform"
client_file_name = joinpath(file_directory, "customer_requests.csv")
driver_file_name = joinpath(file_directory, "driver_shifts.csv")
map_file_name = joinpath(file_directory, "mTSP_matrix.csv")
gamma_file_name = joinpath(file_directory, "gammas.csv")
node_coordinates_file_name = joinpath(file_directory, "node_coordinates.csv")

people = build_people_real_file_only_client(client_file_name, driver_file_name, map_file_name, gamma_file_name, false)
depots, gare = build_drivers_and_gare(driver_file_name)
mappy, n = parser_real_file_symetry(map_file_name)


using Plots; pyplot()
x = range(0, stop=1, length=10)
y = range(0, stop=1, length=10)
function find_best_2(x, y)
    sol = creation_cluster_with_metric(people, gare, depots, mappy, x*dist_src_dst+y*dist_mean, 20)
    buses = compute_solution(sol)
    return sum(get_total_time.(buses))
end
plot(x, y, find_best_2, st=:surface, camera=(-30,30))
savefig("function_escalier.png")