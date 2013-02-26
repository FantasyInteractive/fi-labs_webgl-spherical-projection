###
#============================================================
#
# Generic Utilities
#
# @author Matthew Wagerfield (Fantasy Interactive)
#
#============================================================
###

class Utils

  ###
  # Generates a GUID.
  # @param {number} length The length of the guid.
  # @param {string} prefix String to prefix the GUID with.
  # @return {string} The generated GUID.
  ###
  @guid = (length = 8, prefix = 'eco') ->
    guid = ((Math.random().toFixed 1).substr 2 for i in [0...length])
    guid = "#{prefix}#{guid.join ''}"
    return guid

  ###
  # Returns THREE blending hash object.
  # @return {object} Blending hash object.
  ###
  @blending =
    NoBlending: THREE.NoBlending
    NormalBlending: THREE.NormalBlending
    AdditiveBlending: THREE.AdditiveBlending
    SubtractiveBlending: THREE.SubtractiveBlending
    MultiplyBlending: THREE.MultiplyBlending
    CustomBlending: THREE.CustomBlending

  ###
  # Returns THREE destination hash object.
  # @return {object} Blending destination hash object.
  ###
  @destination =
    ZeroFactor: THREE.ZeroFactor
    OneFactor: THREE.OneFactor
    SrcColorFactor: THREE.SrcColorFactor
    OneMinusSrcColorFactor: THREE.OneMinusSrcColorFactor
    SrcAlphaFactor: THREE.SrcAlphaFactor
    OneMinusSrcAlphaFactor: THREE.OneMinusSrcAlphaFactor
    DstAlphaFactor: THREE.DstAlphaFactor
    OneMinusDstAlphaFactor: THREE.OneMinusDstAlphaFactor

  ###
  # Adds leading zeros to a given number.
  # @param {number} number The number to add the zeros to.
  # @param {number} length The number of zeros to add.
  # @return {string} The number with the leading zeros added.
  ###
  @leadingZeros = (number, length) ->
    number += ''
    return number if number.length > length
    number = '0' + number for n in [number.length...length]
    return number

  ###
  # Separates a number with commas at every 1000 units.
  # @return {string} The formatted number as a string.
  ###
  @comify = (string) ->
    string += ''
    x = string.split '.'
    x1 = x[0]
    x2 = if x.length > 1 then '.' + x[1] else ''
    expression = /(\d+)(\d{3})/
    while expression.test x1
      x1 = x1.replace expression, '$1' + ',' + '$2'
    return x1 + x2

  ###
  # Projects a Vector3 in a THREE Scene to a 2D coordinate.
  # @param {object} center An object with the dimensions of the screen center.
  # @param {object} camera A THREE Camera.
  # @param {object} object The parent THREE Object3D of the vector.
  # @param {object} vector A THREE Vector3 to project.
  # @return {object} The projected coordinate.
  ###
  @project: (center, camera, object, vector) ->
    coordinate = x:0, y:0
    return coordinate unless center? and camera? and object? and vector?

    # Create the scene graph.
    graph = @buildGraph object

    # Compose the scene matrix.
    matrix = new THREE.Matrix4
    @buildMatrix graph, matrix
    matrix.multiplyVector3 clone = vector.clone()

    # Project the vector by the matrix.
    projector = new THREE.Projector
    projector.projectVector clone, camera

    # Create the center coordinate.
    coordinate.x = Math.round center.x + clone.x * center.x
    coordinate.y = Math.round center.y - clone.y * center.y

    # Return the screen coordinate.
    return coordinate

  ###
  # Adds ellipsis to an element at the point where the height is exceeded.
  # @param {jQuery} $elements jQuery selection.
  # @param {number} height The maximum height.
  # @param {number} max The maximum characters to restrict when using fallback method.
  ###
  @ellipsis = ($elements, height, max = 200) ->
    expression = /\W*\s(\S)*$/g
    $elements.each (index, item) ->
      $element = $(item)
      string = $element.text()
      fallback = false
      append = false
      while $element.outerHeight() > height and max > 0
        append = true
        if not fallback and expression.test string
          $element.text (index, text) ->
            string = text.replace expression, ""
            return string
        else
          fallback = true
          $element.text (index, text) ->
            string = text.substr 0, max
            return string
          max -= 5
      $element.text string + "..." if append
    return

  ###
  # Adds ellipsis to an element at the point where the height is exceeded.
  # @param {THREE.Object3D} object The nested object.
  # @param {THREE.Object3D} height The root object to build the graph up to.
  # @return {array} Array of objects from the root to the object.
  ###
  @buildGraph = (object, root) ->
    graph = [object]
    graph.push object = object.parent while object.parent? and object isnt root
    return graph.reverse()

  ###
  # Adds ellipsis to an element at the point where the height is exceeded.
  # @param {array} graph Array of THREE.Object3D objects.
  # @param {THREE.Matrix4} matrix Matrix to apply graph transformations to.
  # @return {THREE.Matrix4} The transformed matrix.
  ###
  @buildMatrix = (graph, matrix) ->
    matrix.identity()
    matrix.multiplySelf object.matrix for object in graph
    return matrix

# Expose to the window.
@Utils = Utils
