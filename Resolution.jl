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

function metaheuristique()    
end