extends Control

@export var item_texture: Texture2D
@export var item_name: String
@export var item_type: String

var is_dragging := false
var drag_preview: Control = null

func _ready():
	$TextureRect.texture = item_texture
	$TextureRect.connect("gui_input", Callable(self, "_gui_input"))

func _find_ui_layer(node := get_tree().current_scene):
	if node is CanvasLayer and node.name == "UILayer":
		return node
	for child in node.get_children():
		var found = _find_ui_layer(child)
		if found:
			return found
	return null

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		is_dragging = true
		if drag_preview:
			drag_preview.queue_free()
		drag_preview = preload("res://Scenes/DragPreview.tscn").instantiate()
		drag_preview.set_texture(item_texture)
		var ui_layer = _find_ui_layer()
		if ui_layer:
			ui_layer.add_child(drag_preview)
			drag_preview.global_position = get_global_mouse_position()
		else:
			print("UILayer not found in this scene!")
		$TextureRect.visible = false

func _unhandled_input(event):
	if is_dragging:
		if event is InputEventMouseMotion:
			if drag_preview:
				drag_preview.global_position = get_global_mouse_position()
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			is_dragging = false
			$TextureRect.visible = true
			if drag_preview:
				drag_preview.queue_free()
				drag_preview = null
			var mouse_pos = get_global_mouse_position()
			if _is_over_chia(mouse_pos) and item_type == "Ingredient":
				if GameManager.chia_node and is_instance_valid(GameManager.chia_node):
					# Only remove from inventory if Chia wants this ingredient
					var chia_ingredients = ProgressionManager.get_current_ingredients()
					var item_path = item_texture.resource_path
					if chia_ingredients.has(item_path):
						GameManager.chia_node.receive_item(item_texture)
						GameManager.remove_from_inventory(item_texture)
						queue_free()
					else:
						print("Chia does not want this ingredient right now!")
				else:
					print("Error: Chia node is not set or invalid!")
			elif _is_over_glyph_receptacle(mouse_pos) and item_type == "Glyph":
				GameManager.remove_from_inventory(item_texture)
				queue_free()

func _is_over_chia(mouse_pos: Vector2) -> bool:
	var chia = GameManager.chia_node
	if chia and is_instance_valid(chia) and chia.has_node("CollisionShape2D"):
		var space_state = chia.get_world_2d().direct_space_state
		var params = PhysicsPointQueryParameters2D.new()
		params.position = mouse_pos
		params.collide_with_areas = true
		params.collide_with_bodies = false
		params.exclude = []
		var result = space_state.intersect_point(params)
		for hit in result:
			if hit.collider == chia:
				return true
	return false

func _is_over_glyph_receptacle(mouse_pos: Vector2) -> bool:
	var glyph_receptacle = get_tree().get_root().get_node("GlyphMachine/Area2D/GlyphReceptacle")
	if glyph_receptacle and is_instance_valid(glyph_receptacle):
		var space_state = glyph_receptacle.get_world_2d().direct_space_state
		var params = PhysicsPointQueryParameters2D.new()
		params.position = mouse_pos
		params.collide_with_areas = true
		params.collide_with_bodies = false
		params.exclude = []
		var result = space_state.intersect_point(params)
		for hit in result:
			if hit.collider == glyph_receptacle:
				return true
	return false
