shader_type canvas_item;

uniform float flicker_speed = 20.0;
uniform float flicker_strength : hint_range(0.0, 0.5) = 0.05;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec4 scene_color = texture(SCREEN_TEXTURE, SCREEN_UV);

    float flicker = 1.0 - flicker_strength + flicker_strength * sin(TIME * flicker_speed);
    scene_color.rgb *= flicker;

    COLOR = scene_color;
}
