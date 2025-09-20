shader_type canvas_item;

uniform float grain_intensity : hint_range(0.0, 1.0) = 0.05;
uniform float time_speed = 5.0;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec4 scene_color = texture(SCREEN_TEXTURE, SCREEN_UV);

    float noise = fract(sin(dot(UV * (TIME * time_speed), vec2(12.9898,78.233))) * 43758.5453);

    vec3 grain = mix(scene_color.rgb, vec3(noise), grain_intensity);

    COLOR = vec4(grain, scene_color.a);
}
