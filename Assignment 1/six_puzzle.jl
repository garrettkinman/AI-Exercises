# imports


# State represents a given configuration of the board
struct State
    # empty_slot is so we don't have to search each time for it
    board::AbstractMatrix
    empty_slot::Tuple{Integer, Integer}
end

# SearchNode represents a node in the search tree
struct SearchNode
    state_id::Integer
    state::State
    parent::SearchNode
    cost_so_far::Integer
    current_depth::Integer
end

# SearchTree represents the current state of a search tree
mutable struct SearchTree
    current::SearchNode
    goal::AbstractMatrix
end

# QueueItem represents an item in a queue
mutable struct QueueItem
    node::SearchNode
    next::SearchNode
end

# Queue represents a queue
mutable struct Queue
    head::QueueItem
    tail::QueueItem
end

# breadth-first search
# TODO: queue type
#=
1. Initialize SearchTree
2. While SearchTree.current.state != SearchTree.goal:
    1. Determine all possible successor states
    2. For each successor state:
        1. If unvisited, add to Queue
        2. Else, continue
    3. SearchTree.current = dequeue!(Queue).node
3. Follow pointers back to parent node for full path
=#


# uniform-cost search




# depth-first search
# TODO: stack type




# iterative deepening
