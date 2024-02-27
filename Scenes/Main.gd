extends Node

@onready var players = {
	"1": {
		viewport = $CanvasLayer/Control/HBoxContainer/P1_SubViewportContainer/SubViewport,
		camera = $CanvasLayer/Control/HBoxContainer/P1_SubViewportContainer/SubViewport/Camera2D,
		player =$CanvasLayer/Control/HBoxContainer/P1_SubViewportContainer/SubViewport/Level01/Icon
	},
	"2": {
		viewport = $CanvasLayer/Control/HBoxContainer/P2_SubViewportContainer/SubViewport,
		camera = $CanvasLayer/Control/HBoxContainer/P2_SubViewportContainer/SubViewport/Camera2D,
		player =$CanvasLayer/Control/HBoxContainer/P1_SubViewportContainer/SubViewport/Level01/Icon2
	}
}


func _ready() -> void:
	players["2"].viewport.world_2d = players["1"].viewport.world_2d
	for node in players.values():
		var remote_transform := RemoteTransform2D.new()
		remote_transform.remote_path = node.camera.get_path()
		node.player.add_child(remote_transform)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
