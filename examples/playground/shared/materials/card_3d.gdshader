// Faceted-glass look for Card3D — translucent faces, a bright fresnel rim
// along each facet edge, and a soft emissive glow from the core. Recoloured
// to the app's own accent palette (design-brief.md §Component guide "3D
// Card"), not v2_stuff/icosahedron.png's green. progress (0..1) drives
// emissive and fresnel strength, mirroring Card.set_progress(t).
shader_type spatial;
render_mode blend_mix, cull_back, unshaded;

uniform vec4 core_color : source_color = vec4(0.309804, 0.27451, 0.898039, 1.0); // accent
uniform vec4 rim_color : source_color = vec4(0.654902, 0.545098, 0.980392, 1.0); // accent-soft
uniform vec4 outline_color : source_color = vec4(0.968627, 0.972549, 1.0, 1.0); // bright outline
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float base_alpha : hint_range(0.0, 1.0) = 0.35;
uniform float fresnel_power : hint_range(0.1, 8.0) = 2.5;
uniform float outline_strength : hint_range(0.0, 2.0) = 0.7;
uniform float outline_width : hint_range(0.0, 0.03) = 0.008;

void fragment() {
	float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), fresnel_power);
	float emissive_strength = mix(0.4, 1.6, progress);
	float fresnel_strength = mix(0.6, 2.2, progress);
	float edge = length(vec2(dFdx(fresnel), dFdy(fresnel)));
	float outline_mask = smoothstep(0.0, outline_width, edge);
	vec3 base_color = mix(core_color.rgb, rim_color.rgb, fresnel);
	vec3 final_color = mix(base_color, outline_color.rgb, outline_mask * outline_strength);

	ALBEDO = final_color;
	EMISSION = core_color.rgb * emissive_strength + rim_color.rgb * fresnel * fresnel_strength + outline_color.rgb * outline_mask * outline_strength * 0.9;
	EMISSION = outline_color.rgb * outline_mask * outline_strength * 0.9;
	ALPHA = clamp(base_alpha + fresnel * 0.5, 0.0, 1.0);
}
