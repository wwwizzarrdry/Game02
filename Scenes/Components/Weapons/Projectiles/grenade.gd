extends RigidBody2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var DAMAGE_NUMBER = preload("res://Scenes/Components/DamageNumber/DamageNumber.tscn")
@onready var damage_area: CollisionShape2D = $Area2D/DamageArea
@onready var timer: Timer = $Timer

var speed = 1000
var bodies_in_damage_area = []
var fuse: = 0.0 # fuse time
var r =  0.0 # growing circle to indicate fuse time
var radius: float = 0.0
var alpha: float = 0.0

func _ready() -> void:
	animation_player.play("Grenade_Throw_Anim")
	radius = damage_area.shape.radius
	fuse = timer.wait_time

func _process(_delta: float) -> void:
	alpha = (fuse - timer.time_left) / fuse
	r = alpha * radius
	queue_redraw()



func _draw() -> void:
	draw_circle(to_local(self.global_position), r, Color(1, 0, 0, clamp(alpha/3, 0, 0.5)))
	#draw_arc(to_local(self.global_position), radius, 0, 360, 60, Color(1, 0, 0), 10.0)

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
			print("Combined Grenade Damage: ", bodies_in_damage_area.size() * damage_template.damage)

	queue_free()

func _on_Damage_area_entered(body: Node2D) -> void:
	print("Entered ", body)
	if body.is_in_group("enemy") or body.is_in_group("player"):
		bodies_in_damage_area.append(body)
		body.modulate = Color(1, 0, 0)

func _on_Damage_area_exited(body: Node2D) -> void:
	print("Exited ", body)
	if body.is_in_group("enemy") or body.is_in_group("player"):
		bodies_in_damage_area.erase(body)
		body.modulate = Color(1, 1, 1)
