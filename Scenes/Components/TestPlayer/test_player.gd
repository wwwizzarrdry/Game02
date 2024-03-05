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
@export_enum("Pistol", "Uzi", "Rifle", "Shotgun") var character_gun: String = "Pistol"
@export var player_skin: Dictionary = {
	"backpack": preload("res://Scenes/Components/TestPlayer/BodyParts/Backpack_Yellow.tres"),
	"shoulders": preload("res://Scenes/Components/TestPlayer/BodyParts/Shoulders_Yellow.tres"),
	"arm_right": preload("res://Scenes/Components/TestPlayer/BodyParts/Arm_Right_Yellow.tres"),
	"arm_left": preload("res://Scenes/Components/TestPlayer/BodyParts/Arm_Left_Yellow.tres"),
	"head": preload("res://Scenes/Components/TestPlayer/BodyParts/Head_Yellow.tres"),
}

@onready var body_parts: Node = $BodyParts
@onready var backpack: Sprite2D = $BodyParts/Backpack
@onready var shoulders: Sprite2D = $BodyParts/Shoulders
@onready var arm_right: Sprite2D = $BodyParts/Arm_Right
@onready var arm_left: Sprite2D = $BodyParts/Arm_Left
@onready var guns: Node = $BodyParts/Guns
@onready var rifle: Sprite2D = $BodyParts/Guns/Rifle
@onready var shotgun: Sprite2D = $BodyParts/Guns/Shotgun
@onready var uzi: Sprite2D = $BodyParts/Guns/Uzi
@onready var pistol: Sprite2D = $BodyParts/Guns/Pistol
@onready var head: Sprite2D = $BodyParts/Head
@onready var laser: RayCast2D = $Laser
@onready var DAMAGE_NUMBER = preload("res://Scenes/Components/DamageNumber/DamageNumber.tscn")

var outfits = {
	"Shoulders": [preload("res://Scenes/Components/TestPlayer/BodyParts/Shoulders_Blue.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Shoulders_Forest_Digital.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Shoulders_Green.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Shoulders_Olive.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Shoulders_Yellow.tres")],
	"Backpack": [preload("res://Scenes/Components/TestPlayer/BodyParts/Backpack_Blue.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Backpack_Blue_Digital.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Backpack_Brown.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Backpack_Forest_Digital.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Backpack_Green.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Backpack_Green_Camo.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Backpack_Grey.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Backpack_Grey_Digital.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Backpack_Olive.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Backpack_Orange_Gradient.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Backpack_Red.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Backpack_Salmon.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Backpack_Tan.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Backpack_White.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Backpack_Yellow.tres")],
	"Arm_Left": [preload("res://Scenes/Components/TestPlayer/BodyParts/Arm_Left_Blue.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Arm_Left_Blue_Digital.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Arm_Left_Brown.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Arm_Left_Forest_Digital.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Arm_Left_Green.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Arm_Left_Green_Camo.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Arm_Left_Grey.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Arm_Left_Grey_Digital.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Arm_Left_Olive.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Arm_Left_Orange_Gradient.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Arm_Left_Red.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Arm_Left_Salmon.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Arm_Left_Tan.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Arm_Left_White.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Arm_Left_Yellow.tres")],
	"Arm_Right": [preload("res://Scenes/Components/TestPlayer/BodyParts/Arm_Right_Blue.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Arm_Right_Blue_Digital.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Arm_Right_Brown.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Arm_Right_Forest_Digital.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Arm_Right_Green.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Arm_Right_Green_Camo.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Arm_Right_Grey.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Arm_Right_Grey_Digital.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Arm_Right_Olive.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Arm_Right_Orange_Gradient.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Arm_Right_Red.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Arm_Right_Salmon.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Arm_Right_Tan.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Arm_Right_White.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Arm_Right_Yellow.tres")],
	"Head": [preload("res://Scenes/Components/TestPlayer/BodyParts/Head_Blue.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Head_Blue_Digital.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Head_Brown.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Head_Forest_Digital.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Head_Green_Camo.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Head_Grey.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Head_Grey_Digital.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Head_Light_Blue.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Head_Olive.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Head_Orange_Gradient.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Head_Red.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Head_Tan.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Head_White.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Head_Yellow.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Head_Beige.tres"), preload("res://Scenes/Components/TestPlayer/BodyParts/Head_Dark_Grey.tres")]
}

var rotate_speed: float = 10.0
var speed: float = character_speed * 1.0  # increasing speed, also decreases traction
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
		rotation = lerp_angle(rotation, lookDirection.angle(), turn_speed * delta)

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
	var next_gun = wrap(current_gun + 1, 0, all_guns.size())

	for i in range(all_guns.size()):
		all_guns[i].visible = false
		if i == next_gun:
			all_guns[i].visible = true
			laser.global_position = all_guns[i].get_child(0).global_position
	current_gun = next_gun

	pass

func show_laser(val) -> void:
	is_aiming = val
	laser.global_position = all_guns[current_gun].get_child(0).global_position
	laser.enabled = is_aiming
	laser.visible = is_aiming

func shoot() -> void:
	if can_shoot and is_shooting:
		print($ArcBeam.is_colliding())
		$ArcBeam.global_position = all_guns[current_gun].get_child(0).global_position
		$ArcBeam.visible = true
		if $ArcBeam.is_colliding():
			var dmg_lbl= DAMAGE_NUMBER.instantiate()
			get_parent().add_child(dmg_lbl)
			dmg_lbl.global_position = $ArcBeam.get_collision_point()
			dmg_lbl.set_label(str(15), Color(1, 0.251, 0.169, 1))
	else:
		$ArcBeam.visible = false

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

func _on_danger_area_entered(body) -> void:
	if body == self:
		print("Player is in danger!")
		# Update player to in-danger state
		modulate = Color(1, 0, 0)

func _on_danger_area_exited(body) -> void:
	if body == self:
		print("Player is out of danger!")
		# Update player to out-of-danger state
		modulate = Color(1, 1, 1)
		set_health(100)
		set_shield(100)

func _on_player_entered_pit(body) -> void:
	print(body.name + " in the pit!!!")

func _on_player_exited_pit(body) -> void:
	print(body.name + " escaped the pit!")
	show()

func on_player_died(body):
	print(body.name + " died")
	# World camera needs to update its targets before freeing player
	#queue_free()
	hide()
