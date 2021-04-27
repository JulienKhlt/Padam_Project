using SparseArrays
using LightGraphs

include("../Parsers.jl")
include("../plot.jl")

file_directory = "/Users/gache/Documents/ENPC/2A/semestre_2/Projet_IMI/git/Data/circle"
client_file_name = joinpath(file_directory, "customer_requests.csv")
driver_file_name = joinpath(file_directory, "driver_shifts.csv")
map_file_name = joinpath(file_directory, "mTSP_matrix.csv")
gamma_file_name = joinpath(file_directory, "../gammas.csv")
node_coordinates_file_name = joinpath(file_directory, "node_coordinates.csv")

loc = build_localisations(node_coordinates_file_name)
depots, gare = build_drivers_and_gare(driver_file_name)
pl = plot_bus_stops(loc, depots, gare)
