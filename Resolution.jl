include("Cluster.jl")

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
      add_point!(p, sol.clusters[best_cluster(p, sol, size, check)], size)
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

function get_nearby_solutions(solution)
   """
   INPUT : solution = Solution de clusters qui fonctionne
            map
            people
            length_max
   OUTPUT : new_sol = liste contenant toutes les solutions (de type Solution) voisines de l'input
   """
   sol_clusters = copy(solution.clusters) # liste de clusters de type Cluster
   new_sol = [] # liste contenant des types Solution
   for i in 1:length(sol_clusters)
      current_cluster = sol_clusters[i]
      current_points = current_cluster.points
      frontier_stops = []
      center_stop = argmin([1/length(current_points) * sum([solution.map[m, n] for m in 1:length(current_points)]) for n in 1:length(current_points)])
      furthest_stop = argmax([solution.map[k, center_stop] for k in 1:length(current_points)])
      dist_center = 7/10 * solution.map[furthest_stop, center_stop]
      for j in current_points
         if solution.map[j, center_stop] > dist_center
            push!(frontier_stops, j)
         end
      end

      for p in frontier_stops
         nearby_sol = copy(sol_clusters) # liste de clusters de type Cluster
         if closest(p, solution)==i
            j = closest(p, solution, true)[2]
            push!(nearby_sol[j].points, p)
         else
            j = closest(p, solution)
            push!(nearby_sol[j].points, p)
         end
         if !check_cluster(nearby_sol[j], solution.map, solution.all_people, solution.length_max)
            pop!(nearby_sol.point) # on annule ce qu'on a fait
         else
            remove!(nearby_sol[i].points, p)
            push!(new_sol, Solution(nearby_sol, solution.length_max, solution.map, solution.all_people))
         end
      end

   end
   return new_sol
end

function metaheuristique_tabou(s0, maxIter, maxTabuSize)
   """
   INPUT : s0 = ensemble (liste) de clusters qui fonctionne
           map
           people
           length_max
   OUTPUT : sBest = autre ensemble de clusters meilleur (ou égal) au premier
   """
   sBest = s0
   bestCandidate = s0
   tabuList = []
   push!(tabuList, s0)
   k=0
   while (k<maxIter)
      sNeighborhood = get_nearby_solutions(bestCandidate)
      bestCandidate = sNeighborhood[0]
      for sCandidate in sNeighborhood
         if !(sCandidate in tabuList) && compute_solution(sCandidate) > compute_solution(bestCandidate)
               bestCandidate = sCandidate
         end
      end
      if compute_solution(bestCandidate) > compute_solution(sBest)
         sBest = bestCandidate
      end
      push!(tabuList, bestCandidate)
      if (lenght(tabuList) > maxTabuSize)
         deleteat!(tabuList, 1)
      end
      k+=1
   end
   return sBest
end


function close_mean_arg(i, means, map, index_people)
   """
   INPUT : i = indice du client
           means = tableau des moyennes sur chaque cluster
           map
           index_people = tableau des start_point de tous les clients
   OUTPUT : j = indice du cluster dont la moyenne est la plus proche du client i
   """
   j = 1
   mini = 100000
   for k in 1:length(means)
      if abs(means[k] - map[train_index,index_people[i]]) < mini
         mini = abs(means[k] - map[train_index,index_people[i]])
         j = k
      end
   end
   return j
end

function different_sol(sol1,sol2)
   """
   INPUT : sol1, sol2 = Solutions
   OUTPUT : true ssi les clusters sont les mêmes
   """
   i = 1
   j = 1
   boo = length(sol1.clusters) == length(sol2.clusters)
   while i<length(sol1.clusters) && boo
      j = 1
      boo = boo && length(sol1.clusters[i].points)==length(sol2.clusters[i].points)
      while j<length(sol1.clusters[i].points) && boo
         boo = boo && sol1.clusters[i].points[j]==sol2.clusters[i].points[j]
         j+=1
      end
      i+=1
   end
   return !boo
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

function closest_depot(map, list, depots)
   """
   INPUT : map
           list = vecteur des start_point des clients appartenant à un même cluster
           depots = vecteur avec tous les depots (type Person)
   OUTPUT : dépôt le plus proche du cluster (type Person)
   """
    index = argmin([dist_cluster_depot(map,list,k) for k in depots])
    return depots[index]
end


