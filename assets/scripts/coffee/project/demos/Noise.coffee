###
#============================================================
#
# Prototype: Noise
#
# @author Matthew Wagerfield
#
#============================================================
###

class DEMOS.Noise extends DEMOS.Demo

  ###
  #========================================
  # Constants
  #========================================
  ###

  SEGMENTS = 100



  ###
  #========================================
  # Class Variables
  #========================================
  ###

  @class = 'DEMOS.Noise'



  ###
  #========================================
  # Instance Variables
  #========================================
  ###

  scene: null
  gui: null

  # Object
  attributes: null
  uniforms: null
  geometry: null
  material: null
  terrain: null
  origin: null
  cage: null
  dust: null

  # Properties
  autoRotation: null
  displacement: null
  frequency: null
  color1: null
  color2: null
  alpha1: null
  alpha2: null
  noiseX: null
  noiseY: null
  noiseZ: null
  noiseW: null
  range: null
  pulse: null
  depth: null
  size: null



  ###
  #========================================
  # Instance Methods
  #========================================
  ###

  initialise: (dimensions) =>
    super
    @gui = new dat.GUI
    @scene = new DEMOS.Scene @width, @height
    @scene.add @origin = new THREE.Object3D
    @$container.append @scene.$element
    @$container.append @scene.$vignetting
    @$container.append @scene.$lensflare
    @$container.append @scene.$scanlines
    @setProperties()
    @addControls()
    @addParticles()
    @addDust()
    @addCage()
    @updateObjects()
    return

  setProperties: () =>
    @size = 400
    @depth = 240
    @displacement = 0.001

    @color1 = '#FF4400'
    @color2 = '#8866FF'
    @alpha1 = 0.2
    @alpha2 = 0.2

    @autoRotation = true
    @pulse = false

    @frequency = 0.1

    @noiseX = 1.0
    @noiseY = 0.6
    @noiseZ = 0.4
    @noiseW = 0.2

    @range = 4.2
    return

  addControls: () =>
    controller = @gui.add @, 'size', 100, 1000
    controller.onChange (value) => @updateObjects()

    controller = @gui.add @, 'depth', 100, 1000
    controller.onChange (value) => @updateObjects()

    controller = @gui.add @, 'displacement', 0, 1
    controller.onChange (value) => @updateObjects()

    controller = @gui.add @, 'range', 0, 10
    controller.onChange (value) => @updateObjects()

    controller = @gui.add @, 'pulse'
    controller.onChange (value) => @updateObjects()

    controller = @gui.add @, 'frequency', 0, 1
    controller.onChange (value) => @updateObjects()

    controller = @gui.add @, 'noiseX', 0, 1
    controller.onChange (value) => @updateObjects()

    controller = @gui.add @, 'noiseY', 0, 1
    controller.onChange (value) => @updateObjects()

    controller = @gui.add @, 'noiseZ', 0, 1
    controller.onChange (value) => @updateObjects()

    controller = @gui.add @, 'noiseW', 0, 1
    controller.onChange (value) => @updateObjects()

    controller = @gui.addColor @, 'color1'
    controller.onChange (value) => @updateObjects()

    controller = @gui.add @, 'alpha1', 0, 1
    controller.onChange (value) => @updateObjects()

    controller = @gui.addColor @, 'color2'
    controller.onChange (value) => @updateObjects()

    controller = @gui.add @, 'alpha2', 0, 1
    controller.onChange (value) => @updateObjects()

    controller = @gui.add @, 'autoRotation'
    controller.onChange (value) => @updateObjects()
    return

  addDust: () =>
    @dust = new DEMOS.Dust
    @dust.initialise 200, 600, 1000, @width, @height
    @scene.scene.add @dust
    return

  addCage: () =>
    material = new THREE.MeshBasicMaterial
      blending: THREE.AdditiveBlending
      side: THREE.DoubleSide
      transparent: true
      depthWrite: false
      depthTest: true
      wireframe: true
      color: 0xFFFFFF
      opacity: 0.05
    segments = 10
    geometry = new THREE.CubeGeometry 1, 1, 1, segments, segments, segments
    @cage = new THREE.Mesh geometry, material
    @cage.scale.set @size, @depth, @size
    @origin.add @cage
    return

  addParticles: () =>

    # Cache the attributes and uniforms.
    @attributes = SHADERS.Noise.cloneAttributes()
    @uniforms = SHADERS.Noise.cloneUniforms()

    # Create the geometry.
    @geometry = new THREE.PlaneGeometry 1, 1, SEGMENTS, SEGMENTS
    THREE.GeometryUtils.triangulateQuads @geometry

    # Create and configure the material.
    @material = new SHADERS.Noise
      blending: THREE.AdditiveBlending
      attributes: @attributes
      side: THREE.DoubleSide
      uniforms: @uniforms
      transparent: true
      depthWrite: false
      depthTest: true
      wireframe: true

    # Create and configure the mesh.
    @terrain = new THREE.Mesh @geometry, @material
    @origin.add @terrain
    return

  updateObjects: () =>
    @updateUniforms()
    @updateCage()
    return

  updateUniforms: () =>
    if @uniforms?
      @uniforms.uNoise.value.set @noiseX, @noiseY, @noiseZ, @noiseW
      @uniforms.uColor1.value = Color.vector4 @color1, @alpha1
      @uniforms.uColor2.value = Color.vector4 @color2, @alpha2
      @uniforms.uSize.value.set @size, @depth, @size
      @uniforms.uDisplacement.value = @displacement
      @uniforms.uRange.value.set -@range, @range
      @uniforms.uFrequency.value = @frequency
    return

  updateCage: () =>
    if @cage?
      @cage.scale.set @size, @depth, @size
    return

  update: (delta, time) =>
    if @uniforms?
      @uniforms.uTime.value = time if @pulse

    if @autoRotation and @origin?
      @origin.rotation.x = 0.2 + 0.2 * Math.sin time * 0.5
      @origin.rotation.y += delta * 0.2

    @dust?.update delta, time
    @scene?.update delta, time
    return

  resize: (@width, @height) =>
    @dust?.resize @width, @height
    @scene?.resize @width, @height
    @updateObjects()
    return
