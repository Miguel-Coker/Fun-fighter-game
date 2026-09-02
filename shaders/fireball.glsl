uniform vec3 fireball_positions[8];
uniform int num_lights;

vec4 effect(vec4 colour, Image tex, vec2 texture_coords, vec2 pixel_coords)
{
    vec4 pixel = Texel(tex, texture_coords);

    float total_light = 0.0;

    for (int i = 0; i < num_lights; i++)
    {
        vec2 light_pos = fireball_positions[i].xy;
        float light_radius = fireball_positions[i].z;
        
        float distance = length(pixel_coords - light_pos);
        float fade = clamp(distance / light_radius, 0.0, 1.0);

        float light_amount = 1.0 - fade;

        total_light += light_amount;
    }

    total_light = clamp(total_light, 0.0, 1.0);
    pixel.a = pixel.a * (1.0 +total_light);

    return pixel * colour;
}