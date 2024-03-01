extends Node
# Declare your global variables
#
# Access them anywhere with:
# Global.variable_name


func apply_tether_force(delta: float, object: Node, center_point: Vector2, max_dist: int, mass: float):
	center_point = center_point if center_point else Vector2.ZERO
	max_dist = max_dist if max_dist else 500
	mass = mass if mass else 1.0

	var IDEAL_ROPE_DISTANCE = max_dist * 0.8 # adjust as needed
	var ROPE_SPRING_CONSTANT = 200 # adjust as needed

	var rope_vector = object.position - center_point
	var rope_distance = rope_vector.length()
	if rope_distance > IDEAL_ROPE_DISTANCE:
		var rope_force = ROPE_SPRING_CONSTANT * (rope_distance - IDEAL_ROPE_DISTANCE)
		object.velocity += rope_vector.normalized() * -rope_force * delta / mass

func print_dict(d, indent:int=0):
	var spaces = "\t"
	for i in indent: spaces = spaces + str("\t")

	for key in d:
		if typeof(d[key]) == TYPE_DICTIONARY:
			print(spaces + str(key) + ":")
			print_dict(d[key], indent + 1)
		else:
			print(spaces + str(key) + ": " + str(d[key]))

func print_array(arr, indent=0):
	var spaces = "\t"
	for i in indent: spaces = spaces + str("\t")
	for i in range(arr.size()):
		var value = arr[i]
		if value is Array:
			print(spaces + "Array:")
			print_array(value, indent + 1)
		elif value is Dictionary:
			print(spaces + "Dictionary:")
			print_dict(value, indent + 1)
		else:
			print(spaces + str(i) + ": " + str(value))

func print_object(obj, indent=0):
	var spaces = "\t"
	for i in indent: spaces = spaces + str("\t")
	for property in obj.get_property_list():
		var name = property.name
		var value = obj.get(name)
		print(spaces + str(name) + ": " + str(value))

func printobj(obj):
	if !obj: return
	if obj is Array: print_array(obj)
	elif obj is Dictionary: print_dict(obj)
	elif obj is Object: print_object(obj)
	else: print(obj)

func find_and_remove(array: Array, value) -> void:
	var index = array.find(value)
	if index != -1:
		# Item was found
		array.remove_at(index)

func replace_or_append(array: Array, value) -> void:
	var index = array.find(value)
	if index != -1:
		# Item was found
		array[index] = value
	else:
		# Item was not found
		array.append(value)

func timeout(time:float = 1.0):
	return get_tree().create_timer(time).timeout

func alert(title:String = "Alert", msg:String = Time.get_datetime_string_from_system()) -> void:
	OS.alert(msg, title)
	pass

func uuid() -> String:
	var id = OS.get_unique_id()
	prints("Unique ID: ", id)
	return id

func get_all_children_of_type(parent_node, type):
	# Usage:
	# var color_rects = get_all_children_of_type($Node2D, "ColorRect")
	var children_of_type = []
	for child in parent_node.get_children():
		if child.get_class() == type:
			children_of_type.append(child)
	return children_of_type

func get_viewport_size(scene = null) -> Vector2:
	if scene == null:
		scene = get_tree().get_current_scene()
	var viewport_rect = scene.get_viewport_rect()
	var viewport_size = viewport_rect.size
	return viewport_size

func get_nodes_in_branch_group(branch: Node, group: String) -> Array:
	var group_nodes_on_branch:= []
	for i in branch.get_children():
		if i.is_in_group(group):
			group_nodes_on_branch.append(i)
		if i.get_child_count() > 0:
			get_nodes_in_branch_group(i, group)
	return group_nodes_on_branch

