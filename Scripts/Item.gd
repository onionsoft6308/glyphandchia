extends Area2D 

@export var item_texture: Texture2D  # Texture of the item
@export var item_name: String = "Unnamed Item"  # Name of the item
@export var item_type: String = "Ingredient"  # Default type
@export var is_in_inventory: bool = false  # True if the item is in the inventory
@export var item_description: String = "No description available."  # Description for dialogue

var original_position: Vector2 = Vector2.ZERO  # Original position for snapping back
var is_dragging: bool = false  # Tracks whether the item is being dragged
var drag_offset: Vector2 = Vector2.ZERO  # Offset between the mouse and the item's position

func _ready():
	# Set the texture for the Sprite2D node dynamically
	if $Sprite2D:
		$Sprite2D.texture = item_texture
		$Sprite2D.scale = Vector2(1, 1)  # Adjust the scale as needed
		
	else:
		print("Error: Sprite2D node not found!")

	# Set the size of the CollisionShape2D to match the Sprite2D
	if $CollisionShape2D and $CollisionShape2D.shape is RectangleShape2D:
		if $Sprite2D.texture:
			var sprite_size = $Sprite2D.texture.get_size()
			$CollisionShape2D.shape.extents = sprite_size / 2  # Set extents to half the size
		else:
			print("Error: Sprite2D.texture is null for item:", item_name)

	# Save the original position for snapping back (only for inventory items)
	if is_in_inventory:
		original_position = position

	# Connect signals for mouse interactions
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))
	connect("input_event", Callable(self, "_on_input_event"))

func _on_mouse_entered():
	GameManager.show_dialogue(item_description)

func _on_mouse_exited():
	GameManager.hide_dialogue()

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if is_in_inventory:
				is_dragging = true
				drag_offset = position - get_global_mouse_position()
			else:
				if InventoryManager.can_add_to_inventory(item_name):
					if not InventoryManager.is_item_collected(item_name):
						InventoryManager.add_item(item_texture, item_name, item_type)
						GameManager.update_inventory_ui()
						InventoryManager.mark_item_collected(item_name)
						GameManager.hide_dialogue()
						queue_free()
	elif event is InputEventMouseButton and not event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT and is_in_inventory:
			is_dragging = false
			if is_over_chia():
				handle_drop_on_chia()
			elif is_over_glyph_receptacle():
				handle_drop_on_glyph_receptacle()
			else:
				position = original_position

func _process(delta):
	# Follow the mouse while dragging (only for inventory items)
	if is_dragging:
		position = get_global_mouse_position() + drag_offset

func collect_item():
	print("Attempting to collect item:", item_name)
	if InventoryManager.can_add_to_inventory(item_name):
		print("Adding item to inventory:", item_name)
		InventoryManager.add_item(item_texture, item_name, item_type)
		GameManager.update_inventory_ui()
		GameManager.hide_dialogue()
		queue_free()  # Remove the item from the world
	else:
		print(item_name, "cannot be added to the inventory.")

func is_over_chia() -> bool:
	var chia = get_tree().get_root().get_node("creaturescreen/Chia")  # Replace with actual path
	if chia and chia.get_global_rect().has_point(get_global_mouse_position()):
		return true
	return false

func is_over_glyph_receptacle() -> bool:
	var glyph_receptacle = get_tree().get_root().get_node("Area2D/GlyphReceptacle")  # Replace with actual path
	if glyph_receptacle and glyph_receptacle.get_global_rect().has_point(get_global_mouse_position()):
		return true
	return false

func handle_drop_on_chia():
	if item_type == "Ingredient":
		GameManager.remove_from_inventory(item_texture)
		queue_free()
		GameManager.chia_node.receive_item(item_texture)

func handle_drop_on_glyph_receptacle():
	if item_type == "Glyph":
		GameManager.remove_from_inventory(item_texture)
		queue_free()

func add_item(texture: Texture2D, item_name: String, item_type: String):
	if texture not in InventoryManager.inventory_items:
		InventoryManager.inventory_items.append({"texture": texture, "name": item_name, "type": item_type})
		print("Item added to inventory:", item_name, "Texture:", texture)
	else:
		print("Item already exists in inventory:", item_name)
