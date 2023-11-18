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

grid_size = 100
num_states = grid_size^2
num_actions = 5 # N, S, E, W, Stay

Random.seed!(123)
dasher = [rand(1:grid_size), rand(1:grid_size)]
order = [rand(1:grid_size), rand(1:grid_size)]

Q = zeros(num_states, num_actions)
gamma = 1 
alpha = 0.5 
model = Q_learning(num_states, num_actions, gamma, Q, alpha)

indices = LinearIndices((grid_size, grid_size))


s_prime = indices[order[1], order[2]]

for i in 1:50000
    s = indices[dasher[1], dasher[2]]
    a = rand(1:num_actions)
    r = -sqrt((dasher[1]-order[1])^2 + (dasher[2]-order[2])^2)
    old_Q = model.Q[s, a]
    update!(model, s, a, r, s_prime)
    new_Q = model.Q[s, a]
    
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

    # Print information every 1000 steps
    if i % 10 == 0
        println("Step: $i Action: $a Reward: $r Old Q: $old_Q New Q: $new_Q")
    end
end