###
#============================================================
#
# Trackball Controls for three.js
#
# @requires three.js
# @see https://github.com/mrdoob/three.js/
#
# @requires jquery.js
# @see http://jquery.com/
#
# @author Matthew Wagerfield (Fantasy Interactive)
#
#============================================================
###

class TrackballControls

  ###
  #========================================
  # Constants
  #========================================
  ###

  DELAY = 200

  X_AXIS = new THREE.Vector3 1, 0, 0
  Y_AXIS = new THREE.Vector3 0, 1, 0
  Z_AXIS = new THREE.Vector3 0, 0, 1



  ###
  #========================================
  # Instance Variables
  #========================================
  ###

  $window: null
  $element: null

  object: null
  element: null

  dragging: null
  dragged: null

  roll: null
  pan: null

  current: null
  previous: null



  ###
  #========================================
  # Instance Methods
  #========================================
  ###

  constructor: (@object, @element) ->

    @$window = $(window)
    @$element = $(@element)

    @current = new THREE.Vector2
    @previous = new THREE.Vector2

    @roll = @addControl 0.00025, 0.92
    @roll.velocity = new THREE.Vector2
    @roll.delta = new THREE.Vector2

    @pan = @addControl 0.015, 0.98
    @pan.velocity = new THREE.Vector2
    @pan.delta = new THREE.Vector2

    @dragged = new signals.Signal
    @dragging = false

    @addEventListeners()
    return

  addControl: (speed, friction) =>
    friction: friction
    speed: speed
    enabled: yes

  addEventListeners: () =>
    @$element.on 'mousedown', @onMouseDown
    return

  rotateAroundObjectAxis: (object, axis, radians) =>
    rotationObjectMatrix = new THREE.Matrix4
    rotationObjectMatrix.makeRotationAxis axis.normalize(), radians
    object.matrix.multiplySelf rotationObjectMatrix
    object.rotation.setEulerFromRotationMatrix object.matrix
    return

  rotateAroundWorldAxis: (object, axis, radians) =>
    rotationWorldMatrix = new THREE.Matrix4
    rotationWorldMatrix.makeRotationAxis axis.normalize(), radians
    rotationWorldMatrix.multiplySelf object.matrix
    object.matrix = rotationWorldMatrix
    object.rotation.setEulerFromRotationMatrix object.matrix
    return

  update: () =>

    # Pan
    if @pan.enabled
      @pan.velocity.addSelf @pan.delta.multiplyScalar @pan.speed
      @object.position.x =  @pan.velocity.x
      @object.position.y = -@pan.velocity.y
      @pan.velocity.multiplyScalar @pan.friction

    # Roll.
    if @roll.enabled
      @roll.velocity.addSelf @roll.delta.multiplyScalar @roll.speed
      @rotateAroundWorldAxis @object, X_AXIS, @roll.velocity.y
      @rotateAroundWorldAxis @object, Y_AXIS, @roll.velocity.x
      @roll.velocity.multiplyScalar @roll.friction
    return



  ###
  #========================================
  # Callbacks
  #========================================
  ###

  onMouseDown: (event) =>
    event.preventDefault()
    @dragged.dispatch @dragging = true
    @$window.on 'mouseup', @onMouseUp
    @$window.on 'mousemove', @onMouseMove
    @current.set event.pageX, event.pageY
    @previous.set event.pageX, event.pageY
    return

  onMouseMove: (event) =>
    @current.set event.pageX, event.pageY
    @roll.delta.sub @current, @previous
    @pan.delta.sub @current, @previous
    @previous.copy @current
    return

  onMouseUp: (event) =>
    @$window.off 'mousemove', @onMouseMove
    @$window.off 'mouseup', @onMouseUp
    @dragged.dispatch @dragging = false
    return
