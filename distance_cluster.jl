import Base.+, Base.*

*(a::Float64, d::Function) = (sol) -> a*min_dist(sol,d)
+(c::Function, d::Function) = (sol) -> min_dist(sol,d)+min_dist(sol,c)


function ward_dist(S1,S2, map)
   """
   INPUT : S1, S2 = Clusters
           map
   OUTPUT : n1*n2/(n1+n2)*distance entre les moyennes des clusters
   """
   train_index = S1.gare.start_point
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


function dist_max(S1,S2, map)
   """
   INPUT : S1, S2 = Clusters
           map
   OUTPUT : distance entre les points les plus éloignés des clusters
   """
   S1_points = S1.points
   S2_points = S2.points
   distance_max = max([map[i,j] for i in S1_points for j in S2_points])
   return distance_max
end

function dist_min(S1,S2, map)
   """
   INPUT : S1, S2 = Clusters
           map
   OUTPUT : distance entre les points les plus éloignés des clusters
   """
   S1_points = S1.points
   S2_points = S2.points
   distance_min = min([map[i,j] for i in S1_points for j in S2_points])
   return distance_min
end

function min_dist(sol, dist)
   """
   INPUT : sol = Solution
            dist = function (C1,C2,map)
   OUTPUT : liste triée par ordre croissant des distances de Ward entre tous les couples i,j de clusters différents
   """
   n = length(sol.clusters)
   L = [[dist(sol.clusters[convert(Int, k%n)+1], sol.clusters[convert(Int, floor(k/n))+1], sol.map), convert(Int, k%n)+1, convert(Int, floor(k/n))+1] for k in 1:n*n-1 if convert(Int, k%n)<convert(Int,floor(k/n))]
   sort!(L, by=x->x[1])
end



function dist_opt(map, C1, C2)
    bus1 = Bus(id=1, people=[], stops=vcat([C1.depot.start_point], C1.points, [C1.gare.start_point]), time=[])
    bus2 = Bus(id=2, people=[], stops=vcat([C2.depot.start_point], C2.points, [C2.gare.start_point]), time=[])
    rearrangement_2opt(bus1, map)
    rearrangement_2opt(bus2, map)
    time = compute_total_time(bus1, map)+compute_total_time(bus2, map)
    bus = Bus(id=1, people=[], stops=vcat([C1.depot.start_point], C1.points, C2.points, C1.gare.start_point]), time=[])
    rearrangement_2opt(bus, map)
    new_time = compute_total_time(bus, map)
    return new_time-time
end
