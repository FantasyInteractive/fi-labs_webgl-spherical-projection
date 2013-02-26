###
#============================================================
#
# Prototype: Heatmap
#
# @author Matthew Wagerfield
#
#============================================================
###

class DEMOS.Heatmap extends DEMOS.Demo

  ###
  #========================================
  # Constants
  #========================================
  ###

  RESOLUTION = 3
  RATIO = 1 / RESOLUTION
  DELAY = 500



  ###
  #========================================
  # Class Variables
  #========================================
  ###

  @class = 'DEMOS.Heatmap'



  ###
  #========================================
  # Instance Variables
  #========================================
  ###

  debounce: null
  scene: null
  gui: null

  # Object
  particles: null
  uniforms: null
  heatmap: null
  spikes: null
  origin: null
  cage: null
  dust: null

  # Properties
  autoRotation: null
  displacement: null
  maskHeatmap: null
  showHeatmap: null
  innerRadius: null
  outerRadius: null
  frequency: null
  linewidth: null
  alpha1: null
  alpha2: null
  alpha3: null
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
    @debounce = _.debounce @format, DELAY
    @heatmap = new DEMOS.HeatmapCanvas RESOLUTION
    @uniforms = SHADERS.Heatmap.cloneUniforms()
    @uniforms.uMap.value = THREE.ImageUtils.loadTexture '/assets/graphics/particle.png'
    @scene = new DEMOS.Scene @width, @height
    @scene.add @origin = new THREE.Object3D
    @$container.append @scene.$element
    @$container.append @scene.$vignetting
    @$container.append @scene.$lensflare
    @$container.append @scene.$scanlines
    @$container.append @heatmap.$element
    @setProperties()
    @addEventListeners()
    @addControls()
    @addDust()
    @addCage()
    @updateObjects()
    return

  setProperties: () =>
    @innerRadius = 200
    @outerRadius = 260
    @linewidth = 1
    @size = 3.5

    @displacement = 0.01
    @frequency = 0.1

    @alpha1 = 0.55
    @alpha2 = 0.25
    @alpha3 = 0.05

    @autoRotation = true
    @maskHeatmap = false
    @showHeatmap = true
    @pulse = false
    return

  addEventListeners: () =>
    @heatmap.rendered.add @onHeatmapRendered
    return

  addControls: () =>
    controller = @gui.add @, 'clearHeatmap'
    controller = @gui.add @, 'generatePoints'

    controller = @gui.add @, 'maskHeatmap'
    controller.onChange (value) => @heatmap.mask value

    controller = @gui.add @, 'showHeatmap'
    controller.onChange (value) => @heatmap.visible value

    controller = @gui.add @, 'displacement', 0, 1
    controller.onChange (value) => @updateObjects()

    # controller = @gui.add @, 'pulse'
    # controller.onChange (value) => @updateObjects()

    # controller = @gui.add @, 'frequency', 0, 1
    # controller.onChange (value) => @updateObjects()

    controller = @gui.add @, 'size', 0, 20
    controller.onChange (value) => @updateObjects()

    # controller = @gui.add @, 'linewidth', 1, 10
    # controller.onChange (value) => @updateObjects()

    controller = @gui.add @, 'innerRadius', 0, 400
    controller.onChange (value) => @updateObjects()

    controller = @gui.add @, 'outerRadius', 0, 400
    controller.onChange (value) => @updateObjects()

    # controller = @gui.add @, 'alpha1', 0, 1
    # controller.onChange (value) => @updateObjects()

    # controller = @gui.add @, 'alpha2', 0, 1
    # controller.onChange (value) => @updateObjects()

    # controller = @gui.add @, 'alpha3', 0, 1
    # controller.onChange (value) => @updateObjects()

    controller = @gui.add @, 'autoRotation'
    controller.onChange (value) => @updateObjects()

    # @gui.close()
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
      opacity: 0.02
    geometry = new THREE.SphereGeometry 1, 80, 40
    THREE.GeometryUtils.triangulateQuads geometry
    frame = new THREE.Mesh geometry, material

    material = new THREE.MeshBasicMaterial
      map: THREE.ImageUtils.loadTexture '/assets/images/land1080.png'
      blending: THREE.AdditiveBlending
      side: THREE.DoubleSide
      transparent: true
      depthWrite: false
      depthTest: true
      color: 0xFFFFFF
      opacity: 0.08
    geometry = new THREE.SphereGeometry 1, 80, 40
    globe = new THREE.Mesh geometry, material

    @cage = new THREE.Object3D
    @cage.add frame
    @cage.add globe
    @cage.scale.set @innerRadius, @innerRadius, @innerRadius
    @origin.add @cage
    return

  addParticles: (width, height, data) =>
    if @particles?
      @origin.remove @particles
      @scene.renderer.deallocateObject @particles
    attributes = SHADERS.Heatmap.cloneAttributes()
    geometry = new THREE.Geometry
    material = new SHADERS.Heatmap
      blending: THREE.AdditiveBlending
      attributes: attributes
      linewidth: @linewidth
      uniforms: @uniforms
      transparent: true
      depthWrite: false
      depthTest: true
    for pixel, index in data
      latitude  = pixel.y * RATIO + 90
      longitude = pixel.x * RATIO - 180
      normal = Map.project latitude, longitude, 1
      vertex = Map.project latitude, longitude, pixel.rgb
      color = new THREE.Vector4 pixel.r, pixel.g, pixel.b, pixel.a
      hue = new THREE.Vector3 pixel.h, pixel.s, pixel.v
      attributes.aNormal.value.push normal
      attributes.aColor.value.push color
      attributes.aHue.value.push hue
      attributes.aType.value.push 0
      geometry.vertices.push vertex
    @particles = new THREE.ParticleSystem geometry, material
    @origin.add @particles
    @updateObjects()
    return

  addSpikes: (width, height, data) =>
    if @spikes?
      @origin.remove @spikes
      @scene.renderer.deallocateObject @spikes
    attributes = SHADERS.Heatmap.cloneAttributes()
    geometry = new THREE.Geometry
    material = new SHADERS.Heatmap
      blending: THREE.AdditiveBlending
      attributes: attributes
      linewidth: @linewidth
      uniforms: @uniforms
      transparent: true
      depthWrite: false
      depthTest: true
    for pixel, index in data
      latitude  = pixel.y * RATIO + 90
      longitude = pixel.x * RATIO - 180
      normal = Map.project latitude, longitude, 1
      vertex = Map.project latitude, longitude, pixel.rgb
      color = new THREE.Vector4 pixel.r, pixel.g, pixel.b, pixel.a
      hue = new THREE.Vector3 pixel.h, pixel.s, pixel.v
      attributes.aNormal.value.push normal, normal
      attributes.aColor.value.push color, color
      attributes.aHue.value.push hue, hue
      attributes.aType.value.push 1, 2
      geometry.vertices.push vertex, vertex
    @spikes = new THREE.Line geometry, material, THREE.LinePieces
    @origin.add @spikes
    @updateObjects()
    return

  updateObjects: () =>
    @updateUniforms()
    @updateSpikes()
    @updateCage()
    return

  updateUniforms: () =>
    if @uniforms?
      @uniforms.uRadii.value.set @innerRadius, @outerRadius
      @uniforms.uAlpha.value.set @alpha1, @alpha2, @alpha3
      @uniforms.uDisplacement.value = @displacement
      @uniforms.uFrequency.value = @frequency
      @uniforms.uScale.value = @height / 2
      @uniforms.uSize.value = @size
    return

  updateSpikes: () =>
    @spikes.material.linewidth = @linewidth if @spikes?
    return

  updateCage: () =>
    @cage.scale.set @innerRadius, @innerRadius, @innerRadius if @cage?
    return

  clearHeatmap: () =>
    @heatmap?.clear()
    return

  generatePoints: () =>
    @heatmap?.generate 100
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

  format: (data) =>
    data = Canvas.format data, true, true, 0.5
    @addParticles data.width, data.height, data
    @addSpikes data.width, data.height, data
    return



  ###
  #========================================
  # Callbacks
  #========================================
  ###

  onHeatmapRendered: (data) =>
    @debounce data
    return
