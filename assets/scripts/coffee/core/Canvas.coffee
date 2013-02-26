###
#============================================================
#
# Collection of canvas methods.
#
# @author Matthew Wagerfield (Fantasy Interactive)
#
#============================================================
###

class Canvas

  ###
  # Parses an image data object and formats the RGBA values.
  # @param {data} imageData The image data object to parse.
  # @param {boolean} normalise Whether or not to normalise the data.
  # @return {array} Formatted array of RGBA objects.
  ###
  @format = (imageData, normalise = false, ignore = false, scale = 1) ->

    # Calculate the step
    STEP = 1 / scale

    # Cache the width, height and data.
    data = imageData.data
    width = imageData.width
    height = imageData.height
    pixels = []

    # Loop through each row
    for y in [0...height] by STEP

      # Loop through each column
      for x in [0...width] by STEP

        # Extract and assign the RGBA values.
        r = data[((width * y) + x) * 4 + 0]
        g = data[((width * y) + x) * 4 + 1]
        b = data[((width * y) + x) * 4 + 2]
        a = data[((width * y) + x) * 4 + 3]

        # Convert the colour to HSV format.
        hsv = Color.hsv r, g, b
        h = hsv.h
        s = hsv.s
        v = hsv.v
        hsv = h + s + v

        # Normalise the RGBA values if the normalise flag is set.
        if normalise
          r /= 255
          g /= 255
          b /= 255
          a /= 255

        # Calculate RGB and RGBA values
        rgba = r + g + b + a
        rgb = r + g + b

        # Add the values to the pixel array.
        if not ignore or rgba
          pixels.push x:x, y:y, r:r, g:g, b:b, a:a, rgb:rgb, rgba:rgba, h:h, s:s, v:v, hsv:hsv

    return pixels

  ###
  # Parses an image data object and formats the RGBA values.
  # @param {array} sourceImageData The source ImageData to set the values on.
  # @param {array} imageDataMultiplier Array of image data objects to multiply.
  # @param {array} channelMultiplier Array of channel multipliers for RGBA.
  # @return {array} Formatted array of RGBA objects.
  ###
  @multiply = (sourceImageData, imageDataMultiplier, channelMultiplier = [1,1,1,1]) ->

    # Cache the width and height of the first image data object.
    data = sourceImageData.data
    width = sourceImageData.width
    height = sourceImageData.height
    length = sourceImageData.data.length

    # Check that the provided image data objects are the same size.
    for imageData in imageDataMultiplier
      if imageData.width isnt width or imageData.height isnt height
        warn 'Canvas.multiply: image data must be the same dimensions'
        return

    # Iterate through all the source data pixels
    for p in [0...length] by 4

      # Multiply the RGBA channels by the respective imageDataMultiplier values.
      for imageData in imageDataMultiplier

        data[p + 0] *= imageData.data[p + 0] / 255
        data[p + 1] *= imageData.data[p + 1] / 255
        data[p + 2] *= imageData.data[p + 2] / 255
        data[p + 3] *= imageData.data[p + 3] / 255

      # Multiply the RGBA channels by the channel multiplier values.
      data[p + 0] *= channelMultiplier[0]
      data[p + 1] *= channelMultiplier[1]
      data[p + 2] *= channelMultiplier[2]
      data[p + 3] *= channelMultiplier[3]

    # Return the updated source image.
    return sourceImageData

# Expose to the window.
@Canvas = Canvas
