extends Area2D

@export var item_texture: Texture2D
@export var item_name: String
@export var item_description: String
@export var can_inspect: bool = true
@export var can_collect: bool = false

var is_hovered := false
var interaction_mode := false

func _ready():
	$ItemSprite.texture = item_texture
	$GlintSprite.visible = false
	$InspectIcon.visible = false
	$CollectIcon.visible = false

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
			# Show inspect and collect icons, hide glint
			$GlintSprite.visible = false
			$InspectIcon.visible = true
			$CollectIcon.visible = true
			interaction_mode = true
		elif can_inspect and not can_collect:
			_show_inspect()
		elif can_collect and not can_inspect:
			_collect_item()

func _unhandled_input(event):
	if interaction_mode and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# If not clicking on the icons themselves, hide icons
		_reset_icons()
		var mouse_pos = to_local(get_global_mouse_position())
		var clicked_inspect = $InspectIcon.visible and $InspectIcon.get_rect().has_point(mouse_pos)
		var clicked_collect = $CollectIcon.visible and $CollectIcon.get_rect().has_point(mouse_pos)
		if clicked_inspect and can_inspect:
			_show_inspect()
			_reset_icons()
		elif clicked_collect and can_collect:
			_collect_item()
			_reset_icons()
		else:
			# Clicked elsewhere: hide icons
			_reset_icons()

func _reset_icons():
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
	GameManager.show_dialogue(item_description)

func _collect_item():
	if can_collect:
		InventoryManager.add_item(item_texture, item_name, "AdvancedItem")
		GameManager.update_inventory_ui()
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
	pass # Replace with function body.


func _on_inspect_icon_input_event(viewport, event, shape_idx):
	pass # Replace with function body.
