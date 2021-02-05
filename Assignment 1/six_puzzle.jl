# imports
import Base: ==

# ~~~~~~~~~~~~~~~~
# global constants
# ~~~~~~~~~~~~~~~~

const INITIAL_STATE = [1 4 2; 5 3 nothing]
const GOAL_STATE = [nothing 1 2; 5 4 3]

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

# Operation represents the result of a possible operation in a given state
struct Operation
    result_state::State
    tile_moved::Int
end

# SearchNode represents a node in the search tree
struct SearchNode
    state::State
    parent::Union{SearchNode,Nothing}
    cost_so_far::Int
    current_depth::Int

    # constructor builds state from a board config, handles null and non-null parents (since root of tree will have null parent)
    function SearchNode(board::Matrix, parent::Union{SearchNode,Nothing}, cost_so_far::Int, current_depth::Int)
        return new(State(board), parent, cost_so_far, current_depth)
    end
end

# SearchTree represents the current state of a search tree
mutable struct SearchTree
    current::SearchNode
    goal::State

    # constructor initializes with a node at root of tree, hence null parent and zero cost and depth
    function SearchTree(start::Matrix, goal::Matrix)
        return new(SearchNode(start, nothing, 0, 0), State(goal))
    end
end

# QueueItem represents an item in a queue
mutable struct QueueItem
    node::SearchNode
    next::Union{QueueItem,Nothing}

    # constructor sets next to null
    function QueueItem(node::SearchNode)
        return new(node, nothing)
    end
end

# Queue represents a queue
mutable struct Queue
    head::Union{QueueItem,Nothing}
    tail::Union{QueueItem,Nothing}
    length::Int

    # constructor creates an empty queue
    function Queue()
        return new(nothing, nothing, 0)
    end
end

# ~~~~~~~~~~~~~~~~~~~~~
# function declarations
# ~~~~~~~~~~~~~~~~~~~~~

# Checks equality of two instances of State
function ==(s1::State, s2::State)
    return (s1.board == s2.board) && (s1.empty_slot == s2.empty_slot)
end

# Adds an item to a Queue
function enqueue!(queue::Queue, item::QueueItem)
    if queue.length == 0
        queue.head = item
        queue.tail = item
    else
        queue.tail.next = item
        queue.tail = item
    end
    queue.length += 1
end

# Removes an item from a Queue and returns it
function dequeue!(queue::Queue)::QueueItem
    item = queue.head
    queue.head = queue.head.next
    queue.length -= 1
    return item
end

# Returns all potential successor states to a given state, as well as the number of the tile moved
function successor_states(state::State)::Set{Operation}
    i, j = state.empty_slot

    # find all the potential new empty slots
    potential_empties = []
    if (i, j) == (1, 1)
        potential_empties = [(2, 1), (1, 2)]
    elseif (i, j) == (1, 2)
        potential_empties = [(1, 1), (2, 2), (1, 3)]
    elseif (i, j) == (1, 3)
        potential_empties = [(1, 2), (2, 3)]
    elseif (i, j) == (2, 1)
        potential_empties = [(1, 1), (2, 2)]
    elseif (i, j) == (2, 2)
        potential_empties = [(2, 1), (1, 2), (2, 3)]
    elseif (i, j) == (2, 3)
        potential_empties = [(2, 2), (1, 3)]
    end

    states = []
    for (i_new, j_new) ∈ potential_empties
        board = copy(state.board)
        board[i, j] = state.board[i_new, j_new]
        board[i_new, j_new] = state.board[i, j]
        tile_moved = board[i, j]
        append!(states, [Operation(State(board), tile_moved)])
    end

    return Set(states)
end

# ~~~~~~~~~~~~~~~~~~~~
# breadth-first search
# ~~~~~~~~~~~~~~~~~~~~

# initialize tree, queue, and visited list
bfs_tree = SearchTree(INITIAL_STATE, GOAL_STATE)
bfs_queue = Queue()
enqueue!(bfs_queue, QueueItem(bfs_tree.current))
bfs_visited = []

# perform BFS algorithm
while bfs_tree.current.state != bfs_tree.goal
    append!(bfs_visited, [bfs_tree.current.state])
    successors = successor_states(bfs_tree.current.state)

    # remove all the visited states, enqueue the unvisited
    filter!(s -> ∉(s, bfs_visited), successors)
    for successor ∈ successors
        # using unit cost; increment the depth
        node = SearchNode(successor.result_state.board, bfs_tree.current, bfs_tree.current.cost_so_far + 1, bfs_tree.current.current_depth + 1)
        enqueue!(bfs_queue, QueueItem(node))
    end
    bfs_tree.current = dequeue!(bfs_queue).node
end

# TODO: show solution path

# ~~~~~~~~~~~~~~~~~~~
# uniform-cost search
# ~~~~~~~~~~~~~~~~~~~



# ~~~~~~~~~~~~~~~~~~
# depth-first search
# ~~~~~~~~~~~~~~~~~~

# TODO: stack type



# ~~~~~~~~~~~~~~~~~~~
# iterative deepening
# ~~~~~~~~~~~~~~~~~~~
