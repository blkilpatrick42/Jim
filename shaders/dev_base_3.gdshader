shader_type canvas_item;

uniform float light_opacity : hint_range(0, 1);
uniform float dark_opacity : hint_range(0, 1);

void fragment() {
    if (AT_LIGHT_PASS) COLOR.a *= light_opacity;
    else COLOR.a *= dark_opacity;
}