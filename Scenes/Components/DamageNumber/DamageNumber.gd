extends Node2D

@onready var label_container: Node2D = $LabelContainer
@onready var label: Label = $LabelContainer/Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	pass # Replace with function body.

func _process(_delta: float) -> void:
	pass

func set_label(val: String = "NaN", c: Color = Color(1.0, 1.0, 1.0, 1.0)) -> void:
	label.text = val
	label.label_settings.font_color = c
	animation_player.play("Damage_Number_Anim")

func remove() -> void:
	animation_player.stop()
	if is_inside_tree():
		get_parent().remove_child(self)