# Global Dialog Box Manager
var dialogBox = null
func openDialog(text: String = "", speed: float = 0.05, typing_effect: bool = true, scene = null):
	if scene == null:
		scene = get_tree().get_current_scene()

	# Check if the RichTextLabel already exists in the scene
	closeDialog()

	# Max Box Size
	dialogBox = RichTextLabel.new()
	var width = 350
	var height = 100
	var margin = 23

	#viewport dimension for centering
	var viewport_size = get_viewport_size()

	dialogBox.name = "DialogBox"
	dialogBox.top_level = true
	dialogBox.fit_content = true
	dialogBox.scroll_following = true
	dialogBox.bbcode_enabled = true
	dialogBox.clip_contents = false
	dialogBox.custom_minimum_size = Vector2(width, height)

	# Center the dialog box
	var posx = ((viewport_size.x / 2.0) - (width/2.0))
	var posy = ((viewport_size.y / 2.0) - (height))
	dialogBox.set_position(Vector2(posx, posy))

	# Create a new theme
	var theme = Theme.new()

	# Create a new style box with a border and background color
	var style = StyleBoxFlat.new()
	style.set_bg_color(Color(0.2, 0.2, 0.2))  # dark gray background
	style.set_border_color(Color(1, 1, 1))  # white border
	style.set_border_width_all(2)  # border width
	style.set_corner_radius_all(10)  # rounded corners
	style.set_content_margin(SIDE_LEFT, margin)  # left padding
	style.set_content_margin(SIDE_TOP, margin)  # top padding
	style.set_content_margin(SIDE_RIGHT, margin)  # right padding
	style.set_content_margin(SIDE_BOTTOM, margin)  # bottom padding
	# Create a new style box for the drop shadow
	style.shadow_color = Color(0, 0, 0, 0.5)  # dark gray background
	style.shadow_offset = Vector2(15, 15)
	style.shadow_size = 1

	# Apply the style boxes to the theme
	theme.set_stylebox("normal", "RichTextLabel", style)

	# Apply the theme to the dialogBox
	dialogBox.set_theme(theme)

	# Create a new Button to close the dialog
	var button = Button.new()
	button.text = "X"
	button.custom_minimum_size = Vector2(25, 25)  # adjust the size as needed

	# Set the button color to red
	var button_style = StyleBoxFlat.new()
	button_style.bg_color = Color("#F7332E")  # red
	button_style.set_border_color(Color(1, 1, 1))  # white border
	button_style.set_border_width_all(2)  # border width
	button_style.set_corner_radius_all(4)  # rounded corners
	button.add_theme_stylebox_override("normal", button_style)

	# Set the button text color to white
	button.add_theme_color_override("font_color", Color(1, 1, 1)) # white

	# Position the button at the top-right corner of the dialogBox
	button.position = Vector2(dialogBox.custom_minimum_size.x - button.custom_minimum_size.x/2, -button.custom_minimum_size.y/2)

	# Connect the button's pressed signal to a function that removes the RichTextLabel
	button.pressed.connect(_on_dialogCloseButton_pressed.bind(dialogBox))

	# Add the button to the RichTextLabel
	dialogBox.add_child(button)

	# Add hte dialog to the scene
	scene.add_child(dialogBox)
	dialogBox.focus_mode = Control.FOCUS_ALL

	if typing_effect:
		start_typing_effect(dialogBox, text, speed)
	else:
		dialogBox.add_text(text)
	pass

var current_richtextlabel = null
func start_typing_effect(richtextlabel, text, speed):
	current_richtextlabel = richtextlabel
	for c in text:
		if richtextlabel != current_richtextlabel or richtextlabel == null:
			return  # Cancel the coroutine
		current_richtextlabel.append_text(c)
		await get_tree().create_timer(speed).timeout  # wait for 0.1 seconds

func closeDialog():
	if dialogBox != null:
		dialogBox.queue_free()
		dialogBox = null
	pass

func _on_dialogCloseButton_pressed(_richtextlabel):
	closeDialog()
	#richtextlabel.queue_free()  # remove the RichTextLabel
	pass

