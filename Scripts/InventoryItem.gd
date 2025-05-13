extends Control

@export var item_texture: Texture2D
@export var item_name: String
@export var item_type: String

var is_dragging := false
var drag_offset := Vector2.ZERO
var original_position := Vector2.ZERO

func _ready():
	$TextureRect.texture = item_texture
	$TextureRect.connect("gui_input", Callable(self, "_gui_input"))
	original_position = global_position

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			drag_offset = get_global_mouse_position() - global_position
			print("Start dragging:", item_name)
		else:
			is_dragging = false
			print("Stop dragging:", item_name)
			# Check drop targets
			var mouse_pos = get_global_mouse_position()
			if _is_over_chia(mouse_pos) and item_type == "Ingredient":
				GameManager.chia_node.receive_item(item_texture)
				GameManager.remove_from_inventory(item_texture)
				queue_free()
			elif _is_over_glyph_receptacle(mouse_pos) and item_type == "Glyph":
				GameManager.remove_from_inventory(item_texture)
				queue_free()
				# Add your glyph logic here
			else:
				# Snap back to original position
				global_position = original_position

func _process(delta):
	if is_dragging:
		global_position = get_global_mouse_position() - drag_offset

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
	var glyph_receptacle = get_tree().get_root().get_node("glyphscreen/GlyphReceptacle") # Adjust path
	return glyph_receptacle and glyph_receptacle.get_global_rect().has_point(mouse_pos)
