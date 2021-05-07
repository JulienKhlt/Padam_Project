include("distance.jl")
include("Resolution.jl")
include("Parsers.jl")
include("Person.jl")
include("Bus.jl")

file_directory = "/home/julien/Padam_Project/Data/uniform"
client_file_name = joinpath(file_directory, "customer_requests.csv")
driver_file_name = joinpath(file_directory, "driver_shifts.csv")
map_file_name = joinpath(file_directory, "mTSP_matrix.csv")
gamma_file_name = joinpath(file_directory, "gammas.csv")
node_coordinates_file_name = joinpath(file_directory, "node_coordinates.csv")

people = build_people_real_file_only_client(client_file_name, driver_file_name, map_file_name, gamma_file_name, false)
depots, gare = build_drivers_and_gare(driver_file_name)
map, n = parser_real_file_symetry(map_file_name)

function find_best(x)
    sol = creation_cluster_with_metric(people, gare, depots, map, x[1]*dist_clo+x[2]*dist_mean+x[3]*dist_src_dst, 20)
    buses = compute_solution(sol)
    return sum(get_total_time.(buses))
end

function optimise_esc(f, pas)
    best = 10e10
    vect = [0, 0, 0]
    for i in 0:pas:1
        for j in 0:pas:1
            for k in 0:pas:1
                main = f([i, j, k])
                if best > main
                    best = main
                    vect = [i, j, k]
                end 
            end
        end
    end
    return best, vect
end

println(optimise_esc(find_best, 0.2))