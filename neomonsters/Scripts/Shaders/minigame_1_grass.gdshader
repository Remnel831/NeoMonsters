shader_type canvas_item;

uniform float wind_speed : hint_range(0.1, 5.0) = 1.0;
uniform float wind_strength : hint_range(0.0, 2.0) = 0.3;
uniform vec3 grass_color : source_color = vec3(0.2, 0.6, 0.2);
uniform vec3 dark_grass_color : source_color = vec3(0.1, 0.4, 0.1);
uniform float density : hint_range(5.0, 50.0) = 20.0;
uniform float wave_frequency : hint_range(1.0, 10.0) = 3.0;

uniform sampler2D noise_texture : source_color; // Import the TextureRect texture
uniform float noise_strength : hint_range(0.0, 1.0) = 0.3;

void fragment() {
    vec2 uv = SCREEN_UV;
    
    // Grass height gradient
    float grass_height = smoothstep(0.0, 1.0, uv.y);
    
    // Wave motion for the grass
    float wave = sin(uv.x * density + TIME * wind_speed) * wind_strength;
    
    // Define the grass blade shapes
    float blade = smoothstep(0.4 + wave, 1.0, uv.y);
    
    // Sample the imported noise texture from TextureRect
    float noise = texture(noise_texture, uv).r;

    // Blend colors with noise
    vec3 base_color = mix(dark_grass_color, grass_color, grass_height);
    base_color *= blade;
    
    // Apply noise effect correctly
    base_color = mix(base_color, base_color * (1.0 - noise_strength * noise), noise_strength);

    COLOR = vec4(base_color, 1.0);
}
