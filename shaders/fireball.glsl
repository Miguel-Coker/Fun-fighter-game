uniform vec3 light_positions[16]; // x, y, radius
uniform int num_lights; // total number of lights
uniform vec3 light_colour; // colour of the light

vec4 effect(vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 pixel = Texel(texture, texture_coords) * colour;
    
    float total_light = 0.0;
    
    for (int i = 0; i < num_lights; i++) {
        vec2 light_pos = light_positions[i].xy;
        float radius = light_positions[i].z;
        
        float distance = length(screen_coords - light_pos);
        float fade = clamp(distance / radius, 0.0, 1.0);
        
        // Invert fade so light is 1.0 at center, 0.0 at edge
        float light_amount = 1.0 - fade;
        total_light += light_amount;
    }
    
    // Clamp total light and use it to reduce darkness
    total_light = clamp(total_light, 0.0, 1.0);
    
    // Apply light_colour to the totalLight
    vec3 final_light = total_light + light_colour;

    return vec4(pixel.rgb * final_light, pixel.a);
}