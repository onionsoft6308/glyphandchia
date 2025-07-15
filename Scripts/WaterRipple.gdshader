shader_type canvas_item; // This tells Godot this is a 2D (CanvasItem) shader

// Uniforms: values set from GDScript or the editor
uniform sampler2D mask_texture;      // Black/white mask: black = water, white = land
uniform float ripple_strength = 0.5;// How bright/strong the ripple ring is
uniform float ripple_speed = 1.0;    // How fast the ripple animates

uniform vec2 ripple_center0;
uniform float ripple_time0;
uniform vec2 ripple_center1;
uniform float ripple_time1;
uniform vec2 ripple_center2;
uniform float ripple_time2;
uniform vec2 ripple_center3;
uniform float ripple_time3;
uniform vec2 ripple_center4;
uniform float ripple_time4;
uniform vec2 ripple_center5;
uniform float ripple_time5;
uniform vec2 ripple_center6;
uniform float ripple_time6;
uniform vec2 ripple_center7;
uniform float ripple_time7;

void fragment() {
    vec2 uv = UV; // The current pixel's UV coordinates (0..1 across the sprite)
    float mask = texture(mask_texture, uv).r; // Sample the mask: 1=water, 0=land
    vec4 base = texture(TEXTURE, uv); // Sample the base water texture/color

    float ring = 0.0; // This will hold the brightness of the ripple at this pixel
    for (int i = 0; i < 5; i++) {
        vec2 center = vec2(0.0);
        float time = 0.0;
        if (i == 0) { center = ripple_center0; time = ripple_time0; }
        else if (i == 1) { center = ripple_center1; time = ripple_time1; }
        else if (i == 2) { center = ripple_center2; time = ripple_time2; }
        else if (i == 3) { center = ripple_center3; time = ripple_time3; }
        else if (i == 4) { center = ripple_center4; time = ripple_time4; }
        else if (i == 5) { center = ripple_center5; time = ripple_time5; }
        else if (i == 6) { center = ripple_center6; time = ripple_time6; }
        else if (i == 7) { center = ripple_center7; time = ripple_time7; }

        float fade = clamp(1.0 - (time / 0.5), 0.0, 1.0); // Fade out over 0.5 seconds
        // Only draw ripples on water (mask > 0.5) and if the center x is non-negative
        float max_radius = 0.1; // adjust as needed (0.1~0.2 is typical for local effect)
        if (mask < 0.5 && center.x >= 0.0) {
            float dist = distance(uv, center);
            if (dist < max_radius) { // Only draw ripple if within radius
                float t = time * ripple_speed;
                float wave = sin((dist - t) * 60.0); // Higher frequency for smaller rings
                if (abs(wave) < 0.08) {
                    // Optional: fade out as it gets further from center
                    float local_fade = 1.0 - (dist / max_radius);
                    ring += ripple_strength * fade * local_fade;
                }
            }
        }
    }

    // Add the ripple ring (white) to the base color
    COLOR = base + vec4(vec3(ring), 1.0);
}
