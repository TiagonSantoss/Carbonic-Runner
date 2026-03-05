shader_type canvas_item;

uniform float speed : hint_range(-10.0, 10.0) = 1.0;
uniform float direction : hint_range(-1.0, 1.0) = 1.0;
uniform vec2 center = vec2(0.5, 0.5);

uniform sampler2D palette_texture;
uniform bool use_palette = false;

void fragment() {
    vec2 uv = UV;

    // move UV to rotation center
    uv -= center;

    float angle = TIME * speed * direction;

    float s = sin(angle);
    float c = cos(angle);

    uv = vec2(
        uv.x * c - uv.y * s,
        uv.x * s + uv.y * c
    );

    uv += center;

    vec4 base_color = texture(TEXTURE, uv);

    if (use_palette) {
        float index = base_color.r; 
        vec4 palette_color = texture(palette_texture, vec2(index, 0.5));
        COLOR = vec4(palette_color.rgb, base_color.a);
    } else {
        COLOR = base_color;
    }
}