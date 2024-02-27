extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var spawn: Marker2D = $Spawn

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.position = spawn.position
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
