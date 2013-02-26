###
#============================================================
#
# Prototype: Abstract Demo Class
#
# @author Matthew Wagerfield
#
#============================================================
###

class DEMOS.Demo extends Class

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

  @class = 'DEMOS.Demo'



  ###
  #========================================
  # Instance Variables
  #========================================
  ###

  $container: null

  # Dimensions
  height: null
  width: null



  ###
  #========================================
  # Instance Methods
  #========================================
  ###

  constructor: (@$container) ->
    return

  initialise: (dimensions) =>
    super
    @height = dimensions.windowHeight
    @width = dimensions.windowWidth
    return

  update: (delta, time) =>
    return

  resize: (@width, @height) =>
    return
