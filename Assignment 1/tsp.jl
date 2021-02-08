# ~~~~~~~
# imports
# ~~~~~~~

using Statistics

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
