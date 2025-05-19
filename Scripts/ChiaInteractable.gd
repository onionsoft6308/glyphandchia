extends Area2D


@export var inspect_json_path: String = ""
@export var conversation_json_path: String = ""

var is_hovered := false
var interaction_mode := false

func _ready():
	$GlintSprite.visible = false
	$InspectIcon.visible = false
	$InspectIcon.get_node("CollisionShape2D").disabled = true
	$ConversationIcon.visible = false
	$ConversationIcon.get_node("CollisionShape2D").disabled = true
	interaction_mode = false

func _on_mouse_entered():
	is_hovered = true
	
	if not interaction_mode:
		$GlintSprite.visible = true

func _on_mouse_exited():
	is_hovered = false
	
	if not interaction_mode:
		$GlintSprite.visible = false
		$InspectIcon.visible = false
		$InspectIcon.get_node("CollisionShape2D").disabled = true
		$ConversationIcon.visible = false
		$ConversationIcon.get_node("CollisionShape2D").disabled = true

func _input_event(viewport, event, shape_idx):
	if not is_hovered:
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not interaction_mode:
			ItemInteractionManager.set_active_item(self)
			$GlintSprite.visible = false
			$InspectIcon.visible = true
			$InspectIcon.get_node("CollisionShape2D").disabled = false
			$ConversationIcon.visible = true
			$ConversationIcon.get_node("CollisionShape2D").disabled = false
			interaction_mode = true

func _unhandled_input(event):
	if not is_inside_tree():
		return
	if interaction_mode and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_global_mouse_position()
		var over_inspect_icon = false
		var over_conversation_icon = false

		if is_instance_valid($InspectIcon) and $InspectIcon.visible and $InspectIcon.has_node("CollisionShape2D"):
			var shape = $InspectIcon.get_node("CollisionShape2D").shape
			if shape is CircleShape2D:
				var icon_pos = $InspectIcon.global_position
				var radius = shape.radius
				over_inspect_icon = mouse_pos.distance_to(icon_pos) <= radius

		if is_instance_valid($ConversationIcon) and $ConversationIcon.visible and $ConversationIcon.has_node("CollisionShape2D"):
			var shape = $ConversationIcon.get_node("CollisionShape2D").shape
			if shape is CircleShape2D:
				var icon_pos = $ConversationIcon.global_position
				var radius = shape.radius
				over_conversation_icon = mouse_pos.distance_to(icon_pos) <= radius

		if over_inspect_icon or over_conversation_icon:
			return
		_reset_icons()

func _on_inspect_icon_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		ItemInteractionManager.set_active_item(self)
		_hide_icons_immediately()
		_show_dialogue(inspect_json_path)

func _on_conversation_icon_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		ItemInteractionManager.set_active_item(self)
		_hide_icons_immediately()
		_show_dialogue(conversation_json_path)

func _show_dialogue(json_path):
	var file = FileAccess.open(json_path, FileAccess.READ)
	var dialogue = []
	if file:
		var file_text = file.get_as_text()
		var json_result = JSON.parse_string(file_text)
		if typeof(json_result) == TYPE_ARRAY:
			dialogue = json_result
		else:
			push_error("Dialogue JSON is not an array!")
	else:
		push_error("Could not open dialogue file: " + json_path)

	var ui_layer = get_tree().get_root().find_child("UILayer", true, false)
	if ui_layer and ui_layer.has_node("DialoguePanel"):
		ui_layer.get_node("DialoguePanel").show_dialogue(dialogue, global_position)
	else:
		push_error("DialoguePanel not found in UILayer!")



func _reset_icons():
	await get_tree().create_timer(0.3).timeout
	$InspectIcon.visible = false
	$InspectIcon.get_node("CollisionShape2D").disabled = true
	$ConversationIcon.visible = false
	$ConversationIcon.get_node("CollisionShape2D").disabled = true
	interaction_mode = false

func _hide_icons_immediately():
	$GlintSprite.visible = false
	$InspectIcon.visible = false
	$InspectIcon.get_node("CollisionShape2D").disabled = true
	$ConversationIcon.visible = false
	$ConversationIcon.get_node("CollisionShape2D").disabled = true
	interaction_mode = false

func _exit_tree():
	ItemInteractionManager.clear_active_item(self)
