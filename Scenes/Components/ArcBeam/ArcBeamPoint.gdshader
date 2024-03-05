shader_type canvas_item;

void vertex() {
	VERTEX.y += sin(TIME * 80.0) * 100.0 * (UV.x - 1.0);
}