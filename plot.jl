using Plots
pyplot()
include("Bus.jl")
Plots.scalefontsizes()
Plots.scalefontsizes(1)
colors = palette(:tab20)
#colors = ["tomato1","mediumpurple", "springgreen2", "royalblue4", "lightskyblue", "yellow", "teal", "goldenrod1", "brown2", "brown2", "brown2", "brown2", "brown2", "brown2" ]

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
        label = label,
        legend=:outertopleft
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
        label = label,
        legend = :outertopleft
    )
end

"Ajoute un cluster à un graphique"
function scatter_cluster_to_plot!(cluster::Cluster, localisations::Vector{Bus_stop}, pl::Plots.Plot, colors, index::Int = 0)
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
        color = colors,
        markerstrokealpha = 0,
        label = label,
        legend = false,# :outertopleft
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


"Affiche le graphique des clusters présents dans une solution sans modifier le graphe initial"
function plot_clusters_copy(solution::Solution, localisations::Vector{Bus_stop}, pl::Plots.Plot, scatter = true)::Plots.Plot
    pl_copy = deepcopy(pl)
    for (index, cluster) in enumerate(solution.clusters)
        if scatter
            scatter_cluster_to_plot!(cluster, localisations, pl_copy, index)
        else
            add_cluster_to_plot!(cluster, localisations, pl_copy, index)
        end
    end
    plot!(title = "Carte des clusters")
    return pl_copy
end



"Affiche les dépots et la gare"
function plot_terminus(loc::Vector{Bus_stop}, drivers::Vector{Person}, gare::Person, pl = nothing)::Plots.Plot
    index_gare = gare.start_point
    if pl == nothing
        pl = plot()
    end

    #On affiche les dépots
    latitude_list = []
    longitude_list = []
    for driver in drivers
        loc_depot = loc[driver.start_point]
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
        legend=:outertopleft
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
        legend = :outertopleft
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
function plot_bus_stops(localisations::Vector{Bus_stop}, drivers::Vector{Person}, gare::Person)::Plots.Plot
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
        legend=:outertopleft
    )
    plot_terminus(localisations, drivers, gare, pl)
    plot!(title = "Carte des arrets de bus")
    return pl
end

function add_bus_route_to_plot!(bus::Bus, localisations::Vector{Bus_stop}, pl::Plots.Plot, index::Int = 0)
    latitude_list = []
    longitude_list = []
    for i in 1:length(bus.stops)
        bus_stop = localisations[bus.stops[i]]
        push!(latitude_list, bus_stop.latitude)
        push!(longitude_list, bus_stop.longitude)
    end
    if index == 0
        label = "bus"
    else
        label = "bus n°" * string(index)
    end
    plot!(
        pl, latitude_list, longitude_list,
        linewidth = 1,
        label = label,
        legend =:outertopleft,
    )
end

function add_bus_route_to_plot!(bus::Bus, localisations::Vector{Bus_stop}, pl::Plots.Plot, color,index::Int = 0)
    latitude_list = []
    longitude_list = []
    for i in 1:length(bus.stops)
        bus_stop = localisations[bus.stops[i]]
        push!(latitude_list, bus_stop.latitude)
        push!(longitude_list, bus_stop.longitude)
    end
    if index == 0
        label = "bus"
    else
        label = "bus n°" * string(index)
    end
    plot!(
        pl, latitude_list, longitude_list,
        linewidth = 1,
        label = label,
        legend = false,#:outertopleft,
        color=color,
    )
end

function plot_bus_routes(buses::Vector{Bus},localisations::Vector{Bus_stop}, pl::Plots.Plot)
    for (index, bus) in enumerate(buses)
        add_bus_route_to_plot!(bus, localisations, pl, index)
    end
    plot!(title = "Carte des bus")
    return pl
end

function plot_bus_routes_copy(buses::Vector{Bus},localisations::Vector{Bus_stop}, pl::Plots.Plot)
    pl_copy = deepcopy(pl)
    for (index, bus) in enumerate(buses)
        add_bus_route_to_plot!(bus, localisations, pl_copy, index)
    end
    plot!(title = "Carte des bus")
    return pl_copy
end



function plot_points_bus_routes_copy(depots, gare, clients_refuses, solution, buses::Vector{Bus},localisations::Vector{Bus_stop})
     pl_new = plot_terminus(localisations, depots, gare)
     for (index, cluster) in enumerate(solution.clusters)
         color = colors[index]
         scatter_cluster_to_plot!(cluster, localisations, pl_new, color, index)
     end
     for (index, bus) in enumerate(buses)
         color = colors[index]
         add_bus_route_to_plot!(bus, localisations, pl_new, color, index)
     end
     latitude_list = []
     longitude_list = []
     for (index, person) in enumerate(clients_refuses)
         push!(latitude_list,  localisations[person.start_point].latitude)
         push!(longitude_list,  localisations[person.start_point].longitude)
     end
     if length(clients_refuses) != 0
         scatter!(
             pl_new, latitude_list, longitude_list,
             marker = (:circle, 3, 0.7, "black"),
             label = "clients refusés",
             legend=false#:outertopleft
         )
     end
     plot!(title = "Carte des clusters et des bus")
     return pl_new
 end
