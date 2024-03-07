shader_type canvas_item;

uniform float vignette_intensity = 0.4;
uniform float vignette_opacity : hint_range(0.0, 1.0) = 0.5;
uniform vec4 vignette_rgb : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform sampler2D smolder_texture;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

float vignette(vec2 uv){
	uv *= 1.0 - uv.xy;
	float vignette = uv.x * uv.y * 15.0;
	return pow(vignette, vignette_intensity * vignette_opacity);
}

void fragment(){
	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec4 text = texture(TEXTURE, UV);
	vec4 smolder_color = texture(smolder_texture, SCREEN_UV);

	text.rgba *= (vignette_rgb.rgba);
	text.rgba *= (1.0 - vignette(UV));

	// Combine the colors of the textures
    vec4 combined_color = mix(text, color, 0.5); // Change 0.5 to any value between 0.0 and 1.0 to adjust the mix ratio

    COLOR = combined_color;

	//COLOR = vec4((text.rgb)*color.rgb,text.a);
}