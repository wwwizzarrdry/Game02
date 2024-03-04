extends Node2D

# Debug Tools
@export var debug: bool = false : set = set_debug
@export var show_mouse_coords: bool = false : set = set_show_mouse_coords
@export var show_grid: bool = false : set = set_show_grid
@export var show_radar: bool = false : set = set_show_radar

# World Objects
@onready var world_camera: Camera2D = $WorldCamera
@onready var world: Node2D = $World
@onready var player: CharacterBody2D = $Player

var root
var viewport

# Show max-distance perimeter of an object being tethered
var show_max_dist_perimeter = false
var perimeter_width: float = 0
var center_point: Vector2 = Vector2.ZERO
var max_distance: int = 0
var alpha: float  = 0
var delt: float = 0

# Multi-target Camera
var camera_targets = []



func _ready() -> void:
	pass

func _input(event):
	if event.is_action_pressed("ui_focus_next"):
		debug = !debug
	if event is InputEventKey and event.pressed and event.keycode == KEY_1:
		show_mouse_coords = !show_mouse_coords
	if event is InputEventKey and event.pressed and event.keycode == KEY_2:
		show_grid = !show_grid
	if event is InputEventKey and event.pressed and event.keycode == KEY_3:
		show_radar = !show_radar

func _process(_delta: float) -> void:
	pass

func _draw():

	# Draw Tether
	draw_dashed_line(center_point, $Player.position, Color(0, 0, 1), 5.0, 20.0, true)

	if show_max_dist_perimeter:
		# Draw max distace perimeter
		draw_arc(center_point, max_distance, 0, 360, 360, Color(0, 1, 0, alpha), perimeter_width, true)

	if debug:

		# Multi-terget camera bounds
		draw_circle(world_camera.position, 10, Color.CORAL)
		draw_rect(cam_rect, Color.CORAL, false, 4.0)

		if show_mouse_coords:
			# Show coords on mouse pointer
			var mouse_pos = get_global_mouse_position()
			draw_string(Global.default_font, Vector2(mouse_pos.x + 10, mouse_pos.y - 10), str(Vector2(round(mouse_pos.x), round(mouse_pos.y))))


		if show_grid or show_radar:

			var num_tiles = 16
			var tile_size: float = 128.0
			var max_length: float = num_tiles * tile_size

			# Center Point
			draw_circle(Vector2.ZERO, 10.0, Color(1, 0, 0)) # center dot

			if show_grid:
				#
				# Draw dashed line (x/y)
				#
				# X-Axis
				draw_dashed_line(Vector2(-max_length, 0), Vector2(max_length, 0), Color(1, 1, 1), 1.0, 2.0, true)
				# Y-Axis
				draw_dashed_line(Vector2(0, -max_length), Vector2(0, max_length), Color(1, 1, 1), 1.0, 2.0, true)

			for i in range(1, num_tiles):
				var radius = i * tile_size

				# Label
				# X
				draw_circle(Vector2(radius, 0), 5.0, Color(1, 0, 0))
				draw_dashed_line(Vector2(radius, 0), Vector2(radius + 10, 16), Color(1, 1, 1), 1.0, 1.0, true)
				draw_string(Global.default_font, Vector2(radius + 10, 30), str(radius) + "px")

				draw_circle(Vector2(-radius, 0), 5.0, Color(1, 0, 0))
				draw_dashed_line(Vector2(-radius, 0), Vector2(-radius + 10, 16), Color(1, 1, 1), 1.0, 1.0, true)
				draw_string(Global.default_font, Vector2(-radius + 10, 30), str(-radius) + "px")

				# Y
				draw_circle(Vector2(0, radius), 5.0, Color(1, 0, 0))
				draw_dashed_line(Vector2(0, radius), Vector2(16, radius + 10), Color(1, 1, 1), 1.0, 1.0, true)
				draw_string(Global.default_font, Vector2(16, radius + 20), str(radius) + "px")

				draw_circle(Vector2(0, -radius), 5.0, Color(1, 0, 0))
				draw_dashed_line(Vector2(0, -radius), Vector2(16, -radius + 10), Color(1, 1, 1), 1.0, 1.0, true)
				draw_string(Global.default_font, Vector2(16, -radius + 20), str(-radius) + "px")

				if show_grid:
					# Draw dashed line
					# X-Axis
					draw_dashed_line(Vector2(-max_length, radius), Vector2(max_length, radius), Color(1, 1, 1), 1.0, 2.0, true)
					draw_dashed_line(Vector2(-max_length, -radius), Vector2(max_length, -radius), Color(1, 1, 1), 1.0, 2.0, true)
					# Y-Axis
					draw_dashed_line(Vector2(radius, -max_length), Vector2(radius, max_length), Color(1, 1, 1), 1.0, 2.0, true)
					draw_dashed_line(Vector2(-radius, -max_length), Vector2(-radius, max_length), Color(1, 1, 1), 1.0, 2.0, true)

				if show_radar:
					#
					# Draw radial grid
					#
					draw_arc(Vector2.ZERO, radius, 0, 360, 360, Color(1, 0, 0, 0.5), 2.0, true)

func draw_max_distance_perimeter(center, max_dist, distance_ratio):
	show_max_dist_perimeter = true if distance_ratio >= 0.9 else false
	center_point = center
	max_distance = max_dist
	alpha = lerp(0.0, 1.0, (distance_ratio - 0.9) * 10) # Interpolate alpha based on distance ratio
	perimeter_width = lerp(0.0, 10.0, (distance_ratio - 0.9) * 10) # Replace with your desired width
	queue_redraw()



# Debug Controls
func set_debug(val: bool) -> void:
	debug = val

func set_show_mouse_coords(val: bool) -> void:
	show_mouse_coords = val

func set_show_grid(val: bool) -> void:
	show_grid = val

func set_show_radar(val: bool) -> void:
	show_radar = val

var cam_rect = Rect2()
func draw_cam_rect(r):
	cam_rect = r
	queue_redraw()

func _on_timer_timeout() -> void:
	var radius = $Player.max_distance
	if radius > 0:
		radius = radius - 10.0
	else:
		radius = 5000.0

	$Player.max_distance = radius
	$World.set_new_radius(radius)
	$Timer.start()





