shader_type canvas_item;

uniform float brightness = 1.0;
uniform bool is_selected = false;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    tex_color.rgb *= brightness;

    if (is_selected) {
        tex_color.rgb = vec3(1.0); 
    }

    COLOR = tex_color;
}
