extends Control

@onready var player_1: VBoxContainer = $PanelContainer/MarginContainer/HBoxContainer/Player1
@onready var player_2: VBoxContainer = $PanelContainer/MarginContainer/HBoxContainer/Player2
@onready var p1_ready_btn: Button = $PanelContainer/MarginContainer/HBoxContainer/Player1/Button
@onready var p2_ready_btn: Button = $PanelContainer/MarginContainer/HBoxContainer/Player1/Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_1.hide()
	player_2.hide()
	p1_ready_btn.disabled = true
	p2_ready_btn.disabled = true
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton:
		if event.device == 0:
			player_1.show()
			p1_ready_btn.disabled = false
			p1_ready_btn.text = "READY!"
			p1_ready_btn.grab_focus()

		if event.device == 1:
			player_2.show()
			p2_ready_btn.disabled = false
			p2_ready_btn.text = "READY!"
			p2_ready_btn.grab_focus()
