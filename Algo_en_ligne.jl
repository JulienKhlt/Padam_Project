using PyPlot: pygui
pygui(true)
using Plots
pyplot()

using SparseArrays
using LightGraphs

include("Parsers.jl")
include("Resolution.jl")
include("plot.jl")


def read_data(file_directory::string)
    """
    INPUT : file_directory::string qui donne nom du dossier où sont rangés les fichiers de données

    La fonction importe les données

    OUTPUT
    loc un vecteur de Bus_stop qui représente les coordonnées des arrets de bus
    depots::Vector{Person} la liste des conducteurs
    gare::Person
    map::
    n::Int ? représente ?
    clients::Vector{Person}
    Pour les clients, la contrainte de gamma est directement intégrée directement dans leur time window
    """
    driver_file_name = joinpath(file_directory, "driver_shifts.csv")
    map_file_name = joinpath(file_directory, "mTSP_matrix.csv")
    gamma_file_name = joinpath(file_directory, "gammas.csv")
    node_coordinates_file_name = joinpath(file_directory, "node_coordinates.csv")
    loc = build_localisations(node_coordinates_file_name)
    depots, gare = build_drivers_and_gare(driver_file_name)
    map,n = parser_real_file(map_file_name)
    clients = build_people_real_file_only_client(client_file_name, driver_file_name, map_file_name, gamma_file_name, false)
    return loc, depots, gare, map, n, clients
end


def fast_insertion(solution::Solution, buses::Vector{Bus}, new_client::Person)
    """
    INPUT
    solution::Solution la solution actuelle
    new_client::Person qu'on veut insérer

    Insertion rapide : on essaye d'insérer directement le client dans un cluster
    Quels choix stratégiques pour l'insertion ? Avec une métrique ou juste dans l'ordre des clusters ?
    Pour l'instant, on fait dans l'ordre des clusters par simplicité, on raffinera après si on a le temps

    OUTPUT
    solution::Solution la solution actuelle
    success::Bool true si on a réussi à insérer le client dans un cluster
    """
    try
        index_modified_cluster, dist = best_cluster(point, sol, size, metric, check = false)
    catch
        success = false
        return solution, buses, success
    end
    success = true
    add_point!(point, cluster, size)
    # success = false
    # index_cluster = 1
    # while(!success && (index_cluster <= length(solution.clusters)))
    #     current_cluster = solution.clusters[i]
    #     nb_passagers = current_cluster.len
    #     # d'abord on vérifie qu'il y a de la place dans le bus correspondant
    #     if (nb_passagers < solution.length_max) # inégalité stricte parce qu'il faut pouvoir rajouter un passager
    #         #try TSPTW
    #         current_points = current_cluster.points
    #         people = concatenate(current_points, )
    #         resolution_tsptw(nb_people, people, solution.map, M) # try catch
    #         #success =
    #     index_cluster = +1
    return solution, buses, success
end


def algo_pseudo_en_ligne(file_directory::string)
    """
    INPUT : file_directory::string qui donne nom du dossier où sont rangés les fichiers de données
    OUTPUT : pas encore défini
    times un vecteur de temps (pour l'instant ça n'y est pas)
    Un EDT des bus ? Un version imprimée de solution ?
    """
    # Import data
    loc, depots, gare, map, n, clients = read_data(file_directory)
    #check data makes sens
    pl = plot_bus_stops(loc, depots, gare)

    # Avoir une version ligne de commande où on insère les clients à la main ? bof c'est pénible pour les tests
    # il faut stocker les grandeurs intéressantes (temps d'insertion, ect )
    # Il faut un processus pour l'initialisation des premiers clients
    # - les forcer à etre dans des cluster différents ?
    # - essayer de les mettre dans un/plusieurs bus comme pour le cas général ??

    #insertion_time = 0
    #times = []
    while(true) # Ou for people in

        #push!(times, insertion_time)
    end
end
