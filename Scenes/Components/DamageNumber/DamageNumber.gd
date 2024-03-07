extends Node2D

@onready var label_container: Node2D = $LabelContainer
@onready var label: Label = $LabelContainer/Label
@onready var label2: Label = $LabelContainer/Label2
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func set_label(val: String = "NaN", c: Color = Color(1.0, 1.0, 1.0, 1.0)) -> void:
	label.text = val # UNDER
	label2.text = val # OVER
	label.label_settings.font_color = c
	animation_player.play("Damage_Number_Anim")

func remove() -> void:
	animation_player.stop()
	if is_inside_tree():
		get_parent().remove_child(self)
