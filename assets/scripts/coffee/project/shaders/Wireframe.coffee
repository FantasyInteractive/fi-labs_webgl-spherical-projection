###
#============================================================
#
# Wireframe edge detection fragment shader
#
# @author Three.js example file
#
#============================================================
###

WIREFRAME_EDGE_DETECTION = """ // GLSL

/*
/  Wireframe
/
/  Must be declared in vertex shader:
/  uniform float vLinewidth;
/  varying float vLinewidth;
*/
#extension GL_OES_standard_derivatives : enable

varying float vLinewidth;

// Position
float edgeFactor( vec3 center ) {
  vec3 d = fwidth( center );
  vec3 a3 = smoothstep( vec3( 0.0 ), d * vLinewidth, center );
  return min( min( a3.x, a3.y ), a3.z );
}

float edgeFactorQuad( vec2 center ) {
  vec2 d = fwidth( center );
  vec2 a2 = smoothstep( vec2(0.0), d * vLinewidth, center );
  return min( a2.x, a2.y );
}

float edgeFactor(vec2 center) {
  return min( edgeFactorQuad( center ), edgeFactorQuad( 1.0 - center ) );
}
"""
