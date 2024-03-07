extends RayCast2D


@export var texture_color: Color = Color(0.38, 0.839, 0.929, 0.729) : set = set_texture_color, get = get_texture_color
@export var line_width: int = 600 : set = set_line_width, get = get_line_width
@onready var line: Line2D = $ArcBeamLine
@onready var point: Node2D = $Point
var max_distance: float = 5000.0

func _ready() -> void:

	# Set texture color
	point.modulate = get_texture_color()
	(line.material as ShaderMaterial).set_shader_parameter("color1", get_texture_color())
	(line.material as ShaderMaterial).set_shader_parameter("color2", get_texture_color())
	line.width = get_line_width()

	target_position = Vector2(max_distance, 0)
	line.points[1].x = target_position.x
	point.hide()

func _process(_delta: float) -> void:

	if is_colliding():
		# Vary the width
		line.width = randf_range(get_line_width() * 0.15, get_line_width())

		# Handle Scale ---
		# Scale the impact point relative the width of the laser
		var node1 = line
		var node2 = point
		# Get the width of node1
		var node1_width = node1.width
		# Calculate the scale factor
		var scale_factor = node1_width / 1024 # point texture is 512x512px
		# Scale node2
		node2.scale = Vector2(scale_factor, scale_factor)

		# Handle Collision ---
		var collision_point = to_local(get_collision_point())
		line.points[1].x = collision_point.x
		point.position.x = collision_point.x

		var collision_normal = get_collision_normal()
		var incoming_vector = -target_position.normalized()
		var reflection = incoming_vector.reflect(collision_normal)

		# Convert the reflection vector to an angle
		var angle = atan2(reflection.y, reflection.x)
		angle += PI
		# Rotate the impact node to the reflection angle
		point.rotation = angle
		point.show()

	else:
		# Vary the width
		line.width = get_line_width() * 0.25
		line.points[1].x = target_position.x
		point.hide()

func  set_texture_color(c:Color) -> void:
	texture_color = c
func get_texture_color() -> Color:
	return texture_color

func  set_line_width(w:int) -> void:
	line_width =w
func get_line_width() -> int:
	return line_width
