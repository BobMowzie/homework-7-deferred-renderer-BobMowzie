#version 300 es
precision highp float;

#define EPS 0.0001
#define PI 3.1415962

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_gb0;
uniform sampler2D u_gb1;
uniform sampler2D u_gb2;

uniform float u_Time;

uniform mat4 u_View;
uniform vec4 u_CamPos; 

const vec3 lightVec = vec3(5, 7, 3);

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

vec2 random2( vec2 p ) {
    return normalize(2. * fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453) - 1.);
}

const vec3 amp1 = vec3(0.4, 0.5, 0.8);
const vec3 freq1 = vec3(0.2, 0.4, 0.2);
const vec3 freq2 = vec3(1.0, 1.0, 2.0);
const vec3 amp2 = vec3(0.25, 0.25, 0.0);

const vec3 e = vec3(0.2, 0.5, 0.8);
const vec3 f = vec3(0.2, 0.25, 0.5);
const vec3 g = vec3(1.0, 1.0, 0.1);
const vec3 h = vec3(0.0, 0.8, 0.2);

vec3 Gradient(float t)
{
    return amp1 + freq1 * cos(6.2831 * (freq2 * t + amp2));
}

vec3 Gradient2(float t)
{
    return e + f * cos(6.2831 * (g * t + h));
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
	// read from GBuffers

	vec4 gb0 = texture(u_gb0, fs_UV);
	vec4 gb1 = texture(u_gb1, fs_UV);
	vec4 gb2 = texture(u_gb2, fs_UV);

	vec3 norm = gb0.xyz;
	float depth = gb0.w;
	vec3 col = gb2.xyz;

	// Lambert shading
	float diffuseTerm = dot(normalize(norm), normalize(lightVec));
	float ambientTerm = 0.4;
	float lightIntensity = diffuseTerm + ambientTerm;
	col = vec3(col * lightIntensity);

	out_Col = vec4(col, 1.0);

	if (depth == 1.) {
        float noise = 0.;
        float n = 4.;
        for (float i = 0.; i < n; i++) {
            noise += PerlinNoise((fs_UV + vec2(rand(vec2(i,i)), rand(vec2(i,i)))) * (4. + 6. * i/n) * vec2(1./fs_UV.y, 1./(fs_UV.y * fs_UV.y))+ vec2(u_Time * 0.3, 0.)) + 0.5;
        }
        noise /= n;
        noise *= noise;
        noise = clamp(noise, 0., 1.);
        vec3 noiseCol = vec3(noise * 0.5, noise * 0.3, noise * 0.6);
        vec3 color = mix(vec3(0.2, 0.2, 0.2), vec3(0.4, 0.4, 0.45), clamp(fs_UV.y*2. + 0.7, 0., 1.));
        color = mix(color, noiseCol, clamp(fs_UV.y*2. - 0.7, 0., 1.));
		out_Col = vec4(color, 1.);
    }
}