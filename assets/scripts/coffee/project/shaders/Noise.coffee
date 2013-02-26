###
#============================================================
#
# Prototype: Noise Shader
#
# @author Matthew Wagerfield (Fantasy Interactive)
#
#============================================================
###

class SHADERS.Noise extends SHADERS.Shader

  ###
  #========================================
  # Attributes
  #========================================
  ###

  # @ATTRIBUTES =
  #   aUV:
  #     type: 'v2'
  #     value: []



  ###
  #========================================
  # Uniforms
  #========================================
  ###

  @UNIFORMS =
    uSize:
      type: 'v3'
      value: new THREE.Vector3 0, 0, 0
    uRange:
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
    uColor1:
      type: 'v4'
      value: new THREE.Vector4 1, 1, 1, 1
    uColor2:
      type: 'v4'
      value: new THREE.Vector4 1, 1, 1, 1
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
  #{SIMPLEX_NOISE}
  #{UTILS}

  // Uniforms
  uniform vec3 uSize;
  uniform vec2 uRange;
  uniform float uTime;
  uniform float uFrequency;
  uniform float uDisplacement;
  uniform vec4 uColor1;
  uniform vec4 uColor2;
  uniform vec4 uNoise;

  // Varyings
  varying vec4 vColor;

  // Surface
  float surface(vec3 coordinate) {
    float noise = 0.0;
    noise += uNoise.x * snoise(coordinate * 1.0);
    noise += uNoise.y * snoise(coordinate * 2.0);
    noise += uNoise.z * snoise(coordinate * 4.0);
    noise += uNoise.w * snoise(coordinate * 8.0);
    return noise;
  }

  // Main
  void main() {

    // Calculate the displacement of the vertex.
    float noise = surface(vec3(uv, uTime * uFrequency));
    float displacement = map(noise, uRange.x, uRange.y, 0.0, 1.0);
    float range = uSize.y * uDisplacement * displacement;
    float offset = uSize.y * -0.5;

    // Calculate vertex position.
    vec3 vertexPosition = vec3(position.x * uSize.x, range + offset, position.y * uSize.z);
    vec4 modelViewPosition = modelViewMatrix * vec4(vertexPosition, 1.0);

    // Set gl_Position
    gl_Position = projectionMatrix * modelViewPosition;

    // Color
    vColor = mix(uColor1, uColor2, (vertexPosition.y - offset) / uSize.y);
  }
  """



  ###
  #========================================
  # Fragment Shader
  #========================================
  ###

  @FRAGMENT_SHADER = """ // GLSL

  // Varyings
  varying vec4 vColor;

  // Main
  void main() {

    // Set gl_FragColor
    gl_FragColor = vColor;
  }
  """
