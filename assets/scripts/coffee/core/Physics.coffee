###
#============================================================
#
# Simple Physics.
#
# @author Matthew Wagerfield (Fantasy Interactive)
#
#============================================================
###

class Physics

  ###
  #========================================
  # Constants
  #========================================
  ###

  MIN = 0
  MAX = 0.99



  ###
  #========================================
  # Instance Variables
  #========================================
  ###

  reference: null
  velocity: null
  inertia: null
  delta: null



  ###
  #========================================
  # Instance Methods
  #========================================
  ###

  constructor: (@reference) ->
    @velocity = {}
    @inertia = {}
    @delta = {}
    return

  chase: (target, friction, inertia) ->
    friction = Math.max friction, MIN
    friction = Math.min friction, MAX

    inertia = Math.max inertia, MIN
    inertia = Math.min inertia, MAX

    for key, value of target
      @delta[key] = target[key] - @reference[key]
      @velocity[key] = parseInt @velocity[key] or 0
      @velocity[key] = @velocity[key] * inertia + @delta[key] * (1 - friction)
      @reference[key] += @velocity[key]
      @inertia[key] = @velocity[key]
    return

  drift: (target, friction) ->
    friction = Math.max friction, MIN
    friction = Math.min friction, MAX

    for key, value of target
      @inertia[p] = (parseInt @inertia[p]) * (1 - friction)
      @reference[p] += @inertia[p]
    return
