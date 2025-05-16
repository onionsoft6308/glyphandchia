extends Area2D

@export var item_texture: Texture2D
@export var item_name: String
@export var item_description: String
@export var item_type: String = "Ingredient" # or "Glyph" as needed per instance
@export var can_inspect: bool = true
@export var can_collect: bool = false
@export var dialogue_json_path: String = ""

var is_hovered := false
var interaction_mode := false

func _ready():
	$ItemSprite.texture = item_texture
	$GlintSprite.visible = false
	$InspectIcon.visible = false
	$CollectIcon.visible = false
	interaction_mode = false

func _on_mouse_entered():
	is_hovered = true
	_show_description()
	if can_inspect and can_collect:
		$GlintSprite.visible = true
	elif can_inspect:
		$InspectIcon.visible = true

func _on_mouse_exited():
	is_hovered = false
	_clear_description()
	if not interaction_mode:
		$GlintSprite.visible = false
		$InspectIcon.visible = false
		$CollectIcon.visible = false

func _input_event(viewport, event, shape_idx):
	if not is_hovered:
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if can_inspect and can_collect and not interaction_mode:
			$GlintSprite.visible = false
			$InspectIcon.visible = true
			$CollectIcon.visible = true
			interaction_mode = true
		elif can_inspect and not can_collect:
			_show_inspect()
		elif can_collect and not can_inspect:
			_collect_item()

func _unhandled_input(event):
	if not is_inside_tree():
		return
	if interaction_mode and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_global_mouse_position()
		var over_inspect_icon = false
		var over_collect_icon = false

		# Check InspectIcon (circular)
		if is_instance_valid($InspectIcon) and $InspectIcon.visible and $InspectIcon.has_node("CollisionShape2D"):
			var shape = $InspectIcon.get_node("CollisionShape2D").shape
			if shape is CircleShape2D:
				var icon_pos = $InspectIcon.global_position
				var radius = shape.radius
				over_inspect_icon = mouse_pos.distance_to(icon_pos) <= radius

		# Check CollectIcon (circular)
		if is_instance_valid($CollectIcon) and $CollectIcon.visible and $CollectIcon.has_node("CollisionShape2D"):
			var shape = $CollectIcon.get_node("CollisionShape2D").shape
			if shape is CircleShape2D:
				var icon_pos = $CollectIcon.global_position
				var radius = shape.radius
				over_collect_icon = mouse_pos.distance_to(icon_pos) <= radius

		if over_inspect_icon or over_collect_icon:
			return
		_reset_icons()

func _reset_icons():
	await get_tree().create_timer(0.3).timeout
	$InspectIcon.visible = false
	$CollectIcon.visible = false
	interaction_mode = false

func _show_description():
	var ui_layer = _find_ui_layer()
	if ui_layer and ui_layer.has_node("DescriptionBox/DescriptionLabel"):
		ui_layer.get_node("DescriptionBox/DescriptionLabel").text = item_description

func _clear_description():
	var ui_layer = _find_ui_layer()
	if ui_layer and ui_layer.has_node("DescriptionBox/DescriptionLabel"):
		ui_layer.get_node("DescriptionBox/DescriptionLabel").text = ""

func _show_inspect():
	print("DEBUG: _show_inspect called for", item_name)
	print("DEBUG: dialogue_json_path =", dialogue_json_path)
	var file = FileAccess.open(dialogue_json_path, FileAccess.READ)
	var dialogue = []
	if file:
		var file_text = file.get_as_text()
		print("DEBUG: JSON file contents:\n", file_text)
		var json_result = JSON.parse_string(file_text)
		print("DEBUG: JSON parse result =", json_result)
		if typeof(json_result) == TYPE_ARRAY:
			dialogue = json_result
			print("DEBUG: Parsed dialogue array:", dialogue)
		else:
			push_error("Dialogue JSON is not an array!")
	else:
		push_error("Could not open dialogue file: " + dialogue_json_path)

	var ui_layer = _find_ui_layer()
	print("DEBUG: ui_layer =", ui_layer)
	if ui_layer and ui_layer.has_node("DialoguePanel"):
		print("DEBUG: Showing dialogue panel")
		ui_layer.get_node("DialoguePanel").show_dialogue(dialogue, global_position)
	else:
		push_error("DialoguePanel not found in UILayer!")

func _collect_item():
	print("Collect button pressed for:", item_name)
	if can_collect:
		InventoryManager.add_item(item_texture, item_name, item_type, true)
		GameManager.update_inventory_ui()
		await get_tree().create_timer(0.3).timeout
		queue_free()

func _find_ui_layer(node := get_tree().current_scene):
	if node is CanvasLayer and node.name == "UILayer":
		return node
	for child in node.get_children():
		var found = _find_ui_layer(child)
		if found:
			return found
	return null

func _on_collect_icon_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_collect_item()
		# Do NOT call _reset_icons() here!

func _on_inspect_icon_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_show_inspect()
		# Do NOT call _reset_icons() here!

