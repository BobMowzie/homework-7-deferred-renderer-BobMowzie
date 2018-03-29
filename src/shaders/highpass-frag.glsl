#version 300 es
precision highp float;

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_frame;
uniform float u_Time;

void main() {
	vec4 col = vec4(texture(u_frame, fs_UV));
	float lum = 0.2126 * col.r + 0.7152 * col.g + 0.0722 * col.b;
	if (lum < 0.45) col = vec4(0., 0., 0., 1.);
	out_Col = col;
}
