using SparseArrays
using LightGraphs

include("Person.jl")
include("Bus.jl")
include("TSPTW.jl")
include("mTSPTW.jl")
include("Parsers.jl")
capa = 15

function parser_drivers(driver_file_name)
    data_driver = open(driver_file_name) do file
        readlines(file)
    end
    nb_driver =  length(data_driver)-1
    driver_tab = []
    train_index = parse(Int,split(data_driver[2], ";")[3])
    for i in 1:nb_driver
        driver = split(data_driver[1+i], ";")
        start_point = parse(Int, driver[2])
        end_point = parse(Int, driver[3])
        start_time = convert_time_str_int(driver[4])
        end_time = convert_time_str_int(driver[5])
        push!(driver_tab,[start_point, start_time, end_time])
    end
    return driver_tab, train_index
end


function depot_tour_groups(driver_file_name)
    drivers, train_index = parser_drivers(driver_file_name)
    n = length(drivers)
    groups = []
    for i in 1:n
        index, start_time, end_time = drivers[i]
        j = 1
        while j <= length(groups)
            if length(groups)==0
                push!(groups,[drivers[i],1])
                break
            else
                if groups[j][1][2] == start_time && groups[j][1][3] == end_time
                    groups[j][2] += 1
                    break
                else
                    j+=1
                end
            end
        end
        if j >length(groups)
            push!(groups,[drivers[i],1])
        end
    end
    return groups, train_index
end

function furthest(train_index, map, uncluster,n)
    index_min = 0
    mini = 100000
    for i in 1:n
        if uncluster[i] && map[train_index, i] < mini
            index_min = i
            mini = map[train_index, i]
        end
    end
    return index_min
end

function geom_center(qi,map,uncluster,n)
    #pick the closest client to the geometricacl center of the cluster qi among the unclustered vertices
    v = 0
    mini = 100000
    for i in 1:n
        if uncluster[i] && 1/length(qi)*sum(map[i,qi[j]] for j in length(qi)) < mini
            v = i
            mini = 1/length(qi)*sum(map[i,qi[j]] for j in length(qi))
        end
    end
    return v
end

function clustering_loop(map, train_index, start_time, end_time, m,n)
    #A_hybrid_column_generation_and_clustering_approach
    i = 0
    #W = capa
    W = ceil(n/m)
    uncluster = [true for i in 1:n]
    uncluster[train_index] = false
    q = []
    print(count(uncluster))
    while count(uncluster)!=0
        v = furthest(train_index, map, uncluster,n)
        uncluster[v] = false
        qi = [v]
        li = W - 1
        while li > 0 && count(uncluster)!=0
            v = geom_center(qi, map, uncluster,n)
            uncluster[v] = false
            push!(qi, v)
            li -= 1
        end
        push!(q,qi)
    end
    return q
end


function tours(driver_file_name, map, n)
    tab, train_index = depot_tour_groups(driver_file_name)
    clusters_tot = []
    for i in 1:length(tab)
        if tab[i][1][1] == train_index
            clusters = clustering_loop(map, train_index, tab[i][1][2], tab[i][1][3], tab[i][2], n)
            #clusters[i] = ensemble des clients dans le cluster i ie dessservis par le bus i
            push!(clusters_tot, clusters)
        end
    end
    return clusters_tot
end

map_sym,n = parser_real_file_symetry("Data/mTSP_matrix.csv")
clusters = tours("Data/driver_shifts.csv",map_sym,n)
print(clusters)
