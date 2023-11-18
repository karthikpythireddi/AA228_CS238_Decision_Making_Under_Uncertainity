

# #function to calculate the prior
# function prior(variable_names, G)
#     n = length(variable_names)
#     alpha = zeros(n, n)
#     r = [variable_names[i].r for i in 1:n]
#     q = [prod([r[j]] for j in inneighbors(G, i)) for i in 1:n]
#     return [ones(q[i], r[i]) for i in 1:n]
# end

# #function to calculate the statistics
# function statistics(variable_names, G, data_T)
#     n = size(data_T, 1)
#     r = [variable_names[i].r for i in 1:n]
#     q = [prod([r[j]] for j in inneighbors(G, i)) for i in 1:n]
#     M = [zeros(q[i], r[i]) for i in 1:n]
#     for o in eachcol(D)
#         for i in 1:n
#             k = o[i]
#             parents = inneighbors(G, i)
#             j = i
#             if !isempty(parents)
#                 j = sub2ind(r[parents], o[parents])
#             end
#             M[i][j, k] += 1.0
#         end
#     end
#     return M
# end

# #function to calculate the bayesianscore component
# function bayesianscore_component(M,alpha)

#     p = sum(loggamma.(alpha + M))
#     q = sum(loggamma.(alpha))

#     r = sum(loggamma.sum(alpha, dims = 2))
#     s = sum(loggamma.(sum(alpha, dims = 2) + sum(M, dims = 2)))

#     return p - q + r - s
# end

# #function to calculate the bayesian score
# function bayesianscore(variable_names, G, data_T)
#     n = length(variable_names)
#     M = statistics(variable_names, G, data_T)
#     alpha = prior(variable_names, G)
#     return sum(bayesianscore_component.(M[i], alpha[i]) for i in 1:n)
# end


# inputfilename = "/home/karthikpythireddi/Stanford_Classes/AA228/AA228-CS238-Student/project1/example/example.csv"
# outputfilename = "/home/karthikpythireddi/Stanford_Classes/AA228/AA228-CS238-Student/project1/example/example.gph"