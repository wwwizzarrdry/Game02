extends CharacterBody2D

@export var max_distance:float = 5000.0 : set = set_max_distance, get = get_max_distance
func set_max_distance(val: float) -> void:
	max_distance = val
func get_max_distance() -> float:
	return max_distance

@export var health:float = 100.0 : set = set_health, get = get_health
func set_health(val: float) -> void:
	health = val
func get_health() -> float:
	return health

@export var shield:float = 100.0 : set = set_shield, get = get_shield
func set_shield(val: float) -> void:
	shield = val
func get_shield() -> float:
	return shield

@export_enum("Soldier", "Engineer", "Marksman") var character_class: int = 0
@export_enum("Slow:100", "Average:200", "Very Fast:300") var character_speed: int = 500
@export_enum("Rebecca", "Mary", "Leah") var character_name: String = "Rebecca"
@export_enum("Pistol", "Uzi", "Rifle", "Shotgun", "Machinegun", "Sniper", "Missile", "RPG", "Laser", "Grenade") var character_gun: String = "Pistol"
@export var player_skin: Dictionary = {
	"backpack": preload("res://Scenes/Components/TestPlayer/BodyParts/Backpack_Yellow.tres"),
	"shoulders": preload("res://Scenes/Components/TestPlayer/BodyParts/Shoulders_Yellow.tres"),
	"arm_right": preload("res://Scenes/Components/TestPlayer/BodyParts/Arm_Right_Yellow.tres"),
	"arm_left": preload("res://Scenes/Components/TestPlayer/BodyParts/Arm_Left_Yellow.tres"),
	"head": preload("res://Scenes/Components/TestPlayer/BodyParts/Head_Yellow.tres"),
}

@onready var body_parts: Node = $BodyParts
@onready var head: Sprite2D = $BodyParts/Head
@onready var backpack: Sprite2D = $BodyParts/Backpack
@onready var shoulders: Sprite2D = $BodyParts/Shoulders
@onready var arm_right: Sprite2D = $BodyParts/Arm_Right
@onready var arm_left: Sprite2D = $BodyParts/Arm_Left

@onready var guns: Node = $BodyParts/Guns
@onready var pistol: Sprite2D = $BodyParts/Guns/Pistol
@onready var uzi: Sprite2D = $BodyParts/Guns/Uzi
@onready var rifle: Sprite2D = $BodyParts/Guns/Rifle
@onready var shotgun: Sprite2D = $BodyParts/Guns/Shotgun
@onready var machinegun: Sprite2D = $BodyParts/Guns/Machinegun
@onready var sniper: Sprite2D = $BodyParts/Guns/Sniper
@onready var missile: Sprite2D = $BodyParts/Guns/Missile
@onready var rpg: Sprite2D = $BodyParts/Guns/RPG
@onready var rocket: Sprite2D = $BodyParts/Guns/RPG/Rocket
@onready var grenade: Sprite2D = $BodyParts/Guns/Grenade
@onready var laser: RayCast2D = $Laser
@onready var arc_beam: RayCast2D = $BodyParts/Guns/Laser/ArcBeam
@onready var rope: Rope = $Rope

# Projectiles
@onready var grenade_projectile: PackedScene = preload("res://Scenes/Components/Weapons/Projectiles/Grenade.tscn")
@onready var DAMAGE_NUMBER = preload("res://Scenes/Components/DamageNumber/DamageNumber.tscn")

