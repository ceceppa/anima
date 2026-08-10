shader_type canvas_item;

uniform vec4 bg_color : source_color = vec4(0.08, 0.09, 0.12, 0.85);
uniform vec4 border_color : source_color = vec4(0.2, 0.25, 0.35, 0.5);
uniform vec4 glow_color : source_color = vec4(1.0, 0.75, 0.2, 1.0);

uniform float aspect_ratio = 4.0; // Node Width / Node Height
uniform float corner_radius : hint_range(0.0, 1.0) = 0.8; // 1.0 = Full Pill shape
uniform float border_width : hint_range(0.001, 0.1) = 0.025;
uniform float line_length : hint_range(0.05, 1.0) = 0.3; // Length of the trailing glow
uniform float speed : hint_range(-5.0, 5.0) = 0.8;
uniform float glow_intensity : hint_range(1.0, 5.0) = 2.0;

// Signed Distance Function for a rounded rectangle
float sd_rounded_box(vec2 p, vec2 b, float r) {
    vec2 q = abs(p) - b + vec2(r);
    return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - r;
}

void fragment() {
    // Correct UV for aspect ratio to prevent corner stretching
    vec2 uv = (UV - vec2(0.5)) * vec2(aspect_ratio, 1.0);
    vec2 half_size = vec2(aspect_ratio, 1.0) * 0.5 - vec2(border_width);

    // Calculate maximum corner radius for short edge
    float max_radius = 0.5 - border_width;
    float radius = corner_radius * max_radius;

    // Outer & inner distance fields
    float dist = sd_rounded_box(uv, half_size, radius);

    // Anti-aliasing width
    float aa = 0.005;

    // Masks for fill background and border outline
    float bg_mask = smoothstep(aa, -aa, dist);
    float border_mask = smoothstep(border_width + aa, border_width - aa, abs(dist));

    // Continuous angle [0.0, 1.0] around the perimeter center
    float angle = atan(uv.y, uv.x) / (2.0 * 3.14159265359) + 0.5;

    // Calculate moving head and trailing glow
    float head = fract(TIME * speed * 0.25);
	//head = fract(speed * 0.25) + 0.1;
    float dist_along_path = fract(head - angle * 2.);
    float light_trail = pow(clamp(1.0 - dist_along_path / line_length, 0.0, 1.0), 3.0);

    // Blend base border with light beam glow
    vec4 current_border = mix(border_color, glow_color * glow_intensity, light_trail);

    // Final color assembly
    vec4 final_color = mix(vec4(0.0), bg_color, bg_mask);
    final_color = mix(final_color, current_border, border_mask);

    COLOR = final_color;
}