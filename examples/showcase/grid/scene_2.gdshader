shader_type canvas_item;

// Color Settings (Matching reference image)
uniform vec4 inner_color : source_color = vec4(0.51, 0.13, 0.16, 0.95); // Bright warm red center glow
uniform vec4 outer_color : source_color = vec4(0.21, 0.05, 0.07, 0.95); // Dark wine red outer fill
uniform vec4 border_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);  // Solid white border

// Shape Controls
uniform vec2 rect_size = vec2(300.0, 300.0); // Match your Control Node size (pixels)
uniform float corner_radius : hint_range(0.0, 1.0) = 0.2;  // Corner roundness
uniform float border_width : hint_range(0.0, 0.5) = 0.03;  // Thickness of outer border
uniform float blur_size : hint_range(0.0001, 0.2) = 0.01;  // Feathering/Softness

// Radial Gradient Controls
uniform vec2 radial_center = vec2(0.5, 0.4); // Offset center of radial glow (0.5, 0.5 = middle)
uniform float radial_exponent : hint_range(0.1, 5.0) = 1.2; // Falloff curve exponent

// Signed Distance Function for a rounded rectangle
float sd_rounded_box(vec2 p, vec2 b, float r) {
    vec2 q = abs(p) - b + vec2(r);
    return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - r;
}

void fragment() {
    // Aspect ratio correction relative to center
    vec2 aspect = rect_size / min(rect_size.x, rect_size.y);
    vec2 p = (UV - vec2(0.5)) * aspect;
    
    // Calculate internal radial gradient
    vec2 center_offset = (radial_center - vec2(0.5)) * aspect;
    float dist_from_radial = length(p - center_offset) / (0.5 * min(aspect.x, aspect.y));
    float radial_t = pow(clamp(dist_from_radial, 0.0, 1.0), radial_exponent);
    vec4 fill_color = mix(inner_color, outer_color, radial_t);

    // Box bounds inset by blur_size to prevent edge clipping
    vec2 half_bounds = (vec2(0.5) * aspect) - vec2(blur_size);
    float radius = corner_radius * min(half_bounds.x, half_bounds.y);

    // Calculate distance to box edge
    float dist = sd_rounded_box(p, half_bounds, radius);

    // Smoothstep masks for blurred anti-aliasing
    float outer_mask = 1.0 - smoothstep(-blur_size, blur_size, dist);
    float fill_mask  = 1.0 - smoothstep(-blur_size, blur_size, dist + border_width);
    float border_mask = clamp(outer_mask - fill_mask, 0.0, 1.0);

    // Composite fill and border
    vec4 final_color = mix(fill_color * fill_mask, border_color, border_mask * border_color.a);
    final_color.a *= outer_mask;

    COLOR = final_color;
}