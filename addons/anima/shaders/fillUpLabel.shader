shader_type canvas_item;

uniform float fx_value: hint_range(0, 1) = 1.0;
uniform float uv_multiplier = 13.0;
uniform vec4 initial_color: hint_color = vec4(0.0);
uniform vec4 final_color: hint_color = vec4(1.0);

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	
	float ratio = 1.0 - step(UV.y * uv_multiplier, fx_value);
	float inverse_ratio = 1.0 - ratio;
	
	color.r = final_color.r * ratio + initial_color.r * inverse_ratio;
	color.g = final_color.g * ratio + initial_color.g * inverse_ratio;
	color.b = final_color.b * ratio + initial_color.b * inverse_ratio;

	COLOR = color;
}