###
#============================================================
#
# Prototype: Particles Shader
#
# @author Matthew Wagerfield (Fantasy Interactive)
#
#============================================================
###

class SHADERS.Projection extends SHADERS.Shader

  ###
  #========================================
  # Attributes
  #========================================
  ###

  @ATTRIBUTES =
    aPosition:
      type: 'v3'
      value: []
    aRange:
      type: 'v2'
      value: []
    aStep:
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
    uScatter:
      type: 'f'
      value: 1
    uPhase:
      type: 'f'
      value: 1
    uPulse:
      type: 'f'
      value: 1
    uTime:
      type: 'f'
      value: 1
    uCylinderRatio:
      type: 'f'
      value: 0
    uSphereRatio:
      type: 'f'
      value: 0
    uScale:
      type: 'f'
      value: 1
    uRadius:
      type: 'f'
      value: 1
    uOffset:
      type: 'f'
      value: 1
    uSize:
      type: 'f'
      value: 1
    uDisplacement:
      type: 'f'
      value: 0
    uColor1:
      type: 'v4'
      value: new THREE.Vector4 1, 1, 1, 1
    uColor2:
      type: 'v4'
      value: new THREE.Vector4 1, 1, 1, 1



  ###
  #========================================
  # Vertex Shader
  #========================================
  ###

  @VERTEX_SHADER = """ // GLSL

  // Includes
  #{UTILS}

  // Attributes
  attribute vec3 aPosition;
  attribute vec3 aRange;
  attribute float aStep;

  // Uniforms
  uniform float uSphereRatio;
  uniform float uCylinderRatio;
  uniform float uDisplacement;
  uniform float uScatter;
  uniform float uPulse;
  uniform float uTime;
  uniform sampler2D uMap;
  uniform float uRadius;
  uniform float uOffset;
  uniform float uScale;
  uniform float uSize;
  uniform vec4 uColor1;
  uniform vec4 uColor2;

  // Varyings
  varying vec4 vColor;

  // Main
  void main() {

    // Calculate pulse.
    float sine = sin(uTime * 2.5 - aPosition.y * 7.5);
    float pulse = map(sine, -1.0, 1.0, 0.0, 1.0);

    // Calculate displacement.
    float displacement = uDisplacement;
    if (uPulse == 1.0) displacement *= pulse;

    // Calculate radius.
    float offset = aPosition.z * uOffset * displacement;
    float radius = uRadius + offset;

    // Calculate longitude and latitude.
    float longitude = aPosition.x * 360.0 - 90.0;
    float latitude  = aPosition.y * 180.0 + 90.0;

    // Calculate plane position.
    vec3 planePosition;
    planePosition.x = aPosition.x * uRadius * 4.0 - uRadius * 2.0;
    planePosition.y = aPosition.y * uRadius * 2.0 + uRadius * 1.0;
    planePosition.z = offset;

    // Calculate cylinder position.
    vec3 cylinderPosition = planePosition;
    cylinderPosition.x = sin(aPosition.x * PI2) * radius * -1.0;
    cylinderPosition.z = cos(aPosition.x * PI2) * radius * -1.0;

    // Calculate sphere position.
    vec3 spherePosition = project(longitude, latitude, radius);

    // Derive the vertex position.
    vec3 mix1 = mix(planePosition, cylinderPosition, uCylinderRatio);
    vec3 mix2 = mix(mix1, spherePosition, uSphereRatio);
    vec4 modelViewPosition = modelViewMatrix * vec4(mix2, 1.0);

    // Set gl_PointSize
    gl_PointSize = uSize * (uScale / length(modelViewPosition.xyz));

    // Set gl_Position
    gl_Position = projectionMatrix * modelViewPosition;

    // Color
    vColor = mix(uColor1, uColor2, aPosition.z * displacement);
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

    // Set gl_FragColor
    gl_FragColor = vColor;
    gl_FragColor *= texture2D(uMap, vec2(gl_PointCoord.x, 1.0 - gl_PointCoord.y));
  }
  """
