class_name Player
extends CharacterBody2D

@export_enum("Soldier", "Engineer", "Marksman") var character_class: int = 0
@export_enum("Slow:100", "Average:200", "Very Fast:300") var character_speed: int = 0
@export_enum("Rebecca", "Mary", "Leah") var character_name: String = "Rebecca"
@export_enum("Pistol", "Uzi", "Rifle", "Shotgun") var character_gun: String = "Pistol"
@export var player_skin: Dictionary = {
	"backpack": preload("res://Scenes/Components/Player/BodyParts/Backpack_Yellow.tres"),
	"shoulders": preload("res://Scenes/Components/Player/BodyParts/Shoulders_Yellow.tres"),
	"arm_right": preload("res://Scenes/Components/Player/BodyParts/Arm_Right_Yellow.tres"),
	"arm_left": preload("res://Scenes/Components/Player/BodyParts/Arm_Left_Yellow.tres"),
	"head": preload("res://Scenes/Components/Player/BodyParts/Head_Yellow.tres"),
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

var speed = 100.0
var rotate_speed: float = 10.0
var all_parts = []
var all_guns = []
var current_gun = 0

func _ready() -> void:

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

func _process(_delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	get_input(delta)
	pass

func get_input(delta):

	# Sprint
	if Input.is_action_just_pressed('sprint'):
		toggle_sprint()

	#  Laser Sight
	if Input.is_action_just_pressed('aim'):
		show_laser(true)
	if Input.is_action_just_released("aim"):
		show_laser(false)

	# Chane Weapon
	if Input.is_action_just_pressed('change_weapon'):
		change_weapons()

	# Movement using left analog stick
	var moveInput = Vector2(
		-Input.get_action_strength("move_left") + Input.get_action_strength("move_right"),
		+Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()
	velocity = moveInput * speed
	move_and_slide()

	# Rotation using right analog stick
	var lookDirection = Vector2(
		-Input.get_action_strength("aim_left") + Input.get_action_strength("aim_right"),
		+Input.get_action_strength("aim_down") - Input.get_action_strength("aim_up")
	).normalized()

	if lookDirection.length() > 0.1:
		rotation = lerp_angle(rotation, lookDirection.angle(), rotate_speed * delta)

func toggle_sprint() -> void:
	if speed == 500:
		set_move_speed(100)
	else:
		set_move_speed(500)

func set_move_speed(s) -> void:
	speed = s

func change_weapons() -> void:
	var next_gun = wrap(current_gun + 1, 0, all_guns.size() - 1)

	for i in range(all_guns.size()):
		all_guns[i].visible = false
		if i == next_gun:
			all_guns[i].visible = true
	current_gun = next_gun
	pass

func show_laser(val) -> void:
	$BodyParts/Laser.visible = val

func set_outfit(part: String, res: AtlasTexture) -> void:
	player_skin[part] = res