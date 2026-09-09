uniform vec3 light_positions[16]; // x, y, radius
uniform int num_lights; // total number of lights
uniform vec3 light_colour;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 pixel = Texel(texture, texture_coords) * color;
    
    float totalLight = 0.0;
    
    for (int i = 0; i < num_lights; i++) {
        vec2 lightPos = light_positions[i].xy;
        float radius = light_positions[i].z;
        
        float distance = length(screen_coords - lightPos);
        float fade = clamp(distance / radius, 0.0, 1.0);
        
        // Invert fade so light is 1.0 at center, 0.0 at edge
        float lightAmount = 1.0 - fade;
        totalLight += lightAmount;
    }
    
    // Clamp total light and use it to reduce darkness
    totalLight = clamp(totalLight, 0.0, 1.0);
    
    vec3 final_light = totalLight + light_colour;

    return vec4(pixel.rgb * final_light, pixel.a);
}