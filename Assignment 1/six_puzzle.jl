# imports

# ~~~~~~~~~~~~~~~~~
# type declarations
# ~~~~~~~~~~~~~~~~~

# State represents a given configuration of the board
struct State
    # empty_slot is so we don't have to search each time for it
    board::Matrix
    empty_slot::Tuple{Int,Int}

    # constructor that sets the value of empty_slot based on the board
    function State(board::Matrix)
        for i ∈ 1:2
            for j ∈ 1:3
                if board[i,j] == nothing
                    return new(board, (i,j))
                end
            end
        end
    end
end

# SearchNode represents a node in the search tree
struct SearchNode
    state::State
    parent::Union{SearchNode,Nothing}
    cost_so_far::Int
    current_depth::Int
    function SearchNode(board::Matrix, parent::Union{SearchNode,Nothing}, cost_so_far::Int, current_depth::Int)
        return new(State(board), parent, cost_so_far, current_depth)
    end
end

# SearchTree represents the current state of a search tree
mutable struct SearchTree
    current::SearchNode
    goal::Matrix
    function SearchTree(start::Matrix, goal::Matrix)
        return new(SearchNode(start, nothing, 0, 0), goal)
    end
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

# ~~~~~~~~~~~~~~~~~~~~~
# function declarations
# ~~~~~~~~~~~~~~~~~~~~~

# Checks equality of two instances of State
function isequal(s1::State, s2::State)
    return (isequal(s1.board, s2.board) && s1.empty_slot == s2.empty_slot))
end

# Adds an item to a Queue
function enqueue!(queue::Queue, item::QueueItem)
    queue.tail.next = item
    queue.tail = item
end

# Removes an item from a Queue and returns it
function dequeue!(queue::Queue)::QueueItem
    item = queue.head
    queue.head = queue.head.next
    return item
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
