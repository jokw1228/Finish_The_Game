shader_type canvas_item;

uniform float hole_radius : hint_range(0.0, 1.0) = 1.0;
uniform float edge_softness : hint_range(0.0, 0.1) = 0.00;

void fragment() {
	vec2 centered = UV - vec2(0.5);

	vec2 resolution = vec2(1.0) / SCREEN_PIXEL_SIZE;
	centered.x *= resolution.x / resolution.y;

	float dist = length(centered);

	float mask = smoothstep(hole_radius, hole_radius + edge_softness, dist);

	COLOR = vec4(0.0, 0.0, 0.0, mask);
}