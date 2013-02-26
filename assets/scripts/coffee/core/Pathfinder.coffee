###
#============================================================
#
# Pathfinder
#
# Collection of methods for Pathfinding.js.
#
# @requires underscore.js
# @see http://underscorejs.org/
#
# @author Zaidin Amiot (Fantasy Interactive)
#
#============================================================
###

class Pathfinder

  ###
  #========================================
  # Constants
  #========================================
  ###

  @algorithms =
    AStar: @AStar = PF.AStarFinder
    BiAStar: @BiAStar = PF.BiAStarFinder
    BreadthFirst: @BreadthFirst = PF.BreadthFirstFinder
    BiBreadthFirst: @BiBreadthFirst = PF.BiBreadthFirstFinder
    BestFirst: @BestFirst = PF.BreadthFirstFinder
    BiBestFirst: @BiBestFirst = PF.BiBestFirstFinder
    Dijkstra: @Dijkstra = PF.DijkstraFinder
    BiDijkstra: @BiDijkstra = PF.BiDijkstraFinder
    JumpPoint: @JumpPoint = PF.JumpPointFinder



  ###
  #========================================
  # Static Properties
  #========================================
  ###

  @grid = null
  @nodes = null
  @finder = null
  @horizontalSegments = null
  @verticalSegments = null
  @operations = []



  ###
  #========================================
  # Static Methods
  #========================================
  ###

  ###
  # Set the grid and the finder.
  # @param {number} horizontalSegments Number of horizontal segments.
  # @param {number} verticalSegments Number of vertical segments.
  # @param {constant} finder Type of pathfinding finder.
  # @param {object} options Options for the finder.
  ###
  @initialise = (horizontalSegments, verticalSegments, finder, options) ->
    @setGrid(horizontalSegments, verticalSegments)
    @setFinder(finder, options)
    @operations = []
    return

  # Patch PF.node class
  @addHookOnNode: () =>
    Object.defineProperty PF.Node.prototype, 'opened',
      get: ()->
        return @._opened
      set: (value)->
        @._opened = value
        Pathfinder.operations.push
          x: @x
          y: @y
          attr: 'opened'
          value: value
        return

    Object.defineProperty PF.Node.prototype, 'closed',
      get: ()->
        return @._closed
      set: (value)->
        @._closed = value
        Pathfinder.operations.push
          x: @x
          y: @y
          attr: 'closed'
          value: value
        return

  ###
  # Set the grid.
  # @param {number} horizontalSegments Number of horizontal segments.
  # @param {number} verticalSegments Number of vertical segments.
  ###
  @setGrid = (@horizontalSegments, @verticalSegments, matrix=[]) ->
    matrix = @createMatrix() if matrix.length is 0
    @nodes = @horizontalSegments * @verticalSegments
    @grid = new PF.Grid @horizontalSegments, @verticalSegments, matrix
    return

  ###
  # Create empty matrix.
  # @param {number} horizontalSegments Number of horizontal segments.
  # @param {number} verticalSegments Number of vertical segments.
  # @return {array} Return a bi-dimensional array filled with 0.
  ###
  @createMatrix = () ->
    return ((0 for i in [0...@horizontalSegments]) for i in [0...@verticalSegments])

  ###
  # Set the finder.
  # @param {constant} finder Type of pathfinding finder.
  # @param {object} options Options for the finder.
  ###
  @setFinder = (finder=@AStar, options={}) ->
    @finder = new finder options
    return

  ###
  # Set walkable.
  # @param {array} node Simple tuple with x/y coordinates.
  # @param {boolean} state Walkable state of the grid.
  ###
  @setWalkable = (node, state=false) ->
    return unless @grid
    @grid.setWalkableAt node[0], node[1], state
    return

  ###
  # Return a solution.
  # @param {array} nodes Start and end nodes as a {x, y} object.
  # @return {array} Return an array of points.
  ###
  @solution = (start, end) ->
    return [] unless @grid
    solution = @finder.findPath start.x,
      start.y, end.x, end.y, @grid.clone()
    return (@coordinateToIndex node for node in solution)

  ###
  # Return a complex solution.
  # @param {array} nodes Start and end nodes as a {x, y} object.
  # @return {array} Return an array of points.
  ###
  @complexify = (start, end, complexity = 0.5) ->
    @setGrid(@horizontalSegments, @verticalSegments)
    simple = @solution start, end
    domain = simple[1...-1]
    @setWalkable @indexToCoordinate domain[node] for node in @pickPoints domain.length, Math.ceil domain.length * complexity
    return @solution start, end

  ###
  # get coordinate in the matrix from index
  # @param {int} index Index of the node in the nodes collection.
  # @return {array} Return a tuple of coordinates.
  ###
  @indexToCoordinate = (index) ->
    x = index % @horizontalSegments
    y = Math.floor index / @horizontalSegments
    return [x, y]

  ###
  # get index from coordinates
  # @param {array} coordinate Tuple of coordinates.
  # @return {int} index Index of the node in the nodes collection.
  ###
  @coordinateToIndex = (coordinate) ->
    return coordinate[0] + coordinate[1] * @horizontalSegments

  ###
  # Return n random indexes in the collection.
  # @param {int} length Length of the collection.
  # @param {int} numbers Number of elements returned.
  # @return {array} Return an array of indexes.
  ###
  @pickPoints = (length=@nodes, numbers=2) ->
    collection = [0...length]
    data = []
    while data.length < numbers
      data = data.concat collection.splice Math.randomInt(length), 1
    return data
