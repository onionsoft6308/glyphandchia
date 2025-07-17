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
var timer_task = null

func start_dungeon(dungeon_json):
	dungeon_data = dungeon_json
	current_index = 0
	visible = true
	text_label.clear()
	image_rect.texture = null
	image_rect.modulate.a = 0.0
	options_container.visible = false
	timer_bar.visible = false
	background_rect.modulate.a = 0.0  # Start fully transparent

	# Fade in black background first
	var tween = get_tree().create_tween()
	tween.tween_property(background_rect, "modulate:a", 1.0, 1.0)
	await tween.finished

	await show_section()

func scroll_text(new_text):
	text_label.bbcode_enabled = true
	text_label.text += "\n\n" + new_text
	if text_label.get_line_count() > text_label.max_lines_visible:
		text_label.scroll_to_line(text_label.get_line_count() - text_label.max_lines_visible)

func fade_image(image_path, fade_in, fade_out):
	if image_path == "":
		await fade_out_image(fade_out)
		return
	var tex = load(image_path)
	image_rect.texture = tex
	var tween = get_tree().create_tween()
	tween.tween_property(image_rect, "modulate:a", 1.0, fade_in)
	await tween.finished

func fade_out_image(fade_out):
	var tween = get_tree().create_tween()
	tween.tween_property(image_rect, "modulate:a", 0.0, fade_out)
	await tween.finished
	image_rect.texture = null

func show_options(options, timer_sec = null):
	options_container.visible = true
	for child in options_container.get_children():
		child.queue_free()
	for option in options:
		var btn = Button.new()
		btn.text = option["label"]
		btn.pressed.connect(_on_option_selected.bind(option["next"]))
		options_container.add_child(btn)
	if timer_sec:
		timer_bar.visible = true
		await run_timer(timer_sec)
		timer_bar.visible = false

func run_timer(seconds):
	green_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	white_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	green_bar.rect_min_size.x = white_bar.rect_min_size.x
	var start_width = white_bar.rect_min_size.x
	var tween = get_tree().create_tween()
	tween.tween_property(green_bar, "rect_min_size:x", 0, seconds)
	await tween.finished
	# If timer runs out, auto-select first option
	if options_container.get_child_count() > 0:
		options_container.get_child(0).emit_signal("pressed")

func _on_option_selected(next_index):
	current_index = int(next_index)
	await show_section()

func show_section():
	var section = dungeon_data[current_index]
	scroll_text(section.get("text", ""))
	var image_path = section.get("image", "")
	var fade_in = section.get("image_fade", {}).get("in", 0.5)
	var fade_out = section.get("image_fade", {}).get("out", 0.5)
	await fade_image(image_path, fade_in, fade_out)
	if section.has("options"):
		var timer_sec = section.get("timer", null)
		await show_options(section["options"], timer_sec)
