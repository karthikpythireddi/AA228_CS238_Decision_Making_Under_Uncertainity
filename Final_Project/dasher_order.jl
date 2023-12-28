using Plots
using Random

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

# ε-greedy strategy
function choose_action(model :: Q_learning, s, epsilon)
    if rand() < epsilon
        return rand(1:model.A)
    else
        values = [lookahead(model, s, a) for a in 1:model.A]
        return argmax(values)
    end
end

function move_dasher!(dasher, a, grid_size)
    # Move the dasher based on the action
    if a == 1 # North
        dasher[1] = max(1, dasher[1]-1)
    elseif a == 2 # South
        dasher[1] = min(grid_size, dasher[1]+1)
    elseif a == 3 # East
        dasher[2] = min(grid_size, dasher[2]+1)
    elseif a == 4 # West
        dasher[2] = max(1, dasher[2]-1)
    end
    return dasher
end

grid_size = 100
num_states = grid_size^2
num_actions = 5 # N, S, E, W, Stay

Random.seed!(123)
dasher_Q = [rand(1:grid_size), rand(1:grid_size)]
dasher_no_Q = copy(dasher_Q) # Start at the same position
order = [rand(1:grid_size), rand(1:grid_size)]

Q = zeros(num_states, num_actions)
gamma = 0.95
alpha = 0.7
model = Q_learning(num_states, num_actions, gamma, Q, alpha)

indices = LinearIndices((grid_size, grid_size))

s_prime = indices[order[1], order[2]]

# Arrays to store rewards and Q-values
rewards_Q = Float64[]
rewards_no_Q = Float64[]
Q_values = Float64[]

epsilon = 0.01

for i in 1:10000
    global dasher_Q, dasher_no_Q
    s_Q = indices[dasher_Q[1], dasher_Q[2]]
    a_Q = choose_action(model, s_Q, epsilon)
    r_Q = -sqrt((dasher_Q[1]-order[1])^2 + (dasher_Q[2]-order[2])^2)
    old_Q = model.Q[s_Q, a_Q]
    update!(model, s_Q, a_Q, r_Q, s_prime)
    new_Q = model.Q[s_Q, a_Q]

    # Store the reward and new Q-value
    push!(rewards_Q, r_Q)
    push!(Q_values, new_Q)

    # For the no_Q case, the agent takes a random action and we don't update the Q-values
    s_no_Q = indices[dasher_no_Q[1], dasher_no_Q[2]]
    a_no_Q = rand(1:num_actions)
    r_no_Q = -sqrt((dasher_no_Q[1]-order[1])^2 + (dasher_no_Q[2]-order[2])^2)
    push!(rewards_no_Q, r_no_Q)

    # Move the dashers based on the actions
    dasher_Q = move_dasher!(dasher_Q, a_Q, grid_size) 
    dasher_no_Q = move_dasher!(dasher_no_Q, a_no_Q, grid_size) 

    # Print information every 10 steps
    if i % 100 == 0
        println("Step: $i Action: $a_Q Reward: $r_Q Old Q: $old_Q New Q: $new_Q")
    end
end

# Plot the rewards and Q-values
plot(rewards_Q, label = "Rewards with Q-Learning")

plot!(rewards_no_Q, label = "Rewards without Q-Learning", xlabel="Iteration", ylabel="Reward", title="Rewards over Iterations")
savefig("rewards_with_Q-Learning_plot.png")

plot(Q_values, title="Q-values over Iterations", xlabel="Iteration", ylabel="Q-value", legend=false)
savefig("qvalues_plot.png")