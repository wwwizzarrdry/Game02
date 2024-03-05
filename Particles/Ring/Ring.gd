extends Node2D

@export var radius: float = 1000 : set = set_radius, get = get_radius
@export var num_points: int = 360 : set = set_num_points, get = get_num_points
@export var line_width: int = 60 : set = set_line_width, get = get_line_width
@export var line_color: Color = Color(1.0, 1.0, 1.0, 0.0) : set = set_line_color, get = get_line_color
@export var fill_texture: CompressedTexture2D = preload("res://Assets/Images/Textures/Pixel.png") : set = set_fill_texture, get = get_fill_texture
@export var line_material: ShaderMaterial = preload("res://Particles/Ring/Ring_shader_material.tres") : set = set_line_material, get = get_line_material
@export var line_shader: Shader = preload("res://Particles/Ring/Ring.gdshader") : set = set_line_shader, get = get_line_shader

@onready var ring: Line2D = $Line2D


func _ready() -> void:
	draw_ring()

func draw_ring():
	# Number of points in the circle
	var r = get_radius()
	var p = get_num_points()
	var line_points = PackedVector2Array()

	for i in range(p):
		var angle = i * 2.0 * PI / p
		var point = Vector2(cos(angle), sin(angle)) * r
		line_points.append(point)
	line_points.append(line_points[0])



	ring.points = line_points
	ring.width = get_line_width()
	ring.default_color = get_line_color()
	ring.texture = get_fill_texture()
	ring.texture_mode = Line2D.LINE_TEXTURE_STRETCH

	#ring.material = get_line_material()
	#ring.material.shader = get_line_shader()

	#ring.material.set_shader_parameter("wobbliness", 0.55) # <-- crashes my debug session
	#(ring.material as ShaderMaterial).set_shader_parameter("laserSize", 0.5)
	#(ring.material as ShaderMaterial).set_shader_parameter("wobbliness", 0.75) # <-- properly sets my wobbliness value to 0.55



#
# GET / SET
#
func set_radius(r: float) -> void:
	radius = r

func get_radius() -> float:
	return radius

func set_num_points(p: int) -> void:
	num_points = p

func get_num_points() -> int:
	return num_points

func set_line_width(w: int) -> void:
	line_width = w

func get_line_width() -> int:
	return line_width

func set_line_color(c: Color) -> void:
	line_color = c

func get_line_color() -> Color:
	return line_color

func set_fill_texture(t: CompressedTexture2D) -> void:
	fill_texture = t

func get_fill_texture() -> CompressedTexture2D:
	return fill_texture

func set_line_material(m: ShaderMaterial) -> void:
	line_material = m

func get_line_material() -> ShaderMaterial:
	return line_material

func set_line_shader(s: Shader) -> void:
	line_shader = s

func get_line_shader() -> Shader:
	return line_shader
