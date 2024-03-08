extends CharacterBody2D

const SPEED = 300.0
const max_health: float = 1000.0
const max_shield: float = 1000.0
@export var health:float = 1000.0 : set = set_health, get = get_health
func set_health(val: float) -> void:
	health = val
func get_health() -> float:
	return health
@export var shield:float = 1000.0 : set = set_shield, get = get_shield
func set_shield(val: float) -> void:
	shield = val
func get_shield() -> float:
	return shield
@onready var grenade_projectile: PackedScene = preload("res://Scenes/Components/Weapons/Projectiles/Grenade.tscn")
@onready var DAMAGE_NUMBER = preload("res://Scenes/Components/DamageNumber/DamageNumber.tscn")
var can_shoot = true

func _physics_process(_delta: float) -> void:
	#var direction := Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
	#move_and_slide()
	if $Sprite2D/RayCast2D.is_colliding():
		fire_grenade()
	pass

func fire_grenade() -> void:
	if can_shoot:
		can_shoot = false
		var direction =  $Sprite2D/RayCast2D.get_collision_point() - global_position
		var g = grenade_projectile.instantiate() as RigidBody2D
		# Set collision layer and mask
		var area = g.get_node("Area2D")
		area.set_collision_layer_value(4, true)
		area.set_collision_mask_value(1, true)
		area.set_collision_mask_value(2, false)
		area.set_collision_mask_value(3, false)
		area.set_collision_mask_value(4, false)
		g.position = $Sprite2D/Front.global_position
		g.linear_velocity = direction.normalized() * g.speed
		get_tree().current_scene.get_node("Projectiles").add_child(g)
		await Global.timeout(0.15)
		can_shoot = true
	pass

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

		play_audio("shield_damaged")
		set_shield(clamp(current_shield - damage, 0.0, max_shield))
		current_shield = get_shield()

		if current_shield == 0:
			play_audio("shield_broken")

	if current_health > 0:
		if remaining_damage > 0:
			var dmg_lbl2 = DAMAGE_NUMBER.instantiate()
			get_parent().add_child(dmg_lbl2)
			dmg_lbl2.global_position = self.global_position
			dmg_lbl2.set_label(str(round(remaining_damage)), Color(1, 0.251, 0.169, 1))

			play_audio("health_damaged")
			set_health(clamp(current_health - remaining_damage, 0.0, max_health))
			current_health = get_health()

	if current_health == 0:
		play_audio("death")
		on_died(self)

func on_died(body)-> void:
	if body == self:
		print(body.name + " died")
		# Game needs to update its targets before freeing player
		#queue_free()
		hide()
		$RespawnTimer.start()

func play_audio(val: String) -> void:
	match val:
		"shield_damaged":
			Audio.queue({"listener": $AudioListener, "device": $ShieldDamaged})
		"shield_broken":
			Audio.queue({"listener": $AudioListener, "device": $ShieldBroken})
		"health_damaged":
			Audio.queue({"listener": $AudioListener, "device": $HealthDamaged})
		"death":
			Audio.queue({"listener": $AudioListener, "device": $Death})
		_:
			return

func _on_respawn_timer_timeout() -> void:
	health = max_health
	shield = max_shield
	show()
	pass # Replace with function body.
