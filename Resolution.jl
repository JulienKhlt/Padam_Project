include("Cluster.jl")

function insertion_heuristic()
   solution = creation_cluster()
end

function creation_cluster(people, gare, depots, map, length_max)
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
      add_point!(p, sol.clusters[closest(p, sol)], length(nbre_people(p, all_people)))
   end
   return sol
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


function close_mean_arg(i, means, map, index_people)
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
   return minimum([map[depot, i] for i in list])
end

function closest_depot(map, list, depots)
    index = argmin([dist_cluster_depot(map,list,k.start_point) for k in depots])
    return depots[index]
end


function k_means(people, len, map, train_index, depots)
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
   n1 = length(S1)
   n2 = length(S2)
   mean_S1 =  1/n1*sum(map[train_index, i] for i in S1)
   mean_S2 =  1/n2*sum(map[train_index, i] for i in S2)
   closest_to_mean1 = argmin([abs(map[train_index,S1[i]] - mean_S1) for i in length(S1)])
   closest_to_mean2 = argmin([abs(map[train_index,S2[i]] - mean_S2) for i in length(S2)])
   return n1*n2/(n1+n2)*map[S1[closest_to_mean1], S2[closest_to_mean2]]
end

function min_ward_dist(s_list, map, train_index)
   n = length(s_list)
   L = [[ward_dist(s_list[convert(Int, k%n)+1].points, s_list[convert(Int, floor(k/n))+1].points, map, train_index), convert(Int, k%n)+1, convert(Int, floor(k/n))+1] for k in 1:n*n-1 if convert(Int, k%n)<convert(Int,floor(k/n))]
   sort!(L, by=x->x[1])
end

function concat(c1, c2, map, depots)
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
   train_index = gare.start_point
   all_people = people[:]
   sol = Solution([],length_max,map, all_people)
   for k in 1:length(people)
      list = [people[k].start_point]
      cluster = Cluster(list, gare, closest_depot(map,list, depots), 1)
      add_cluster!(cluster, sol)
   end
   boo = true
   while boo
      i = 1
      admissible = false
      while !admissible && i <= floor(length(sol.clusters)*(length(sol.clusters)-1)/2)
         i_min= convert(Int, min_ward_dist(sol.clusters, map, train_index)[i][2])
         j_min=  convert(Int, min_ward_dist(sol.clusters, map, train_index)[i][3])
         aggregate = concat(sol.clusters[i_min], sol.clusters[j_min], map, depots)
         admissible = check_cluster(aggregate, map, all_people, length_max)
         i+=1
      end
      if admissible
         remove_cluster!(i_min, sol)
         remove_cluster!(j_min, sol)
         add_cluster(aggregate,sol)
      else
         boo = false
      end
   end
   return sol
end
