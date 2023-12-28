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


function choose_action(model :: Q_learning, s, epsilon)
    if rand() < epsilon
        # Choose a random action
        return rand(1:model.A)
    else
        # Choose the action with the highest estimated reward
        values = [lookahead(model, s, a) for a in 1:model.A]
        return argmax(values)
    end
end

function move_dasher!(dasher, a, grid_size)
    # Save current dasher position
    old_position = copy(dasher)

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

    # Check if the new position is out of grid
    if dasher[1] < 1 || dasher[1] > grid_size || dasher[2] < 1 || dasher[2] > grid_size
        # If new position is out of grid, the dasher stays in the same old position
        dasher = old_position
    end

    return dasher
end


grid_size = 25
num_states = grid_size^2
num_actions = 4 # N, S, E, W

Random.seed!(123)
dasher_Q = [rand(1:grid_size), rand(1:grid_size)]
dasher_no_Q = copy(dasher_Q) # Start at the same position
order = [rand(1:grid_size), rand(1:grid_size)]

Q = zeros(num_states, num_actions)
gamma = 0.5
alpha = 0.1
model = Q_learning(num_states, num_actions, gamma, Q, alpha)

indices = LinearIndices((grid_size, grid_size))

s_prime = indices[order[1], order[2]]

# Arrays to store rewards and Q-values
rewards_Q = Float64[]
rewards_no_Q = Float64[]
rewards_Q_epsilon = Float64[]
rewards_no_Q_epsilon = Float64[]
Q_values = Float64[]

epsilon = 0.01

for i in 1:100
    
    # For the Q-Learning with ε-greedy case
    global dasher_Q, dasher_no_Q
    s_Q_epsilon = indices[dasher_Q[1], dasher_Q[2]]
    a_Q_epsilon = choose_action(model, s_Q_epsilon, epsilon)

    # Check if the dasher is at the order location, else reward is -1
    if dasher_Q == order
        r_Q_epsilon = 10.0
    else
        r_Q_epsilon = -1.0
    end

    old_Q_epsilon = model.Q[s_Q_epsilon, a_Q_epsilon]
    update!(model, s_Q_epsilon, a_Q_epsilon, r_Q_epsilon, s_prime)
    new_Q_epsilon = model.Q[s_Q_epsilon, a_Q_epsilon]

    # Store the reward
    push!(rewards_Q_epsilon, r_Q_epsilon)
    push!(rewards_Q, r_Q_epsilon)


    # For the No Q-Learning with ε-greedy case, the agent takes a random action and we don't update the Q-values
    s_no_Q_epsilon = indices[dasher_no_Q[1], dasher_no_Q[2]]
    a_no_Q = rand(1:num_actions)
    a_no_Q_epsilon = rand(1:num_actions)

    # Check if the dasher is at the order location, else reward is -1
    if dasher_no_Q == order
        r_no_Q_epsilon = 10.0
    else
        r_no_Q_epsilon = -1.0
    end

    push!(rewards_no_Q_epsilon, r_no_Q_epsilon)
    push!(rewards_no_Q, r_no_Q_epsilon)

    # Move the dashers based on the actions
    dasher_Q = move_dasher!(dasher_Q, a_Q_epsilon, grid_size) 
    dasher_no_Q = move_dasher!(dasher_no_Q, a_no_Q, grid_size) 

    # Print information every 100 steps
    if i % 10 == 0
        println("Step: $i Action: $a_Q_epsilon Reward: $r_Q_epsilon Old Q: $old_Q_epsilon New Q: $new_Q_epsilon")
    end
end


# Plot for Q-Learning vs No Q-Learning
plot(1:100, cumsum(rewards_Q), label="Q-Learning")
plot!(1:100, cumsum(rewards_no_Q), label="No Q-Learning")
title!("Q-Learning vs No Q-Learning")
xlabel!("Steps")
ylabel!("Cumulative Reward")
savefig("Q-Learning vs No Q-Learning.png")

# Plot for Q-Learning with ε-greedy vs No Q-Learning with ε-greedy
plot(1:100, cumsum(rewards_Q_epsilon), label="Q-Learning with ε-greedy")
plot!(1:100, cumsum(rewards_no_Q_epsilon), label="No Q-Learning")
title!("Q-Learning with ε-greedy vs No Q-Learning")
xlabel!("Steps")
ylabel!("Cumulative Reward")
savefig("Q-Learning with ε-greedy vs No Q-Learning.png")



# Plot the rewards and Q-values
plot(rewards_Q, label = "Rewards with Q-Learning")

plot!(rewards_no_Q, label = "Rewards without Q-Learning", xlabel="Iteration", ylabel="Reward", title="Rewards over Iterations")
savefig("rewards_with_Q-Learning_plot.png")