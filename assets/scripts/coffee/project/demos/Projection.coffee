###
#============================================================
#
# Prototype: Projection
#
# @author Matthew Wagerfield
#
#============================================================
###

class DEMOS.Projection extends DEMOS.Demo

  ###
  #========================================
  # Constants
  #========================================
  ###

  DURATION = 4.0
  EASE = Quad.easeInOut


  ###
  #========================================
  # Class Variables
  #========================================
  ###

  @class = 'DEMOS.Projection'



  ###
  #========================================
  # Instance Variables
  #========================================
  ###

  buffer: null
  scene: null
  gui: null

  # Object
  attributes: null
  uniforms: null
  geometry: null
  material: null
  system: null
  origin: null
  dust: null
  map: null

  # Properties
  sphereRatio: null
  cylinderRatio: null
  displacement: null
  autoRotation: null
  showSource: null
  scatter: null
  color1: null
  color2: null
  alpha1: null
  alpha2: null
  cylinder: null
  sphere: null
  radius: null
  offset: null
  pulse: null
  size: null



  ###
  #========================================
  # Instance Methods
  #========================================
  ###

  initialise: (dimensions) =>
    super
    @gui = new dat.GUI
    @buffer = new DEMOS.ImageBuffer '/assets/images/elevation1080.png'
    @scene = new DEMOS.Scene @width, @height
    @scene.add @origin = new THREE.Object3D
    @$container.append @scene.$element
    @$container.append @scene.$vignetting
    @$container.append @scene.$lensflare
    @$container.append @scene.$scanlines
    @$container.append @buffer.$canvas
    @setProperties()
    @addEventListeners()
    @addControls()
    @addDust()
    return

  setProperties: () =>
    @displacement = 0.001
    @radius = 150
    @offset = 40

    @showSource = true
    @autoRotation = true
    @scatter = false
    @cylinder = false
    @sphere = false
    @pulse = false

    @cylinderRatio = 0.001
    @sphereRatio = 0.001

    @size = 2.0
    @color1 = '#FF4400'
    @color2 = '#2266FF'
    @alpha1 = 0.2
    @alpha2 = 0.4
    return

  addEventListeners: () =>
    @buffer.rendered.add @onBufferRendered
    return

  addControls: () =>
    controller = @gui.add @, 'showSource'
    controller.onChange (value) =>
      if value then @buffer.$canvas.removeClass 'hide' else @buffer.$canvas.addClass 'hide'

    controller = @gui.add @, 'cylinder'
    controller.onChange (value) =>
      TweenLite.to @, DURATION,
        onUpdate: => @updateUniforms()
        cylinderRatio: if value then 1 else 0
        ease: EASE

    controller = @gui.add @, 'sphere'
    controller.onChange (value) =>
      TweenLite.to @, DURATION,
        onUpdate: => @updateUniforms()
        sphereRatio: if value then 1 else 0
        ease: EASE

    controller = @gui.add @, 'autoRotation'
    controller.onChange (value) => @updateUniforms()

    controller = @gui.add @, 'displacement', 0, 1
    controller.onChange (value) => @updateUniforms()

    controller = @gui.add @, 'pulse'
    controller.onChange (value) => @updateUniforms()

    controller = @gui.add @, 'radius', 50, 400
    controller.onChange (value) => @updateUniforms()

    controller = @gui.add @, 'offset', 0, 100
    controller.onChange (value) => @updateUniforms()

    controller = @gui.add @, 'size', 1, 10
    controller.onChange (value) => @updateUniforms()

    controller = @gui.addColor @, 'color1'
    controller.onChange (value) => @updateUniforms()

    controller = @gui.add @, 'alpha1', 0, 1
    controller.onChange (value) => @updateUniforms()

    controller = @gui.addColor @, 'color2'
    controller.onChange (value) => @updateUniforms()

    controller = @gui.add @, 'alpha2', 0, 1
    controller.onChange (value) => @updateUniforms()
    return

  addDust: () =>
    @dust = new DEMOS.Dust
    @dust.initialise 200, 600, 1000, @width, @height
    @scene.scene.add @dust
    return

  addParticles: (width, height, data) =>

    RESOLUTION = width / 360

    # Load the logo texture map.
    @map = THREE.ImageUtils.loadTexture '/assets/graphics/particle.png'

    # Cache the attributes and uniforms.
    @attributes = SHADERS.Projection.cloneAttributes()
    @uniforms = SHADERS.Projection.cloneUniforms()
    @uniforms.uMap.value = @map

    # Create the geometry.
    @geometry = new THREE.Geometry

    # Create and configure the material.
    @material = new SHADERS.Projection
      blending: THREE.AdditiveBlending
      attributes: @attributes
      uniforms: @uniforms
      transparent: true
      depthWrite: false
      depthTest: true

    # Populate point geometry with vertices.
    for pixel in data
      step = Math.randomInRange 0, Math.PI * 2.0
      latitude  = (90  - pixel.y / RESOLUTION)
      longitude = (180 - pixel.x / RESOLUTION) * -1
      position = new THREE.Vector3
      position.x = pixel.x / width
      position.y = pixel.y / height * -1
      position.z = pixel.rgb
      range = new THREE.Vector2
      range.x = Math.randomInRange 0.0, 0.5
      range.y = Math.randomInRange 0.5, 1.0
      vertex = Map.project latitude, longitude
      @attributes.aPosition.value.push position
      @attributes.aRange.value.push range
      @attributes.aStep.value.push step
      @geometry.vertices.push vertex

    # Create and configure the point system.
    @system = new THREE.ParticleSystem @geometry, @material
    @system.rotation.x = Math.degreesToRadians -45

    # Add the points to the object.
    @origin.add @system

    # Update the uniforms.
    @updateUniforms()
    return

  updateUniforms: () =>
    if @uniforms?
      @uniforms.uColor1.value = Color.vector4 @color1, @alpha1
      @uniforms.uColor2.value = Color.vector4 @color2, @alpha2
      @uniforms.uScatter.value = if @scatter then 1 else 0
      @uniforms.uPulse.value = if @pulse then 1 else 0
      @uniforms.uDisplacement.value = @displacement
      @uniforms.uCylinderRatio.value = @cylinderRatio
      @uniforms.uSphereRatio.value = @sphereRatio
      @uniforms.uScale.value = @height / 2
      @uniforms.uRadius.value = @radius
      @uniforms.uOffset.value = @offset
      @uniforms.uSize.value = @size
    return

  update: (delta, time) =>
    @uniforms.uTime.value = time if @uniforms?
    @origin?.rotation.y += delta * 0.15 if @autoRotation
    @dust?.update delta, time
    @scene?.update delta, time
    return

  resize: (@width, @height) =>
    @dust?.resize @width, @height
    @scene?.resize @width, @height
    @updateUniforms()
    return



  ###
  #========================================
  # Callbacks
  #========================================
  ###

  onBufferRendered: (width, height, data) =>
    @addParticles width, height, data
    return
