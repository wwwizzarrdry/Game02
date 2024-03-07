extends Camera2D

@export var move_speed = 30 # camera position lerp speed
@export var zoom_speed = 3.0  # camera zoom lerp speed
@export var min_zoom = 5.0  # camera won't zoom closer than this
@export var max_zoom = 0.5  # camera won't zoom farther than this
@export var margin = Vector2(400, 200)  # include some buffer area around targets

var targets = []

@onready var screen_size = get_viewport_rect().size

func _ready() -> void:
	get_camera_targets()
	#set_camera_limits()

func _input(_event):

	if Input.is_action_just_released("zoom_in"):
		# Mouse Wheel
		zoom.x += 0.1
		zoom.y += 0.1

	if Input.is_action_just_released("zoom_out"):
		# Mouse Wheel
		zoom.x -= 0.1
		zoom.y -= 0.1

	if Input.is_action_just_released("ui_left"):
		position.x -= 2
	if Input.is_action_just_released("ui_right"):
		position.x += 2
	if Input.is_action_just_released("ui_up"):
		position.y -= 2
	if Input.is_action_just_released("ui_down"):
		position.y += 2

func _process(delta):
	if !targets:
		return

	# Keep the camera centered among all targets
	var p = Vector2.ZERO
	for target in targets:
		p += target.position
	p /= targets.size()
	position = lerp(position, p, move_speed * delta)

	# Find the zoom that will contain all targets
	var r = Rect2(position, Vector2.ONE)
	for target in targets:
		r = r.expand(target.position)
	r = r.grow_individual(margin.x, margin.y, margin.x, margin.y)
	var z
	if r.size.x > r.size.y * screen_size.aspect():
		z = 1 / clamp(r.size.x / screen_size.x, max_zoom, min_zoom)
	else:
		z = 1 / clamp(r.size.y / screen_size.y, max_zoom, min_zoom)
	zoom = lerp(zoom, Vector2.ONE * z, zoom_speed * delta)

	# For debug
	get_parent().draw_cam_rect(r)

func add_target(t):
	if not t in targets:
		targets.append(t)

func remove_target(t):
	if t in targets:
		targets.remove(t)

func get_camera_targets():
	# Get camera targets
	# var player_nodes = Global.get_nodes_in_branch_group($SomeNode, "player")
	var target_nodes = get_parent().get_tree().get_nodes_in_group("player")
	for p in target_nodes:
		add_target(p)

func set_camera_limits():
	# Set the limits of the World Camera
	var tile_map = get_parent().get_node("TileMap")
	if tile_map != null:
		var r = tile_map.get_used_rect()
		limit_left = r.position.x * tile_map.tile_set.tile_size.x
		limit_right = r.end.x * tile_map.tile_set.tile_size.x
		limit_bottom = r.end.y * tile_map.tile_set.tile_size.y
