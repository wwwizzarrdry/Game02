extends Node

@onready var main_hud: PackedScene = preload("res://Scenes/Components/Hud/Hud.tscn")
@onready var main_camera: PackedScene = preload("res://Scenes/Components/WorldCamera/WorldCamera.tscn")

var hud
var world_camera
var camera_targets = []
var debug = false

var Level = false
var level_index = 0
var levels = [
	"res://Scenes/Levels/LoadingScreen/LoadingScreen.tscn",
	"res://Scenes/Levels/StartScreen/StartScreen.tscn",
	"res://Scenes/Levels/Level01/Level01.tscn"
]

func _ready() -> void:
	load_level()

func _process(_delta: float) -> void:
	pass

func _input(event):
	if level_index < 2: return

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

func get_camera_targets():
	# Get camera targets
	var player_nodes = Global.get_nodes_in_branch_group(Level, "player")
	print("camera targets: ", player_nodes)
	for p in player_nodes:
		world_camera.add_target(p)

func set_camera_limits():
	# Set the limits of the World Camera
	var tile_map = Level.get_node("TileMap")
	var r = tile_map.get_used_rect()
	world_camera.limit_left = r.position.x * tile_map.tile_set.tile_size.x
	world_camera.limit_right = r.end.x * tile_map.tile_set.tile_size.x
	world_camera.limit_bottom = r.end.y * tile_map.tile_set.tile_size.y

func load_level():
	if level_index < levels.size():

		if Level:
			var current_level = get_node("Level")
			# Remove the current level from the scene tree
			remove_child(current_level)
			# Free the resources used by the current level
			current_level.queue_free()

		var level_path = levels[level_index]
		var level_resource = load(level_path)  # Load the scene resource
		var level_instance = level_resource.instantiate()  # Create an instance of the scene
		add_child(level_instance)  # Add the instance to the current scene
		level_instance.name = "Level" #"Level_" + str(level_index)
		Level = level_instance
		level_loaded(level_index, Level)
		level_index += 1
	else:
		print("All levels loaded!")

func level_loaded(index, instance):
	print("Level " + str(index) + " loaded. ", instance)

	if index >= 2:
		# Create HUD
		hud = main_hud.instantiate()
		add_child(hud)
		hud.name = "HUD"

		# Create World Camera
		world_camera = main_camera.instantiate()
		add_child(world_camera)
		world_camera.name = "WorldCamera"

		get_camera_targets()
		set_camera_limits()

		#%HUD.move_to_front()
