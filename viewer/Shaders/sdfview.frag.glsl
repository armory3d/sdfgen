#version 450

uniform sampler2D sdftex; // 2500x50 - 50x50x50

in vec2 texCoord;

out vec4 fragColor;

const float res = 50.0; // sdftex res
const float res2 = res * res;

const int maxSteps = 20;
const float aspect = 640 / 480;

const float near = 0.0;
const float far = 10.0;
const float eps = 0.02;

int steps;

float sliceView(const int slice) {
	ivec2 co;
	const float step = 1 / res;
	co.x = int(texCoord.x * res + slice * res);
	co.y = int(texCoord.y * res);
	return texelFetch(sdftex, co, 0).r;
}

float rayMarch() {
	vec3 ro = vec3(texCoord * 2.0 - 1.0, 0.99);
	// ro.x *= aspect;
	vec3 rd = vec3(0.0, 0.0, -1.0);

	float depth = 0.0;
	
	for (steps = 0; steps < maxSteps; steps++) {
		
		vec3 p = ro + depth * rd;
		p = p * 0.5 + 0.5;

		// TODO: handles single line only
		float s1 = (p.z * res);
		float s2 = int(s1);
		float s = s2 - s1;
		
		float m = sign(rd.z) > 0.0 ? s : (1.0 - s);
		vec2 co = vec2(p.x / res + s2 / res, p.y);
		float dist = (texture(sdftex, co).r) * m;
		
		co.x += 1 / res * sign(rd.z);
		dist += (texture(sdftex, co).r) * (1.0 - m);
		
		if (dist < eps) {
			return depth;
		}

		depth += dist;

		if (depth >= far) {
			return far;
		}
	}

	return far;
}

void main() {

	float d = rayMarch();
	// fragColor = vec4(steps / maxSteps);
	fragColor = vec4(d);

	// float dd = sliceView(2);
	// fragColor = vec4(dd);

	// float col = texelFetch(sdftex, ivec2(texCoord * vec2(res2 * (640 / res2), res * (480 / res))), 0).r;
	// fragColor = vec4(abs(col));
}