var outfits = {
	"Shoulders": [load("res://Scenes/Components/TestPlayer/BodyParts/Shoulders_Blue.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Shoulders_Forest_Digital.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Shoulders_Green.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Shoulders_Olive.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Shoulders_Yellow.tres")],
	"Backpack": [load("res://Scenes/Components/TestPlayer/BodyParts/Backpack_Blue.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Backpack_Blue_Digital.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Backpack_Brown.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Backpack_Forest_Digital.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Backpack_Green.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Backpack_Green_Camo.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Backpack_Grey.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Backpack_Grey_Digital.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Backpack_Olive.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Backpack_Orange_Gradient.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Backpack_Red.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Backpack_Salmon.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Backpack_Tan.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Backpack_White.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Backpack_Yellow.tres")],
	"Arm_Left": [load("res://Scenes/Components/TestPlayer/BodyParts/Arm_Left_Blue.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Arm_Left_Blue_Digital.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Arm_Left_Brown.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Arm_Left_Forest_Digital.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Arm_Left_Green.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Arm_Left_Green_Camo.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Arm_Left_Grey.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Arm_Left_Grey_Digital.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Arm_Left_Olive.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Arm_Left_Orange_Gradient.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Arm_Left_Red.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Arm_Left_Salmon.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Arm_Left_Tan.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Arm_Left_White.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Arm_Left_Yellow.tres")],
	"Arm_Right": [load("res://Scenes/Components/TestPlayer/BodyParts/Arm_Right_Blue.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Arm_Right_Blue_Digital.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Arm_Right_Brown.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Arm_Right_Forest_Digital.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Arm_Right_Green.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Arm_Right_Green_Camo.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Arm_Right_Grey.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Arm_Right_Grey_Digital.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Arm_Right_Olive.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Arm_Right_Orange_Gradient.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Arm_Right_Red.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Arm_Right_Salmon.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Arm_Right_Tan.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Arm_Right_White.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Arm_Right_Yellow.tres")],
	"Head": [load("res://Scenes/Components/TestPlayer/BodyParts/Head_Blue.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Head_Blue_Digital.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Head_Brown.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Head_Forest_Digital.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Head_Green_Camo.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Head_Grey.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Head_Grey_Digital.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Head_Light_Blue.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Head_Olive.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Head_Orange_Gradient.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Head_Red.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Head_Tan.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Head_White.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Head_Yellow.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Head_Beige.tres"), load("res://Scenes/Components/TestPlayer/BodyParts/Head_Dark_Grey.tres")]
}

var last_lookDirection: Vector2 = Vector2.ZERO
var rotate_speed: float = 10.0
var speed: float = character_speed * 1.2  # increasing speed, also decreases traction
var acceleration: float = 2000 # higher = more traction
var friction: float = acceleration / speed
var deadzoneThreshold: float = 0.2
var deadzoneADSThreshold: float = 0.1
var is_aiming = false
var can_shoot = true
var is_shooting = false

var max_health: float = 100.0
var max_shield: float = 100.0

var all_parts = []
var all_guns = []
var current_gun = 0


func _ready() -> void:

	Signals.player_entered_pit.connect(_on_player_entered_pit)
	Signals.player_exited_pit.connect(_on_player_exited_pit)
	Signals.player_entered_pit_danger_area.connect(_on_danger_area_entered)
	Signals.player_exited_pit_danger_area.connect(_on_danger_area_exited)
	Signals.player_entered_ring.connect(_on_player_entered_ring)
	Signals.player_exited_ring.connect(_on_player_exited_ring)

	backpack.texture = player_skin["backpack"]
	shoulders.texture = player_skin["shoulders"]
	arm_right.texture = player_skin["arm_right"]
	arm_left.texture = player_skin["arm_left"]
	head.texture = player_skin["head"]

	for part in body_parts.get_children():
		if part is Sprite2D:
			all_parts.append(part)

	var i = 0
	for gun in guns.get_children():
		gun.visible = false
		all_parts.append(gun)
		all_guns.append(gun)
		if gun.get_meta("gun_name") == character_gun:
			current_gun = i
			gun.visible = true
		i += 1