function k_means(people, len, map, train_index, depots)
   """
   INPUT : people = clients (type Person)
           map
           gare = gare (type Person)
           depots = vector de dépôts (type Person)
           len = capacité maximale d'un bus
   OUTPUT : calcul d'une Solution (ATTENTION : non admissible...)par k_means
   """
   all_people = people[:]
   sol = Solution([],len,map, all_people)
   means = []
   for i in 1:Int(floor(length(people)/len))
      list = [people[k].start_point for k in len*(i-1)+1:len*i]
      cluster = Cluster(list, train_index, closest_depot(map, list, depots), length(list))
      add_cluster!(cluster, sol)
      push!(means, 1/length(cluster.points)*sum(map[train_index, i] for i in cluster.points))
   end
   boo = true
   while boo
      list_j = []
      for i in 1:length(people)
         j = close_mean_arg(i, means, map, [p.start_point for p in people])
         push!(list_j,j)
      end
      new_sol = Solution([],len,map, all_people)
      new_means = []
      for j in 1:length(sol.clusters)
         list = [people[i].start_point for i in 1:length(people) if list_j[i] == j]
         cluster = Cluster(list, train_index, closest_depot(map, list, depots), length(list))
         if cluster.points != []
            add_cluster!(cluster, new_sol)
            push!(new_means, 1/length(cluster.points)*sum(map[train_index, i] for i in cluster.points))
         end
      end
      boo = different_sol(sol, new_sol)
      sol = new_sol
      means = new_means
   end
   return sol
end

function ward_dist(S1,S2, map, train_index)
   """
   INPUT : S1, S2 = Clusters
           map
           train_index = start_point de la gare
   OUTPUT : Approximation de la distance de ward entre les clusters S1 et S2 (pas distance exacte : la moyenne n'appartient pas au maillage)
   """
   S1_points = S1.points
   S2_points = S2.points
   n1 = length(S1_points)
   n2 = length(S2_points)
   mean_S1 =  1/n1*sum(map[train_index, i] for i in S1_points)
   mean_S2 =  1/n2*sum(map[train_index, i] for i in S2_points)
   closest_to_mean1 = argmin([abs(map[train_index,S1_points[i]] - mean_S1) for i in 1:n1])
   closest_to_mean2 = argmin([abs(map[train_index,S2_points[i]] - mean_S2) for i in 1:n2])
   return n1*n2/(n1+n2)*map[S1_points[closest_to_mean1], S2_points[closest_to_mean2]]
end

function min_ward_dist(sol, gare)
   """
   INPUT : sol = Solution
   OUTPUT : liste triée par ordre croissant des distances de Ward entre tous les couples i,j de clusters différents
   """
   n = length(sol.clusters)
   L = [[ward_dist(sol.clusters[convert(Int, k%n)+1], sol.clusters[convert(Int, floor(k/n))+1], sol.map, gare.start_point), convert(Int, k%n)+1, convert(Int, floor(k/n))+1] for k in 1:n*n-1 if convert(Int, k%n)<convert(Int,floor(k/n))]
   sort!(L, by=x->x[1])
end

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
   return Cluster(list, c1.gare, closest_depot(map, list, depots), length(list))
end

function hierarchical_clustering(people, map, gare, depots, length_max)
   """
   INPUT : people = clients (type Person)
           map
           gare = gare (type Person)
           depots = vector de dépôts (type Person)
           length_max = capacité maximale d'un bus
   OUTPUT : calcul d'une Solution par clustering hierarchique (fusion de clusters avec distance de ward)
   """
   train_index = gare.start_point
   all_people = people[:]
   #on part d'une solution de départ où le cluster i est composé du seul client i
   sol = Solution([],length_max,map, all_people)
   for k in 1:length(people)
      list = [people[k].start_point]
      cluster = Cluster(list, gare, closest_depot(map,list, depots), 1)
      add_cluster!(cluster, sol)
   end

   boo = true
   while boo #tant qu'on peut fusionner des clusters de façon à ce qu'ils restent admissibles pour le TSPTW
      i = 1
      admissible = false
      ward_distances = min_ward_dist(sol, gare)
      while !admissible && i <= floor(length(sol.clusters)*(length(sol.clusters)-1)/2)
         #on prend la première paire de clusters telle que leur fusion reste admissible (minimisation de la distance de ward)
         i_min= convert(Int, ward_distances[i][2])
         j_min=  convert(Int,ward_distances[i][3])
         aggregate = concat(sol.clusters[i_min], sol.clusters[j_min], map, depots)
         admissible = check_cluster(aggregate, map, all_people, length_max)
         if admissible
            #dans ce cas, on fusionne les clusters
            remove_cluster!(max(i_min, j_min), sol)
            remove_cluster!(min(i_min,j_min), sol)
            add_cluster!(aggregate,sol)
         end
         i+=1
      end
      if !admissible
         boo = false
      end
   end
   return sol
end


# Fonctions qui créent des clusters avec la méthode de Louise:

function remove!(a, item)
   deleteat!(a, findall(x->x==item, a))
end

function cluster_by_warehouse(warehouses, rep_warehouses, stops)
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
   nb_stops_per_warehouse = []
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
       current_cluster = []
       while length(current_cluster) < nb_stops_per_warehouse[i]
           nearest_stop = argmin([map[warehouses[i].start_point, j] for j in stops_left])
           push!(current_cluster, stops_left[nearest_stop])
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
   clusters_by_warehouses = cluster_by_warehouse(warehouses, rep_warehouses, people)
   clusters = []
   global_solution = Solution(clusters, length_max, map, people)
   for area in clusters_by_warehouses
      solution = creation_cluster(people, gare, depots, map, length_max)
      push!(global_solution.clusters, solution.clusters)
   end
   return global_solution
end