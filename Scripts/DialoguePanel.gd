extends Control

@onready var text_label = $VBoxContainer/RichTextLabel
@onready var options_container = $VBoxContainer/OptionsContainer
@onready var exit_button = $HBoxContainer/ExitButton


var dialogue_data = []
var current_index = 0
var is_typing = false
var full_text = ""
var typewriter_speed = 0.02
var can_auto_exit := false


# Called when the node enters the scene tree for the first time.
func _ready():
	print("DEBUG: exit_button is ", exit_button)

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
		_set_panel_side(click_position)
		_show_section()
		visible = true
		exit_button.visible = false
		options_container.visible = false
		#get_tree().paused = true # Block game input

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
	full_text = section.get("text", "")
	text_label.text = ""
	is_typing = true
	exit_button.visible = false
	options_container.visible = false
	await _typewriter_effect()
	if section.has("options"):
		_show_options(section["options"])

func _typewriter_effect():
	var i = 0
	print("DEBUG: Starting typewriter for:", full_text)
	while i <= full_text.length() and is_typing:
		text_label.text = full_text.substr(0, i)
		await get_tree().create_timer(typewriter_speed).timeout
		i += 1
	text_label.text = full_text
	is_typing = false
	if not dialogue_data[current_index].has("options"):
		exit_button.visible = true

func _show_options(options):
		options_container.visible = true
		options_container.clear()
		for option in options:
				var btn = Button.new()
				btn.text = option["label"]
				btn.pressed.connect(_on_option_selected.bind(option["next"]))
				options_container.add_child(btn)

func _on_option_selected(next_index):
		current_index = next_index
		_show_section()

func _on_ExitButton_pressed():
	print("DEBUG: Exit button pressed")
	is_typing = false
	visible = false

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		# If the mouse is over the exit button, let the button handle it
		if exit_button.get_rect().has_point(exit_button.get_local_mouse_position()):
			return

		if is_typing:
			is_typing = false
			text_label.text = full_text
		elif not is_typing:
			if current_index < dialogue_data.size():
				if not dialogue_data[current_index].has("options"):
					if current_index < dialogue_data.size() - 1:
						current_index += 1
						await _show_section()
					else:
						exit_button.visible = true