# Subtle lean forward while aiming
var targetYOffset: float = 100.0  # Set your desired target Y offset
var lerpSpeed: float = 0.1  # Adjust the speed of the lerp (0.0 to 1.0)
func _process(delta: float) -> void:

	Global.apply_tether_force(delta, self, Vector2(64.0, 64.0), max_distance, 3.0)
	shoot()

	if is_aiming:
		targetYOffset = 8.0
		head.offset.y      = lerp(head.offset.y, targetYOffset + 8, lerpSpeed)
		arm_right.offset.y = lerp(arm_right.offset.y, targetYOffset, lerpSpeed)
		arm_left.offset.y  = lerp(arm_left.offset.y, targetYOffset, lerpSpeed)
		rifle.offset.y     = lerp(rifle.offset.y, targetYOffset, lerpSpeed)
		shotgun.offset.y   = lerp(shotgun.offset.y, targetYOffset, lerpSpeed)
		uzi.offset.y       = lerp(uzi.offset.y, targetYOffset, lerpSpeed)
		pistol.offset.y    = lerp(pistol.offset.y, targetYOffset, lerpSpeed)
	else:
		targetYOffset = 0.0
		head.offset.y      = lerp(head.offset.y, targetYOffset, lerpSpeed)
		arm_right.offset.y = lerp(arm_right.offset.y, targetYOffset, lerpSpeed)
		arm_left.offset.y  = lerp(arm_left.offset.y, targetYOffset, lerpSpeed)
		rifle.offset.y     = lerp(rifle.offset.y, targetYOffset, lerpSpeed)
		shotgun.offset.y   = lerp(shotgun.offset.y, targetYOffset, lerpSpeed)
		uzi.offset.y       = lerp(uzi.offset.y, targetYOffset, lerpSpeed)
		pistol.offset.y    = lerp(pistol.offset.y, targetYOffset, lerpSpeed)

func _physics_process(delta: float) -> void:
	get_input(delta)
	set_move_direction(delta)
	set_aim_direction(delta)
	pass

func get_input(_delta):
	# Sprint
	if Input.is_action_just_pressed('sprint'):
		toggle_sprint()

	#  Laser Sight
	if Input.is_action_just_pressed('aim'):
		show_laser(true)
	if Input.is_action_just_released("aim"):
		show_laser(false)

	#  Shoot
	if Input.is_action_pressed('shoot'):
		is_shooting = true
	else:
		is_shooting = false

	# Chane Weapon
	if Input.is_action_just_pressed('change_weapon'):
		change_weapons()

	# Chane Outfit
	if Input.is_action_just_pressed('inv_right'):
		random_outfit()


func set_move_direction(delta: float) -> void:

	var move_speed = speed
	if is_aiming:
		move_speed = speed / 2.0

	friction = acceleration / move_speed
	apply_traction(delta)
	apply_friction(delta)
	move_and_slide()

