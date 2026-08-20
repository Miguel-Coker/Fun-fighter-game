uniform vec2 fireball_pos;
uniform vec3 light_colour;
uniform float ambient_light;

vec4 effect(vec4 colour, Image tex, vec2 texture_coords, vec2 pixel_coords)
{
    vec4 base_colour = Texel(tex, texture_coords) * colour;
    
    float light_radius = 50;
    float dist = distance(pixel_coords, fireball_pos);
    
    float attenuation = 0.0;

    if (dist < light_radius)
    {
        attenuation = 1.0f - (dist / light_radius);
        attenuation = clamp(attenuation, 0.0, 1.0);
    }

    vec3 final_light = ambient_light + (light_colour + attenuation);
    return vec4(base_colour.rgb * final_light, base_colour.a);
}