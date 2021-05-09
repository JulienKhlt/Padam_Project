include("distance.jl")
include("distance_cluster.jl")
include("Algo_en_ligne.jl")
include("Parsers.jl")
include("Person.jl")
include("Bus.jl")

DIST = [dist_clo, dist_mean, dist_src_dst]
DIST_CLUSTER = [ward_dist, sum_dist_point_mean, dist_max, dist_min, angle_min, angle_max]
file_dir = "/home/julien/Padam_Project/Data/Instance Padam/"

function find_best(x)
    sol, tot = algo_pseudo_en_ligne(file_dir, x[1]*dist_src_dst+x[2]*dist_clo+x[3]*dist_mean,  angle_max, true, false)
    return tot
end

function optimise_esc(f, pas)
    best = 0
    vect = [0, 0, 0]
    for i in 0:pas:1
        for j in 0:pas:1
            for k in 0:pas:1
                main = f([i, j, k])
                if best < main
                    best = main
                    vect = [i, j, k]
                end 
            end
        end
    end
    return best, vect
end

println(optimise_esc(find_best, 0.3))