using SparseArrays
using LightGraphs

include("../Person.jl")
include("../Bus.jl")
# include("TSPTW.jl")
# include("mTSPTW.jl")
include("../Parsers.jl")
include("../Cluster.jl")
include("../Resolution.jl")

mappy = parser("Data/large.csv")
people, gare, depots = build_people("Data/people_large.csv")
sol = creation_cluster(people, gare, depots, mappy, 20)
maxIter = 3
maxTabuSize = 3
margeFrontiere = 9/10
autre_sol = metaheuristique_tabou(sol, maxIter, maxTabuSize, margeFrontiere)
println("les deux solutions sont égales", sum([compute_total_time(b, sol.map) for b in compute_solution(sol)]) == sum([compute_total_time(b, autre_sol.map) for b in compute_solution(autre_sol)]))

"""message d'erreur : 

ERROR: LoadError: ArgumentError: reducing over an empty collection is not allowed
Stacktrace:
 [1] _empty_reduce_error() at .\reduce.jl:212
 [2] reduce_empty(::Function, ::Type) at .\reduce.jl:222
 [3] mapreduce_empty(::typeof(identity), ::Function, ::Type) at .\reduce.jl:247
 [4] _mapreduce(::typeof(identity), ::typeof(min), ::IndexLinear, ::Array{Float64,1}) at .\reduce.jl:301
 [5] _mapreduce_dim at .\reducedim.jl:312 [inlined]
 [6] #mapreduce#584 at .\reducedim.jl:307 [inlined]
 [7] mapreduce at .\reducedim.jl:307 [inlined]
 [8] _minimum at .\reducedim.jl:657 [inlined]
 [9] _minimum at .\reducedim.jl:656 [inlined]
 [10] #minimum#593 at .\reducedim.jl:652 [inlined]
 [11] minimum at .\reducedim.jl:652 [inlined]
 [12] dist_clo(::Int64, ::SparseMatrixCSC{Float64,Int64}, ::Cluster) at d:\Louise\Cours\2A_Ponts\Projet_departement\Padam_Project\Cluster.jl:53   
 [13] (::var"#196#198"{Int64,Solution})(::Cluster) at .\none:0
 [14] collect_to!(::Array{Float64,1}, ::Base.Generator{Array{Cluster,1},var"#196#198"{Int64,Solution}}, ::Int64, ::Int64) at .\generator.jl:47
 [15] collect_to_with_first!(::Array{Float64,1}, ::Float64, ::Base.Generator{Array{Cluster,1},var"#196#198"{Int64,Solution}}, ::Int64) at .\array.jl:646
 [16] collect(::Base.Generator{Array{Cluster,1},var"#196#198"{Int64,Solution}}) at .\array.jl:627
 [17] closest(::Int64, ::Solution, ::Bool) at d:\Louise\Cours\2A_Ponts\Projet_departement\Padam_Project\Cluster.jl:73
 [18] closest(::Int64, ::Solution) at d:\Louise\Cours\2A_Ponts\Projet_departement\Padam_Project\Cluster.jl:67
 [19] get_nearby_solutions(::Solution, ::Float64) at d:\Louise\Cours\2A_Ponts\Projet_departement\Padam_Project\Resolution.jl:55
 [20] metaheuristique_tabou(::Solution, ::Int64, ::Int64, ::Float64) at d:\Louise\Cours\2A_Ponts\Projet_departement\Padam_Project\Resolution.jl:88
 [21] top-level scope at d:\Louise\Cours\2A_Ponts\Projet_departement\Padam_Project\test_meta.jl:18
in expression starting at d:\Louise\Cours\2A_Ponts\Projet_departement\Padam_Project\test_meta.jl:18"""