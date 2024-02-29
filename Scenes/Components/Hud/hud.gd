extends Control

@onready var icons: Array = [$Gamepads/BoxContainer/MarginContainer/HBoxContainer/Gamepad1_State, $Gamepads/BoxContainer/MarginContainer/HBoxContainer/Gamepad2_State]
var connected_gamepads = []

func _ready() -> void:
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	connected_gamepads = Input.get_connected_joypads()

	set_process_input(false)  # Disable input processing

	for i in range(connected_gamepads.size()):
		icons[i].color = Color(0.329, 0.639, 0.337)

func _input(_event):
	if Input.is_action_just_pressed("pause"):
		pause_game(!get_tree().paused)

func pause_game(value):
	connected_gamepads = Input.get_connected_joypads()
	if value:
		$BG.color = Color(0, 0, 0, 0.5)
		%PausedLabel.visible = true
		get_tree().paused = true
	else:
		$BG.color = Color(0, 0, 0, 0.0)
		%PausedLabel.visible = false
		get_tree().paused = false

func toggle_pause():
	var is_paused = get_tree().paused
	connected_gamepads = Input.get_connected_joypads()

	if is_paused:
		$BG.color = Color(0, 0, 0, 0.0)
		%PausedLabel.visible = false
		get_tree().paused = false
	else:
		$BG.color = Color(0, 0, 0, 0.5)
		%PausedLabel.visible = true
		get_tree().paused = true

func on_device_connected(device: int) -> void:
	%GamepadConnected.play()
	icons[device].get_material().set_shader_parameter("is_pulsing", false)
	icons[device].color = Color(0.329, 0.639, 0.337)
	if connected_gamepads.size() == PlayerData.player_count:
		pause_game(false)

func on_device_disconnected(device: int) -> void:

	print("player count: " + str(PlayerData.player_count), connected_gamepads.size() < PlayerData.player_count)
	%GamepadDisconnected.play()
	icons[device].color = Color(0.227, 0.227, 0.227)
	if connected_gamepads.size() < PlayerData.player_count:
		icons[device].get_material().set_shader_parameter("is_pulsing", true)
		icons[device].color = Color(0.7, 0.0, 0.0)
		pause_game(true)

func _on_joy_connection_changed(device: int, connected: bool):
	print("Device " + str(device) + (" connected" if connected else " disconnected"))
	connected_gamepads = Input.get_connected_joypads()
	match connected:
		true:
			%GamepadConnected.play()
			on_device_connected(device)
		false:
			%GamepadDisconnected.play()
			on_device_disconnected(device)
		_:
			return
