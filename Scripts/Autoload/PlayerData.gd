extends Node

var players = [
	{
		"gamepad_id": 0,
		"name": "Player 1",
		"speed": 100,
		"health": 100,
		"shield": 100,
		"inventory": [
			{
				"id": 0,
				"name": "Medkit",
				"count": 3
			}
		]
	},
	{
		"gamepad_id": 1,
		"name": "Player 2",
		"speed": 100,
		"health": 100,
		"shield": 100,
		"inventory": [
			{
				"id": 0,
				"name": "Medkit",
				"count": 3
			}
		]
	}
]

func update(player_index: int = 0, key: String = "", value = "") -> void:
	players[player_index][key] = value

func getItem(player_index: int = 0,  key: String = ""):
	if !players.has(key):
		return null
	else:
		return players[player_index][key]
