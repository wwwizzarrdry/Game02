extends Control

@onready var title: Label = $PanelContainer/VBoxContainer/Title
@onready var progress_bar: ProgressBar = $PanelContainer/VBoxContainer/ProgressBar
@onready var continue_btn: Button = $PanelContainer/VBoxContainer/ContinueBtn
@onready var log: Label = $PanelContainer/VBoxContainer/Log
@onready var NEXT_SCENE: PackedScene = preload("res://Scenes/Levels/LoadingScreen/LoadingScreen.tscn")

var folder = "res://Assets/"
var total_resources = []
var t = 0

func _ready() -> void:

	continue_btn.disabled = true
	continue_btn.hide()
	title.show()
	progress_bar.show()
	log.show()
	log.text = ""


	# Start loading the game resources here.
	total_resources = get_all_files(folder)
	if total_resources.size() > 0:
		progress_bar.max_value = total_resources.size()
		progress_bar.value = 0

		for r in total_resources:
			t = randf_range(0.01, 0.07)
			await(get_tree().create_timer(t).timeout)
			load_resource(r)
	else:
		printerr("Can't Load Resources!\nAn error occurred when trying to access %s." % folder)

func get_all_files(path: String, file_ext := "", files := []):
	var dir = DirAccess.open(path)

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				files = get_all_files(dir.get_current_dir() / file_name,  file_ext, files)
			else:
				if file_ext and file_name.get_extension() != file_ext:
					file_name = dir.get_next()
					continue

				# File Name
				#files.append(file_name)

				# Full File Path
				files.append(dir.get_current_dir()/file_name)

			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access %s." % path)

	return files

func load_resource(resource)->void:
	progress_bar.value += 1
	log.text = str(resource)
	if progress_bar.value == progress_bar.max_value:
		progress_bar.hide()
		log.hide()
		title.text = "Loading Complete!"
		continue_btn.disabled = false
		continue_btn.show()
		continue_btn.grab_focus()

func _input(event: InputEvent) -> void:
	if progress_bar.value < progress_bar.max_value: return
	if Input.is_anything_pressed():
		continue_btn.grab_focus()
		_on_continue_btn_pressed()

func change_scene(scene):
	get_tree().reload_current_scene()
	#get_tree().change_scene_to_packed(scene)

func _on_continue_btn_pressed() -> void:
	continue_btn.disabled = true
	await(get_tree().create_timer(1).timeout)
	call_deferred("change_scene", NEXT_SCENE)
