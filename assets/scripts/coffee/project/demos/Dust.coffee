###
#============================================================
#
# Prototype: Dust
#
# @author Matthew Wagerfield
#
#============================================================
###

class DEMOS.Dust extends THREE.Object3D

  ###
  #========================================
  # Class Variables
  #========================================
  ###

  @class = 'DEMOS.Dust'



  ###
  #========================================
  # Instance Variables
  #========================================
  ###

  innerRadius: null
  outerRadius: null
  length: null
  height: null
  width: null
  count: null

  # Object
  attributes: null
  uniforms: null
  geometry: null
  material: null
  system: null
  map: null

  # Properties
  innerRatio: null
  outerRatio: null
  minOpacity: null
  maxOpacity: null
  height: null
  width: null
  color: null
  size: null



  ###
  #========================================
  # Instance Methods
  #========================================
  ###

  initialise: (@innerRadius, @outerRadius, @count, @width, @height) =>
    @length = @outerRadius - @innerRadius
    @setProperties()
    @addDust()
    return

  setProperties: () =>

    # Ratios
    @innerRatio = 0.2
    @outerRatio = 0.8
    @speed = 2.5
    @phase = 4.0

    # Properties
    @color = '#BBDDFF'
    @minOpacity = 0.2
    @maxOpacity = 0.6
    @size = 4.5
    return

  addDust: () =>

    # Load the logo texture map.
    @map = THREE.ImageUtils.loadTexture '/assets/graphics/particle.png'

    # Cache the atmosphere attributes and uniforms.
    @attributes = SHADERS.Dust.cloneAttributes()
    @uniforms = SHADERS.Dust.cloneUniforms()

    # Cache and assign the shader maps.
    @uniforms.uMap.value = @map

    # Create and configure the geometry.
    @geometry = new THREE.Geometry

    # Create and configure the shader.
    @material = new SHADERS.Dust
      blending: THREE.AdditiveBlending
      attributes: @attributes
      uniforms: @uniforms
      transparent: true
      depthWrite: false
      depthTest: true

    for index in [0...@count]

      vertex = new THREE.Vector3
      vertex.x = Math.randomInRange 0, 360
      vertex.y = Math.randomInRange -90, 90
      vertex.z = Math.randomInRange 0.0, 1.0

      @geometry.vertices.push vertex

      step = new THREE.Vector4
      step.x = Math.randomInRange -1.0, 1.0
      step.y = Math.randomInRange -1.0, 1.0
      step.z = Math.randomInRange -1.0, 1.0
      step.w = Math.randomInRange 0.5, 1.0
      scale = Math.randomInRange 0.5, 1.0

      @attributes.aScale.value.push scale
      @attributes.aStep.value.push step

    # Create and configure the system.
    @system = new THREE.ParticleSystem @geometry, @material

    # Add the system to the object.
    @add @system

    # Update the uniforms.
    @updateUniforms()
    return

  updateUniforms: () =>
    if @uniforms?
      @uniforms.uRadii.value.x = @innerRadius + @innerRatio * @length
      @uniforms.uRadii.value.y = @innerRadius + @outerRatio * @length
      @uniforms.uColor.value = Color.vector3 @color
      @uniforms.uOpacity.value.x = @minOpacity
      @uniforms.uOpacity.value.y = @maxOpacity
      @uniforms.uScale.value = @height / 2
      @uniforms.uSpeed.value = @speed
      @uniforms.uPhase.value = @phase
      @uniforms.uSize.value = @size
    return

  update: (delta, time) =>
    @uniforms.uTime.value = time if @uniforms?
    @system.rotation.y += delta * 0.1 if @system?
    return

  resize: (@width, @height) =>
    @updateUniforms()
    return
