using Plots
pyplot()


"Ajoute un cluster à un graphique"
function add_cluster_to_plot!(cluster::Cluster, localisations::Vector{Bus_stop}, pl::Plots.Plot)
    latitude_list = []
    longitude_list = []
    for i in 1:length(cluster.points)
        bus_stop = localisations[i]
        push!(latitude_list, bus_stop.latitude)
        push!(longitude_list, bus_stop.longitude)
    end
    plot!(
        pl, latitude_list, longitude_list,
        linewidth = 1
    )
end

"Affiche le graphique des clusters présents dans une solution"
function plot_clusters(solution::Solution, localisations::Vector{Bus_stop})::Plots.Plot
    pl = plot()
    for cluster in solution.clusters
        add_cluster_to_plot!(cluster, localisations, pl)
    end
    plot!(title = "Carte des clusters")
    return pl
end


"""
Inputs :
- localisations un vecteur d'éléments de type Bus_stop qui contient les localisations de tous les arrets de bus
- depots la liste des indices des dépots
- index_gare l'indice de la gare
Affiche le graphique des arrets de bus, des dépots et de la gare
Output : le graphe
"""
function plot_bus_stops(localisations::Vector{Bus_stop}, depots, index_gare)::Plots.Plot
    pl = plot()

    #On affiche les arrets de bus
    latitude_list = []
    longitude_list = []
    for i in 1:length(localisations)
        bus_stop = localisations[i]
        push!(latitude_list, bus_stop.latitude)
        push!(longitude_list, bus_stop.longitude)
    end
    scatter!(
        pl, latitude_list, longitude_list,
        marker = (:circle, 3, 0.7, "black"),
        label = "arrets de bus",
    )

    #On affiche les dépots
    latitude_list = []
    longitude_list = []
    for index_depot in depots
        loc_depot = localisations[index_depot]
        push!(latitude_list, loc_depot.latitude)
        push!(longitude_list, loc_depot.longitude)
    end
    scatter!(
        pl, latitude_list, longitude_list,
        markershape = :diamond,
        markersize = 5,
        markeralpha = 1,
        markercolor = :green,
        markerstrokealpha = 0,
        label = "depots",
    )

    #On affiche la gare
    loc_gare = loc[index_gare]
    scatter!(
        pl, [loc_gare.latitude], [loc_gare.longitude],
        markershape = :rect,
        markersize = 5,
        markeralpha = 1,
        markercolor = :red,
        markerstrokealpha = 0,
        label = "gare",
    )
    plot!(title = "Carte des arrets de bus")
    return pl
end
