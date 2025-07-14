shader_type canvas_item; // This tells Godot this is a 2D (CanvasItem) shader

// Uniforms: values set from GDScript or the editor
uniform sampler2D mask_texture;      // Black/white mask: white = water, black = land
uniform float time;                  // Time since the ripple started (in seconds)
uniform vec2 ripple_center;          // UV coordinates (0..1) of the ripple's center
uniform float ripple_strength = 0.25;// How bright/strong the ripple ring is
uniform float ripple_speed = 1.0;    // How fast the ripple animates

void fragment() {
    vec2 uv = UV; // The current pixel's UV coordinates (0..1 across the sprite)
    float mask = texture(mask_texture, uv).r; // Sample the mask: 1=water, 0=land
    vec4 base = texture(TEXTURE, uv); // Sample the base water texture/color

    float ring = 0.0; // This will hold the brightness of the ripple at this pixel

    // Only draw ripples on water (mask > 0.5)
    if (mask > 0.5) {
        float dist = distance(uv, ripple_center); // Distance from this pixel to the ripple center
        float t = time * ripple_speed;            // Animate the ripple over time
        float wave = sin((dist - t) * 20.0);      // Create a circular wave pattern
        // Only show the ring where the wave is near zero (the crest of the wave)
        if (abs(wave) < 0.08) {                  // 0.08 controls ring thickness
            ring = ripple_strength;              // Set ring brightness
        }
    }

    // Add the ripple ring (white) to the base color
    COLOR = base + vec4(vec3(ring), 1.0);
}
