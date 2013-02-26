###
#============================================================
#
# Shader Utilities
#
# @author Matthew Wagerfield (Fantasy Interactive)
# @author Zaidin Amiot (Fantasy Interactive)
#
#============================================================
###

UTILS = """ // GLSL

// Constants
float PI = 3.14159265358979323846264;
float PI2 = PI * 2.0;
float PIH = PI * 0.5;

// Blend
float blend(float value, float a, float b) {
  return clamp((value - a) / (b - a), 0.0, 1.0);
}

// Normalise
float normalise(float value, float min, float max) {
  return (value - min) / (max - min);
}

// Normalise
float interpolate(float value, float a, float b) {
  return a + (b - a) * value;
}

// Map
float map(float value, float min1, float max1, float min2, float max2) {
  return interpolate(normalise(value, min1, max1), min2, max2);
}

// Fog
float fog(float depth, vec3 fog) {
  return map(blend(depth, fog.x, fog.y), 0.0, 1.0, 1.0, fog.z);
}

// Project
vec3 project(float longitude, float latitude, float radius) {

  // Convert degrees to radians.
  float rx = radians(longitude);
  float ry = radians(latitude);

  // Cache sin and cos for x and y.
  float sx = sin(rx);
  float cx = cos(rx);
  float sy = sin(ry);
  float cy = cos(ry);

  // Calculate x, y and z.
  float x = -radius * cy * cx;
  float y =  radius * sy;
  float z =  radius * cy * sx;

  // Return the projected vec3.
  return vec3(x, y, z);
}

// Bezier
vec2 bezierPoint(float index, float size, vec3 factoral, vec2 control, float ratio) {

  vec2 point = vec2(0.0);

  float f = factoral.x / (factoral.y * factoral.z);
  float p = pow(1.0 - ratio, size - index) * pow(ratio, index);

  point.x = f * p * control.x;
  point.y = f * p * control.y;

  return point;
}

// Bezier
vec2 bezier5v(vec2 points[5], float ratio) {

  // Point to return.
  vec2 point = vec2(0.0);
  vec3 factoral = vec3(4.0 * 3.0 * 2.0);
  float size = 4.0;

  // Factoral calculation:
  // return 1 if value is 0
  // factoral = 1
  // factoral *= i for i in [value...1]

  // Point 0: i = 0
  factoral.y = 1.0;  // f(i)        = Special case = 1
  factoral.z = 24.0; // f(size - i) = 4 - 0 = 4 * 3 * 2 * 1 = 24
  point += bezierPoint(0.0, size, factoral, points[0], ratio);

  // Point 1: i = 1
  factoral.y = 1.0;  // f(i)        = 1 * 1 = 1
  factoral.z = 6.0;  // f(size - i) = 4 - 1 = 3 * 2 * 1 = 6
  point += bezierPoint(1.0, size, factoral, points[1], ratio);

  // Point 2: i = 2
  factoral.y = 2.0;  // f(i)        = 2 * 1 = 2
  factoral.z = 2.0;  // f(size - i) = 4 - 2 = 2 * 1 = 2
  point += bezierPoint(2.0, size, factoral, points[2], ratio);

  // Point 3: i = 3
  factoral.y = 6.0;  // f(i)        = 3 * 2 * 1 = 6
  factoral.z = 1.0;  // f(size - i) = 4 - 3 = 1 * 1 = 1
  point += bezierPoint(3.0, size, factoral, points[3], ratio);

  // Point 4: i = 4
  factoral.y = 24.0; // f(i)        = 4 * 3 * 2 * 1 = 24
  factoral.z = 1.0;  // f(size - i) = 4 - 4 = 0 = Special case = 1
  point += bezierPoint(4.0, size, factoral, points[4], ratio);

  // Return the point.
  return point;
}
"""



TERRAIN_UTILS = """ // GLSL

// Compute position base on phase, amplitude and noise seeds.
vec3 computePosition(vec3 position, float phase, float amplitude, vec4 noise) {
  float displace = snoise( (position + noise.xyz * 100.0) / noise.w / 100.0 );
  return position + vec3(0, 0, 1) * displace * phase * amplitude;
}

// Compute phase based on time and frequency.
float computePhase(float time, float frequency) {
  if(time == -1.0){
    time = 1.0;
  }
  return sin( time * frequency );
}

// Compute the normal of the triangle based on its 3 vertices.
vec3 computeNormal(vec3 p0, vec3 p1, vec3 p2) {
  return cross( p1 - p0, p2 - p1 );
}

// Compute the normal of the segment based on its 2 vertices.
vec2 computeSegmentNormals(vec2 p0, vec2 p1) {
  float dx = p1.x - p0.x;
  float dy = p1.y - p0.y;
  return normalize( vec2( -dy, dx ) );
}
"""
