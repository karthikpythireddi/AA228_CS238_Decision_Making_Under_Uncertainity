using Graphs  # for DiGraph and add_edge!
using TikzGraphs   # for TikZ plot output
using TikzPictures # to save TikZ as PDF


using Graphs
using GraphRecipes
using Plots

g = DiGraph(2) # create a directed graph
add_edge!(g, 1, 2) # add edge from node 1 to node 2

p = plot(g, node_labels=["First", "Second"], marker=:circle) # create plot with labels
savefig(p, "graph.pdf") # save plot as PDF

# p = plot(g, ["First", "Second"]) # create TikZ plot with labels
# save(PDF("graph.pdf"), p) # save TikZ as PDF



# using Graphs
# using TikzGraphs
# using TikzPictures
# using LaTeXStrings
# using PGFPlotsX

# # Create a graph
# g = SimpleGraph(4)
# add_edge!(g, 1, 2)
# add_edge!(g, 2, 3)
# add_edge!(g, 3, 4)
# add_edge!(g, 4, 1)

# # Create TikzGraph object
# tg = TikzGraph(g)

# # Customize the appearance of the graph
# tg.style[:vertex][1][:text] = "Node 1"
# tg.style[:vertex][2][:text] = "Node 2"
# tg.style[:vertex][3][:text] = "Node 3"
# tg.style[:vertex][4][:text] = "Node 4"

# # Generate TikZ code for the graph
# code = to_tikz(tg)

# # Create TikzPicture object
# tp = TikzPicture(code)

# # Save TikZ as PDF
# save(PDF("graph.pdf"), tp)