func get_move_direction() -> Vector2:
	var move_direction: Vector2 = Vector2(
		-Input.get_action_strength("move_left") + Input.get_action_strength("move_right"),
		+Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()
	return move_direction

func set_aim_direction(delta: float) -> void:
	# Rotation using right analog stick
	var deadzone := deadzoneThreshold
	var turn_speed := rotate_speed

	if is_aiming:
		deadzone = deadzoneADSThreshold
		turn_speed = rotate_speed / 3

	var lookDirection := Vector2(
		-Input.get_action_strength("aim_left") + Input.get_action_strength("aim_right"),
		+Input.get_action_strength("aim_down") - Input.get_action_strength("aim_up")
	).normalized()

	if lookDirection.length() >= deadzone:
		last_lookDirection = lookDirection
		rotation = lerp_angle(rotation, lookDirection.angle(), turn_speed * delta)

func get_aim_direction() -> Vector2:
	var lookDirection := Vector2(
		-Input.get_action_strength("aim_left") + Input.get_action_strength("aim_right"),
		+Input.get_action_strength("aim_down") - Input.get_action_strength("aim_up")
	).normalized()
	return lookDirection

func apply_traction(delta: float) -> void:
	var traction: Vector2 = Vector2(
		-Input.get_action_strength("move_left") + Input.get_action_strength("move_right"),
		+Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()
	velocity += traction * acceleration * delta

func apply_friction(delta: float) -> void:
	velocity -= velocity * friction * delta

func toggle_sprint() -> void:
	if speed >= 800:
		set_move_speed(500)
	else:
		set_move_speed(800)

func set_move_speed(s) -> void:
	speed = s

func change_weapons() -> void:
	is_shooting = false
	var next_gun = wrap(current_gun + 1, 0, all_guns.size())
	for i in range(all_guns.size()):
		all_guns[i].visible = false
		if i == next_gun:
			all_guns[i].visible = true
	current_gun = next_gun
	pass

func show_laser(val) -> void:
	is_aiming = val
	laser.global_position = all_guns[current_gun].get_child(0).global_position
	laser.enabled = is_aiming
	laser.visible = is_aiming

# Fire Weapons
var arc_beam_pause = false
func shoot() -> void:
	if can_shoot and is_shooting:
		#print(current_gun, ": ", all_guns[current_gun].get_meta("gun_name"))
		match all_guns[current_gun].get_meta("gun_name"):
			"Pistol": fire_pistol()            #0
			"Uzi": fire_uzi()                  #1
			"Rifle": fire_rifle()              #2
			"Shotgun": fire_shotgun()          #3
			"Machinegun": fire_machinegun()    #4
			"Sniper": fire_sniper()            #5
			"Missile": fire_missile()          #6
			"RPG": fire_rpg()                  #7
			"Grenade": fire_grenade()          #8
			"Laser": fire_laser()              #9
			_:
				can_shoot = true
				return
	else:
		arc_beam.enabled = false
		arc_beam.visible = false
		arc_beam_pause = false

func fire_pistol() -> void:
	print("Fire Pistol")
	can_shoot = false
	await Global.timeout(1.0)
	can_shoot = true
	pass

func fire_uzi() -> void:
	print("Fire Uzi")
	can_shoot = false
	await Global.timeout(0.12)
	can_shoot = true
	pass

func fire_rifle() -> void:
	print("Fire Rifle")
	can_shoot = false
	await Global.timeout(0.237)
	can_shoot = true
	pass

func fire_shotgun() -> void:
	can_shoot = false
	var rays = shotgun.get_children()
	for i in range(1, rays.size()):
		if rays[i] is RayCast2D:
			rays[i].enabled = true
			rays[i].force_raycast_update()
			if rays[i].is_colliding():
				if rays[i].get_collider().has_method("take_damage"):
					var damage_template = Global.get_damage_template(self)
					damage_template.damage_type = "shotgun"
					damage_template.damage = 25
					rays[i].get_collider().take_damage(damage_template)
			rays[i].enabled = false

	await Global.timeout(0.5)
	can_shoot = true
	pass

func fire_machinegun() -> void:
	print("Fire Machinegun")
	can_shoot = false
	await Global.timeout(0.187)
	can_shoot = true
	pass

func fire_sniper() -> void:
	print("Fire Sniper")
	can_shoot = false
	await Global.timeout(2.42)
	can_shoot = true
	pass

func fire_missile() -> void:
	print("Fire Missile")
	can_shoot = false
	await Global.timeout(3.67)
	can_shoot = true
	pass

func fire_rpg() -> void:
	print("Fire RPG")
	can_shoot = false
	await Global.timeout(3.15)
	can_shoot = true
	pass

func fire_grenade() -> void:
	can_shoot = false
	grenade.hide()
	var g = grenade_projectile.instantiate() as RigidBody2D
	g.position = $BodyParts/Guns/Grenade/MuzzleGrenade.global_position

	if get_aim_direction() == Vector2.ZERO:
		g.linear_velocity = last_lookDirection * g.speed
	else:
		g.linear_velocity = get_aim_direction() * g.speed

	# Apply the total velocity as an impulse to the grenade
	var total_velocity = get_aim_direction() * g.speed + self.velocity
	g.apply_impulse(Vector2.ZERO, total_velocity)

	get_parent().get_node("Projectiles").add_child(g)

	await Global.timeout(4.2)
	can_shoot = true
	if current_gun == 9: grenade.show()
	pass

func fire_laser() -> void:
	if is_shooting and current_gun == 8:
		arc_beam.enabled = true
		arc_beam.visible = true

		if arc_beam.is_colliding() and !arc_beam_pause:
			arc_beam_pause = true
			arc_beam.apply_damage(25.0, arc_beam.get_collider(), arc_beam.get_collision_point())

			#var dmg_lbl= DAMAGE_NUMBER.instantiate()
			#get_parent().add_child(dmg_lbl)
			#dmg_lbl.global_position = arc_beam.get_collision_point()
			#dmg_lbl.set_label(str(15), Color(1, 0.251, 0.169, 1))

			await Global.timeout(0.25)
			arc_beam_pause = false
	else:
		arc_beam.enabled = false
		arc_beam.visible = false
		arc_beam_pause = false
	pass

func generate_shotgun_spread(num_pellets, radius, distance, num_center_pellets):
	var pellets = []
	var center = Vector2(cos(self.rotation), sin(self.rotation)) * distance
	for i in range(num_center_pellets):
		pellets.append(center)
	for i in range(num_pellets - num_center_pellets):
		var angle = randf() * 2 * PI
		var pos = center + Vector2(cos(angle), sin(angle)) * radius
		pellets.append(pos)
	return pellets

func set_outfit(part: String, res: AtlasTexture) -> void:
	player_skin[part] = res

func random_outfit():
	var r = randi_range(0, outfits.Arm_Right.size()-1)
	#shoulders.texture = outfits.Shoulders[randi_range(0, outfits.Shoulders.size() - 1)]
	backpack.texture = outfits.Backpack[r]
	arm_right.texture = outfits.Arm_Right[r]
	arm_left.texture = outfits.Arm_Left[r]
	head.texture = outfits.Head[r]

func take_damage(data):
	print(name + " took " + data.damage_type + " damage for " + str(data.damage) + "HP!")
	var damage = data.damage
	var current_shield = get_shield()
	var current_health = get_health()
	var remaining_damage = clamp(damage - current_shield, 0.0, damage)


	if current_shield > 0:
		var dmg_lbl1 = DAMAGE_NUMBER.instantiate()
		get_parent().add_child(dmg_lbl1)
		dmg_lbl1.global_position = self.global_position

		if remaining_damage == 0:
			dmg_lbl1.set_label(str(round(clamp(damage, 0.0, max_shield))), Color(0.169, 0.757, 1))
		else:
			dmg_lbl1.set_label(str(round(clamp(current_shield - damage, 0.0, max_shield))), Color(0.169, 0.757, 1))

		play_audio("player_shield_damaged")
		set_shield(clamp(current_shield - damage, 0.0, max_shield))
		current_shield = get_shield()

		if current_shield == 0:
			play_audio("player_shield_broken")

	if current_health > 0:
		if remaining_damage > 0:
			var dmg_lbl2 = DAMAGE_NUMBER.instantiate()
			get_parent().add_child(dmg_lbl2)
			dmg_lbl2.global_position = self.global_position
			dmg_lbl2.set_label(str(round(remaining_damage)), Color(1, 0.251, 0.169, 1))

			play_audio("player_health_damaged")
			set_health(clamp(current_health - remaining_damage, 0.0, max_health))
			current_health = get_health()

	if current_health == 0:
		play_audio("player_death")
		Signals.player_died.emit(self)
		on_player_died(self)


	print("Shield: ", current_shield)
	print("Health: ", current_health)

func play_audio(val: String) -> void:
	match val:
		"player_shield_damaged":
			Audio.queue({"listener": $PlayerAudioListener, "device": $PlayerShieldDamaged})
		"player_shield_broken":
			Audio.queue({"listener": $PlayerAudioListener, "device": $PlayerShieldBroken})
		"player_health_damaged":
			Audio.queue({"listener": $PlayerAudioListener, "device": $PlayerHealthDamaged})
		"player_death":
			Audio.queue({"listener": $PlayerAudioListener, "device": $PlayerDeath})
		_:
			return

# Ring Entered (Safety)
func _on_player_entered_ring(body) -> void:
	# Update player to out-of-danger state
	if body == self:
		modulate = Color(1, 1, 1)
	pass

# Ring Exited (Hazard)
func _on_player_exited_ring(body) -> void:
	# Update player to in-danger state
	if body == self:
		modulate = Color(1, 0, 0)
	pass

# Pit Danger Area Entered
func _on_danger_area_entered(body) -> void:
	if body == self:
		# Update player to in-danger state
		modulate = Color(1, 0, 0)

# Pit Danger Area Exited
func _on_danger_area_exited(body) -> void:
	if body == self:
		print("Player is out of danger!")
		# Update player to out-of-danger state
		modulate = Color(1, 1, 1)
		set_health(100)
		set_shield(100)

# Pit Entered
func _on_player_entered_pit(body) -> void:
	if body == self:
		print(body.name + " in the pit!!!")

# Pit Exited
func _on_player_exited_pit(body) -> void:
	if body == self:
		print(body.name + " escaped the pit!")
		show()

func on_player_died(body):
	if body == self:
		print(body.name + " died")
		# World camera needs to update its targets before freeing player
		#queue_free()
		hide()
