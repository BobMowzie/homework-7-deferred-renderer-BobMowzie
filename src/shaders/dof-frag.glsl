#version 300 es
precision highp float;

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_frame;
uniform sampler2D u_depth;
uniform float u_Time;

void main() {
	float width = gl_FragCoord.x/fs_UV.x;
	float height = gl_FragCoord.y/fs_UV.y;

	float rSum = 0.;
    float gSum = 0.;
    float bSum = 0.;
    float totalSamples = 0.;
	float range = 20.;
	float depthSelect = texture(u_depth, fs_UV).w/20. - 1.;
    float radius = 6. * (1. - (pow(2., -range*depthSelect*depthSelect))) + 1.;
    float sigma = 0.45;
    for (float i = -radius; i <= radius; i++) {
        for (float j = -radius; j <= radius; j++) {
            if (i != j) {
                vec4 tex = texture(u_frame, fs_UV + vec2(float(i)/width, float(j)/height));
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

	out_Col = vec4(r, g, b, 1.);
	// out_Col = vec4(vec3(radius/5.), 1.);
	// out_Col = texture(u_frame, fs_UV);

}
