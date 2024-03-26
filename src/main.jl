using Distributions

include("menu.jl")
include("models.jl")
include("algorithms/hill_climbing.jl")
include("algorithms/simulated_annealing.jl")
include("algorithms/genetic_algorithm.jl")

using .Models: State, Package, Veichle, Population
using .Menu: choose_menu

function generate_package_stream(num_packages, map_size)
    types = ["fragile", "normal", "urgent"]
    return [Package(
                i,
                rand(types),
                rand(Uniform(0, map_size)),
                rand(Uniform(0, map_size)),
            ) for i in 1:num_packages]
end

function fitness(state::State)
    #=
        1. Distance Cost: C * distance
        2. Damage Cost: Z * n_breaked_packages // Calculated in the State constructor
        3. Urgente Cost: C * total_late_minutes
    =#
    
    C = 0.3
    distance_cost = C * state.total_distance
    urgent_cost = C * state.total_late_minutes
    return - (distance_cost + state.broken_packages_cost + urgent_cost)
end

function main()
    num_packages = 100
    map_size = 60
    velocity = 60 # 60 km/h

    packages_stream = generate_package_stream(num_packages, map_size)
    state::State = State(packages_stream, Veichle(0, 0, velocity))

    # Testing  GA
    current_state = genetic_algorithm(state, 100, 1000, 10, 0.1)
    
    # print number of packages in current_state
    print("Number of Packages: ")
    println(length(current_state.packages_stream))
    
    print("GA: ")
    println(current_state.total_time)

    current_state = hill_climbing(state, 1000)
    print("Hill Climbing: ")
    println(current_state.total_time)

    current_state = simulated_annealing(state, max_iterations=1000)
    print("Simulated Annealing: ")
    println(current_state.total_time)
    return

    algorithm, iterations = choose_menu()

    if algorithm == "Hill Climbing"
        current_state = hill_climbing(state, iterations)
    elseif algorithm == "Simulated Annealing"
        current_state = simulated_annealing(state, max_iterations=iterations)
    elseif algorithm == "Genetic Algorithm"
        #init_population = generate_population(20)
        #current_state = genetic_algorithm(init_population, iterations)
    end

    println(current_state.total_time)
end

main()
