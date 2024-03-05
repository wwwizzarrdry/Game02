extends RayCast2D

@export var laser_color: Color = Color(1, 0.024, 0.031, 0.851) : set = set_laser_color, get = get_laser_color
@onready var line: Line2D = $LaserBeam
@onready var point: Node2D = $Point
var max_distance: float = 5000.0

func _ready() -> void:

	# Set laser color
	(line.material as ShaderMaterial).set_shader_parameter("color1", get_laser_color())
	(line.material as ShaderMaterial).set_shader_parameter("color2", get_laser_color())
	point.modulate = get_laser_color()

	target_position = Vector2(max_distance, 0)
	line.points[1].x = target_position.x
	point.hide()

func _process(_delta: float) -> void:
	if is_colliding():
		var collision_point = to_local(get_collision_point())
		line.points[1].x = collision_point.x
		point.position.x = collision_point.x
		point.show()
	else:
		line.points[1].x = target_position.x
		point.hide()

func  set_laser_color(c:Color) -> void:
	laser_color = c
func get_laser_color() -> Color:
	return laser_color
