// Author: Oliver Cabrera Volo
// Title: Mill effect distorted by ridge noise

#ifdef GL_ES
precision mediump float;
#endif

#define PI 3.14159265359

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

float random(in vec2 st) {
    return 2. * fract(sin(dot(st.xy,
                    vec2(12.9898, 78.233))) *
                43758.5453123) - 1.;
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
    // Initial values
    float value = 0.0;
    float amplitude = .5;
    //float frequency = 0.;

    // Loop of octaves
    for (int i = 0; i < OCTAVES; i++) {
        value += amplitude * abs(noise(vec2(st.x, st.y)));
        st *= 2.;
        amplitude *= .5;
    }
    return 1. - value;
}

mat2 rotate2d(float _angle) {
    return mat2(cos(_angle), -sin(_angle),
        sin(_angle), cos(_angle));
}

void main() {
    vec2 st = gl_FragCoord.xy / u_resolution.xy;
    st.x *= u_resolution.x / u_resolution.y;
    st = st * 2. - 1.;

    st = rotate2d(u_time / 6.) * st;

    // Número de sectores
    int N = 6;

    // añadir distorsión
    st.x += 1.5 * fbm(st) + 1.5 * sin(u_time) + 0.2 * cos(u_time * 1.5);

    // Ángulo y radio del píxel actual
    float a = atan(st.x, st.y);
    float r = PI * 2. / float(N);

    // Color basado en módulo
    vec3 color = vec3(mod(a, r));

    gl_FragColor = vec4(color, 1.0);
}
