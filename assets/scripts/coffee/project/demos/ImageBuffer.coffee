###
#============================================================
#
# Prototype: Image Buffer
#
# @author Matthew Wagerfield
#
#============================================================
###

class DEMOS.ImageBuffer extends Class

  ###
  #========================================
  # Constants
  #========================================
  ###



  ###
  #========================================
  # Class Variables
  #========================================
  ###

  @class = 'DEMOS.ImageBuffer'



  ###
  #========================================
  # Instance Variables
  #========================================
  ###

  $image: null
  $canvas: null

  formattedData: null
  imageData: null
  rendered: null
  context: null
  height: null
  width: null
  image: null
  data: null
  url: null



  ###
  #========================================
  # Instance Methods
  #========================================
  ###

  constructor: (@url) ->
    @rendered = new signals.Signal
    @$canvas = $('<canvas>').addClass 'buffer'
    @context = @$canvas[0].getContext '2d'
    @image = new Image
    @$image = $ @image
    @$image.load @onImageLoad
    @load @url
    return

  load: (@url) =>
    @$image.attr 'src', @url
    return



  ###
  #========================================
  # Callbacks
  #========================================
  ###

  onImageLoad: (event) =>
    @width = event.target.width
    @height = event.target.height
    @$canvas.attr width:@width, height:@height
    @context.clearRect 0, 0, @width, @height
    @context.drawImage @image, 0, 0
    @imageData = @context.getImageData 0, 0, @width, @height
    @formattedData = Canvas.format @imageData, true, true
    @rendered.dispatch @width, @height, @formattedData
    return
