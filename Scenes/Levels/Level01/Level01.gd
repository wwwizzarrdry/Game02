extends Node2D

@onready var PLAYER = preload("res://Scenes/Components/Player/Player.tscn")
@onready var spawn: Marker2D = $Spawn
@onready var spawn2: Marker2D = $Spawn2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player1 = PLAYER.instantiate()
	#var player2 = PLAYER.instantiate()
	add_child(player1)
	#add_child(player2)
	player1.name = "Player1"
	#player2.name = "Player2"
	player1.position = spawn.position
	#player2.position = spawn2.position
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
