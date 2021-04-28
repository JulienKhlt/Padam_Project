import Base.+, Base.*

*(a::Float64, d::Function) = (point, map, Cluster) -> a*d(point, map, Cluster)
+(c::Function, d::Function) = (point, map, Cluster) -> c(point, map, Cluster)+d(point, map, Cluster)

function dist_clo(point, map, Cluster)
    """Function that return the distance between a point and the closest point from a cluster"""
    return minimum(vcat([map[point, i] for i in Cluster.points], [map[point, Cluster.gare.start_point], map[point, Cluster.depot.start_point]]))
end

function dist_mean(point, map, Cluster)
    """Function that return the distance between a point and the average point from a cluster"""
    return sum(vcat([map[point, i] for i in Cluster.points], [map[point, Cluster.gare.start_point], map[point, Cluster.depot.start_point]]))/(length(Cluster.points) + 2)
end

function dist_src_dst(point, map, Cluster)
    """Function that return the distance between a point and the average point from a cluster"""
    return sum([map[point, Cluster.gare.start_point], map[point, Cluster.depot.start_point]])
end

function dist_opt(point, map, Cluster)
    bus = Bus(id=1, people=[], stops=vcat([Cluster.depot.start_point], Cluster.points, [Cluster.gare.start_point]), time=[])
    rearrangement_2opt(bus, map)
    time = compute_total_time(bus, map)
    bus = Bus(id=1, people=[], stops=vcat([Cluster.depot.start_point], Cluster.points, [point, Cluster.gare.start_point]), time=[])
    rearrangement_2opt(bus, map)
    new_time = compute_total_time(bus, map)
    return new_time-time
end