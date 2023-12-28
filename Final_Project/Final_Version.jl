using Random
using Plots
using Statistics  # Include this line to use the mean function

# Define the Environment
struct GridWorld
    grid_size::Int
    customer_location::Vector{Int}
end


function move_agent!(agent_position, action, env::GridWorld)
    new_position = copy(agent_position)
    if action == 1 # North
        new_position[1] = max(1, new_position[1] - 1)
    elseif action == 2 # South
        new_position[1] = min(env.grid_size, new_position[1] + 1)
    elseif action == 3 # East
        new_position[2] = min(env.grid_size, new_position[2] + 1)
    elseif action == 4 # West
        new_position[2] = max(1, new_position[2] - 1)
    end
    return new_position
end

# Define the Q-learning Agent
mutable struct QLearningAgent
    state_space::Int
    action_space::Int
    gamma::Float64
    Q::Array{Float64, 2}
    alpha::Float64
    epsilon::Float64
end

function choose_action(agent::QLearningAgent, state)
    if rand() < agent.epsilon
        return rand(1:agent.action_space)
    else
        values = [agent.Q[state, a] for a in 1:agent.action_space]
        return argmax(values)
    end
end

function update!(agent::QLearningAgent, s, a, r, s_prime)
    old_q = agent.Q[s, a]
    max_future_reward = maximum(agent.Q[s_prime, :])
    agent.Q[s, a] += agent.alpha * (r + agent.gamma * max_future_reward - agent.Q[s, a])
    new_q = agent.Q[s, a]

    # Print Old_Q and New_Q values
    println("Old Q-Value: $old_q, New Q-Value: $new_q")
end

function simulate_with_q_learning(env::GridWorld, num_iterations::Int, agent::QLearningAgent)
    cumulative_reward = 0.0
    cumulative_rewards = Float64[]
    indices = LinearIndices((env.grid_size, env.grid_size))
    agent_position = [1, rand(1:env.grid_size)]

    for i in 1:num_iterations
        s = indices[agent_position...]
        a = choose_action(agent, s)
        agent_position = move_agent!(agent_position, a, env)
        s_prime = indices[agent_position...]
        r = (agent_position == env.customer_location) ? 10.0 : -1.0
        update!(agent, s, a, r, s_prime)
        cumulative_reward += r
        push!(cumulative_rewards, cumulative_reward)

        # Print iteration, action, and reward at intervals
        if i % 1000 == 0
            println("Iteration $i, Action $a, Q-Learning Reward: $r")
        end
    end
    return cumulative_rewards
end

function simulate_without_q_learning(env::GridWorld, num_iterations::Int)
    cumulative_reward = 0.0
    cumulative_rewards = Float64[]
    indices = LinearIndices((env.grid_size, env.grid_size))
    agent_position = [1, rand(1:env.grid_size)]

    for i in 1:num_iterations
        s = indices[agent_position...]
        a = rand(1:4)  # Random action
        agent_position = move_agent!(agent_position, a, env)
        r = (agent_position == env.customer_location) ? 10.0 : -1.0
        cumulative_reward += r
        push!(cumulative_rewards, cumulative_reward)

        # Print iteration and reward at intervals
        if i % 1000 == 0
            println("Iteration $i, Non-Q-Learning Reward: $r")
        end
    end
    return cumulative_rewards
end

# Initialize Environment and Agent
grid_size = 20
num_states = grid_size^2
num_actions = 4 # N, S, E, W

env = GridWorld(grid_size, [19, 12])
agent = QLearningAgent(num_states, num_actions, 0.5, zeros(num_states, num_actions), 0.1, 0.05)

# Run Simulations
Random.seed!(123)
rewards_with_q_learning = simulate_with_q_learning(env, 10000, agent)
rewards_without_q_learning = simulate_without_q_learning(env, 10000)

# Calculate mean and standard deviation within a rolling window
window_size = 100  # Adjust the window size as needed
rolling_means_q_learning = [mean(rewards_with_q_learning[max(1, i-window_size+1):i]) for i in 1:length(rewards_with_q_learning)]
rolling_stds_q_learning = [std(rewards_with_q_learning[max(1, i-window_size+1):i]) for i in 1:length(rewards_with_q_learning)]

rolling_means_no_q_learning = [mean(rewards_without_q_learning[max(1, i-window_size+1):i]) for i in 1:length(rewards_without_q_learning)]
rolling_stds_no_q_learning = [std(rewards_without_q_learning[max(1, i-window_size+1):i]) for i in 1:length(rewards_without_q_learning)]

# Plotting with mean and standard deviation
p = plot(title="Rewards Comparison", xlabel="Iteration", ylabel="Rolling Mean Reward")
plot!(p, 1:10000, rolling_means_q_learning, ribbon=rolling_stds_q_learning, label="Q-Learning", fillalpha=0.3)
plot!(p, 1:10000, rolling_means_no_q_learning, ribbon=rolling_stds_no_q_learning, label="No Q-Learning", fillalpha=0.3, legend=:topright)

display(p)
savefig(p, "Rolling_Mean_Rewards_Comparison.png")