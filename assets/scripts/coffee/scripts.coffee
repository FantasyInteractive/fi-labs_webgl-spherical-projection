#============================================================
#
# CoffeeScript Imports
#
# Lists the source files to be concatenated and compiled into
# ../js/scripts.js using CodeKit's import directives.
#
# @see http://incident57.com/codekit/help.php
# @author Matthew Wagerfield
#
#============================================================

#------------------------------
# Core
#------------------------------
# @codekit-prepend "core/Array.coffee"
# @codekit-prepend "core/Math.coffee"
# @codekit-prepend "core/Ease.coffee"
# @codekit-prepend "core/Utils.coffee"
# @codekit-prepend "core/Color.coffee"
# @codekit-prepend "core/Canvas.coffee"
# @codekit-prepend "core/Map.coffee"
# @codekit-prepend "core/Pathfinder.coffee"
# @codekit-prepend "core/Physics.coffee"
# @codekit-prepend "core/TrackballControls.coffee"
# @codekit-prepend "core/Class.coffee"
# @codekit-prepend "core/Base.coffee"
# @codekit-prepend "core/Layout.coffee"
# @codekit-prepend "core/Codepen.coffee"

#------------------------------
# Shaders
#------------------------------
# @codekit-prepend "project/shaders/Utils.coffee"
# @codekit-prepend "project/shaders/Wireframe.coffee"
# @codekit-prepend "project/shaders/SimplexNoise.coffee"
# @codekit-prepend "project/shaders/Shader.coffee"
# @codekit-prepend "project/shaders/Dust.coffee"
# @codekit-prepend "project/shaders/Noise.coffee"
# @codekit-prepend "project/shaders/Heatmap.coffee"
# @codekit-prepend "project/shaders/Projection.coffee"

#------------------------------
# Demos
#------------------------------
# @codekit-prepend "project/demos/Dust.coffee"
# @codekit-prepend "project/demos/Scene.coffee"
# @codekit-prepend "project/demos/ImageBuffer.coffee"
# @codekit-prepend "project/demos/Demo.coffee"
# @codekit-prepend "project/demos/Pathfinding.coffee"
# @codekit-prepend "project/demos/Projection.coffee"
# @codekit-prepend "project/demos/HeatmapCanvas.coffee"
# @codekit-prepend "project/demos/Heatmap.coffee"
# @codekit-prepend "project/demos/Noise.coffee"

#------------------------------
# Project
#------------------------------
# @codekit-prepend "project/Main.coffee"



$ -> DEMO.initialise()
