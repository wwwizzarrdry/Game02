shader_type canvas_item;

uniform vec4 color1 : source_color;
uniform vec4 color2 : source_color;
uniform float colorMixFactor : hint_range(0, 10) = 1.0;
uniform float glowFactor = 3.0;

void fragment() {
	vec2 uv = vec2(UV.x + sin(TIME * 10.0) * 0.1, UV.y + sin(TIME * 1.0) * 0.05);
	vec4 tex_color = texture(TEXTURE, uv);
    COLOR = tex_color * color1;
	COLOR = tex_color * mix(color1, color2, clamp(1.0 * colorMixFactor, 0.0, 1.0)) * glowFactor;
	//COLOR = texture(TEXTURE, uv);
}

