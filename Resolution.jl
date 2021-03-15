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
