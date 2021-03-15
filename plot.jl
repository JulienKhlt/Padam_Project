using Plots
pyplot()


"Ajoute un cluster à un graphique"
function add_cluster_to_plot!(cluster::Cluster, localisations::Vector{Bus_stop}, pl::Plots.Plot)
    X_list = []
    Y_list = []
    for i in 1:length(cluster.points)
        bus_stop = localisations[i]
        push!(X_list, bus_stop.coordx)
        push!(Y_list, bus_stop.coordy)
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
