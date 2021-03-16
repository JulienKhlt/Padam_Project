using Plots
pyplot()


"Ajoute un cluster à un graphique"
function add_cluster_to_plot!(cluster::Cluster, localisations::Vector{Bus_stop}, pl::Plots.Plot)
    X_list = []
    Y_list = []
    for i in 1:length(cluster.points)
        bus_stop = localisations[i]
        push!(X_list, bus_stop.latitude)
        push!(Y_list, bus_stop.longitude)
    end
    plot!(
        pl, X_list, Y_list,
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

"Affiche le graphique des arrets de bus"
function plot_bus_stops(localisations::Vector{Bus_stop})::Plots.Plot
    pl = plot()
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
    plot!(title = "Carte des arrets de bus")
    return pl
end
