extends Node2D

@onready var hud:= $CanvasLayer/HUD
@onready var world_camera:= $WorldCamera
@onready var player = preload("res://Scenes/Components/TestPlayer/TestPlayer.tscn")
@onready var spawn1: Marker2D = $Spawn1
@onready var spawn2: Marker2D = $Spawn2

var camera_targets = []
var debug = false

var Level = false
var level_index = 0
var levels = [
	"res://Scenes/Levels/LoadingScreen/LoadingScreen.tscn",
	"res://Scenes/Levels/StartScreen/StartScreen.tscn"
]

var progress_bar
var thread

func _ready() -> void:
	hud.process_mode = Node.PROCESS_MODE_DISABLED
	load_level()

func _input(event):
	if level_index < 2: return

	if event.is_action_pressed("ui_focus_next"):
		debug = !debug

var cam_rect = Rect2()
func draw_cam_rect(r):
	cam_rect = r
	queue_redraw()

func _draw():
	if !debug:
		return
	if level_index < 2:
		return

	draw_circle(world_camera.position, 10, Color.CORAL)
	draw_rect(cam_rect, Color.CORAL, false, 4.0)

func get_camera_targets():
	# Get camera targets
	# var player_nodes = Global.get_nodes_in_branch_group($SomeNode, "player")
	var player_nodes = get_tree().get_nodes_in_group("player")
	for p in player_nodes:
		world_camera.add_target(p)

func set_camera_limits():
	# Set the limits of the World Camera
	var tile_map = get_node("TileMap")
	var r = tile_map.get_used_rect()
	world_camera.limit_left = r.position.x * tile_map.tile_set.tile_size.x
	world_camera.limit_right = r.end.x * tile_map.tile_set.tile_size.x
	world_camera.limit_bottom = r.end.y * tile_map.tile_set.tile_size.y

func load_level():

	if Level:
		var current_level = get_node("Level")
		# Remove the current level from the scene tree
		remove_child(current_level)
		# Free the resources used by the current level
		current_level.queue_free()

	if level_index < levels.size():
		var level_path = levels[level_index]
		var level_resource = load(level_path)  # Load the scene resource
		var level_instance = level_resource.instantiate()  # Create an instance of the scene
		add_child(level_instance)  # Add the instance to the current scene
		level_instance.name = "Level" #"Level_" + str(level_index)
		level_instance.position = world_camera.position
		Level = level_instance
		level_index += 1
	else:
		level_index = 2
		load_game(level_index)
		print("All levels loaded!")

func load_game(index):



	if index >= 2:
		spawn_players()
		hud.process_mode = Node.PROCESS_MODE_ALWAYS
		hud.set_process_input(true)  # Disable input processing
		$TileMap.visible = true
		hud.visible = true
		world_camera.visible = true
		world_camera.enabled = true
		get_camera_targets()
		set_camera_limits()

func spawn_players():
	var player1 = player.instantiate()
	add_child(player1)
	player1.name = "Player1"
	player1.position = spawn1.position

	var player2 = player.instantiate()
	add_child(player2)
	player2.name = "Player2"
	player2.position = spawn2.position

