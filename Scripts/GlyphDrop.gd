extends Area2D
@export var glyph_texture: Texture2D

func _ready():
	$Sprite2D.texture = glyph_texture

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		# Add to inventory as a Control-based item
		InventoryManager.add_item(glyph_texture, "Glyph", "Glyph", true) # <-- force_add = true
		GameManager.update_inventory_ui()
		queue_free()
