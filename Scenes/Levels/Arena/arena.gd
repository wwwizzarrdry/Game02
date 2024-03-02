extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_arena()
	pass # Replace with function body.

func generate_arena(_type: String = "circle") -> void:
	var style = _type  # Style of tile placement: "circle", "spiral", "angle", or "noise"
	var tilemap = $TileMap  # Reference to the TileMap node
	var center =  Vector2.ZERO #tilemap.local_to_map(world_camera.position) #Vector2(10, 10)  # Center of the circle
	var radii = [100, 300, 600]  # List of radii
	var tile_ids = [0,1,2]  # Corresponding tile IDs for water, land, mountain, and noise-based tiles
	var border_tile_id = -1
	var perimeter_tile_id = -1
	var atlas_ids = [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)] # The atalas corrds if in a tilesheet
	var angle_segment = PI / 4  # Angle segment for the "angle" style
	var perimeter_tiles = []
	var collision_colors = [Color(1, 0, 0, 0.15), Color(0, 1, 0, 0.15), Color(0, 0, 1, 0.15)] #debug color for the coliision shapes

	tilemap.clear()

	if style == "circle":
		for i in range(radii.size()):

			var radius = radii[i]
			var area = Area2D.new()
			var collision_shape = CollisionShape2D.new()
			var circle_shape = CircleShape2D.new()

			area.name = "AreaFloorRnig_" + str(i)
			area.add_to_group("area_floor_ring")
			area.set_meta("ring_id", i)
			area.set_meta("ring_rank", (radii.size()-i))
			area.set_meta("acceleration", (radii.size()-i)*2000)
			area.set_meta("bonus_modifier", (radii.size()-i)/10) # ex. If raddii[] is size 3, Ring 1 = (3-0/10) => 0.3 => 30%
			area.set_meta("radius", radius)

			circle_shape.radius = radius
			collision_shape.shape = circle_shape
			collision_shape.debug_color = collision_colors[i]

			area.add_child(collision_shape)
			area.position = center
			add_child(area)

			area.body_entered.connect(_on_body_entered.bind(area))
			area.body_exited.connect(_on_body_exited.bind(area))

		for x in range(center.x - radii[-1], center.x + radii[-1]):

			for y in range(center.y - radii[-1], center.y + radii[-1]):

				var pos_world = Vector2(x, y)
				var pos_map = tilemap.local_to_map(pos_world)  # Convert to map coordinates
				var dist = pos_world.distance_to(center)

				for i in range(len(radii)):

					# Place floor tile for this radius
					if dist <= radii[i] and tilemap.get_cell_source_id(0, pos_map) == -1:  # Check if there isn't already a tile at the position
						tilemap.set_cell(0, pos_map, tile_ids[i], atlas_ids[i], 0)  # Place a tile at the position

					# Place border tile for the edge of this radius
					if dist >= radii[i] - 1 and dist <= radii[i] + 1:

						# Add the border tiles (id: -1 is delete)
						for dx in range(-1, 2):
							for dy in range(-1, 2):
								if dx == 0 and dy == 0:
									continue  # Skip the current tile
								var neighbor_pos = pos_map + Vector2i(dx, dy)
								var neighbor_tile_id = tilemap.get_cell_source_id(0, neighbor_pos, false)
								if neighbor_tile_id == -1 and neighbor_tile_id != tile_ids[i]:
									tilemap.set_cell(0, pos_map, border_tile_id, Vector2(0, 0), 0)
									break

					# Place and Save the perimeter tiles
					if dist >= radii[-1] - 1 and dist <= radii[-1] + 1:
						perimeter_tiles.append(pos_map)  # Save the perimeter tiles
						tilemap.set_cell(0, pos_map, perimeter_tile_id, Vector2(0, 0), 0)  # Place a border tile

	elif style == "noise":
		var noise_texture = load("res://Assets/Images/Textures/PNG/Techno 2 - 128x128.png")  # Noise texture
		var size = Vector2(70, 720)  # Size of the area in tile coordinates
		var noise_scale = Vector2(0.1, 0.1)  # Scale factor for the noise texture
		center = Vector2(size.x/2, size.y/2)
		tile_ids = [9, 3, 11]  # Corresponding tile IDs

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

				if x == 0 or y == 0 or x == size.x - 1 or y == size.y - 1:  # Check if the tile is on the edge of the square
					perimeter_tiles.append(pos_tile)  # Save the perimeter tiles


	print("Center tile: ", center)
	print("Perimeter tiles: ", perimeter_tiles)

func _on_body_entered(body, area):
	print("Body entered: ", body.name)
	if body.has_method("ring_entered"):
		body.ring_entered({
			"node": area,
			"ring_id": area.get_meta("ring_id"),
			"name": area.name,
			"group": area.get_groups()[0],
			"ring_rank": area.get_meta("ring_rank"),
			"radius": area.get_meta("radius"),
			"acceleration": area.get_meta("acceleration"),
			"bonus_modifier": area.get_meta("bonus_modifier")
		})

func _on_body_exited(body, area):
	print("Body exited: ", body, area)
	if body.has_method("ring_exited"):
		body.ring_exited({
			"node": area,
			"ring_id": area.get_meta("ring_id"),
			"name": area.name,
			"group": area.get_groups()[0],
			"ring_rank": area.get_meta("ring_rank"),
			"radius": area.get_meta("radius"),
			"acceleration": area.get_meta("acceleration"),
			"ring_num": area.get_meta("rank"),
			"bonus_modifier": area.get_meta("bonus_modifier")
		})
