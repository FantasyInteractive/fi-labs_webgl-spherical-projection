###
#============================================================
#
# Prototype: Dust Shader
#
# @author Matthew Wagerfield (Fantasy Interactive)
#
#============================================================
###

class SHADERS.Dust extends SHADERS.Shader

  ###
  #========================================
  # Attributes
  #========================================
  ###

  @ATTRIBUTES =
    aScale:
      type: 'f'
      value: []
    aStep:
      type: 'v4'
      value: []



  ###
  #========================================
  # Uniforms
  #========================================
  ###

  @UNIFORMS =
    uAlpha:
      type: 'f'
      value: 1
    uTime:
      type: 'f'
      value: 0
    uSpeed:
      type: 'f'
      value: 0
    uPhase:
      type: 'f'
      value: 0
    uScale:
      type: 'f'
      value: 1
    uSize:
      type: 'f'
      value: 1
    uOpacity:
      type: 'v2'
      value: new THREE.Vector2
    uRadii:
      type: 'v2'
      value: new THREE.Vector2
    uMap:
      type: 't'
      value: new THREE.Texture
    uColor:
      type: 'v3'
      value: new THREE.Vector3 1, 1, 1



  ###
  #========================================
  # Vertex Shader
  #========================================
  ###

  @VERTEX_SHADER = """ // GLSL

  // Includes
  #{UTILS}

  // Attributes
  attribute float aScale;
  attribute vec4 aStep;

  // Uniforms
  uniform sampler2D uMap;
  uniform float uAlpha;
  uniform float uTime;
  uniform float uSpeed;
  uniform float uPhase;
  uniform float uScale;
  uniform float uSize;
  uniform vec2 uOpacity;
  uniform vec3 uColor;
  uniform vec2 uRadii;

  // Varyings
  varying vec4 vColor;

  // Main
  void main() {

    // Calculate the position of the vertex.
    float speed = uTime * uSpeed;
    float longitude = position.x + speed * aStep.x;
    float latitude = position.y + speed * aStep.y;
    float radius = map(position.z, 0.0, 1.0, uRadii.x, uRadii.y);

    // Calculate vertex and model view position.
    vec3 vertexPosition = project(longitude, latitude, radius);
    // vec3 vertexPosition = project(longitude, latitude, 100.0);
    vec4 modelViewPosition = modelViewMatrix * vec4(vertexPosition, 1.0);

    // Set gl_PointSize
    gl_PointSize = uSize * (uScale / length(modelViewPosition.xyz)) * aScale;

    // Set gl_Position
    gl_Position = projectionMatrix * modelViewPosition;

    // Color
    float phase = sin(uTime * uPhase * aStep.w);
    vColor = vec4(uColor, map(phase, -1.0, 1.0, uOpacity.x, uOpacity.y));
    vColor.w *= uAlpha;
  }
  """



  ###
  #========================================
  # Fragment Shader
  #========================================
  ###

  @FRAGMENT_SHADER = """ // GLSL

  // Uniforms
  uniform sampler2D uMap;

  // Varyings
  varying vec4 vColor;

  // Main
  void main() {

    // Map.
    vec4 map = texture2D(uMap, vec2(gl_PointCoord.x, 1.0 - gl_PointCoord.y));

    // Set gl_FragColor
    gl_FragColor = vColor * map;
  }
  """
