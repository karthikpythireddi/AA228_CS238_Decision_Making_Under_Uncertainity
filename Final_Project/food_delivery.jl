using Pluto
using Plots
using CSV
using DataFrames
using Random

# Define a Q-learning model type
mutable struct Q_learning
    S # state space
    A # action space
    gamma # discount factor
    Q # action value function
    alpha # learning rate

end

lookahead(model :: Q_learning, s, a) = model.Q[s, a]

function update!(model :: Q_learning, s, a, r, s_prime)
    gamma, Q , alpha = model.gamma, model.Q, model.alpha
    Q[s, a] = Q[s, a] + alpha * (r + gamma * maximum(Q[s_prime, :]) - Q[s, a])
    return model
end


# Define a grid of size 100x100
grid_size = 10

# Define state and action spaces
num_states = grid_size^2 # Each cell in the grid is a possible state
num_actions = 5 # N, S, E, W, or stay put

# Generate random locations for dashers and food orders
Random.seed!(123)
dashers = [rand(1:grid_size), rand(1:grid_size)]
orders = [rand(1:grid_size), rand(1:grid_size)]

# Initialize Q-values
Q = zeros(num_states, num_actions)

# Define the Q-learning model
gamma = 1 # Discount factor
alpha = 0.5 # Learning rate
model = Q_learning(num_states, num_actions, gamma, Q, alpha)

# Define the linear indices for the grid
indices = LinearIndices((grid_size, grid_size))


# Initialize a plot
plot = scatter([], [], xlim = (1,grid_size), ylim = (1,grid_size), 
xticks = 1:grid_size, yticks = 1:grid_size, legend = false)

@time begin
    for _ in 1:50000 # Simulate 50000 steps
        # Generate new random positions for dasher and order
        dasher = [rand(1:grid_size), rand(1:grid_size)]
        order = [rand(1:grid_size), rand(1:grid_size)]

        # Represent the state as a single number using linear indices
        s = indices[dasher[1], dasher[2]]
        s_prime = indices[order[1], order[2]]

        # Choose a random action
        a = rand(1:num_actions)

        # Compute the reward as the negative Euclidean distance
        r = -sqrt((dasher[1]-order[1])^2 + (dasher[2]-order[2])^2)

        update!(model, s, a, r, s_prime)
        # Add the positions of the dasher and the order to the plot
        scatter!(plot, [dasher[2]], [dasher[1]], color = "blue", marker = :circle)
        scatter!(plot, [order[2]], [order[1]], color = "red", marker = :star5)
        display(plot) # This line will display the plot after each update
    end
    
    best_actions = [argmax(Q[s, :]) for s in 1:num_states]
end

policy_output = "final.policy"
open(policy_output, "w") do f
    for action in best_actions
        write(f, "$action\n")
    end
end