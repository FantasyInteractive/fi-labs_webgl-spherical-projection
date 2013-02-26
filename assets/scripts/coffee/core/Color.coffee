###
#============================================================
#
# Collection of colour methods.
#
# @author Matthew Wagerfield (Fantasy Interactive)
#
#============================================================
###

class Color

  ###
  # Converts a HEX string to an RGB object.
  # @param {number} hex Hex value of the color.
  # @param {number} range Range of the color.
  # @return {object} The Color.
  ###
  @rgb = (hex, range = 255) ->
    hexString = hex.replace '#', ''
    r: (r = (parseInt hexString.substring(0, 2), 16) / range)
    g: (g = (parseInt hexString.substring(2, 4), 16) / range)
    b: (b = (parseInt hexString.substring(4, 6), 16) / range)
    colors: [r, g, b]
    rgb: "rgb(#{r},#{g},#{b})"
    hex: hex

  ###
  # Converts a HEX string to an RGB object.
  # @param {number} hex Hex value of the color.
  # @param {number} alpha Opacity of the color.
  # @param {number} range Range of the color.
  # @return {object} The Color.
  ###
  @rgba = (hex, alpha, range = 255) ->
    color = @rgb hex, range
    color.a = alpha
    color.colors.push alpha
    color.rgba = "rgba(#{color.r},#{color.g},#{color.b},#{color.a})"
    return color

  ###
  # Converts a RGB to HSL.
  # @param {number} r Red value of the color.
  # @param {number} g Green value of the color.
  # @param {number} b Blue value of the color.
  # @return {object} HSL color object.
  ###
  @hsl = (r, g, b) ->
    r /= 255
    g /= 255
    b /= 255

    max = Math.max r, g, b
    min = Math.min r, g, b
    d = max - min

    h = 0
    s = 0
    l = (max + min) / 2

    if max isnt min
      s = if l > 0.5 then d / (2 - max - min) else d / (max + min)
      switch max
        when r then h = (g - b) / d + (if g < b then 6 else 0)
        when g then h = (b - r) / d + 2
        when b then h = (r - g) / d + 4
      h /= 6

    return h:h, s:s, l:l

  ###
  # Converts a RGB to HSV.
  # @param {number} r Red value of the color   (0 - 255).
  # @param {number} g Green value of the color (0 - 255).
  # @param {number} b Blue value of the color  (0 - 255).
  # @return {object} HSV color object (0 - 1).
  ###
  @hsv = (r, g, b) ->
    r /= 255
    g /= 255
    b /= 255

    max = Math.max r, g, b
    min = Math.min r, g, b
    d = max - min

    h = 0
    s = if max is 0 then 0 else d / max
    v = max

    if max isnt min
      switch max
        when r then h = (g - b) / d + (if g < b then 6 else 0)
        when g then h = (b - r) / d + 2
        when b then h = (r - g) / d + 4
      h /= 6

    return h:h, s:s, v:v

  ###
  # Returns a colour in the form of a THREE.Vector3.
  # @param {string} hex String representation of a hex colour - #FF0000.
  # @return {THREE.Vector3} The generated colour as a THREE.Vector3.
  ###
  @vector3 = (hex) ->
    color = Color.rgb hex
    vector = new THREE.Vector3 color.colors...
    return vector

  ###
  # Returns a colour in the form of a THREE.Vector4.
  # @param {string} hex String representation of a hex colour - #FF0000.
  # @param {number} opacity The opacity value 0 - 1.
  # @return {THREE.Vector4} The generated colour as a THREE.Vector4.
  ###
  @vector4 = (hex, opacity) ->
    color = Color.rgba hex, opacity
    vector = new THREE.Vector4 color.colors...
    return vector

# Expose to the window.
@Color = @Colour = Colour = Color
