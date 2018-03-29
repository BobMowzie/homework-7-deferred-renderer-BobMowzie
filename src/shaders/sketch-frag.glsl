#version 300 es
precision highp float;

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_frame;
uniform float u_Time;

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

vec2 random2( vec2 p ) {
    return normalize(2. * fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453) - 1.);
}

float surflet(vec2 P, vec2 gridPoint)
{
    // Compute falloff function by converting linear distance to amp1 polynomial
    float distX = abs(P.x - gridPoint.x);
    float distY = abs(P.y - gridPoint.y);
    float tX = 1. - 6. * pow(distX, 5.0) + 15. * pow(distX, 4.0) - 10. * pow(distX, 3.0);
    float tY = 1. - 6. * pow(distY, 5.0) + 15. * pow(distY, 4.0) - 10. * pow(distY, 3.0);

    // Get the random vector for the grid point
    vec2 gradient = random2(gridPoint);
    // Get the vector from the grid point to P
    vec2 diff = P - gridPoint;
    // Get the value of our height field by dotting grid->P with our gradient
    float height = dot(diff, gradient);
    // Scale our height field (i.e. reduce it) by our polynomial falloff function
    return height * tX * tY;
}

float PerlinNoise(vec2 uv)
{
    // Tile the space
    vec2 uvXLYL = floor(uv);
    vec2 uvXHYL = uvXLYL + vec2(1.,0.);
    vec2 uvXHYH = uvXLYL + vec2(1.,1.);
    vec2 uvXLYH = uvXLYL + vec2(0.,1.);

    return surflet(uv, uvXLYL) + surflet(uv, uvXHYL) + surflet(uv, uvXHYH) + surflet(uv, uvXLYH);
}

void main() {
	float width = gl_FragCoord.x/fs_UV.x;
	float height = gl_FragCoord.y/fs_UV.y;

	vec4 col = vec4(texture(u_frame, fs_UV));
	if (col.r > 1.) col.r = 1.;
	if (col.g > 1.) col.g = 1.;
	if (col.b > 1.) col.b = 1.;
	float lum = 0.2126 * col.r + 0.7152 * col.g + 0.0722 * col.b;
	float noise1 = 0.003 * PerlinNoise(fs_UV * 60.);
	float noise2 = 0.003 * PerlinNoise(fs_UV * 3000.);
	
	float cells = 6.;
	for (float i = 1.; i < cells; i++) {
		if (lum <= i/cells && lum > (i-1.)/cells) {
			float step = i/cells;
			float freq = 0.02 * mix(0.1, 1., step);
			float x = mod(fs_UV.x + fs_UV.y + noise1 + noise2, freq) - freq/2.;
			float lines = 1. - (1. - lum) * pow(2., -300000.*x*x);
			col = vec4(vec3(lines), 1.);
			break;
			// col = vec4(vec3(step), 1.);
		}
	}

	mat3 horizontal = mat3(vec3(3., 0., -3.),
                           vec3(10., 0., -10.),
                           vec3(3., 0., -3.)
                           );
    mat3 vertical = mat3(vec3(3., 10., 3.),
                           vec3(0., 0., 0.),
                           vec3(-3., -10., -3.)
                           );
    vec3 gradienth = vec3(0., 0., 0.);
    vec3 gradientv = vec3(0., 0., 0.);
    for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
            vec4 tex = texture(u_frame, fs_UV + vec2(float(i)/width, float(j)/height));
            float h = horizontal[i + 1][j + 1];
            float v = vertical[i + 1] [j + 1];
            gradienth += h * tex.rgb;
            gradientv += v * tex.rgb;
        }
    }
    float r = pow(sqrt(gradienth[0] * gradienth[0] + gradientv[0] * gradientv[0]), 3.); 
    float g = pow(sqrt(gradienth[1] * gradienth[1] + gradientv[1] * gradientv[1]), 3.);
    float b = pow(sqrt(gradienth[2] * gradienth[2] + gradientv[2] * gradientv[2]), 3.);

	if (lum > 0.4) {
		r = 0.;
		g = 0.;
		b = 0.;
	}

	lum = 0.2126 * (col.r - r) + 0.7152 * (col.g - g) + 0.0722 * (col.b - b);
	out_Col = vec4(vec3(lum), 1.);
}
