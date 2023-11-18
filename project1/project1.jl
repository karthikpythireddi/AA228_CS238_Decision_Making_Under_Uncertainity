"""
Many of the functions used in this project have been referred from the Decision Making Under Uncertainty by Mykel J. Kochenderfer, Tim A. Wheeler, Kyle H. Wray
"""


#import the libraries
using CSV
using DataFrames
using GraphPlot, Graphs
using GraphRecipes
using Printf
using Compose
using Cairo
using LinearAlgebra
using SpecialFunctions
using Colors

#struct to store the variable information
struct Variable
    name::Symbol
    r::Int # number of possible values
end

#struct to store the ordering information
struct K2Search
    ordering::Vector{Int}
end


"""
    write_gph(dag::DiGraph, idx2names, filename)

Takes a DiGraph, a Dict of index to names and a output filename to write the graph in `gph` format.
"""
function write_gph(dag::DiGraph, idx2names, filename)
    open(filename, "w") do io
        for edge in edges(dag)
            @printf(io, "%s,%s\n", idx2names[src(edge)], idx2names[dst(edge)])
        end
    end
end

#function to calculate the prior probability
function prior(vars, G)
    n = length(vars)
    r = [vars[i].r for i in 1:n]
    q = [prod([r[j] for j in inneighbors(G, i)]) for i in 1:n] 

    return [ones(q[i], r[i]) for i in 1:n]
end

#function to convert the subscripts to indices
function sub2ind(siz, x)
    k = vcat(1, cumprod(siz[1:end-1]))
    return dot(k, x .- 1) .+ 1
end

#function to calculate the statistics of the data
function statistics(vars, G, data_T)
    n = size(data_T, 1)
    r = [vars[i].r for i in 1:n]
    q = [prod([r[j] for j in inneighbors(G, i)]) for i in 1:n] 
    M = [zeros(q[i], r[i]) for i in 1:n]
    for o in eachcol(data_T)
        for i in 1:n
            k = o[i]
            parents = inneighbors(G, i)
            j = 1
            if !isempty(parents)
                j = sub2ind(r[parents], o[parents])
            end
            M[i][j, k] += 1.0
        end
    end
    return M
end


#function to calculate the bayesianscore component
function bayesianscore_component(M,alpha)

    p = sum(loggamma.(alpha + M))
    q = sum(loggamma.(alpha))
    r = sum(loggamma.(sum(alpha,dims=2)))
    s = sum(loggamma.(sum(alpha,dims=2) + sum(M,dims=2)))

    return p - q + r - s 
end

#function to calculate the bayesian score
function bayesianscore(vars, G, data_T)
    n = length(vars)
    M = statistics(vars, G, data_T)
    alpha = prior(vars, G)
    return sum(bayesianscore_component(M[i], alpha[i]) for i in 1:n)
end

#function to fit the graph  using K2 search
function fit(method::K2Search, vars, data_T)
    G = SimpleDiGraph(length(vars))
    for (k,i) in enumerate(method.ordering[2:end])
        y = bayesianscore(vars, G, data_T)
        while true
            y_best, j_best = -Inf, 0
            for j in method.ordering[1:k]
                if !has_edge(G, j, i)
                    add_edge!(G, j, i)
                    y_ = bayesianscore(vars, G, data_T)
                    if y_ > y_best
                        y_best, j_best = y_, j
                    end
                    rem_edge!(G, j, i)
                end
            end
            if y_best > y
                y = y_best
                add_edge!(G, j_best, i)
            else
                break
            end
        end
    end
    return G
end

#function to read the csv file and return the data frame
function compute(infile, outfile)

    # WRITE YOUR CODE HERE
    # FEEL FREE TO CHANGE ANYTHING ANYWHERE IN THE CODE
    # THIS INCLUDES CHANGING THE FUNCTION NAMES, MAKING THE CODE MODULAR, BASICALLY ANYTHING
    csv_file = CSV.File(infile)
    df = DataFrame(csv_file)
    variable_names = names(df)
    data = Matrix(df)
    data_T = transpose(data)

    #initalize the vars array with the variable information
    vars = []
    for (idx, variable_name) in enumerate(variable_names)
        r = maximum(data_T[idx, :])  # Access the column by its integer index in the transposed matrix
        push!(vars, Variable(Symbol(variable_name), r))
    end
    
    #initalize the node_dict and num_nodes
    node_dict = Dict(zip(1:length(variable_names), variable_names))
    num_nodes = length(variable_names)

    #calculate the G using K2 search and plot using the gplot
    G = fit(K2Search(1:num_nodes), vars, data_T)
    nodefillc = distinguishable_colors(num_nodes, colorant"lightblue")
    p = gplot(G; nodelabel=[node_dict[i] for i in 1:length(variable_names)], nodefillc=nodefillc, nodelabeldist=1.5, layout=circular_layout)
    draw(PNG("small_graph.png"), p)

    #bayesian score for the above graph
    println(bayesianscore(vars, G, data_T))

    # node_dict = Dict(zip(1:num_nodes, variable_names))
    write_gph(G, node_dict, outfile)

end

inputfilename = "/home/karthikpythireddi/Stanford_Classes/AA228/AA228-CS238-Student/project1/data/small.csv"
outputfilename = "/home/karthikpythireddi/Stanford_Classes/AA228/AA228-CS238-Student/project1/small.gph"

@time compute(inputfilename, outputfilename) # compute function and the time taken to run it





