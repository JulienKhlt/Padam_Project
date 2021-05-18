import Base.+, Base.*
include("distance.jl")


*(a::Float64, d::Function) = (C1,C2, map) -> a*d(C1,C2, map)
+(c::Function, d::Function) = (C1,C2,map) -> c(C1,C2, map)+d(C1,C2, map)


function ward_dist(S1,S2, map)
   """
   INPUT : S1, S2 = Clusters
           map
   OUTPUT : distance entre les moyennes des clusters
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


function sum_dist_point_mean(S1, S2 ,map)
   """
   INPUT : S1, S2 = Clusters
           map
   OUTPUT : distance minimale entre les points du premier cluster et la moyenne de l'autre
   """
   return minimum(dist_mean(point, map, S2) for point in S1.points)
end

function dist_max(S1,S2, map)
   """
   INPUT : S1, S2 = Clusters
           map
   OUTPUT :  distance entre les points les plus loins des clusters
   """
   S1_points = S1.points
   S2_points = S2.points
   distance_max = maximum([map[i,j] for i in S1_points for j in S2_points])
   return distance_max
end

function angle_min(S1,S2, map)
   """
   INPUT : S1, S2 = Clusters
           map
   OUTPUT : angle max (cf Al Kashi) entre les points
   """
   S1_points = S1.points
   S2_points = S2.points
   angle_min =  minimum([acos(max(-1,min(1,(map[S1.gare.start_point,j]^2+map[i,S1.gare.start_point]^2 -map[i,j]^2)/(2*map[S1.gare.start_point,j]*map[i,S1.gare.start_point])))) for i in S1_points for j in S2_points])
   return angle_min
end

function angle_max(S1,S2, map)
   """
   INPUT : S1, S2 = Clusters
           map
   OUTPUT : angle max (cf Al Kashi) entre les points
   """
   S1_points = S1.points
   S2_points = S2.points
   angle_min =  maximum([acos(max(-1,min(1,(map[S1.gare.start_point,j]^2+map[i,S1.gare.start_point]^2 -map[i,j]^2)/(2*map[S1.gare.start_point,j]*map[i,S1.gare.start_point])))) for i in S1_points for j in S2_points])
   return angle_min
end

function min_dist_tot(sol, dist)
   """
   INPUT : sol = Solution
            dist = function (C1,C2,map)
   OUTPUT : liste triée par ordre croissant des distances (dist) entre tous les couples i,j de clusters différents
   """
   """
   n = length(sol.clusters)
   L = [[dist(sol.clusters[convert(Int, k%n)+1], sol.clusters[convert(Int, floor(k/n))+1], sol.map), convert(Int, k%n)+1, convert(Int, floor(k/n))+1] for k in 1:n*n-1 if convert(Int, k%n)<convert(Int,floor(k/n))]
   return sort!(L, by=x->x[1])"""
   n = length(sol.clusters)
   dist_list = [dist(sol.clusters[convert(Int, k%n)+1], sol.clusters[convert(Int, floor(k/n))+1], sol.map) for k in 1:n*n-1 if convert(Int, k%n)<convert(Int,floor(k/n))]
   correspondance_list = [[convert(Int, k%n)+1, convert(Int, floor(k/n))+1] for k in 1:n*n-1 if convert(Int, k%n)<convert(Int,floor(k/n))]
   return correspondance_list[argmin(dist_list)]
end
