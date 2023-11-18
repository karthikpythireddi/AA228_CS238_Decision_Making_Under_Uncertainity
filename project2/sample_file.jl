using CSV
using DataFrames
using Statistics

data = CSV.read("/home/karthikpythireddi/Stanford_Classes/AA228/AA228-CS238-Student/project2/data/medium.csv", DataFrame)

# Extract the columns for state (s), action (a), reward (r), and next state (s')
s = data[!, :s]
a = data[!, :a]
r = data[!, :r]
s_prime = data[!, :sp]

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
    Q[s, a] = Q[s, a] + alpha * (r + gamma * maximum(skipmissing(Q[s_prime, :])) - Q[s, a])
    return model
end

#given the number of states and actions
num_states = 50000
num_actions = 7

#initialize the Q-learning model
gamma = 1 # discount factor
alpha = 0.5 # learning rate
# Initialize Q-values with NaN
Q = fill(NaN, (num_states, num_actions))

@time begin
model = Q_learning(num_states, num_actions, gamma, Q, alpha)

best_actions = Vector{Int}(undef, num_states)
    # Iterate through your data to update Q-values
    num_rows = size(data, 1)
    for i in 1:num_rows
        state = s[i]
        action = a[i]
        reward = r[i]
        next_state = s_prime[i]
        # Only update the Q-value if it's still NaN
        if isnan(model.Q[state, action])
            update!(model, state, action, reward, next_state)
        end
    end
    
    # Compute the average of known Q-values
    avg_Q = mean(skipmissing(Q))
    
    # Fill missing Q-values with the average
    model.Q = coalesce.(model.Q, avg_Q)

    # Now that the Q-values have been updated, find the best action for each state
    for state in 1:num_states
        best_action = argmax(skipmissing(Q[state, :]))
        best_actions[state] = best_action
    end
end

# Write the policy to a file
policy_output = "/home/karthikpythireddi/Stanford_Classes/AA228/AA228-CS238-Student/project2/data/medium.policy"
open(policy_output, "w") do f
    for action in best_actions
        write(f, "$action\n")
    end
end