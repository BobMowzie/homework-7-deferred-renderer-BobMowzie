#version 300 es
precision highp float;

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_frame;
uniform sampler2D u_highpass;
uniform float u_Time;

void main() {
	float width = gl_FragCoord.x/fs_UV.x;
	float height = gl_FragCoord.y/fs_UV.y;

	float rSum = 0.;
    float gSum = 0.;
    float bSum = 0.;
    float totalSamples = 0.;
    float radius = 5.;
    float sigma = 0.45;
    for (float i = -radius; i <= radius; i++) {
        for (float j = -radius; j <= radius; j++) {
            if (i != j) {
                vec4 tex = texture(u_highpass, fs_UV + vec2(float(i)/width, float(j)/height));
                float l = 0.21 * tex.r + 0.72 * tex.g + 0.07 * tex.b;
                float weight = 1./(2. * 3.1415926 * sigma * sigma) * pow(2.71828, -(pow(i/radius, 2.) + pow(j/radius, 2.))/(2. * 3.1415926 * sigma * sigma));
                rSum += tex.r * weight;
                gSum += tex.g * weight;
                bSum += tex.b * weight;
                totalSamples += weight;
            }
        }
    }
    float r = rSum / totalSamples;
    float g = gSum / totalSamples;
    float b = bSum / totalSamples;
	
	vec4 col = texture(u_frame, fs_UV);

	out_Col = vec4(col.r + r, col.g + g, col.b + b, 1.);
}
