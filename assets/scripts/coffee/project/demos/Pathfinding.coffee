###
#============================================================
#
# Prototype: Pathfinding
#
# @author Zaidin Amiot
# @author Matthew Wagerfield
#
#============================================================
###

class DEMOS.Pathfinding extends DEMOS.Demo

  ###
  #========================================
  # Class Variables
  #========================================
  ###

  GRID_STROKE = 1
  GRID_OFFSET = GRID_STROKE / 2
  SOLUTION_STROKE = 10
  SOLUTION_OFFSET = SOLUTION_STROKE / 2
  SOLUTION_JOIN = 'round'
  SOLUTION_CAP = 'round'
  COLORS =
    background : '#F3EEE8'
    grid       : 'rgba(0,0,0,0.15)'
    wall       : '#DD2222'
    start      : '#4488DD'
    end        : '#4488DD'
    opened     : '#CCCCCD'
    closed     : '#DDDDDD'
    failed     : '#FF8888'
    solution   : 'rgba(0,0,0,0.8)'

  ALGORITHMS = [
    'AStar'
    'BiAStar'
    'BreadthFirst'
    'BiBreadthFirst'
    'BestFirst'
    'BiBestFirst'
    'Dijkstra'
    'BiDijkstra'
    'JumpPoint'
  ]



  ###
  #========================================
  # Class Variables
  #========================================
  ###

  @class = 'DEMOS.Pathfinding'



  ###
  #========================================
  # Instance Variables
  #========================================
  ###

  $canvas: null

  gui: null
  canvas: null
  context: null

  allowDiagonal: null
  algorithm: null
  delay: null

  gridHeight: null
  gridWidth: null
  cellSize: null
  paddingX: null
  paddingY: null
  columns: null
  rows: null

  blocks: null
  walls: null

  operations: null
  operation: null
  solution: null
  start: null
  end: null



  ###
  #========================================
  # Instance Methods
  #========================================
  ###

  initialise: (dimensions) =>
    super
    Pathfinder.addHookOnNode()
    @gui = new dat.GUI
    @$canvas = $('<canvas>').attr width:@width, height:@height
    @canvas = @$canvas.get 0
    @context = @canvas.getContext '2d'
    @$container.append @$canvas
    @setProperties()
    @addEventListeners()
    @addControls()
    @reset()
    return

  setProperties: (dimensions) =>
    @algorithm = 'AStar'
    @allowDiagonal = true
    @columns = 16
    @delay = 0.005
    return

  addEventListeners: () =>
    @$canvas.on 'click', @onMouseClick
    return

  addControls: () =>
    controller = @gui.add @, 'columns', 5, 50
    controller.onChange (value) => @reset()
    controller.step 1

    controller = @gui.add @, 'delay', 0, 0.2
    controller.onChange (value) => @solve()

    controller = @gui.add @, 'algorithm', ALGORITHMS
    controller.onChange (value) => @solve()

    controller = @gui.add @, 'allowDiagonal'
    controller.onChange (value) => @solve()

    controller = @gui.add @, 'solve'
    controller = @gui.add @, 'reset'
    return

  reset: () =>
    @walls = []
    @blocks = []
    @solution = []

    @cellSize = Math.ceil @width / @columns
    @rows = Math.ceil @height / @cellSize

    @gridWidth = @cellSize * @columns
    @gridHeight = @cellSize * @rows

    @paddingX = Math.floor (@width - @gridWidth) / 2
    @paddingY = Math.floor (@height - @gridHeight) / 2

    T = Math.floor (@rows - 1) / 2
    L = Math.floor (@columns - 1) / 4
    R = @columns - L - 1

    @start =
      x: L
      y: T
      index: L + T * @columns

    @end =
      x: R
      y: T
      index: R + T * @columns

    @blocks[@start.index] = COLORS.start
    @blocks[@end.index] = COLORS.end

    @draw()
    return

  solve: () =>
    Pathfinder.initialise @columns, @rows, Pathfinder.algorithms[@algorithm], allowDiagonal:@allowDiagonal
    Pathfinder.setWalkable Pathfinder.indexToCoordinate index for value, index in @walls when value?
    @solution = Pathfinder.solution @start, @end
    TweenLite.killDelayedCallsTo @step
    @operation = 0
    @step()
    return

  step: () =>
    @draw()
    call = @operation < Pathfinder.operations.length
    TweenLite.delayedCall @delay, @step if call
    @operation++
    return

  draw: () =>
    @drawBackground()
    @drawBlocks()
    @drawGrid()
    @drawSolution()
    return

  drawBackground: () =>
    @context.fillStyle = COLORS.background
    @context.fillRect 0, 0, @width, @height
    return

  drawGrid: () =>
    @context.beginPath()

    # Border
    parameters = [
      @paddingX - GRID_OFFSET
      @paddingY - GRID_OFFSET
      @gridWidth + GRID_STROKE
      @gridHeight + GRID_STROKE
    ]
    @context.rect parameters...

    # Vertical Lines
    for x in [1...@columns]
      @context.moveTo @paddingX + GRID_OFFSET + x * @cellSize, @paddingY
      @context.lineTo @paddingX + GRID_OFFSET + x * @cellSize, @paddingY + @gridHeight

    # Horizontal Lines
    for y in [1...@rows]
      @context.moveTo @paddingX, @paddingY + GRID_OFFSET + y * @cellSize
      @context.lineTo @paddingX + @gridWidth, @paddingY + GRID_OFFSET + y * @cellSize

    # Stroke Lines
    @context.strokeStyle = COLORS.grid
    @context.lineWidth = GRID_STROKE
    @context.stroke()
    return

  drawBlocks: () =>

    # Walker
    for operation, index in Pathfinder.operations when index < @operation
      point = @scale operation.x, operation.y
      @context.fillStyle = COLORS[operation.attr]
      @context.fillRect point.x, point.y, @cellSize, @cellSize

    # Start, End & Walls
    for key, value of @blocks when value?
      point = @map key
      @context.fillStyle = value
      @context.fillRect point.x, point.y, @cellSize, @cellSize
    return

  drawSolution: () =>
    return unless @operation is Pathfinder.operations.length
    @context.beginPath()
    for value, index in @solution
      point = @map value
      offset = Math.floor @cellSize / 2
      point.x += offset
      point.y += offset
      method = if index then 'lineTo' else 'moveTo'
      @context[method] point.x, point.y
    @context.strokeStyle = COLORS.solution
    @context.lineWidth = SOLUTION_STROKE
    @context.lineJoin = SOLUTION_JOIN
    @context.lineCap = SOLUTION_CAP
    @context.stroke()
    return

  map: (index) =>
    x = index % @columns
    y = Math.floor index / @columns
    return @scale x, y

  scale: (x, y) =>
    x *= @cellSize
    x += @paddingX
    y *= @cellSize
    y += @paddingY
    return x:x, y:y

  resize: (@width, @height) =>
    @$canvas.attr width:@width, height:@height
    @reset()
    return



  ###
  #========================================
  # Callbacks
  #========================================
  ###

  onMouseClick: (event) =>
    x = Math.floor (event.pageX - @paddingX) / @cellSize
    y = Math.floor (event.pageY - @paddingY) / @cellSize
    index = x + y * @columns
    isStart = @blocks[index] is COLORS.start
    isEnd   = @blocks[index] is COLORS.end
    isWall  = @blocks[index] is COLORS.wall
    return if isStart or isEnd
    @blocks[index] = @walls[index] = if isWall then null else COLORS.wall
    @draw()
    return
