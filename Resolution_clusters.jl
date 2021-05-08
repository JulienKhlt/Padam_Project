include("Cluster.jl")
include("distance_cluster.jl")

function concat(c1, c2, map, depots)
   """
   INPUT : c1, c2 = Clusters
           map
           depots = vecteur des dépôts (type Person)
   OUTPUT : Cluster où on a fusionné les clusters c1 et c2
   """
   list = []
   for i in c1.points
      push!(list, i)
   end
   for i in c2.points
      push!(list, i)
   end
   return Cluster(list, c1.gare, depots[1], length(list))
end

function dist_cluster_depot(map, list, depot)
   """
   INPUT : map
           list = vecteur des start_point des clients appartenant à un même cluster
           depot = un dépôt donné (type Person)
   OUTPUT : distance minimale entre le dépôt et le cluster (minimum des distances avec tous les points du cluster)
   """
   return minimum([map[depot.start_point, i] for i in list])
end

function closest_depot_list(map, list, depots)
   """
   INPUT : map
           list = vecteur des start_point des clients appartenant à un même cluster
           depots = vecteur avec tous les depots (type Person)
   OUTPUT : liste ordonnée des dépôts par distance au du cluster (type Person)
   """
    index = sort!([(dist_cluster_depot(map,list,k), k) for k in depots], by=x->x[1])
    depot_order = unique([index[i][2] for i in 1:length(index)])
    return depot_order
end

function buses_allowed(depots)
   """
   Input : liste des dépots
   Output : nombre de bus dans le i-eme dépôt, start_point du ieme depot
   """
   nb_bus_allowed = []
   index_corres = []
   for driver in depots
      if !(driver.start_point in index_corres)
         push!(index_corres, driver.start_point)
         push!(nb_bus_allowed, 0)
      end
   end
   for i in 1:length(index_corres)
      nb_bus_allowed[i]=sum([driver.start_point==index_corres[i] for driver in depots])
   end
   return nb_bus_allowed, index_corres
end

function hierarchical_clustering(people, map, gare, depots, length_max, nb_buses, metric)
   """
   INPUT : people = clients (type Person)
           map
           gare = gare (type Person)
           depots = vector de dépôts (type Person)
           length_max = capacité maximale d'un bus
           nb_buses = nombre de bus
           metric = distance utilisée pour le calcul des clusters
   OUTPUT : calcul d'une Solution par clustering hierarchique (fusion de clusters avec distance metric)
   """
   train_index = gare.start_point
   all_people = people[:]
   #on part d'une solution de départ où le cluster i est composé du seul client i
   sol = Solution([],length_max,map, all_people)
   for k in 1:length(people)
      list = [people[k].start_point]
      cluster = Cluster(list, gare, depots[1], 1)
      add_cluster!(cluster, sol)
   end
   boo = true
   while boo && length(sol.clusters) > nb_buses #tant qu'on peut fusionner des clusters de façon à ce qu'ils soient en nombre supérieur au nombre de bus
      i = 1
      admissible = false
      distances = min_dist_tot(sol, metric)
      while !admissible && i <= floor(length(sol.clusters)*(length(sol.clusters)-1)/2)
         #on prend la première paire de clusters telle que leur fusion reste admissible (minimisation de la distance de ward)
         i_min= convert(Int, distances[i][2])
         j_min=  convert(Int,distances[i][3])
         if sol.clusters[i_min].len+sol.clusters[j_min].len <= length_max
            #dans ce cas, on fusionne les clusters
            admissible = true
            aggregate = concat(sol.clusters[i_min], sol.clusters[j_min], map, depots)
            remove_cluster!(max(i_min, j_min), sol)
            remove_cluster!(min(i_min,j_min), sol)
            add_cluster!(aggregate,sol)
         else
            if sol.clusters[j_min].len != length_max && sol.clusters[i_min].len != length_max #dans ce cas on ajoute les points du cluster le plus petit dans le cluster le plus grand
               if sol.clusters[i_min].len > sol.clusters[j_min].len
                  table = sort!([(metric(sol.clusters[i_min],Cluster([j],gare, depots[1], 1), map), j) for j in sol.clusters[j_min].points], by=x->x[1])
                  new_len = length_max-sol.clusters[i_min].len
                  new_cluster = Cluster([table[i][2] for i in 1:new_len], gare, depots[1], new_len)
                  aggregate = concat(sol.clusters[i_min],new_cluster, map, depots)
                  admissible = true
                  difference = Cluster([table[i][2] for i in new_len+1:sol.clusters[j_min].len], gare, depots[1], sol.clusters[j_min].len - new_len)
                  remove_cluster!(max(i_min, j_min), sol)
                  remove_cluster!(min(i_min,j_min), sol)
                  add_cluster!(aggregate,sol)
                  add_cluster!(difference,sol)
               else #dans ce cas on ajoute les points du cluster le plus petit dans le cluster le plus grand
                  table = sort!([(metric(Cluster([i],gare, depots[1], 1), sol.clusters[j_min], map), i) for i in sol.clusters[i_min].points], by=x->x[1])
                  new_len = length_max-sol.clusters[j_min].len
                  new_cluster = Cluster([table[i][2] for i in 1:new_len], gare, depots[1], new_len)
                  aggregate = concat(sol.clusters[j_min],new_cluster, map, depots)
                  admissible = true
                  difference = Cluster([table[i][2] for i in new_len+1:sol.clusters[i_min].len], gare, depots[1], sol.clusters[i_min].len - new_len)
                  remove_cluster!(max(i_min, j_min), sol)
                  remove_cluster!(min(i_min,j_min), sol)
                  add_cluster!(aggregate,sol)
                  add_cluster!(difference,sol)
               end
            end
         end
         i+=1
      end
      if !admissible
         boo = false
      end
   end

   bus_list, index_class = buses_allowed(depots)
   list_max_dist = [maximum(map[gare.start_point, i] for i in j.points) for j in sol.clusters]
   cluster_far = sort!([(list_max_dist[j], j) for j in 1:length(sol.clusters)], by=x->-x[1])
   for i in 1:length(cluster_far)
      cluster =  sol.clusters[cluster_far[i][2]]
      depot_list = closest_depot_list(map,cluster.points, depots)
      boo = false
      k=1
      while k <= length(depot_list) && !boo
         depot = depot_list[k]
         for l in 1:length(index_class)
            if index_class[l]==depot.start_point && bus_list[l]>0
               cluster.depot = depot
               boo = true
               bus_list[l]-=1
            end
            k+=1
         end
      end
   end
   return sol
end
