using PyPlot: pygui
#pygui(true)
using Plots
pyplot()

using SparseArrays
using LightGraphs
using IJulia

include("Parsers.jl")
include("Resolution_clusters.jl")
include("Resolution.jl")
include("plot.jl")
include("Bus.jl")


function read_data(file_directory::String)
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


function fast_insertion(solution::Solution, buses::Vector{Bus}, new_client::Person, metric)
    """
    INPUT : solution::Solution donne la solution actuelle
            new_client::Person qu'on veut insérer
            buses : vecteur donnant les bus actuels
            metric : la distance qu'on utilise entre un client et un cluster

    Insertion rapide : on essaye d'insérer directement le client dans un cluster
    Quels choix stratégiques pour l'insertion ? Avec une métrique

    OUTPUT : solution::Solution la nouvelle solution
             buses : vecteur des nouveaux bus
             success::Bool true si on a réussi à insérer le client dans un cluster
    """
    index_modified_cluster = 0
    indices_best_clusters = closest(new_client.start_point, solution, metric, true)[1]
    println(typeof(indices_best_clusters))
    success = false
    i = 1
    while !success && i<length(indices_best_clusters)+1
        index_modified_cluster = indices_best_clusters[i]
        println(typeof(index_modified_cluster), index_modified_cluster)
        add_point!(new_client.start_point, solution.clusters[index_modified_cluster], 1)
        add_point_bus!(buses[index_modified_cluster], new_client.start_point, solution.all_people)
        rearrangement_2opt(buses[index_modified_cluster], solution.map)
        success = admissible_bus(buses[index_modified_cluster], solution.map, solution.length_max)
        i += 1
        println("cluster", i)
    end
    # index_modified_cluster, dist = best_cluster(new_client.start_point, solution, 1, metric, false)
    # success = true
    # add_point!(new_client.start_point, solution.clusters[index_modified_cluster], 1)
    # add_point_bus!(buses[index_modified_cluster], new_client.start_point, solution.people)
    # rearrangement_2opt(buses[index_modified_cluster], solution.map)
    # success = admissible_bus(buses[index_modified_cluster], solution.map, solution.length_max)
    return solution, buses, success
end


function algo_pseudo_en_ligne(file_directory::String, metric_point = dist_src_dst, metric_cluster = angle_max, anim = false)#angle_max est une fonction
    """
    INPUT : file_directory::string qui donne nom du dossier où sont rangés les fichiers de données

    Rq : on appelle "client" une personne qui fait une demande de réservation
    et "passengers " désignent la liste des personnes qui ont été acceptés.

    OUTPUT : pas encore défini
    times un vecteur de temps (pour l'instant ça n'y est pas)
    Un EDT des bus ? Un version imprimée de solution ?
    """
    # Import data
    println("Importation des données...")
    loc, depots, gare, map, n, clients = read_data(file_directory)
    println("Fin de l'importation des données.")
    #check data makes sens
    #pl = plot_bus_stops(loc, depots, gare)

    # Avoir une version ligne de commande où on insère les clients à la main ? bof c'est pénible pour les tests
    # il faut stocker les grandeurs intéressantes (temps d'insertion, ect )
    # Il faut un processus pour l'initialisation des premiers clients
    # - les forcer à etre dans des cluster différents ?
    # - essayer de les mettre dans un/plusieurs bus comme pour le cas général ??
    # Au fond ça n'a pas bcp d'importance car ils seront déplacé dès que l'insertion rapide ne marche plus
    # Il faut surtout trouver une manière rapide de le faire

    if anim
        pl = plot_terminus(loc, depots, gare)
    end
    #insertion_time = 0
    #times = []
    LENGHT_MAX = 20
    nb_clients = length(clients)
    nb_drivers = length(depots)
    nb_seats = nb_drivers * LENGHT_MAX
    nb_passengers = 0
    passengers = Vector{Person}()



    #Initialisation pour le premier client à faire
    client_id = 1
    new_client = clients[client_id]
    push!(passengers, new_client)
    solution = hierarchical_clustering(passengers, map, gare, depots, LENGHT_MAX, nb_drivers, metric_cluster)
    buses = compute_solution(solution)
    if anim
        p_hierarchical_clustering = plot_bus_routes_copy(buses, loc, pl)|> IJulia.display
    end
    client_id = 2
    remember = 1
    # Boucle pour les clients suivants
    while ((nb_passengers < nb_seats) && (client_id <= nb_clients))
        println("Client ",client_id)
        new_client = clients[client_id]
        success_fast_insertion = false
        #solution, buses, success_fast_insertion = fast_insertion(solution, buses, new_client, metric_point)
        #println("fast instertion ", success_fast_insertion)
        if success_fast_insertion
            push!(passengers, new_client)
            nb_passengers += 1
        else
            # on génère des clusters temporaires à partir de zéro
            temporary_passengers = deepcopy(passengers)
            push!(temporary_passengers, new_client)
            temporary_solution = creation_cluster_with_metric(temporary_passengers,  gare, depots, map, metric_point, LENGHT_MAX)
            #hierarchical_clustering(temporary_passengers, map, gare, depots, LENGHT_MAX, nb_drivers,  metric_cluster)

            # Ou bien
            # solution_feasibility = check_cluster(cluster, map, all_people, length_max) ??
            # ou créer un truc hybride qui reprend ça et compute solution
            try
                temporary_buses = compute_solution(temporary_solution)
                # On essaie de faire un TSPTW
                # Si ça passe, on enregistre la solution et on intègre le client à la liste des passagers
                nb_passengers += 1
                solution = temporary_solution
                passengers = temporary_passengers
                buses = temporary_buses
                remember = client_id
                println("Le client ",client_id, " partant du point ", new_client.start_point, " a été inséré suite à un recalcul des clusters")
            catch
                println("Le client ",client_id, " partant du point ", new_client.start_point, " n'a pas pu être inséré dans l'EDT.")
            end
        end
        #push!(times, insertion_time)
        if anim
            p_hierarchical_clustering = plot_bus_routes_copy(buses, loc, pl)|> IJulia.display
        end
        client_id += 1 # On passe au client suivant
    end
    print("Dernier client ", remember)
    print("Nb clients ", length(passengers))
    return solution
end

file_dir = "/Users/gache/Documents/ENPC/2A/semestre_2/Projet_IMI/git/Data/Villages/"
algo_pseudo_en_ligne(file_dir, dist_src_dst,  angle_max,true)
