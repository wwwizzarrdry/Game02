extends RigidBody2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var DAMAGE_NUMBER = preload("res://Scenes/Components/DamageNumber/DamageNumber.tscn")

var speed = 800
var bodies_in_damage_area = []

func _ready() -> void:
	animation_player.play("Grenade_Throw_Anim")
	$Timer.start()

func _on_timer_timeout() -> void:
	animation_player.stop()
	# Audio.queue({"listener": $PlayerAudioListener, "device": $PlayerShieldBroken})
	var dmg_lbl = DAMAGE_NUMBER.instantiate()
	get_parent().add_child(dmg_lbl)
	dmg_lbl.global_position = self.global_position
	dmg_lbl.set_label("KA-BOOM!", Color(1, 0.827, 0.271))

	# Deal damage to all enemies in damage radius
	for body in bodies_in_damage_area:
		if body.has_method("take_damage"):
			var damage_template = Global.get_damage_template()
			damage_template.damage_type = "grenade"
			damage_template.damage = 50.0
			body.take_damage(damage_template)

	queue_free()

func _on_Damage_area_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		bodies_in_damage_area.append(body)
		body.modulate = Color(1, 0, 0)

func _on_Damage_area_exited(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		bodies_in_damage_area.erase(body)
		body.modulate = Color(1, 1, 1)
