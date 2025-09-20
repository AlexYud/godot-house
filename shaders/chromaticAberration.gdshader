shader_type canvas_item;

uniform float aberration_strength : hint_range(0.0, 0.01) = 0.002;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec2 uv = SCREEN_UV;

    float r = texture(SCREEN_TEXTURE, uv + vec2(aberration_strength, 0.0)).r;
    float g = texture(SCREEN_TEXTURE, uv).g;
    float b = texture(SCREEN_TEXTURE, uv - vec2(aberration_strength, 0.0)).b;

    COLOR = vec4(r, g, b, 1.0);
}
