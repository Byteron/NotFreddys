shader_type canvas_item;

uniform sampler2D noise : repeat_enable, filter_nearest;

void fragment() {
	float time = round(TIME * 15.0) / 15.0;
	float r = texture(noise, (UV * vec2(0.0, 1.0)) + vec2(0.0, time * 0.1)).r;
	float g = texture(noise, (UV * vec2(0.0, 1.0)) + vec2(0.0, time)).g * 0.5;
	float d = r + g;
	d *= 0.01;
	d = round(d * 480.0) / 480.0;
	vec2 uv = UV + vec2(d, 0.0);
	COLOR.rgba = texture(TEXTURE, uv);
}
