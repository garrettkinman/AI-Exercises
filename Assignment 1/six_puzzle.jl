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
function successor_states(state::State)::Vector{Operation}
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

    return states
end

# ~~~~~~~~~~~~~~~~~~~~
# breadth-first search
# ~~~~~~~~~~~~~~~~~~~~

# initialize tree, queue, and visited list
bfs_tree = SearchTree(INITIAL_STATE, GOAL_STATE)
bfs_queue = Queue()
bfs_visited = []

# perform BFS algorithm
while bfs_tree.current.state != bfs_tree.goal
    append!(bfs_visited, [bfs_tree.current.state])
    successors = successor_states(bfs_tree.current.state)

    # remove all the visited states, enqueue the unvisited
    filter!(s -> ∉(s.result_state, bfs_visited), successors)
    # TODO: prioritize low tile numbers
    for successor ∈ successors
        # using unit cost; increment the depth
        node = SearchNode(successor.result_state.board, bfs_tree.current, bfs_tree.current.cost_so_far + 1, bfs_tree.current.current_depth + 1)
        enqueue!(bfs_queue, QueueItem(node))
    end
    bfs_tree.current = dequeue!(bfs_queue).node
end

# ~~~~~~~~~~~~~~~~~~~
# uniform-cost search
# ~~~~~~~~~~~~~~~~~~~

# initialize tree, queue, and visited list
ucs_tree = SearchTree(INITIAL_STATE, GOAL_STATE)
ucs_queue = Queue()
ucs_visited = []

# perform UCS algorithm
while ucs_tree.current.state != ucs_tree.goal
    append!(ucs_visited, [ucs_tree.current.state])
    successors = successor_states(ucs_tree.current.state)

    # remove all the visited states, enqueue the unvisited
    filter!(s -> ∉(s.result_state, ucs_visited), successors)

    # prioritize the successor states that move the lower number tile
    sort!(successors, by = s -> s.tile_moved)
    for successor ∈ successors
        # using unit cost; increment the depth
        node = SearchNode(successor.result_state.board, ucs_tree.current, ucs_tree.current.cost_so_far + 1, ucs_tree.current.current_depth + 1)
        enqueue!(ucs_queue, QueueItem(node))
    end
    ucs_tree.current = dequeue!(ucs_queue).node
end

# ~~~~~~~~~~~~~~~~~~
# depth-first search
# ~~~~~~~~~~~~~~~~~~

# initialize tree, stack, and visited list
dfs_tree = SearchTree(INITIAL_STATE, GOAL_STATE)
dfs_stack = []

dfs_visited = []

# perform DFS algorithm
while dfs_tree.current.state != dfs_tree.goal
    append!(dfs_visited, [dfs_tree.current.state])
    successors = successor_states(dfs_tree.current.state)

    # remove all the visited states, enqueue the unvisited
    filter!(s -> ∉(s.result_state, dfs_visited), successors)
    # prioritize the successor states that move the lower number tile
    sort!(successors, by = s -> s.tile_moved, rev=true)

    for successor ∈ successors
        # using unit cost; increment the depth
        node = SearchNode(successor.result_state.board, dfs_tree.current, dfs_tree.current.cost_so_far + 1, dfs_tree.current.current_depth + 1)
        push!(dfs_stack, node)
    end
    dfs_tree.current = pop!(dfs_stack)
end

# ~~~~~~~~~~~~~~~~~~~
# iterative deepening
# ~~~~~~~~~~~~~~~~~~~

ids_tree = SearchTree(INITIAL_STATE, GOAL_STATE)
ids_stack = []
ids_visited = []

# 6! = 720 possible states, so upper limit on depth
for depth ∈ 1:720
    # reinitialize for each depth
    global ids_tree = SearchTree(INITIAL_STATE, GOAL_STATE)
    global ids_stack = []
    global ids_visited = []

    # perform depth-limited search for specified depth
    while ids_tree.current.state != ids_tree.goal
        append!(ids_visited, [ids_tree.current.state])
        successors = successor_states(ids_tree.current.state)

        # remove all the visited states, enqueue the unvisited
        filter!(s -> ∉(s.result_state, ids_visited), successors)
        # prioritize the successor states that move the lower number tile
        sort!(successors, by = s -> s.tile_moved, rev=true)

        for successor ∈ successors
            # using unit cost; increment the depth, but only allow to limited depth
            node = SearchNode(successor.result_state.board, ids_tree.current, ids_tree.current.cost_so_far + 1, ids_tree.current.current_depth + 1)
            if node.current_depth <= depth
                push!(ids_stack, node)
            end
        end

        # try to pop stack, if still nodes to visit
        if isempty(ids_stack)
            break
        end
        ids_tree.current = pop!(ids_stack)
    end
    if ids_tree.current.state == ids_tree.goal
        break
    end
end
