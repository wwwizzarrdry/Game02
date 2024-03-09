extends CharacterBody2D


var speed = 300.0
var acceleration  = 300.0
var friction = acceleration / speed
var rotation_speed = 10.0

func _physics_process(delta: float) -> void:
	var lookDirection := Vector2(
		-Input.get_action_strength("aim_left") + Input.get_action_strength("aim_right"),
		+Input.get_action_strength("aim_down") - Input.get_action_strength("aim_up")
	).normalized()
	rotation = lerp_angle(rotation, lookDirection.angle(), rotation_speed * delta)

	var move_direction: Vector2 = Vector2(
		-Input.get_action_strength("move_left") + Input.get_action_strength("move_right"),
		+Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()
	velocity += move_direction * acceleration * delta
	velocity -= velocity * friction * delta
	move_and_slide()
