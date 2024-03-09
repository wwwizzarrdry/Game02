extends CharacterBody2D

@export var speed: float = 300.0
@export var health:float = 50.0 : set = set_health, get = get_health
func set_health(val: float) -> void:
	health = val
func get_health() -> float:
	return health
@export var shield:float = 10.0 : set = set_shield, get = get_shield
func set_shield(val: float) -> void:
	shield = val
func get_shield() -> float:
	return shield
@export var nav_agent: NavigationAgent2D

@onready var grenade_projectile: PackedScene = preload("res://Scenes/Components/Weapons/Projectiles/Grenade.tscn")
@onready var DAMAGE_NUMBER = preload("res://Scenes/Components/DamageNumber/DamageNumber.tscn")

var skins = [
	load("res://Assets/Images/Sprites/128x128/Alien01.png"),
	load("res://Assets/Images/Sprites/128x128/Alien02.png"),
	load("res://Assets/Images/Sprites/128x128/Alien03.png"),
	load("res://Assets/Images/Sprites/128x128/Alien04.png"),
	load("res://Assets/Images/Sprites/128x128/Alien05.png"),
	load("res://Assets/Images/Sprites/128x128/Alien06.png"),
	load("res://Assets/Images/Sprites/128x128/Alien07.png"),
	load("res://Assets/Images/Sprites/128x128/Alien08.png"),
	load("res://Assets/Images/Sprites/128x128/Alien09.png"),
	load("res://Assets/Images/Sprites/128x128/Alien10.png"),
	load("res://Assets/Images/Sprites/128x128/Player.png")
]


var max_health: float = 100.0
var max_shield: float = 100.0

var center: Vector2 = Vector2.ZERO
var radius: float = 0.0
var targets: Array = []
var current_target: int = 0
var target_node = null
var target_pos: Vector2 = Vector2.ZERO
var home_position: Vector2 = Vector2.ZERO
var is_chasing_player: bool = false
var turn_speed: float = 30.0  # Adjust as needed


func _ready() -> void:
	$Sprite2D.texture = skins[randi_range(0, skins.size()-1)]
	nav_agent.path_desired_distance = 256
	nav_agent.target_desired_distance = 256
	home_position = self.global_position
	set_radius_points()
	set_next_target()

func _process(delta: float) -> void:
	if is_chasing_player:
		speed = 500
		$Sprite2D/Shadow.self_modulate = Color(1, 0.165, 0.165, 0.51)
	else:
		speed = 300
		$Sprite2D/Shadow.self_modulate = Color(0.165, 0.165, 0.165, 0.51)

	if nav_agent.is_navigation_finished():
		return

	var axis = to_local(nav_agent.get_next_path_position()).normalized()
	velocity = axis * speed
	var intended_velocity = velocity
	nav_agent.set_velocity_forced(intended_velocity)

	# Look rotation
	var target_position: Vector2 = nav_agent.get_next_path_position()
	var target_angle: float = $Sprite2D.global_position.angle_to_point(target_position) + 80
	$Sprite2D.rotation = lerp_angle($Sprite2D.rotation, target_angle, turn_speed * delta)


	move_and_slide()

func change_to_explosion_texture() -> void:
	$Sprite2D.texture = load("res://Assets/Images/Sprites/Explo01.png")

func take_damage(data):
	target_node = data.damage_from
	is_chasing_player = true

	var damage = data.damage
	var current_shield = get_shield()
	var current_health = get_health()
	var remaining_damage = clamp(damage - current_shield, 0.0, damage)

	if current_shield > 0:
		var dmg_lbl1 = DAMAGE_NUMBER.instantiate()
		get_parent().add_child(dmg_lbl1)
		dmg_lbl1.position = self.global_position

		if remaining_damage == 0:
			dmg_lbl1.set_label(str(round(clamp(damage, 0.0, max_shield))), Color(0.169, 0.757, 1))
		else:
			dmg_lbl1.set_label(str(round(clamp(current_shield - damage, 0.0, max_shield))), Color(0.169, 0.757, 1))

		set_shield(clamp(current_shield - damage, 0.0, max_shield))
		current_shield = get_shield()

		if current_shield == 0:
			pass

	if current_health > 0:
		if remaining_damage > 0:
			var dmg_lbl2 = DAMAGE_NUMBER.instantiate()
			get_parent().add_child(dmg_lbl2)
			dmg_lbl2.position = self.global_position
			dmg_lbl2.set_label(str(round(remaining_damage)), Color(1, 0.251, 0.169, 1))

			set_health(clamp(current_health - remaining_damage, 0.0, max_health))
			current_health = get_health()

	if current_health == 0:
		$AnimationPlayer.active = true
		$AnimationPlayer.play("Enemy_Explode")

func remove() -> void:
	if is_inside_tree():
		queue_free()

# Enemie's sentry roam radius
func set_radius_points():
	# Number of points in the circle
	var points_count = 180
	for i in range(points_count):
		var angle = i * 2.0 * PI / points_count
		var point = Vector2(cos(angle), sin(angle)) * radius + center
		targets.append(point)

func set_next_target():
	if is_chasing_player:
		return

	if targets.size() > 0:
		var next_target: Vector2 = targets[current_target]
		nav_agent.set_target_position(next_target)
		current_target = wrap(current_target+1, 0, targets.size())

func recalc_path():
	if target_node:
		nav_agent.target_position = target_node.global_position
	else:
		nav_agent.target_position = targets[current_target]
		#nav_agent.target_position = home_position

func _on_recalculate_timer_timeout() -> void:
	recalc_path()

func _on_aggro_range_area_entered(area: Area2D) -> void:
	is_chasing_player = true
	target_node = area.owner

func _on_deaggro_range_area_exited(area: Area2D) -> void:
	if area.owner == target_node:
		target_node = null
		is_chasing_player = false
		set_next_target()

func _on_navigation_agent_2d_navigation_finished() -> void:
	# Called when the agent reaches the current target
	set_next_target()

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
