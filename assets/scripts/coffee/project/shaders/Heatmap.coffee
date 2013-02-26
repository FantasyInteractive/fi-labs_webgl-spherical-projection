###
#============================================================
#
# Prototype: Heatmap Shader
#
# @author Matthew Wagerfield (Fantasy Interactive)
#
#============================================================
###

class SHADERS.Heatmap extends SHADERS.Shader

  ###
  #========================================
  # Attributes
  #========================================
  ###

  @ATTRIBUTES =
    aHue:
      type: 'v3'
      value: []
    aColor:
      type: 'v4'
      value: []
    aNormal:
      type: 'v3'
      value: []
    aType:
      type: 'f'
      value: []



  ###
  #========================================
  # Uniforms
  #========================================
  ###

  @UNIFORMS =
    uMap:
      type: 't'
      value: new THREE.Texture
    uRadii:
      type: 'v2'
      value: new THREE.Vector2 0, 1
    uDisplacement:
      type: 'f'
      value: 0
    uFrequency:
      type: 'f'
      value: 0
    uTime:
      type: 'f'
      value: 1
    uScale:
      type: 'f'
      value: 1
    uSize:
      type: 'f'
      value: 1
    uAlpha:
      type: 'v3'
      value: new THREE.Vector3 1, 1, 1
    uNoise:
      type: 'v4'
      value: new THREE.Vector4 0, 0, 0, 0



  ###
  #========================================
  # Vertex Shader
  #========================================
  ###

  @VERTEX_SHADER = """ // GLSL

  // Includes
  #{UTILS}

  // Attributes
  attribute vec3 aHue;
  attribute vec4 aColor;
  attribute vec3 aNormal;
  attribute float aType;

  // Uniforms
  uniform sampler2D uMap;
  uniform vec2 uRadii;
  uniform float uTime;
  uniform float uSize;
  uniform float uScale;
  uniform float uFrequency;
  uniform float uDisplacement;
  uniform vec3 uAlpha;

  // Varyings
  varying float vType;
  varying vec4 vColor;

  // Main
  void main() {

    // Calculate length.
    float radius = uRadii.x;
    float delta = uRadii.y - uRadii.x;
    float power = 1.0 - aHue.x * 1.5;
    float displacement = power * uDisplacement;
    if (aType != 1.0) radius += delta * displacement;

    // Calculate vertex position.
    vec3 vertexPosition = aNormal * radius;

    // Set the model view position.
    vec4 modelViewPosition = modelViewMatrix * vec4(vertexPosition, 1.0);

    // Set gl_PointSize
    gl_PointSize = uSize * (uScale / length(modelViewPosition.xyz));

    // Set gl_Position
    gl_Position = projectionMatrix * modelViewPosition;

    // Type
    vType = aType;

    // Color
    vColor = aColor;
    if (aType == 0.0) vColor.w = uAlpha.x * (1.0 - uDisplacement);
    if (aType == 1.0) vColor.w = uAlpha.y * uDisplacement;
    if (aType == 2.0) vColor.w = uAlpha.z * uDisplacement;
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
  varying float vType;
  varying vec4 vColor;

  // Main
  void main() {

    // Set gl_FragColor
    gl_FragColor = vColor;
    if (vType == 0.0) gl_FragColor *= texture2D(uMap, vec2(gl_PointCoord.x, 1.0 - gl_PointCoord.y));
  }
  """
