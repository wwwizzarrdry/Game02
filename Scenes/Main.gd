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
		#set_camera_limits()

		progress_bar = $ProgressBar  # Reference to the ProgressBar node
		thread = Thread.new()  # A new thread for map generation
		# Start the map generation in a new thread
		#thread.start(generate_arena.bind("noise"), 2)
		#thread.wait_to_finish()

		generate_arena("noise")

func spawn_players():
	var player1 = player.instantiate()
	add_child(player1)
	player1.name = "Player1"
	player1.position = spawn1.position

	var player2 = player.instantiate()
	add_child(player2)
	player2.name = "Player2"
	player2.position = spawn2.position


func generate_arena(type: String = "circle"):
	var style = type  # Style of tile placement: "circle", "spiral", "angle", or "noise"
	var tilemap = $TileMap  # Reference to the TileMap node
	var center =  Vector2(10, 10) #tilemap.local_to_map(world_camera.position) #Vector2(10, 10)  # Center of the circle
	var radii = [300, 600, 900, 1200, 1500]  # List of radii
	var tile_ids = [3, 8, 9, 10, 11]  # Corresponding tile IDs for water, land, mountain, and noise-based tiles
	var angle_segment = PI / 4  # Angle segment for the "angle" style
	var perimeter_tiles = []

	tilemap.clear()

	if style == "circle":
		for x in range(center.x - radii[-1], center.x + radii[-1]):
			for y in range(center.y - radii[-1], center.y + radii[-1]):
				var pos_world = Vector2(x, y)
				var pos_map = tilemap.local_to_map(pos_world)  # Convert to map coordinates
				var dist = pos_world.distance_to(center)
				for i in range(len(radii)):
					if dist <= radii[i] and tilemap.get_cell_source_id(0, pos_map) == -1:  # Check if there isn't already a tile at the position
						tilemap.set_cell(0, pos_map, tile_ids[i], Vector2(0, 0), 0)  # Place a tile at the position
						if dist == radii[i]:
							perimeter_tiles.append(pos_map)  # Save the perimeter tiles
							break
	elif style == "spiral":
		var angle = 0.0
		var radius = 0.0
		while radius <= radii[-1]:
			var pos_world = Vector2(center.x, center.y) + Vector2(cos(angle), sin(angle)) * radius
			var pos_map = tilemap.local_to_map(pos_world)  # Convert to map coordinates
			var dist = pos_world.distance_to(center)  # Calculate distance using Vector2
			for i in range(len(radii)):
				if dist <= radii[i]:
					print(tile_ids[i])
					tilemap.set_cell(0, pos_map, tile_ids[i], Vector2(0, 0), 0)  # Place a tile at the position
					if dist <= radii[i] and tilemap.get_cell_source_id(0, pos_map) == -1:
						perimeter_tiles.append(pos_map)  # Save the perimeter tiles
						break
			angle += 0.1
			radius += 0.1
	elif style == "angle":
		center = Vector2(10, 10)
		for x in range(center.x - radii[-1], center.x + radii[-1]):
			for y in range(center.y - radii[-1], center.y + radii[-1]):

				var pos_tile = Vector2(x, y)
				var pos_world = tilemap.map_to_local(pos_tile)  # Convert to world coordinates
				var dist = pos_world.distance_to(tilemap.map_to_local(center))  # Calculate distance using world coordinates
				var angle = (pos_world - tilemap.map_to_local(center)).angle()
				var segment = int(angle / angle_segment) % len(tile_ids)
				for i in range(len(radii)):
					if dist <= radii[i] and tilemap.get_cell_source_id(0, pos_world) == -1:
						tilemap.set_cell(0, pos_world, tile_ids[segment], Vector2(0, 0), 0)  # Place a tile at the position
						if dist == radii[i]:
							perimeter_tiles.append(pos_world)  # Save the perimeter tiles
							break
	elif style == "noise":
		var noise_texture = load("res://Assets/Images/Textures/PNG/Techno 2 - 128x128.png")  # Noise texture
		var size = Vector2(720, 720)  # Size of the square in tile coordinates
		var noise_scale = Vector2(0.1, 0.1)  # Scale factor for the noise texture
		center = Vector2(size.x/2, size.y/2)
		tile_ids = [9, 3, 11]  # Corresponding tile IDs

		var total_tiles = size.x * size.y
		var processed_tiles = 0

		for x in range(size.x):
			for y in range(size.y):
				var pos_tile = Vector2(x, y)
				var noise_value = noise_texture.get_pixelv(pos_tile * noise_scale).r  # Sample the noise texture at scaled coordinates
				var tile_id
				tile_ids = [8, 9, 3, 10, 11]
				if noise_value < 0.13:
					tile_id = tile_ids[0]  # DeeP Water
				if noise_value < 0.33:
					tile_id = tile_ids[1]  # Water
				elif noise_value < 0.51:
					tile_id = tile_ids[2]  # Land
				elif noise_value < 0.51:
					tile_id = tile_ids[3]  # Hills
				else:
					tile_id = tile_ids[4]  # Mountain
				tilemap.set_cell(0, pos_tile, tile_id, Vector2(0, 0), 0)  # Place a tile at the position

				processed_tiles += 1
				# Update the progress bar in the main thread
				#call_deferred("_update_progress", processed_tiles / total_tiles)

				if x == 0 or y == 0 or x == size.x - 1 or y == size.y - 1:  # Check if the tile is on the edge of the square
					perimeter_tiles.append(pos_tile)  # Save the perimeter tiles
	print("Center tile: ", center)
	print("Perimeter tiles: ", perimeter_tiles)


func _update_progress(value):
	progress_bar.value = value  # Update the progress bar
