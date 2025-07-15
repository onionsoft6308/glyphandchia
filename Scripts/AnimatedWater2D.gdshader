shader_type canvas_item;

// Colors
uniform vec4 WATER_COL = vec4(0.04, 0.38, 0.88, 1.0);
uniform vec4 WATER2_COL = vec4(0.04, 0.35, 0.78, 1.0);
uniform vec4 FOAM_COL = vec4(0.8125, 0.9609, 0.9648, 1.0);

// Animation and distortion
uniform float distortion_speed = 2.0;
uniform vec2 tile = vec2(5.0, 5.0);
uniform float height = 2.0;
uniform float wave_speed = 1.5;

// Optional: Mask for land outlines (white = land, black = water)
uniform sampler2D mask_texture;
uniform float outline_thickness = 0.08;
uniform float outline_falloff = 0.04;

const float M_2PI = 6.283185307;
const float M_6PI = 18.84955592;

// --- Noise and helper functions ---
float random(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

float noise(vec2 uv) {
    vec2 uv_index = floor(uv);
    vec2 uv_fract = fract(uv);

    float a = random(uv_index);
    float b = random(uv_index + vec2(1.0, 0.0));
    float c = random(uv_index + vec2(0.0, 1.0));
    float d = random(uv_index + vec2(1.0, 1.0));

    vec2 blur = smoothstep(0.0, 1.0, uv_fract);

    return mix(a, b, blur.x) +
           (c - a) * blur.y * (1.0 - blur.x) +
           (d - b) * blur.x * blur.y;
}

float fbm(vec2 uv) {
    int octaves = 4;
    float amplitude = 0.5;
    float frequency = 3.0;
    float value = 0.0;
    for(int i = 0; i < octaves; i++) {
        value += amplitude * noise(frequency * uv);
        amplitude *= 0.5;
        frequency *= 2.0;
    }
    return value;
}

// --- Main water color function ---
vec3 water(vec2 uv, float iTime) {
    uv *= 0.25;
    uv += fbm(uv) * 0.2;

    // Animate with two directional waves
    float h = sin(uv.x + iTime);
    uv += vec2(0.025 * h, 0.025 * h);

    h = sin(0.841471 * uv.x - 0.540302 * uv.y + iTime);
    uv += vec2(0.025 * h, 0.025 * h);

    // Texture distortion
    float d1 = mod(uv.x + uv.y, M_2PI);
    float d2 = mod((uv.x + uv.y + 0.25) * 1.3, M_6PI);
    d1 = iTime * 0.07 + d1;
    d2 = iTime * 0.5 + d2;
    vec2 dist = vec2(
        sin(d1) * 0.15 + sin(d2) * 0.05,
        cos(d1) * 0.15 + cos(d2) * 0.05
    );

    // Two-tone water color
    float bands = smoothstep(0.4, 0.6, sin(uv.y * 10.0 + iTime * 0.5));
    vec3 color = mix(WATER_COL.rgb, WATER2_COL.rgb, bands);

    // Add some foam at the top (for visual interest)
    float foam = smoothstep(0.95, 1.0, uv.y + fbm(uv * 2.0 + iTime * 0.1) * 0.05);
    color = mix(color, FOAM_COL.rgb, foam * 0.5);

    return color;
}

void fragment() {
    vec2 uv = UV * tile;
    float t = TIME * distortion_speed;
    vec3 base_color = water(uv, t);

    // Optional: White outline at land/water edge using mask
    float outline = 0.0;
    if (texture(mask_texture, UV).r > 0.0) {
        float mask = texture(mask_texture, UV).r;
        outline = smoothstep(1.0 - outline_thickness - outline_falloff, 1.0 - outline_thickness, mask);
    }

    vec3 final_color = mix(base_color, vec3(1.0), outline);

    COLOR = vec4(final_color, 1.0);
}