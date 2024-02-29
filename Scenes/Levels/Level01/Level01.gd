extends Node

@onready var player = preload("res://Scenes/Components/TestPlayer/TestPlayer.tscn")
@onready var spawn1: Marker2D = $Spawn1
@onready var spawn2: Marker2D = $Spawn2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player1 = player.instantiate()
	add_child(player1)
	player1.name = "Player1"
	player1.position = spawn1.position

	#var player2 = player.instantiate()
	#add_child(player2)
	#player2.name = "Player2"
	#player2.position = spawn2.position
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
