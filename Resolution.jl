include("Cluster.jl")

function insertion_heuristic()
   solution = creation_cluster() 
end

function creation_cluster(people, map, id_depts)
   clusters = []
   for i in 1:length(id_depts)
      push!(clusters, Cluster([people[1].start_point, id_depts[i], ]))
end

function metaheuristique()    
end