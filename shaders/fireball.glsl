uniform vec3 fireball_positions[8];
uniform int num_lights;

vec4 effect(vec4 colour, Image tex, vec2 texture_coords, vec2 pixel_coords)
{
    vec4 pixel = Texel(tex, texture_coords) * colour;

    float total_light = 0.0;

    float attenuation = 0.0;

    for (int i = 0; i < num_lights; i++)
    {
        vec2 light_pos = fireball_positions[i].xy;
        float light_radius = fireball_positions[i].z;
        
        float dist = distance(pixel_coords, light_pos);

        if (dist < light_radius)
        {
            attenuation = 1.0 - (dist / light_radius);
            attenuation = clamp(attenuation, 0.0, 1.0);
        }

        total_light += attenuation;
    }

    total_light = clamp(total_light, 0.0, 1.0);
    pixel.a = pixel.a * (1.0 + total_light);

    return vec4(pixel.rgb * total_light, pixel.a);
}