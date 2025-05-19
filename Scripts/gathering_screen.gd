extends Control

@onready var text_label = $VBoxContainer/RichTextLabel
@onready var options_container = $VBoxContainer/OptionsContainer
@onready var exit_button = $HBoxContainer/ExitButtonInventoryGrid node
@onready var input_blocker = get_parent().get_node("InputBlocker") # Adjust path as needed
func _ready():
	# Locate the UILayer instance in the scene
var dialogue_data = []de("UILayer")  # Adjust the path if necessary
var current_index = 0
var is_typing = falseayer.get_node("DialogueBox/DialogueLabel")  # Adjust the path if necessary
var full_text = ""i_layer.get_node("InventoryPanel/InventoryGrid")  # Adjust the path if necessary
var typewriter_speed = 0.02
var can_auto_exit := falset found in the scene!")
var displayed_lines := []
	# Initialize the UI
	if dialogue_box:
# Called when the node enters the scene tree for the first time.k but visible
func _ready():ui:
	print("DEBUG: exit_button is ", exit_button)o confirm the inventory UI is found
	text_label.connect("meta_clicked", Callable(self, "_on_option_selected"))
	text_label.scroll_active = falseaced interactive objects
	text_label.scroll_following = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):r all manually placed interactive objects
		passhild in get_children():
		if child is Area2D and child.has_method("get_item_name"):  # Ensure it's an interactable object
func show_dialogue(dialogue, click_position: Vector2):Object_hovered").bind(child))
	print("DEBUG: DialoguePanel show_dialogue called")n_Object_unhovered").bind(child))
	if dialogue.is_empty():event", Callable(self, "_on_Object_clicked").bind(child))
		push_error("Dialogue data is empty!")
		return_Object_hovered(object):
	dialogue_data = dialogue
	current_index = 0y_hover_effect(object)
	displayed_lines = [] "This is a " + object.get_item_name()  # Update dialogue box text
	text_label.text = ""
	_set_panel_side(click_position)):
	visible = truex:
	exit_button.visible = falseffect(object)
	options_container.visible = falsethe dialogue box visible but blank
	input_blocker.visible = true	# Block input
	await get_tree().create_timer(0.3).timeout	# Wait for panel animation (match your tween duration)
	await _show_section()tMouseButton and event.pressed:
		var item_name = object.get_item_name()
func _set_panel_side(click_position):ntory(item_name):  # Validate against Chia's ingredients
		var screen_center = get_viewport_rect().size.x / 2_name, "Ingredient")  # Pass the item type as the third argument
		if click_position.x > screen_center:bject from the scene
				position.x = -size.x
				get_tree().create_tween().tween_property(self, "position:x", 0, 0.3)
		else:t(item_name, "is not part of Chia's desired items.")
				position.x = get_viewport_rect().size.x
				get_tree().create_tween().tween_property(self, "position:x", get_viewport_rect().size.x - size.x, 0.3)
	# Update the inventory UI with the current inventory
func _show_section():
	var section = dialogue_data[current_index]id
	var new_line = section.get("text", "")
	if displayed_lines.size() > current_index:
		displayed_lines[current_index] = new_lineld.texture:
	else:				existing_items.append(child.texture)
		displayed_lines.append(new_line)
ems to the grid
	# Build the base text (all previous lines):
	var base_text = ""
	for idx in range(displayed_lines.size() - 1):				var item_icon = TextureRect.new()
		base_text += displayed_lines[idx] + "\n\n"
ode = TextureRect.EXPAND_IGNORE_SIZE
	# Build the options string for this section (if any)= TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var options_text = ""ze(Vector2(48, 48))  # Ensure proper size
	if section.has("options"):
		for option in section["options"]:to inventory UI:", item["name"], "Texture:", item["texture"].resource_path)
			options_text += "[url=" + str(option["next"]) + "]" + option["label"] + "[/url]\n"	else:
		options_text += "\n"nventory UI not found!")
	is_typing = true	exit_button.visible = false	options_container.visible = false	await _typewriter_effect(base_text, new_line, options_text, section.has("options"))func _typewriter_effect(base_text, new_line, options_text, has_options):	var i = 0	text_label.bbcode_enabled = true	# Type out the new line	while i <= new_line.length() and is_typing:		text_label.text = base_text + new_line.substr(0, i)		text_label.scroll_to_line(text_label.get_line_count() - 1)		await get_tree().create_timer(typewriter_speed).timeout		i += 1	# After the line is done, show the options (if any)	if has_options:		text_label.text = base_text + new_line + "\n\n" + options_text		text_label.scroll_to_line(text_label.get_line_count() - 1)	is_typing = false	if not has_options:		exit_button.visible = truefunc _show_options(options):	options_container.visible = true	# Remove all existing option buttons	for child in options_container.get_children():		child.queue_free()	for option in options:		var btn = Button.new()		btn.text = option["label"]		btn.pressed.connect(_on_option_selected.bind(option["next"]))		options_container.add_child(btn)func _on_option_selected(next_index):	next_index = int(next_index)	if next_index == -1:		_on_ExitButton_pressed()	else:		current_index = next_index		await _show_section()func _on_ExitButton_pressed():	print("DEBUG: Exit button pressed")	is_typing = false	visible = false	input_blocker.visible = false	# Unblock inputfunc _input(event):	if event is InputEventMouseButton and event.pressed:		if is_typing:			is_typing = false			# Instantly finish the typewriter effect			var section = dialogue_data[current_index]			var new_line = section.get("text", "")			var base_text = ""			for idx in range(displayed_lines.size() - 1):				base_text += displayed_lines[idx] + "\n\n"			var options_text = ""			if section.has("options"):				for option in section["options"]:					options_text += "[url=" + str(option["next"]) + "]" + option["label"] + "[/url]\n"				options_text += "\n"			text_label.text = base_text + new_line + ("\n\n" + options_text if options_text != "" else "")			text_label.scroll_to_line(text_label.get_line_count() - 1)		elif not is_typing:			if current_index < dialogue_data.size():				if not dialogue_data[current_index].has("options"):					if current_index < dialogue_data.size() - 1:						current_index += 1						await _show_section()					else:						exit_button.visible = true

