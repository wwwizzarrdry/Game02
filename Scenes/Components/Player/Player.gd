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

@onready var marker_head: Marker2D = $BodyParts/Shoulders/Marker_Head
@onready var marker_backpack: Marker2D = $BodyParts/Shoulders/Marker_Backpack
@onready var marker_arm_left: Marker2D = $BodyParts/Shoulders/Marker_Arm_Left
@onready var marker_arm_right: Marker2D = $BodyParts/Shoulders/Marker_Arm_Right
@onready var marker_rifle: Marker2D = $BodyParts/Shoulders/Marker_Rifle
@onready var marker_shotgun: Marker2D = $BodyParts/Shoulders/Marker_Shotgun
@onready var marker_pistol: Marker2D = $BodyParts/Shoulders/Marker_Pistol
@onready var marker_uzi: Marker2D = $BodyParts/Shoulders/Marker_Uzi


const sprite_scale = Vector2(0.1, 0.1)
const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:

	backpack.texture = player_skin["backpack"]
	shoulders.texture = player_skin["shoulders"]
	arm_right.texture = player_skin["arm_right"]
	arm_left.texture = player_skin["arm_left"]
	head.texture = player_skin["head"]

	scale = sprite_scale

	for part in body_parts.get_children():
		if part is Sprite2D:
			part.scale = sprite_scale

	for gun in guns.get_children():
		gun.scale = sprite_scale
		gun.visible = false
		if gun.get_meta("gun_name") == character_gun:
			gun.visible = true

	backpack.position = marker_backpack.global_position
	arm_right.position = marker_arm_right.global_position
	arm_left.position = marker_arm_left.global_position
	head.position = marker_head.global_position
	shotgun.position = marker_shotgun.global_position
	rifle.position = marker_rifle.global_position
	uzi.position = marker_uzi.global_position
	pistol.position = marker_pistol.global_position

func _physics_process(delta: float) -> void:

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func set_outfit(part: String, res: AtlasTexture):
	player_skin[part] = res
