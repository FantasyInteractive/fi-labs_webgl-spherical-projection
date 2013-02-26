###
#============================================================
#
# Prototype: HeatmapCanvas
#
# @author Matthew Wagerfield
#
#============================================================
###

class DEMOS.HeatmapCanvas extends Class

  ###
  #========================================
  # Class Variables
  #========================================
  ###

  @class = 'DEMOS.HeatmapCanvas'



  ###
  #========================================
  # Instance Variables
  #========================================
  ###

  $element: null
  $window: null

  resolution: null
  height: null
  width: null

  maskRendered: null
  maskHeatmap: null
  rendered: null
  element: null
  heatmap: null
  context: null
  canvas: null
  buffer: null



  ###
  #========================================
  # Instance Methods
  #========================================
  ###

  constructor: (@resolution) ->
    @maskHeatmap = false
    @maskRendered = false
    @width = 360 * @resolution
    @height = 180 * @resolution
    @buffer = new DEMOS.ImageBuffer "/assets/images/land#{@width}.png"
    @rendered = new signals.Signal
    @$window = $ window
    @$output = $('<canvas class="output">').attr width:@width, height:@height
    @$element = $ '<div class="heatmap">'
    @$element.css width:@width, height:@height
    @$element.append @$output
    @element = @$element.get 0
    @gradient = {}
    @gradient['0.00'] = 'rgb( 0,   0,   255 )'
    @gradient['0.25'] = 'rgb( 0,   255, 255 )'
    @gradient['0.50'] = 'rgb( 0,   255, 0   )'
    @gradient['0.75'] = 'rgb( 255, 255, 0   )'
    @gradient['1.00'] = 'rgb( 255, 0,   0   )'
    @heatmap = heatmapFactory.create element:@element, gradient:@gradient
    @heatmapCanvas = @heatmap.get 'canvas'
    @heatmapContext = @heatmap.get 'ctx'
    @outputCanvas = @$output.get 0
    @outputContext = @outputCanvas.getContext '2d'
    @addEventListeners()
    @setRadii 5, 40
    return

  addEventListeners: () =>
    @$element.on 'mousedown', @onHeatmapMouseDown
    @$element.on 'click', @onHeatmapMouseClick
    @buffer.rendered.add @onBufferRendered
    return

  visible: (value) =>
    if value then @$element.removeClass 'hide' else @$element.addClass 'hide'
    return

  mask: (value) =>
    @maskHeatmap = value
    @render()
    return

  addPoint: (x, y) =>
    @heatmap.store.addDataPoint x, y
    @render()
    return

  setRadii: (inner, outer) =>
    @heatmap.set 'radiusIn', inner
    @heatmap.set 'radiusOut', outer
    @render()
    return

  render: () =>
    multipliers = []
    if @maskRendered and @maskHeatmap
      multipliers.push @buffer.context.getImageData 0, 0, @width, @height
    sourceData = @heatmapContext.getImageData 0, 0, @width, @height
    outputData = Canvas.multiply sourceData, multipliers
    @outputContext.putImageData outputData, 0, 0
    @rendered.dispatch outputData
    return

  clear: () =>
    @heatmap.clear()
    @render()
    return

  generate: (count) =>
    @heatmap.clear()
    @heatmap.store.generateRandomDataSet count
    @render()
    return



  ###
  #========================================
  # Callbacks
  #========================================
  ###

  onHeatmapMouseClick: (event) =>
    @addPoint event.offsetX, event.offsetY
    return

  onHeatmapMouseDown: (event) =>
    @$element.on 'mousemove', @onHeatmapMouseMove
    @$window.on 'mouseup', @onWindowMouseUp
    return

  onHeatmapMouseMove: (event) =>
    @addPoint event.offsetX, event.offsetY
    return

  onWindowMouseUp: (event) =>
    @$element.off 'mousemove', @onHeatmapMouseMove
    @$window.off 'mouseup', @onWindowMouseUp
    return

  onBufferRendered: (width, height, data) =>
    @maskRendered = true
    @render()
    return
