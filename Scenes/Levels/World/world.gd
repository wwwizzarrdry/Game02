extends Node2D

@onready var tilemap = $TileMap

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
					print("Border!")
					# The tile is just outside the current radius, so add a border tile here
					tilemap.set_cell(0, tile_coords, 1, border_tile_ids[i], 0)  # Place a border tile at the position
					break
				elif distance_to_center <= radii[i]:
					print("Floor!")
					# The tile is within the current radius, so add a floor tile here
					tilemap.set_cell(0, tile_coords, 1, floor_tile_ids[i], 0)  # Place a border tile at the position
					break
