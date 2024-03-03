extends Node

var default_listenser = null : set = set_default_listener, get = get_default_listener
func set_default_listener(obj) -> void:
	default_listenser = obj
func get_default_listener() -> AudioListener2D:
	return default_listenser

var audio_queue: Array = []
var current_listener: AudioListener2D = null
var current_audio: AudioStreamPlayer2D = null


func _ready() -> void:
	set_default_listener(get_tree().current_scene.get_node_or_null("DefaultListener"))
	current_listener = get_default_listener()


func queue(data: Dictionary) -> void:
	#data = {"listener": AudioListener2D, "device": AudioStreamPlayer2D}
	var audio_listener = data.listener if data.listener is AudioListener2D else get_default_listener()
	var audio_device = data.device if data.device is AudioStreamPlayer2D else null

	if audio_device != null:
		audio_queue.append([audio_listener, audio_device])
		play_next_queued_sound()

func play_next_queued_sound():
	if audio_queue.size() > 0:
		var current_queue_item = audio_queue.pop_front()
		current_listener = current_queue_item[0]
		current_audio = current_queue_item[1]

		current_listener.current = true
		current_audio.play()
		current_audio.finished.connect(_on_current_audio_finished)

	else:
		set_default_listener(get_tree().current_scene.get_node_or_null("DefaultListener"))
		default_listenser = get_default_listener()
		default_listenser.current = true

func _on_current_audio_finished() -> void:
	current_audio.finished.disconnect(_on_current_audio_finished)
	play_next_queued_sound()
