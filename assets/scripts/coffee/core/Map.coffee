###
#============================================================
#
# Map utility methods.
#
# @author Matthew Wagerfield (Fantasy Interactive)
# @author Zaidin Amiot (Fantasy Interactive)
#
#============================================================
###

class Map

  ###
  # Projects a geographic coordinate into a 3D vertex.
  # @param {number} latitude The vertical component.
  # @param {number} longitude The horizontal component.
  # @param {number} length The length of the vector.
  # @return {THREE.Vector3} Projected vector coordinate.
  ###
  @project = (latitude, longitude, length = 1) ->
    latitude = Math.degreesToRadians latitude
    longitude = Math.degreesToRadians longitude

    sinPhi = Math.sin latitude
    cosPhi = Math.cos latitude

    sinTheta = Math.sin longitude
    cosTheta = Math.cos longitude

    x = -length * cosPhi * cosTheta
    y =  length * sinPhi
    z =  length * cosPhi * sinTheta
    return new THREE.Vector3 x, y, z

  ###
  # Projects a latitude into a value in pixel.
  # @param {number} latitude The vertical component.
  # @param {number} height The height of the map.
  # @return {number} Projected number in pixel.
  ###
  @projectLatitude = (latitude, height) ->
    Math.round height * Math.map latitude, -90, 90, 1, 0

  ###
  # Projects a longitude into a value in pixel.
  # @param {number} longitude The vertical component.
  # @param {number} width The height of the map.
  # @return {number} Projected number in pixel.
  ###
  @projectLongitude = (longitude, width) ->
    Math.round width * Math.map longitude, -180, 180, 0, 1

  ###
  # Returns two points in clip space using geographic coordinate on 2D grid.
  # @param {coordinate} start latitude/longitude of the start point.
  # @param {coordinate} end latitude/longitude of the end point.
  # @param {int} horizontal horizontal length of the grid.
  # @param {int} vertical vertical length of the grid.
  # @return {array} Normalised vector coordinate for the two points.
  ###
  @clipSpace = (start, end, horizontal, vertical) ->

    # Calculate delta and length.
    delta =
      x: end.longitude - start.longitude
      y: end.latitude - start.latitude

    length =
      x: Math.abs delta.x
      y: Math.abs delta.y

    # Get base increment.
    incrementX = Math.ceil horizontal / 2.5
    incrementY = Math.ceil vertical / 2.5

    # Arbitrary defines cardinal positions to clamp the points in the grid.
    xAxis = Math.ceil horizontal / 2
    yAxis = Math.ceil vertical / 2

    north = Math.randomInt incrementY, Math.ceil incrementY / 2
    south = vertical - Math.randomInt incrementY, Math.ceil incrementY / 2
    east = Math.randomInt incrementX, Math.ceil incrementX / 2
    west = horizontal - Math.randomInt incrementX, Math.ceil incrementX / 2

    if length.x > length.y

      # Arbitrary assign cardinal points on the longest axis.
      if delta.x > 0
        start.x = east
        end.x = west
      else
        start.x = west
        end.x = east

      # Offset the points on the other axis.
      distance = Math.randomInt(Math.ceil((vertical - incrementY) / 2), 1)
      start.y = yAxis + distance * Math.sign delta.y
      end.y = yAxis - distance * Math.sign delta.y

    else

      # Arbitrary assign cardinal points on the longest axis.
      if delta.y > 0
        start.y = south
        end.y = north
      else
        start.y = north
        end.y = south

      # Offset the points on the other axis.
      distance = Math.randomInt(Math.ceil((horizontal - incrementX) / 2), 1)
      start.x = xAxis - distance * Math.sign delta.x
      end.x = xAxis + distance * Math.sign delta.x

    return [start, end]

  ###
  # Returns two random points on a 2D grid.
  # @param {int} horizontal horizontal length of the grid.
  # @param {int} vertical vertical length of the grid.
  # @return {array} Normalised vector coordinate for the two points.
  ###
  @plotRoute = (horizontal, vertical, paddingX = 0, paddingY = 0) ->

    a = Math.randomInt 1
    b = Math.randomInt 1

    north = paddingY
    south = vertical - paddingY

    east = paddingX
    west = horizontal - paddingX

    # Vertical
    if a is 0

      # North to South or South to North
      positionY = if b is 0 then [north, south] else [south, north]

      start =
        x: (Math.randomInRange east, west, true)
        y: positionY[0]
      end =
        x: (Math.randomInRange east, west, true)
        y: positionY[1]

    # Horizontal
    else

      # East to West or West to East
      positionX = if b is 0 then [east, west] else [west, east]

      start =
        x: positionX[0]
        y: (Math.randomInRange north, south, true)
      end =
        x: positionX[1]
        y: (Math.randomInRange north, south, true)

    return [start, end]

  ###
  # Calculate the distance between 2 points using their coordinates.
  # @param {object} start Starting point.
  # @param {object} end Destination.
  # @return {float} Distance in km.
  ###
  @calculateDistance = (start, end) =>

    # Earth Radius
    R = 6371

    # Distance in KM
    latitude_1 = start.latitude
    latitude_2 = end.latitude
    longitude_1 = start.longitude
    longitude_2 = end.longitude

    deltaLatitude = Math.degreesToRadians latitude_2 - latitude_1
    deltaLongitude = Math.degreesToRadians longitude_2 - longitude_1
    latitude_1 = Math.degreesToRadians latitude_1
    latitude_2 = Math.degreesToRadians latitude_2

    # Haversine approximation
    a = Math.sin(deltaLatitude/2) * Math.sin(deltaLatitude/2) +
      Math.sin(deltaLongitude/2) * Math.sin(deltaLongitude/2) *
      Math.cos(latitude_1) * Math.cos(latitude_2)
    c = 2 * Math.atan2 Math.sqrt(a), Math.sqrt(1 - a)
    return R * c



# Expose to the window.
@Map = Map
