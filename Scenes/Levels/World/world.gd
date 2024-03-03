extends Node2D

@onready var tilemap = $TileMap
@onready var pit_danger_area: Area2D = $PitTrap/Danger
@onready var pit_area: Area2D = $PitTrap/Pit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	#Signals.player_entered_pit.connect(_on_body_entered_pit)
	#Signals.player_exited_pit.connect(_on_body_exited_pit)
	#Signals.player_entered_pit_danger_area.connect(_on_danger_area_entered)
	#Signals.player_exited_pit_danger_area.connect(_on_danger_area_exited)

	self.z_index = -1
	generate_tiles()

	pass # Replace with function body.

func generate_tiles() -> void:
	# Define your arrays of radii and tile IDs here
	var radii = [3, 8, 16, 22, 30, 40]
	var floor_tile_ids = [Vector2(9, 2), Vector2(2, 3), Vector2(0, 3), Vector2(4, 3), Vector2(3, 3), Vector2(6, 3)]  # Assuming these are the ID and Atlas Coords of your floor tiles
	var border_tile_ids = [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 6)] # Assuming these are the ID and Atlas Coords of your border tiles


	var points = []
	var tilemap_width = tilemap.get_used_rect().size.x
	var tilemap_height = tilemap.get_used_rect().size.y

	# Calculate the center of the tilemap
	var xc = tilemap.local_to_map(Vector2(tilemap_width / 2, 0)).x
	var yc = tilemap.local_to_map(Vector2(0, tilemap_height / 2)).y
	var center = Vector2(xc, yc)  # Use the calculated center in local coordinates

	tilemap.clear()

	# Create the tilemap in one pass
	for x in range(-int(tilemap_width / 2), int(tilemap_width / 2)):
		for y in range(-int(tilemap_height / 2), int(tilemap_height / 2)):

			var tile_coords = Vector2(x, y)
			var world_coords = tilemap.local_to_map(tile_coords)  # Convert tile coordinates to world coordinates
			var distance_to_center = tile_coords.distance_to(center)

			for i in range(len(radii)):
				# Place border tile for the edge of this radius
				if distance_to_center > radii[i] and distance_to_center <= radii[i] + 1:
					#print("Border!")
					# The tile is just outside the current radius, so add a border tile here
					tilemap.set_cell(0, tile_coords, 1, border_tile_ids[i], 0)  # Place a border tile at the position
					break
				elif distance_to_center <= radii[i]:
					#print("Floor!")
					# The tile is within the current radius, so add a floor tile here
					if i == 0:
						tilemap.set_cell(0, tile_coords, -1, Vector2.ZERO, 0)  # Place a border tile at the position
					else:
						tilemap.set_cell(0, tile_coords, 1, floor_tile_ids[i], 0)  # Place a border tile at the position
					break

	# Erase the center tiles fo r the pit
	var grid_size = 9
	for x in range(-grid_size / 2, grid_size / 2 + 1):
		for y in range(-grid_size / 2, grid_size / 2 + 1):
			var grid_position = center + Vector2(x, y)
			tilemap.set_cell(0, grid_position, -1, Vector2.ZERO, 0)


func _on_body_entered_pit(body) -> void:
	if body.is_in_group("player"):
		Signals.player_entered_pit.emit(body)
		if body.has_method("take_damage"):
			var pit_damage: float = 50.0
			body.take_damage({"damage_type": "pit", "damage": pit_damage})

func _on_body_exited_pit(body) -> void:
	if body.is_in_group("player"):
		Signals.player_exited_pit.emit(body)

func _on_danger_area_entered(body) -> void:
	if body.is_in_group("player"):
		Signals.player_entered_pit_danger_area.emit(body)

func _on_danger_area_exited(body) -> void:
	if body.is_in_group("player"):
		Signals.player_exited_pit_danger_area.emit(body)



# Danger Zone
func _on_danger_body_entered(body) -> void:
	_on_danger_area_entered(body)

func _on_danger_body_exited(body) -> void:
	_on_danger_area_exited(body)

# Kill Zone
func _on_pit_body_entered(body) -> void:
	_on_body_entered_pit(body)

func _on_pit_body_exited(body) -> void:
	_on_body_exited_pit(body)

