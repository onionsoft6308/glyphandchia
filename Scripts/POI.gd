extends Area2D

@export var poi_name: String = "POI Name"
@export var approach_json_path: String = "" # e.g. res://Scripts/POI_1_approach.json
@export var enter_json_path: String = ""    # e.g. res://Scripts/POI_1_enter.json

@onready var label = $Label
@onready var sprite = $Sprite2D
@onready var anim = $AnimationPlayer
@onready var click_area = $ClickArea

var canoe_in_range = false

func _ready():
	label.text = poi_name
	label.visible = false
	add_to_group("poi")
	connect("area_entered", Callable(self, "_on_area_entered"))
	connect("area_exited", Callable(self, "_on_area_exited"))
	click_area.connect("input_event", Callable(self, "_on_click_area_input_event"))

func _on_area_entered(area):
	if area.name == "Canoe":
		canoe_in_range = true
		label.visible = true
		_start_breathing()
		_start_glow()

func _on_area_exited(area):
	if area.name == "Canoe":
		canoe_in_range = false
		label.visible = false
		_stop_breathing()
		_stop_glow()

func _on_click_area_input_event(viewport, event, shape_idx):
	print("DEBUG: ClickArea input event received")
	if canoe_in_range and event is InputEventMouseButton and event.pressed:
		print("DEBUG: ClickArea clicked while canoe in range")
		# Block canoe input here if needed (see below)
		var approach_dialogue = []
		if approach_json_path != "":
			var file = FileAccess.open(approach_json_path, FileAccess.READ)
			if file:
				approach_dialogue = JSON.parse_string(file.get_as_text())
				print("DEBUG: approach_dialogue loaded: ", approach_dialogue)
		print("DEBUG: Calling show_dialogue_panel with: ", approach_dialogue)
		get_tree().call_group("ui", "show_dialogue_panel", approach_dialogue, global_position)

# Called by DialoguePanel when player chooses "enter"
func start_enter_dialogue():
	var enter_dialogue = []
	if enter_json_path != "":
		var file = FileAccess.open(enter_json_path, FileAccess.READ)
		if file:
			enter_dialogue = JSON.parse_string(file.get_as_text())
	get_tree().call_group("ui", "show_dialogue_with_overlay", enter_dialogue, global_position, true)

func _start_glow():
	anim.play("glow")

func _stop_glow():
	anim.stop()
	sprite.modulate = Color(1,1,1,1)

func _start_breathing():
	anim.play("breathing")

func _stop_breathing():
	anim.stop()
	sprite.scale = Vector2.ONE
