# ~~~~~~~
# imports
# ~~~~~~~

using Statistics
using Combinatorics
using Pipe

# ~~~~~~~~~~~~~~~~~~~
# struct declarations
# ~~~~~~~~~~~~~~~~~~~

struct TSP
    num_cities::Int
    cities::Vector{Tuple{Float64,Float64}}
    distances::Matrix{Float64}

    function TSP(num_cities::Int)
        cities = []
        for i ∈ 1:num_cities
            push!(cities, (rand(), rand()))
        end
        distances = zeros((num_cities, num_cities))
        for i ∈ 1:num_cities
            for j ∈ 1:num_cities
                x_i, y_i = cities[i]
                x_j, y_j = cities[j]
                distances[i, j] = √((x_i - x_j)^2 + (y_i - y_j)^2)
            end
        end
        return new(num_cities, cities, distances)
    end
end


struct StatsResult
    μ::Float64
    min::Float64
    max::Float64
    σ::Float64

    function StatsResult(v::Vector{Float64})
        return new(mean(v), minimum(v), maximum(v), std(v))
    end
end

# ~~~~~~~~~~~~~~~~~~~~~
# function declarations
# ~~~~~~~~~~~~~~~~~~~~~

function evaluate_tour(tsp::TSP, tour::Vector{Int64})::Float64
    cost = 0.0
    # first city is starting point, so no cost
    for i ∈ 2:length(tour)
        cost += tsp.distances[tour[i - 1], tour[i]]
    end
    return cost
end

function brute_force(tsp::TSP, tours::Vector{Vector{Int64}})
    # initialize to max possible cost
    min = √(2) * tsp.num_cities

    # find minimum-cost tour
    for tour ∈ tours
        cost = evaluate_tour(tsp, tour)
        min = cost < min ? cost : min
    end
    return min
end

function generate_rand_tour(n::Int64)::Vector{Int64}
    cities = Set(1:n)
    tour = fill(0, n)

    # for each stage of tour, randomly select next city, and remove it from set of available cities
    for i ∈ 1:n
        city = rand(cities)
        tour[i] = city
        setdiff!(cities, city)
    end
    return tour
end

# ~~~~~~~~~~~~~~~~~~~~~
# brute-force solutions
# ~~~~~~~~~~~~~~~~~~~~~

# all possible tours for 7 cities
seven_tours = collect(permutations([1, 2, 3, 4, 5, 6, 7]))
# generate 100 random TSPs of size 7
seven_TSPs = TSP.(fill(7, 100))
# initialize list of optimal tour costs to zeros
seven_optimals = zeros(100)

# collect stats on optimal tours of all 100 TSPs
for i ∈ 1:100
    seven_optimals[i] = brute_force(seven_TSPs[i], seven_tours)
end
seven_results = StatsResult(seven_optimals)

# ~~~~~~~~~~~~
# random tours
# ~~~~~~~~~~~~

# initialize list of random tour costs to zeros
seven_randoms = zeros(100)

# collect stats on random tours of all 100 TSPs
num_rand_opt = 0
for i ∈ 1:100
    seven_randoms[i] = @pipe generate_rand_tour(7) |> evaluate_tour(seven_TSPs[i], _)
    if seven_randoms[i] == seven_optimals[i]
        num_rand_opt += 1
    end
end
seven_rand_results = StatsResult(seven_randoms)
