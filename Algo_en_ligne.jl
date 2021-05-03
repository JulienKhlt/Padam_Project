using PyPlot: pygui
pygui(true)
using Plots
pyplot()

using SparseArrays
using LightGraphs

include("Parsers.jl")
include("Resolution.jl")
include("plot.jl")


def read_statical_data(file_directory::string)
    """
    INPUT : file_directory::string qui donne nom du dossier où sont rangés les fichiers de données

    La fonction importe les données statiques (càd qui ne vont pas changer lors des réservations)

    OUTPUT
    loc un vecteur de Bus_stop qui représente les coordonnées des arrets de bus
    depots::
    gare::
    map::
    n:: ? représente ?
    """
    #client_file_name = joinpath(file_directory, "customer_requests.csv")
    driver_file_name = joinpath(file_directory, "driver_shifts.csv")
    map_file_name = joinpath(file_directory, "mTSP_matrix.csv")
    gamma_file_name = joinpath(file_directory, "gammas.csv")
    node_coordinates_file_name = joinpath(file_directory, "node_coordinates.csv")
    loc = build_localisations(node_coordinates_file_name)
    depots, gare = build_drivers_and_gare(driver_file_name)
    map,n = parser_real_file(map_file_name)
    #Add gammas
    return loc, depots, gare, map, n
end

"""Insertion rapide : on essaye d'insérer directement le client
Quels choix stratégiques pour l'insertion ? Avec une métrique ou random ? """
def fast_insertion(solution::Solution, new_client)
    success = false
    index_cluster = 1
    while(!success && (index_cluster <= length(solution.clusters)))
        # d'abord on vérifie qu'il y a de la place dans le bus correspondant 
        if ()
            #try TSPTW
            current_cluster = solution.clusters[i]
            current_points = current_cluster.points
            people = concatenate(current_points, )
            resolution_tsptw(nb_people, people, solution.map, M)
            #success =
        index_cluster = +1
    return solution, success
end


def algo(file_directory::string)
    # Import data
    loc, depots, gare, map, n = read_statical_data(file_directory)
    #check data makes sens
    pl = plot_bus_stops(loc, depots, gare)

    # Avoir une version ligne de commande où on insère les clients à la main ?
    # il faut stocker les grandeurs intéressantes (temps d'insertion, ect )
    # Il faut un processus pour l'initialisation des premiers clients
    # - les forcer à etre dans des cluster différents ?
    # - essayer de les mettre dans un/plusieurs bus comme pour le cas général ??
    insertion_time = 0
    times = []
    while(true)

        push!(times, insertion_time)
    end
end
