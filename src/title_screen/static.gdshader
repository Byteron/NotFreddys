shader_type canvas_item;

uniform sampler2D noise : repeat_enable, filter_nearest;

void fragment() {
	vec2 uv = UV * 2.0;
	uv.x = round(uv.x * 240.0) / 240.0;
	uv.y = round(uv.y * 135.0) / 135.0;
	float time = round(TIME * 15.0) / 15.0;
	float r = texture(noise, uv + vec2(-time * 0.2, -time * 0.2)).r;
	float g = texture(noise, uv + vec2(time * 0.05, 0.0)).g;
	float b = texture(noise, uv + vec2(0.0, time * 0.1)).b;
	if (r * g * b > 0.25) {
		COLOR.rgb = vec3(0.5, 0.5, 0.5) * r * g * b;
	}
}
