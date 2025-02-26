shader_type canvas_item;

uniform int x_pixel_size : hint_range(1, 100) = 6;
uniform int y_pixel_size : hint_range(1, 100) = 6;
uniform float noise_intensity : hint_range(0.0, 1.0) = 0.5;
uniform float seed = 0.5;

// Function to generate random noise
float random(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233) * seed)) * 43758.5453123);
}

// Function to generate Voronoi-like noise
float voronoi(vec2 uv) {
    vec2 i = floor(uv);
    vec2 f = fract(uv);

    float min_dist = 1.0;
    vec2 closest = vec2(0.0);

    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec2 neighbor = vec2(float(x), float(y));
            vec2 point = random(i + neighbor) + neighbor;
            float dist = length(f - point);

            if (dist < min_dist) {
                min_dist = dist;
                closest = point;
            }
        }
    }

    return min_dist;
}

void fragment() {
    vec2 tex_size = TEXTURE_PIXEL_SIZE * vec2(float(x_pixel_size), float(y_pixel_size));
    
    // Base pixelation grid
    vec2 pixel_uv = floor(UV / tex_size) * tex_size;

    // Add Voronoi noise to distort pixel positions
    vec2 noise_offset = vec2(voronoi(pixel_uv * seed), voronoi(pixel_uv.yx * seed)) * noise_intensity * tex_size;
    vec2 final_uv = pixel_uv + noise_offset;

    // Sample texture with modified pixelated UVs
    COLOR = texture(TEXTURE, final_uv);
}
