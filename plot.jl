using Plots
pyplot()


"Ajoute un cluster à un graphique (points reliés par des lignes)"
function add_cluster_to_plot!(cluster::Cluster, localisations::Vector{Bus_stop}, pl::Plots.Plot, index::Int = 0)
    loc_depot = localisations[cluster.depot.start_point]
    latitude_list = [loc_depot.latitude]
    longitude_list = [loc_depot.longitude]
    for i in 1:length(cluster.points)
        bus_stop = localisations[cluster.points[i]]
        push!(latitude_list, bus_stop.latitude)
        push!(longitude_list, bus_stop.longitude)
    end
    loc_gare = loc[cluster.gare.start_point]
    push!(latitude_list, loc_gare.latitude)
    push!(longitude_list, loc_gare.longitude)
    if index == 0
        label = "cluster"
    else
        label = "cluster n°" * string(index)
    end
    plot!(
        pl, latitude_list, longitude_list,
        linewidth = 1,
        label = label
    )
end

"Ajoute un cluster à un graphique"
function scatter_cluster_to_plot!(cluster::Cluster, localisations::Vector{Bus_stop}, pl::Plots.Plot, index::Int = 0)
    latitude_list = []
    longitude_list = []
    for i in 1:length(cluster.points)
        bus_stop = localisations[cluster.points[i]]
        push!(latitude_list, bus_stop.latitude)
        push!(longitude_list, bus_stop.longitude)
    end
    if index == 0
        label = "cluster"
    else
        label = "cluster n°" * string(index)
    end
    scatter!(
        pl, latitude_list, longitude_list,
        markersize = 4,
        markeralpha = 1,
        markerstrokealpha = 0,
        label = label
    )
end


"Affiche le graphique des clusters présents dans une solution"
function plot_clusters(solution::Solution, localisations::Vector{Bus_stop}, pl::Plots.Plot, scatter = true)::Plots.Plot
    for (index, cluster) in enumerate(solution.clusters)
        if scatter
            scatter_cluster_to_plot!(cluster, localisations, pl, index)
        else
            add_cluster_to_plot!(cluster, localisations, pl, index)
        end
    end
    plot!(title = "Carte des clusters")
    return pl
end


"Affiche les dépots et la gare"
function plot_terminus(localisations::Vector{Bus_stop}, drivers::Vector{Person}, index_gare, pl = nothing)::Plots.Plot
    if pl == nothing
        pl = plot()
    end

    #On affiche les dépots
    latitude_list = []
    longitude_list = []
    for driver in drivers
        loc_depot = localisations[driver.start_point]
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


"""
Inputs :
- localisations un vecteur d'éléments de type Bus_stop qui contient les localisations de tous les arrets de bus
- drivers la liste des drivers (de type Person)
- index_gare l'indice de la gare
Affiche le graphique des arrets de bus, des dépots et de la gare
Output : le graphe
"""
function plot_bus_stops(localisations::Vector{Bus_stop}, drivers::Vector{Person}, index_gare)::Plots.Plot
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
    plot_terminus(localisations, drivers, index_gare, pl)
    plot!(title = "Carte des arrets de bus")
    return pl
end
