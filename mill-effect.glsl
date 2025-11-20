// Author: Oliver Cabrera Volo

#ifdef GL_ES
precision mediump float;
#endif

#define PI 3.14159265359
#define PI2 PI*2.

uniform vec2 u_resolution;
uniform float u_time;

mat2 rotate2d(float _angle) {
    return mat2(
        cos(_angle), -sin(_angle),
        sin(_angle), cos(_angle)
    );
}

void main() {
    vec2 st = gl_FragCoord.xy / u_resolution.xy;
    st.x *= u_resolution.x / u_resolution.y;
    vec3 color = vec3(0.0);
    float d = 0.0;

    // Redimensiona al espacio -1,1
    st = st * 2. - 1.;

    // Rota el espacio, variando el ángulo en función del tiempo
    st = rotate2d(sin(u_time) * PI) * st;

    // Número de sectores
    int N = 12;

    // Ángulo y radio del píxel actual
    float a = atan(st.x, st.y) + PI;
    float r = PI2 / float(N);

    // Color basado en módulo
    color = vec3(mod(a, r));

    gl_FragColor = vec4(color, 1.0);
}
