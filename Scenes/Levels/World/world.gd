extends Node2D

const magic = preload("res://Particles/Magic.tscn")
@onready var tilemap = $TileMap
@onready var pit_danger_area: Area2D = $PitTrap/Danger
@onready var pit_area: Area2D = $PitTrap/Pit
@onready var void_monster: CharacterBody2D = $VoidMonster

var ring_radius: float = 5000.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	#Signals.player_entered_pit.connect(_on_body_entered_pit)
	#Signals.player_exited_pit.connect(_on_body_exited_pit)
	#Signals.player_entered_pit_danger_area.connect(_on_danger_area_entered)
	#Signals.player_exited_pit_danger_area.connect(_on_danger_area_exited)

	self.z_index = -1
	generate_tiles()
	draw_ring(ring_radius)
	pass # Replace with function body.

func _process(delta: float) -> void:
	# Get closest target
	scale_to_closest_player(void_monster, delta)

# Tile Generation ----------------------------
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

# Ring ---------------------------------------
func set_new_radius(val: float):
	ring_radius = clamp(val - 256, 0, val) # subtract a buffer zone

	#exiting this area deals ring damage
	$Ring/RingEdge.shape.radius = ring_radius
	update_ring(val)

func draw_ring(radius):
	# Number of points in the circle
	var points_count = 360
	var points = PackedVector2Array()
	for i in range(points_count):
		var angle = i * 2.0 * PI / points_count
		var point = Vector2(cos(angle), sin(angle)) * radius
		points.append(point)

		# Add particles to the emission points
		var particles = magic.instantiate()
		particles.position = points[i]
		particles.add_to_group("magic")
		add_child(particles)
		particles.set_emitting(true)
	points.append(points[0])

	var particles = magic.instantiate()
	particles.position = points[0]
	particles.add_to_group("magic")
	add_child(particles)
	particles.set_emitting(true)

	#$RingBorder.points = points
	#await Global.timeout(1.0)
	#$RingBorder.visible = true

func update_ring(radius):
	ring_radius = (radius - (0.05 * radius))
	radius = ring_radius
	# Number of points in the circle
	var particles = get_tree().get_nodes_in_group("magic")
	var points_count: int = particles.size() #$RingBorder.get_point_count()
	#var points: PackedVector2Array = $RingBorder.points
	for i in range(0, points_count):
		var angle = i * 2.0 * PI / points_count
		var point = Vector2(cos(angle), sin(angle)) * radius
		#$RingBorder.set_point_position(i, point)
		if particles.size() > i:
			particles[i].position = point
			set_gravity(particles[i], point)
	#$RingBorder.add_point(Vector2(points[0].x, points[0].y), points_count)
	#particles[-1].position = points[-1]

func set_gravity(particle, point):
	# Assuming the center of the circle is at (center_x, center_y)
	var center = $Barricade.position

	# Assuming the particle's current position is at (pos_x, pos_y)
	var pos = particle.position #a.Vector2(pos_x, pos_y)

	# Calculate the direction vector from the particle to the center
	var dir = center - pos

	# Normalize the direction vector to get a unit vector
	var unit_dir = dir.normalized()

	# Multiply the unit vector by the desired strength of gravity
	var gravity_strength = 20
	var gravity = unit_dir * gravity_strength
	# Now, gravity.x and gravity.y are the x and y gravity values
	particle.process_material.gravity.x = gravity.x
	particle.process_material.gravity.y = gravity.y

# Scale Pit Monster bases onclosest player distance
func scale_to_closest_player(from_node: CharacterBody2D, delta: float):
	var target: Array = get_closest_player(from_node)
	if target[0] == null:
		return

	# Scale porportionally
	var min_distance:= 0.1
	#var min_distance:= -5000.0 + ring_radius
	var max_distance:= 3000.0
	var min_scale:= 0.001
	var max_scale:= 4.0
	var distance: float = target[1]
	var t = inverse_lerp(min_distance, max_distance, distance)
	var scale = lerp(max_scale, min_scale, t)
	from_node.scale = Vector2(scale, scale)

	# Rotate to face the target
	var rotation_speed = 10
	var max_rotation_speed = 60.0
	var acceleration = 300.0

	var target_position: Vector2 = target[0].position # the actual position of the closest target
	var target_angle: float = from_node.global_position.angle_to_point(target_position)
	var angle_difference: float = from_node.rotation - target_angle

	# Adjust the rotation speed
	if angle_difference > PI:
		angle_difference -= 2 * PI
	elif angle_difference < -PI:
		angle_difference += 2 * PI

	rotation_speed += acceleration * delta
	rotation_speed = clamp(rotation_speed, 0, max_rotation_speed)

	# Rotate the character to face the target
	from_node.rotation = lerp_angle(from_node.rotation, target_angle, rotation_speed * delta)

func get_closest_node_in_group(node_A, target_group):
	var target_nodes = get_tree().get_nodes_in_group(target_group)
	var closest_node = null
	var closest_distance = INF

	for node in target_nodes:
		var distance = node_A.global_position.distance_to(node.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_node = node

	return closest_node

func get_closest_player(node_A) -> Array:
	var target_nodes = get_parent().get_node("WorldCamera").targets
	var closest_node = null
	var closest_distance = INF

	if target_nodes.size() == 0:
		return [null, null]

	for node in target_nodes:
		var distance = node_A.global_position.distance_to(node.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_node = node

	return [closest_node, closest_distance]


# Pit Danger Area ----------------------------
func _on_danger_area_entered(body) -> void:
	if body.is_in_group("player"):
		Signals.player_entered_pit_danger_area.emit(body)

func _on_danger_area_exited(body) -> void:
	if body.is_in_group("player"):
		Signals.player_exited_pit_danger_area.emit(body)


# Danger Zone ----------------------------------
func _on_danger_body_entered(body) -> void:
	_on_danger_area_entered(body)

func _on_danger_body_exited(body) -> void:
	_on_danger_area_exited(body)

# Pit Collision ------------------------------
func _on_body_entered_pit(body) -> void:
	if body.is_in_group("player"):
		Signals.player_entered_pit.emit(body)
		if body.has_method("take_damage"):
			var pit_damage: float = 50.0
			body.take_damage({"damage_type": "pit", "damage": pit_damage})

func _on_body_exited_pit(body) -> void:
	if body.is_in_group("player"):
		Signals.player_exited_pit.emit(body)

#Kill Zone -------------------------------------
func _on_pit_body_entered(body) -> void:
	_on_body_entered_pit(body)

func _on_pit_body_exited(body) -> void:
	_on_body_exited_pit(body)

