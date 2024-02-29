extends Node

@onready var player = preload("res://Scenes/Components/TestPlayer/TestPlayer.tscn")
@onready var world_camera: Camera2D = $WorldCamera

var Level
var camera_targets = []
var debug = false

var level_index = 0
var levels = ["res://Scenes/Levels/Level01/Level01.tscn"]


func _ready() -> void:
	print("Main loaded. Player Count == " + str(PlayerData.player_count))
	load_level()
	get_camera_targets()
	set_camera_limits()
	%HUD.move_to_front()

func _process(_delta: float) -> void:
	pass

func _input(event):
	if event.is_action_pressed("ui_focus_next"):
		debug = !debug

var cam_rect = Rect2()
func draw_cam_rect(r):
	cam_rect = r
	Level.queue_redraw()

func _draw():
	if !debug:
		return
	Level.draw_circle(world_camera.position, 10, Color.CORAL)
	Level.draw_rect(cam_rect, Color.CORAL, false, 4.0)

func spawn_players():
	#var player1 = player.instantiate()
	#add_child(player1)
	#player1.name = "Player1"
	#player1.postion = spawn1.position

	#var player2 = player.instantiate()
	#add_child(player2)
	#player2.name = "Player2"
	#player2.position = spawn2.position
	pass

func get_camera_targets():
	# Get camera targets
	var player_nodes = Global.get_nodes_in_branch_group(Level, "player")
	for p in player_nodes:
		world_camera.add_target(p)

func set_camera_limits():
	# Set the limits of the World Camera
	var tile_map = Level.get_node("TileMap")
	var r = tile_map.get_used_rect()
	world_camera.limit_left = r.position.x * tile_map.tile_set.tile_size.x
	world_camera.limit_right = r.end.x * tile_map.tile_set.tile_size.x
	world_camera.limit_bottom = r.end.y * tile_map.tile_set.tile_size.y
	pass

func load_level():
	if level_index < levels.size():
		var level_path = levels[level_index]
		var level_resource = load(level_path)  # Load the scene resource
		var level_instance = level_resource.instantiate()  # Create an instance of the scene
		add_child(level_instance)  # Add the instance to the current scene
		level_instance.name = "Level" #"Level_" + str(level_index)
		level_index += 1
		Level = get_node("Level")
	else:
		print("All levels loaded!")
