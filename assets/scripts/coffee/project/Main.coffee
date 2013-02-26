###
#============================================================
#
# Prototype: Main Class
#
# @author Matthew Wagerfield
#
#============================================================
###

class PROJECT.Main extends Class

  ###
  #========================================
  # Constants
  #========================================
  ###



  ###
  #========================================
  # Class Variables
  #========================================
  ###

  @class = 'PROJECT.Main'



  ###
  #========================================
  # Instance Variables
  #========================================
  ###

  $window: null
  $document: null
  $container: null
  $html: null
  $body: null

  # Properties
  layout: null
  clock: null
  delta: null
  time: null
  demo: null
  raf: null



  ###
  #========================================
  # Instance Methods
  #========================================
  ###

  constructor: () ->

    # Cache selections.
    @$window = $ window
    @$document = $ document
    @$container = $ '#container'
    @$html = $ 'html'
    @$body = $ 'body'
    return

  initialise: () =>
    super

    # Add classes.
    @addClasses()

    # Add event listeners.
    @addEventListeners()

    # Create demo.
    @addDemo()

    # Kick off the animation loop.
    @animate()
    return

  addClasses: () =>
    @layout = new Layout
    @layout.initialise()
    @clock = new THREE.Clock
    return

  addEventListeners: () =>
    @layout.resized.add @onLayoutResized
    return

  addDemo: () =>
    demoName = window.location.href.replace /.*demo=/, ''
    className = (demoName.charAt 0).toUpperCase() + demoName.slice 1
    log 'demo:', demoName
    log 'class:', className
    @demo = new DEMOS[className] @$container
    @demo.initialise @layout.dimensions()
    return

  animate: () =>

    # Call the update method using the requestAnimationFrame callback.
    @raf = requestAnimationFrame @animate
    @delta = @clock.getDelta()
    @time = @clock.elapsedTime

    # Call the root update method.
    @update @delta, @time
    return

  update: (delta, time) =>
    @demo?.update delta, time
    return



  ###
  #========================================
  # Callbacks
  #========================================
  ###

  onLayoutResized: (dimensions) =>
    @demo?.resize dimensions.windowWidth, dimensions.windowHeight
    return



# Create instance of Main class.
@DEMO = DEMO = new PROJECT.Main
