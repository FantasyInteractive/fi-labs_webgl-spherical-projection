###
#============================================================
#
# Prototype: Abstract Shader
#
# @author Matthew Wagerfield (Fantasy Interactive)
#
#============================================================
###

class SHADERS.Shader extends Class

  ###
  #========================================
  # Attributes
  #========================================
  ###

  ATTRIBUTES = null
    # aColor:
    #   type: 'c'
    #   value: []



  ###
  #========================================
  # Uniforms
  #========================================
  ###

  UNIFORMS = null
    # uScale:
    #   type: 'f'
    #   value: 1



  ###
  #========================================
  # Vertex Shader
  #========================================
  ###

  @VERTEX_SHADER = """

  // Attributes
  // attribute vec3 aColor;

  // Uniforms
  // uniform float uScale;

  // Varyings
  // varying vec3 vColor;

  // Main
  void main() {

    // vColor = aColor;

    // Set gl_Position
    gl_Position = projectionMatrix *
                  modelViewMatrix *
                  vec4(position, 1.0);
  }
  """



  ###
  #========================================
  # Fragment Shader
  #========================================
  ###

  @FRAGMENT_SHADER = """

  // Uniforms
  // uniform float uScale;

  // Varyings
  // varying vec3 vColor;

  // Main
  void main() {

    // Set gl_FragColor
    gl_FragColor = vec4(0.8, 0.0, 0.2, 1.0);
  }
  """



  ###
  #========================================
  # Class Methods
  #========================================
  ###

  @merge: (source, object) ->
    source = source or {}
    for name, property of object
      unless source[name]?
        source[name] = {}
        for key, value of property
          copy = value
          if _.isArray value
            copy = value.concat()
          else if _.isFunction value.clone
            copy = value.clone()
          else if value instanceof THREE.Matrix3
            copy = new THREE.Matrix3
            copy.elements = value.elements.concat()
          source[name][key] = copy
    return source

  @clone: (object) ->
    clone = {}
    for name, property of object
      clone[name] = {}
      for key, value of property
        copy = value
        if _.isArray value
          copy = value.concat()
        else if _.isFunction value.clone
          copy = value.clone()
        else if value instanceof THREE.Matrix3
          copy = new THREE.Matrix3
          copy.elements = value.elements.concat()
        clone[name][key] = copy
    return clone

  @cloneAttributes: () ->
    return @clone @ATTRIBUTES

  @cloneUniforms: () ->
    return @clone @UNIFORMS

  @cloneVertexShader: () ->
    return @VERTEX_SHADER

  @cloneFragmentShader: () ->
    return @FRAGMENT_SHADER



  ###
  #========================================
  # Constructor
  #========================================
  ###

  constructor: (parameters) ->
    parameters = parameters or {}
    parameters.vertexShader = @constructor.VERTEX_SHADER
    parameters.fragmentShader = @constructor.FRAGMENT_SHADER
    parameters.uniforms = @constructor.merge parameters.uniforms, @constructor.cloneUniforms()
    parameters.attributes = @constructor.merge parameters.attributes, @constructor.cloneAttributes()
    material = new THREE.ShaderMaterial parameters
    material[key] = value unless material[key]? for key, value of parameters
    return material
