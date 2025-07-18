extends CanvasLayer

@onready var text_label = $TextLabel
@onready var image_rect = $ImageRect
@onready var options_container = $OptionsContainer
@onready var timer_bar = $TimerBar
@onready var green_bar = $TimerBar/GreenBar
@onready var white_bar = $TimerBar/WhiteBar
@onready var background_rect = $BackgroundRect

var dungeon_data = []
var current_index = 0
var is_typing = false
var typewriter_speed := 0.02
var max_visible_lines := 20
var option_click_blocked := false
var option_block_time := 0.5
var text_buffer := []  # Store all previous text sections

func start_dungeon(dungeon_json):
	print("DEBUG: dungeon_json type:", typeof(dungeon_json), " size:", dungeon_json.size())
	dungeon_data = dungeon_json
	current_index = 0
	visible = true
	text_label.clear()
	image_rect.texture = null
	image_rect.modulate.a = 0.0
	options_container.visible = false
	timer_bar.visible = false
	background_rect.modulate.a = 0.0
	option_click_blocked = false
	is_typing = false
	text_buffer.clear()
	# Fade in black background first
	var tween = get_tree().create_tween()
	tween.tween_property(background_rect, "modulate:a", 1.0, 1.0)
	await tween.finished
	await _show_section()

func _show_section():
	print("DEBUG: dungeon_data type:", typeof(dungeon_data), " size:", dungeon_data.size(), " current_index:", current_index)
	if typeof(dungeon_data) != TYPE_ARRAY or dungeon_data.size() == 0:
		push_error("Dungeon data is empty or invalid!")
		return
	if current_index < 0 or current_index >= dungeon_data.size():
		push_error("Dungeon index out of bounds!")
		return
	var section = dungeon_data[current_index]
	var new_line = section.get("text", "")
	if text_buffer.size() <= current_index:
		text_buffer.append(new_line)
	var options = section.get("options", null)
	var options_text = ""
	if options:
		for option in options:
			options_text += "[color=orange]" + option["label"] + "[/color]\n\n"
		options_text += "\n"
	var image_path = section.get("image", "")
	var fade_in = section.get("image_fade", {}).get("in", 0.5)
	var fade_out = section.get("image_fade", {}).get("out", 0.5)
	await _fade_image(image_path, fade_in, fade_out)
	is_typing = true
	options_container.visible = false
	await _typewriter_effect(new_line, options_text, options != null)
	# If there are options, show them (with timer if present)
	if options:
		var timer_sec = section.get("timer", null)
		await _show_options(options, timer_sec)

func _typewriter_effect(new_line, options_text, has_options):
	var i = 0
	text_label.bbcode_enabled = true
	option_click_blocked = true
	var old_text = get_faded_text(text_buffer.slice(0, text_buffer.size() - 1))
	while i <= new_line.length() and is_typing:
		text_label.text = old_text + "\n\n" + new_line.substr(0, i)
		if text_label.get_line_count() > max_visible_lines:
			text_label.scroll_to_line(text_label.get_line_count() - max_visible_lines)
		await get_tree().create_timer(typewriter_speed).timeout
		i += 1
	if has_options:
		# Show options as clickable text
		var section = dungeon_data[current_index]
		var options = section.get("options", [])
		var options_bbcode = ""
		for idx in range(options.size()):
			options_bbcode += "[url=option_" + str(idx) + "]" + options[idx]["label"] + "[/url]\n\n"
		text_label.text = get_faded_text(text_buffer) + "\n\n" + options_bbcode
		if text_label.get_line_count() > max_visible_lines:
			text_label.scroll_to_line(text_label.get_line_count() - max_visible_lines)
		await get_tree().create_timer(option_block_time).timeout
		option_click_blocked = false
	is_typing = false

func get_faded_text(buffer):
	var faded_lines = []
	for i in range(buffer.size()):
		var line = buffer[i]
		# Fade out lines near the top (first half of visible lines)
		if i < buffer.size() - int(max_visible_lines / 2):
			line = "[color=#888888]" + line + "[/color]" # faded gray
		faded_lines.append(line)
	return "\n\n".join(faded_lines)

func _show_options(options, timer_sec = null):
	options_container.visible = false  # Hide container, not used
	var options_text = ""
	for idx in range(options.size()):
		var option = options[idx]
		# Give each option a unique tag for click detection
		options_text += "[url=option_" + str(idx) + "]" + option["label"] + "[/url]\n\n"
	text_label.text += options_text
	text_label.bbcode_enabled = true
	text_label.scroll_to_line(text_label.get_line_count() - max_visible_lines)
	# Connect the meta_clicked signal for clickable text
	if not text_label.is_connected("meta_clicked", Callable(self, "_on_option_text_clicked")):
		text_label.connect("meta_clicked", Callable(self, "_on_option_text_clicked"))
	if timer_sec:
		timer_bar.visible = true
		await _run_timer(timer_sec)
		timer_bar.visible = false

func _run_timer(seconds):
	var total_width = white_bar.size.x
	green_bar.size.x = total_width
	green_bar.position.x = 0
	var tween = get_tree().create_tween()
	tween.tween_property(green_bar, "size:x", 0, seconds)
	tween.tween_property(green_bar, "position:x", total_width, seconds)
	await tween.finished
	if options_container.get_child_count() > 0:
		options_container.get_child(0).emit_signal("pressed")

func _fade_image(image_path, fade_in, fade_out):
	if image_path == "":
		await _fade_out_image(fade_out)
		return
	var tex = load(image_path)
	image_rect.texture = tex
	image_rect.expand = true
	image_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var tween = get_tree().create_tween()
	tween.tween_property(image_rect, "modulate:a", 1.0, fade_in)
	await tween.finished

func _fade_out_image(fade_out):
	var tween = get_tree().create_tween()
	tween.tween_property(image_rect, "modulate:a", 0.0, fade_out)
	await tween.finished
	image_rect.texture = null

func _on_option_selected(next_index):
	current_index = int(next_index)
	await _show_section()

func _input(event):
	if not visible or typeof(dungeon_data) != TYPE_ARRAY or dungeon_data.size() == 0:
		return  # Ignore input if not in dungeon mode

	if event is InputEventMouseButton and event.pressed:
		if is_typing:
			is_typing = false
			var section = dungeon_data[current_index]
			var new_line = section.get("text", "")
			var options = section.get("options", null)
			var options_text = ""
			if options:
				for option in options:
					options_text += "[color=orange]" + option["label"] + "[/color]\n\n"
				options_text += "\n"
			text_label.text = get_faded_text(text_buffer.slice(0, text_buffer.size() - 1)) + "\n\n" + new_line + ("\n\n" + options_text if options_text != "" else "")
			if text_label.get_line_count() > max_visible_lines:
				text_label.scroll_to_line(text_label.get_line_count() - max_visible_lines)
			option_click_blocked = false
		elif not is_typing:
			var section = dungeon_data[current_index]
			if not section.has("options"):
				if current_index < dungeon_data.size() - 1:
					current_index += 1
					await _show_section()

func _on_option_text_clicked(meta):
	if meta.begins_with("option_"):
		var idx = int(meta.replace("option_", ""))
		var section = dungeon_data[current_index]
		var options = section.get("options", [])
		if idx >= 0 and idx < options.size():
			var next_index = int(options[idx]["next"])
			current_index = next_index
			await _show_section()
