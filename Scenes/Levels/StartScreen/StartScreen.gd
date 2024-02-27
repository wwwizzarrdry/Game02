extends Control

@onready var player_1: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Player1
@onready var player_2: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Player2
@onready var p1_ready_btn: Button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Player1/Button
@onready var p2_ready_btn: Button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Player2/Button
@onready var p1_texture_rect: TextureRect = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Player1/TextureRect
@onready var p2_texture_rect: TextureRect = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Player2/TextureRect2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_1.hide()
	player_2.hide()
	p1_ready_btn.disabled = true
	p2_ready_btn.disabled = true
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton:
		match event.device:
			0:
				player_1.show()
				p1_ready_btn.disabled = false
				p1_ready_btn.text = "READY!"
				p1_ready_btn.grab_focus()
			1:
				player_2.show()
				p2_ready_btn.disabled = false
				p2_ready_btn.text = "READY!"
				p2_ready_btn.grab_focus()
			2:
				return
			3:
				return
			_:
				return
