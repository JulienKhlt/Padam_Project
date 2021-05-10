include("Cluster.jl")

function creation_cluster_with_metric(people, gare, depots, map, metric, length_max, check=false)
   all_people = people[:]
   clusters = []
   for i in 1:length(depots)
      push!(clusters, Cluster([], gare, depots[i], 0))
   end

   sol = Solution(clusters, length_max, map, people)
   while length(points_left(all_people)) != 0
      best_dist = 1e6
      best_clu = 0
      best_point = 0
      for p in points_left(all_people)
         size = length(nbre_people(p, all_people))
         cluster, dist = best_cluster(p, sol, size, metric, check)
         if dist < best_dist
            best_dist = dist
            best_clu = cluster
            best_point = p
         end
      end
      size = length(nbre_people(best_point, all_people))
      add_point!(best_point, sol.clusters[best_clu], size)
      all_people = remove_people(all_people, best_point)
   end
   return sol
end

function creation_cluster(people, gare, depots, map, length_max, check = true)
   all_people = people[:]
   clusters = []
   for i in 1:length(depots)
      person = closest_pers(depots[i].start_point, map, all_people)
      push!(clusters, Cluster([person.start_point], gare, depots[i], 0))
      update!(clusters[i], all_people)
      all_people = remove_people(all_people, person.start_point)
   end

   sol = Solution(clusters, length_max, map, people)

   for p in points_left(all_people)
      size = length(nbre_people(p, all_people))
      add_point!(p, sol.clusters[best_cluster(p, sol, size, dist_clo, check)[1]], size)
   end
   return sol
end

function creation_cluster_betterbutlonger(people, gare, depots, map, length_max)
   clusters = []
   for i in 1:length(depots)
      push!(clusters, Cluster([], gare, depots[i], 0))
   end

   sol = Solution(clusters, length_max, map, people)

   for p in points_left(people)
      size = length(nbre_people(p, people))
      add_point!(p, sol.clusters[even_better_cluster(p, people, sol)], size)
   end
   return sol
end

function remove!(a, item)
   deleteat!(a, findall(x->x==item, a))
end

function get_nearby_solutions(buses, metric, people, gare, depots, map, length_max, marge_frontiere)
   """
   INPUT : buses = liste de bus (type Bus) qui forment une solution
            marge_frontiere = fraction qui définit l'épaisseur de la frontière
            metric = moyen de calculer la distance d'un point à un cluster
            map
            people
            length_max
   OUTPUT : new_sol = liste contenant toutes les solutions (de type liste de Bus) voisines de l'input
   """
   sol_buses = copy(buses) # liste de bus de type Bus
   new_sol = [] # liste contenant des listes de Bus
   for i in 1:length(sol_buses) # pour chaque bus de la solution
      current_bus = sol_buses[i]
      current_points = current_bus.stops[2:end-1]
      frontier_stops = [] # liste des points du cluster qui sont en gros à la frontière
      center_stop = argmin([1/length(current_points) * sum([map[m, n] for m in current_points]) for n in current_points])
      furthest_stop = argmax([map[k, center_stop] for k in current_points])
      dist_center = marge_frontiere * map[furthest_stop, center_stop]
      for j in current_points
         if map[j, center_stop] > dist_center
            push!(frontier_stops, j)
         end
      end

      for p in frontier_stops
         nearby_sol = copy(sol_buses) # liste de bus de type Bus
         j = closest_bus(p, buses, i, metric, gare, depots, map)
         if length(nearby_sol[j].people) < length_max
            add_point_bus!(nearby_sol[j], p, people)
            remove_point_bus!(nearby_sol[i], p)
            rearrangement_2opt(nearby_sol[j], map)
            check_bus = admissible_bus(nearby_sol[j], map, length_max)
            if check_bus
               push!(new_sol, nearby_sol)
            end
         end
      end

   end
   return new_sol
end

