extends Control


@onready var player1: VBoxContainer = $PanelContainer/MarginContainer/Devices/Player1
@onready var player2: VBoxContainer = $PanelContainer/MarginContainer/Devices/Player2
@onready var player1_title: Label = $PanelContainer/MarginContainer/Devices/Player1/Title
@onready var player2_title: Label = $PanelContainer/MarginContainer/Devices/Player2/Title
@onready var player1_btn: TextureButton = $PanelContainer/MarginContainer/Devices/Player1/PlayerBtn
@onready var player2_btn: TextureButton = $PanelContainer/MarginContainer/Devices/Player2/PlayerBtn
@onready var player1_label: Label = $PanelContainer/MarginContainer/Devices/Player1/Label
@onready var player2_label: Label = $PanelContainer/MarginContainer/Devices/Player2/Label

@onready var devices_panel: HBoxContainer = $PanelContainer/MarginContainer/Devices
@onready var ready_panel: CenterContainer = $PanelContainer/MarginContainer/ReadyConfirm


# Audio
@onready var device_connected: AudioStreamPlayer2D = $DeviceConnected
@onready var device_disconnected: AudioStreamPlayer2D = $DeviceDisconnected
@onready var player_connected: AudioStreamPlayer2D = $PlayerConnected
@onready var ready_confirmed: AudioStreamPlayer2D = $ReadyConfirmed

var next_scene: PackedScene = preload("res://Scenes/Game.tscn")

var current_scene
var gamepads = []
var players_ready = []

func _ready() -> void:
	current_scene = Global.get_tree().get_current_scene()

	#Input.connect("joy_connection_changed", _on_joy_connection_changed)
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	gamepads = Input.get_connected_joypads()

	ready_panel.visible = false
	devices_panel.visible = true
	player1.visible = true

func _process(_delta: float) -> void:
	PlayerData.player_count = 0
	if gamepads.size() == 0:

		player1_title.modulate = Color(0, 0, 0, 0.392)
		player1_btn.modulate = Color(0, 0, 0, 0.392)
		player1_label.text = "CONNECT CONTROLLER"

		player2_title.modulate = Color(0, 0, 0, 0.392)
		player2_btn.modulate = Color(0, 0, 0, 0.392)
		player2_label.text = "CONNECT CONTROLLER"

		devices_panel.visible = true
		ready_panel.visible = false
		player1.visible = true
		player2.visible = false

func _input(event: InputEvent) -> void:

	if event is InputEventJoypadButton and event.pressed:
		print(event)
		match event.device:
			0:
				if !ready_panel.visible:
					on_player_confirmed(0)
				elif ready_panel.visible and event.button_index == 0:
					#JOY_BUTTON_A = 0
					start_game()
				elif ready_panel.visible and event.button_index == 1:
					#JOY_BUTTON_B = 1
					players_ready.clear()
					show_devices_panel()
				else:
					return
			1:
				if !ready_panel.visible:
					on_player_confirmed(1)
				elif ready_panel.visible and event.button_index == 0:
					#JOY_BUTTON_A = 0
					start_game()
				elif ready_panel.visible and event.button_index == 1:
					#JOY_BUTTON_B = 1
					players_ready.clear()
					show_devices_panel()
				else:
					return
			_:
				return

func on_device_connected(device_id: int) -> void:
	print("connected device: ", device_id)
	gamepads = Input.get_connected_joypads()

	if device_id == 0:
		device_connected.play()
		devices_panel.visible = true
		ready_panel.visible = false
		player1.visible = true
		player1_title.modulate = Color(1, 1, 1, 1)
		player1_btn.modulate = Color(0, 0, 0, 0.392)
		player1_label.text = "PRESS START"
		toggle_pulsing(player1_label, true)

	if device_id == 1:
		device_connected.play()
		devices_panel.visible = true
		ready_panel.visible = false
		player2.visible = true
		player2_title.modulate = Color(1, 1, 1, 1)
		player2_btn.modulate = Color(0, 0, 0, 0.392)
		player2_label.text = "PRESS START"
		toggle_pulsing(player2_label, true)

