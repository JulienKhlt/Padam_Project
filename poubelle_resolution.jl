

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
