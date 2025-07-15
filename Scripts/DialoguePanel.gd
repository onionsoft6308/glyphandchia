extends Control

@onready var text_label = $VBoxContainer/RichTextLabel
@onready var options_container = $VBoxContainer/OptionsContainer
@onready var exit_button = $HBoxContainer/ExitButton
@onready var input_blocker = get_parent().get_node("InputBlocker") # Adjust path as needed


var dialogue_data = []
var current_index = 0
var is_typing = false
var full_text = ""
var typewriter_speed = 0.02
var can_auto_exit = false


# Called when the node enters the scene tree for the first time.
func _ready():
	print("DEBUG: exit_button is ", exit_button)
	text_label.connect("meta_clicked", Callable(self, "_on_option_selected"))
	text_label.scroll_active = false
	text_label.scroll_following = true
	input_blocker.mouse_filter = Control.MOUSE_FILTER_IGNORE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
		pass

func show_dialogue(dialogue, click_position: Vector2):
	print("DEBUG: DialoguePanel show_dialogue called")
	if dialogue.is_empty():
		push_error("Dialogue data is empty!")
		return
	dialogue_data = dialogue
	current_index = 0
	text_label.text = ""
	_set_panel_side(click_position)
	visible = true
	exit_button.visible = false
	options_container.visible = false
	input_blocker.visible = true
	get_tree().call_group("ui", "block_canoe") # <--- Add this line
	await get_tree().create_timer(0.3).timeout
	await _show_section()

func _set_panel_side(click_position):
		var screen_center = get_viewport_rect().size.x / 2
		if click_position.x > screen_center:
				position.x = -size.x
				get_tree().create_tween().tween_property(self, "position:x", 0, 0.3)
		else:
				position.x = get_viewport_rect().size.x
				get_tree().create_tween().tween_property(self, "position:x", get_viewport_rect().size.x - size.x, 0.3)

func _show_section():
	var section = dialogue_data[current_index]
	var new_line = section.get("text", "")
	# Build the base text (all previous lines)
	var base_text = ""
	for idx in range(current_index):
		base_text += dialogue_data[idx].get("text", "") + "\n\n"

	# Build the options string for this section (if any)
	var options_text = ""
	if section.has("options"):
		for option in section["options"]:
			options_text += "[url=" + str(option["next"]) + "]" + option["label"] + "[/url]\n"
		options_text += "\n"

	is_typing = true
	exit_button.visible = false
	options_container.visible = false

	await _typewriter_effect(base_text, new_line, options_text, section.has("options"))

func _typewriter_effect(base_text, new_line, options_text, has_options):
	var i = 0
	text_label.bbcode_enabled = true
	# Type out the new line
	while i <= new_line.length() and is_typing:
		text_label.text = base_text + new_line.substr(0, i)
		text_label.scroll_to_line(text_label.get_line_count() - 1)
		await get_tree().create_timer(typewriter_speed).timeout
		i += 1
	# After the line is done, show the options (if any)
	if has_options:
		text_label.text = base_text + new_line + "\n\n" + options_text
		text_label.scroll_to_line(text_label.get_line_count() - 1)
		input_blocker.visible = false  # <--- ADD THIS LINE
	is_typing = false
	if not has_options:
		exit_button.visible = true

func _show_options(options):
	options_container.visible = true
	# Remove all existing option buttons
	for child in options_container.get_children():
		child.queue_free()
	for option in options:
		var btn = Button.new()
		btn.text = option["label"]
		btn.pressed.connect(_on_option_selected.bind(option["next"]))
		options_container.add_child(btn)

func _on_option_selected(next_index):
	print("DEBUG: Option selected:", next_index)
	next_index = int(next_index)
	if next_index == -1:
		_on_ExitButton_pressed()
	elif next_index == -2:
		# Animate exit of the current panel
		visible = false
		# Block input
		input_blocker.visible = true
		# Find the POI and call its start_enter_dialogue()
		var poi = null
		var pois = get_tree().get_nodes_in_group("poi")
		for p in pois:
			if p.canoe_in_range:
				poi = p
				break
		if poi:
			poi.start_enter_dialogue()
		return
	else:
		current_index = next_index
		await _show_section()

func _on_ExitButton_pressed():
	print("DEBUG: Exit button pressed")
	is_typing = false
	visible = false
	input_blocker.visible = false
	get_tree().call_group("ui", "unblock_canoe") # <--- Add this line
	# Hide overlay
	var ui_layer = get_parent()
	if ui_layer.has_node("DialogueOverlay"):
		ui_layer.get_node("DialogueOverlay").visible = false

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if is_typing:
			is_typing = false
			# Instantly finish the typewriter effect
			var section = dialogue_data[current_index]
			var new_line = section.get("text", "")
			var base_text = ""
			for idx in range(current_index):
				base_text += dialogue_data[idx].get("text", "") + "\n\n"
			var options_text = ""
			if section.has("options"):
				for option in section["options"]:
					options_text += "[url=" + str(option["next"]) + "]" + option["label"] + "[/url]\n"
				options_text += "\n"
			text_label.text = base_text + new_line + ("\n\n" + options_text if options_text != "" else "")
			text_label.scroll_to_line(text_label.get_line_count() - 1)
		elif not is_typing:
			if current_index < dialogue_data.size():
				if not dialogue_data[current_index].has("options"):
					if current_index < dialogue_data.size() - 1:
						current_index += 1
						await _show_section()
					else:
						exit_button.visible = true



