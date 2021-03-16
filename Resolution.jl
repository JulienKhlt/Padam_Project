include("Cluster.jl")

function insertion_heuristic()
   solution = creation_cluster()
end

function creation_cluster(people, gare, depots, map)
   clusters = []
   for i in 1:length(depots)
      person = closest(depots[i].first_point, people)
      push!(clusters, Cluster([gare.start_point, depots[i].first_point, pers.first_point]))
end

function creation_cluster(people, map)

end

function nearby_solutions(solution)
   # solution is a list of clusters
   for i in 1:length(solution)
      current_cluster = solution[i]
      frontier_stops = []
      nearby_clusters = []
      center_stop = argmin([1/length(current_cluster) * sum([map[m, n] for m in 1:length(current_cluster)]) for n in 1:length(current_cluster)])
      furthest_stop = argmax([map[k, center_stop] for k in 1:length(current_cluster)])
      dist_center = 7/10*map[furthest_stop, center_stop]
      for j in 1:length(current_cluster)
         if map[j, center_stop] > dist_center
            push!(frontier_stops, j)
         end
         if closest(j, solution)==i
            if !(closest(j, solution, list=true)[2] in nearby_clusters)
               push!(nearby_clusters, closest(j, solution, list=true)[2])
            end
         else
            if !(closest(j, solution) in nearby_clusters)
               push!(nearby_clusters, closest(j, solution))
            end
         end
      end
   end
end

function metaheuristique_tabou(solution)
end


function close_mean_arg(i, means, map, people)
   j = 1
   mini = 100000
   for k in 1:length(means)
      if abs(means[k] - map[train_index,people[i].start_point]) < mini
         mini = abs(means[k] - map[train_index,people[i].start_point])
         j = k
      end
   end
   return j
end

function different_sol(sol1,sol2)
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

function k_means(people, len, map, train_index)
   sol = Solution([],len,map)
   means = []
   for i in 1:Int(floor(length(people)/len))
      cluster = Cluster([people[k].start_point for k in len*(i-1)+1:len*i])
      add_cluster!(cluster, sol)
      push!(means, 1/length(cluster.points)*sum(map[train_index, i] for i in cluster.points))
   end
   boo = true
   while boo
      list_j = []
      for i in 1:length(people)
         j = close_mean_arg(i, means, map, people)
         push!(list_j,j)
      end
      new_sol = Solution([],len,map)
      new_means = []
      for j in 1:length(sol.clusters)
         cluster = Cluster([people[i].start_point for i in 1:length(people) if list_j[i] == j])
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