function metaheuristique_tabou(s0, maxIter, maxTabuSize, metric, people, gare, depots, map, length_max, marge_frontiere)
   """
   INPUT : s0 = liste de bus qui fonctionne
           maxIter,
           maxTabuSize,
           marge_frontiere
           map
           people
           length_max
           metric
   OUTPUT : sBest = autre liste de bus meilleure (ou égale) à la première
   """
   sBest = s0
   bestCandidate = s0
   tabuList = []
   push!(tabuList, s0)
   k=0
   while (k<maxIter)
      sNeighborhood = get_nearby_solutions(bestCandidate, metric, people, gare, depots, map, length_max, marge_frontiere)
      if length(sNeighborhood)>0
         println("On a tenté ", length(sNeighborhood), " nouvelles solutions")
         bestCandidate = sNeighborhood[1]
         for sCandidate in sNeighborhood
            if !(sCandidate in tabuList)
               if sum([bus.time[end]-bus.time[2] for bus in sCandidate]) < sum([bus.time[end]-bus.time[2] for bus in bestCandidate])
                  bestCandidate = sCandidate
               end
            end
         end
         if sum([(bus.time[end]-bus.time[2]) for bus in bestCandidate]) < sum([(bus.time[end]-bus.time[2]) for bus in sBest])
            sBest = bestCandidate
         end
         push!(tabuList, bestCandidate)
         if (length(tabuList) > maxTabuSize)
            deleteat!(tabuList, 1)
         end
         k+=1
      else
         k=maxIter
      end
   end
   return sBest
end


# Fonctions qui créent des clusters avec la méthode de Louise:

function remove!(a, item)
   deleteat!(a, findall(x->x==item, a))
end

function cluster_by_warehouse(warehouses, rep_warehouses, stops, map)
   """
   INPUTS : warehouses is a list of the warehouses
            rep_warehouses is a list that gives the repartition of the buses in the warehouses,
               i.e the number of buses per warehouse
           stops is a list that gives the id of the buses stops
   OUTPUT : all_clusters : a list of clusters
               warning : this function returns as many clusters as warehouses, not buses !!
   """
   nb_warehouses = length(warehouses)
   nb_stops = length(stops)
   nb_buses = 0
   for i in 1:nb_warehouses
       nb_buses += rep_warehouses[i]
   end
   nb_stops_per_warehouse = [] # donne le nombre d'arrêts où aller pour chaque dépôt
   stops_in_warehouses = 0
   for i in 1:nb_warehouses
       if i<nb_warehouses
           push!(nb_stops_per_warehouse, Int(nb_stops*rep_warehouses[i]/nb_buses))
           stops_in_warehouses += Int(nb_stops*rep_warehouses[i]/nb_buses)
       else
           push!(nb_stops_per_warehouse, nb_stops - stops_in_warehouses)
       end
   end

   stops_left = copy(stops)
   all_clusters = []
   for i in 1:nb_warehouses
      current_cluster = Cluster(Int[], gare, warehouses[i], 0)
       #points_in_current_cluster = []
       while current_cluster.len < nb_stops_per_warehouse[i]
       #while length(points_in_current_cluster) < nb_stops_per_warehouse[i]
           nearest_stop = argmin([map[warehouses[i].start_point, j.start_point] for j in stops_left])
           add_point!(stops_left[nearest_stop].start_point, current_cluster, 1)
           #push!(points_in_current_cluster, stops_left[nearest_stop])
           remove!(stops_left, stops_left[nearest_stop])
       end
       push!(all_clusters, current_cluster)
   end
   return all_clusters
end

function creation_clusters_by_zones(people, gare, depots, map, length_max)
   """
   INPUT / OUTPUT : cf fonction creation_cluster
   warehouses is a list that gives the id of the warehouses
   rep_warehouses is a list that gives the repartition of the buses in the warehouses,
      i.e the number of buses per warehouse
   """
   # il faut définir rep_warehouses et warehouses selon comment est définit depots
   warehouses=[]
   rep_warehouses = []

   for d in depots
      if !(d in warehouses)
         push!(warehouses, d)
         push!(rep_warehouses, 1)
      else
         index = findall(x->x==d, warehouses)
         rep_warehouses[index] += 1
      end
   end
   clusters_by_warehouses = cluster_by_warehouse(warehouses, rep_warehouses, people, map)
   if length(clusters_by_warhouses)!=length(warehouses)
      println("ERREUR : IL N'Y A PAS AUTANT DE ZONES QUE DE DEPOTS")
   end

   global_solution = Solution(Clusters[], length_max, map, people)
   for index_area in 1:length(clusters_by_warehouses)
      area = clusters_by_warehouses[index_area]
      if rep_warehouses[index_area] > 1 # s'il y a plusieurs bus à ce dépôt
         people_area = area.points
         depots_area = [area.depot for i in 1:length(rep_warehouses[index_area])]
         solution = creation_cluster(people_area, gare, depots_area, map, length_max, true)
         push!(global_solution.clusters, solution.clusters)
      else
         if warehouses[index_area] != area.depot
            println("ERREUR DE LIEN ENTRE LES DEPOTS")
         end
         push!(global_solution.clusters, area)
      end

   end
   return global_solution
end
