#ifdef GL_ES
precision mediump float;
#endif

#define PI 3.14159265359

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

mat2 rotate2d(float _angle) {
    return mat2(cos(_angle), -sin(_angle),
        sin(_angle), cos(_angle));
}

float random(in vec2 st) {
    return 2. * fract(sin(dot(st.xy,
                    vec2(12.98981, 78.233))) *
                43758.5453123) - 1.;
}

float circle(in vec2 _st, in float _radius) {
    vec2 l = _st - vec2(0.5);
    return 1. - smoothstep(_radius - (_radius * 0.01),
            _radius + (_radius * 0.01),
            dot(l, l) * 4.0);
}

// Based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd
float noise(in vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) +
        (c - a) * u.y * (1.0 - u.x) +
        (d - b) * u.x * u.y;
}

#define OCTAVES 8
float fbm(in vec2 st) {
    float value = 0.0;
    float amplitude = .5;
    for (int i = 0; i < OCTAVES; i++) {
        value += amplitude * abs(noise(vec2(st.x, st.y)));
        st *= 2.;
        amplitude *= .5;
    }
    return 1. - value;
}

float rotated_ridge(in vec2 pos, in float time) {
    vec2 rotated_pos = rotate2d(0.2 * sin(time * 0.5) + time / 12.) * pos / 2.;
    rotated_pos.x += 1.4 * fbm(rotated_pos * 3. + u_time * .1) + 0.2 * sin(time * .75) + 0.8 * cos(time * .61);
    rotated_pos.y += 0.5 * sin(time * 0.37) * fbm(rotated_pos * 2. + u_time * .1);

    int N = 6;
    float a = atan(rotated_pos.x, rotated_pos.y);
    float r = PI * 2. / float(N);
    return mod(a, r);
}

#define SCALE 100.
void main() {
    vec2 pos = gl_FragCoord.xy / u_resolution.xy;
    pos.x *= u_resolution.x / u_resolution.y;
    pos = pos * 2. - 1.;

    float intensity = rotated_ridge(floor(pos * SCALE) / SCALE, u_time) - 0.1;

    vec2 fract_pos = fract(pos * SCALE);

    vec3 high_color = vec3(56. / 255., 255. / 255., 89. / 255.);
    vec3 low_color = vec3(255. / 255., 30. / 255., 100. / 255.);
    vec3 background_color = vec3(5. / 255., 0. / 255., 80. / 255.);

    float in_circle = 1. - circle(fract_pos, 0.9 * intensity);
    vec3 intensity_color = mix(high_color, low_color, intensity);
    vec3 color = mix(intensity_color, background_color, in_circle);
    gl_FragColor = vec4(color, 1.0);
}
