###
#============================================================
#
# Prototype: Abstract Demo Class
#
# @author Matthew Wagerfield
#
#============================================================
###

class DEMOS.Scene extends Class

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

  @class = 'DEMOS.Scene'



  ###
  #========================================
  # Instance Variables
  #========================================
  ###

  $hotspot: null
  $vignetting: null
  $scanlines: null
  $lensflare: null

  renderer: null
  controls: null
  element: null
  camera: null
  origin: null
  scene: null

  aspect: null
  height: null
  width: null
  near: null
  far: null
  fov: null



  ###
  #========================================
  # Instance Methods
  #========================================
  ###

  constructor: (@width, @height, @fov = 60, @near = 1, @far = 1e6) ->
    @aspect = @width / @height
    @origin = new THREE.Object3D
    @scene = new THREE.Scene
    @scene.add @origin
    @camera = new THREE.PerspectiveCamera @fov, @aspect, @near, @far
    @camera.position.z = 500
    @renderer = new THREE.WebGLRenderer
    @renderer.setSize @width, @height
    @element = @renderer.domElement
    @$element = $(@renderer.domElement).addClass 'scene'
    @$vignetting = $('<div>').addClass 'vignetting'
    @$scanlines = $('<div>').addClass 'scanlines'
    @$lensflare = $('<div>').addClass 'lensflare'
    @controls = new TrackballControls @origin, @element
    @addEventListeners()
    return

  addEventListeners: () =>
    @$element.on 'mousedown', @onMouseDown
    @$element.on 'mouseup', @onMouseUp
    return

  add: (object) =>
    @origin.add object
    return

  remove: (object) =>
    @origin.remove object
    return

  update: (delta, time) =>
    @controls?.update()
    @renderer?.render @scene, @camera
    return

  resize: (@width, @height) =>
    @aspect = @width / @height
    @camera?.aspect = @aspect
    @camera?.updateProjectionMatrix()
    @renderer?.setSize @width, @height
    return



  ###
  #========================================
  # Callbacks
  #========================================
  ###

  onMouseDown: (event) =>
    @$element.addClass 'grabbing'
    return

  onMouseUp: (event) =>
    @$element.removeClass 'grabbing'
    return