func on_device_disconnected(device_id: int) -> void:
	print("disconnected device: ", device_id)
	gamepads = Input.get_connected_joypads()
	Global.find_and_remove(players_ready, device_id)

	if device_id == 0:
		devices_panel.visible = true
		ready_panel.visible = false
		player1.visible = true # always make player1 visible by default
		player1_title.modulate = Color(0, 0, 0, 0.392)
		player1_btn.modulate = Color(0, 0, 0, 0.392)
		player1_label.text = "CONNECT CONTROLLER"
		toggle_pulsing(player1_label, true)

	if device_id == 1:
		devices_panel.visible = true
		ready_panel.visible = false
		player2.visible = false
		player2_title.modulate = Color(0, 0, 0, 0.392)
		player2_btn.modulate = Color(0, 0, 0, 0.392)
		player2_label.text = "CONNECT CONTROLLER"
		toggle_pulsing(player2_label, true)

func on_player_confirmed(player_id: int):
	print("player confirmed: ", player_id)

	# Connect a player with a gamepad
	if player_id == 0:
		print("player_confirmed:", player_id)
		player_connected.play()
		devices_panel.visible = true
		ready_panel.visible = false
		player1.visible = true
		player1_title.modulate = Color(1, 1, 1, 1)
		player1_btn.modulate = Color(1, 1, 1, 1)
		player1_label.text = "READY!"
		toggle_pulsing(player1_label, false)
		Global.replace_or_append(players_ready, player_id)

	elif player_id == 1:
		print("player_confirmed:", player_id)
		player_connected.play()
		devices_panel.visible = true
		ready_panel.visible = false
		player2.visible = true
		player2_title.modulate = Color(1, 1, 1, 1)
		player2_btn.modulate = Color(1, 1, 1, 1)
		player2_label.text = "READY!"
		toggle_pulsing(player2_label, false)
		Global.replace_or_append(players_ready, player_id)

	if players_ready.size() == gamepads.size():
		# All connected gamepadshave been assigned to a player
		await get_tree().create_timer(1.0).timeout
		show_ready_panel()

func show_ready_panel():
	if players_ready.size() == gamepads.size():
		devices_panel.visible = false
		ready_panel.visible = true
	else:
		devices_panel.visible = true
		ready_panel.visible = false

func show_devices_panel():
	gamepads = Input.get_connected_joypads()
	players_ready.clear()

	devices_panel.visible = true
	ready_panel.visible = false
	player1.visible = true

	var p1Index = gamepads.find(0)
	var p2Index = gamepads.find(2)

	if p1Index >= 0:
		player1_title.modulate = Color(1, 1, 1, 1)
		player1_btn.modulate = Color(0, 0, 0, 0.392)
		player1_label.text = "PRESS START"
		toggle_pulsing(player1_label, true)
	else:
		player1_title.modulate = Color(0, 0, 0, 0.392)
		player1_btn.modulate = Color(0, 0, 0, 0.392)
		player1_label.text = "CONNECT CONTROLLER"
		toggle_pulsing(player1_label, true)

	if p2Index >= 0:
		player2_title.modulate = Color(1, 1, 1, 1)
		player2_btn.modulate = Color(0, 0, 0, 0.392)
		player2_label.text = "PRESS START"
		toggle_pulsing(player2_label, true)
	else:
		player2_title.modulate = Color(0, 0, 0, 0.392)
		player2_btn.modulate = Color(0, 0, 0, 0.392)
		player2_label.text = "CONNECT CONTROLLER"
		toggle_pulsing(player2_label, true)

func start_game():
	set_process_input(false)  # Disable input processing
	PlayerData.player_count = players_ready.size()
	print("player count: " + str(PlayerData.player_count))
	ready_confirmed.play()
	await Global.timeout(1)
	call_deferred("_change_scene")

func toggle_pulsing(node, is_pulsing: bool) -> void:
	node.get_material().set_shader_parameter("is_pulsing", is_pulsing)

func _on_joy_connection_changed(device: int, connected: bool):
	print("Device " + str(device) + (" connected" if connected else " disconnected"))
	gamepads = Input.get_connected_joypads()
	match connected:
		true:
			device_connected.play()
			on_device_connected(device)
		false:
			device_disconnected.play()
			on_device_disconnected(device)
		_:
			return

func _on_ready_btn_pressed() -> void:
	start_game()

func _on_back_btn_pressed() -> void:
	devices_panel.visible = true
	ready_panel.visible = false

func _change_scene():
	get_tree().change_scene_to_packed(next_scene)
