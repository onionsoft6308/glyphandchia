extends Area2D

@export var item_texture: Texture2D  # Single source of truth for the item's texture
@export var item_name: String = "Unnamed Item"
@export var item_type: String = "Ingredient"  # Default type
@export var is_in_inventory: bool = false  # True if the item is in the inventory
@export var item_description: String = "No description available."  # Default description

var original_position: Vector2 = Vector2.ZERO  # Original position for snapping back
var is_dragging: bool = false  # Tracks whether the item is being dragged
var drag_offset: Vector2 = Vector2.ZERO  # Offset between the mouse and the item's position

func _ready():
	# Set the texture for the Sprite2D node dynamically
	if $Sprite2D:
		$Sprite2D.texture = item_texture
		print("Sprite2D texture set for item:", item_name, "Texture resource path:", item_texture.resource_path)
	else:
		print("Error: Sprite2D node not found!")

	# Save the original position for snapping back (only for inventory items)
	if is_in_inventory:
		original_position = position

	# Check if this item has already been collected
	if InventoryManager.is_item_collected(item_name):
		queue_free()  # Remove the item from the scene if it's already collected

	print("Item ready:", item_name, "is_in_inventory:", is_in_inventory)

func _on_mouse_entered():
	print("Hovering over item:", item_name)
	GameManager.show_dialogue(item_description)  # Use the item's description

func _on_mouse_exited():
	print("Mouse exited item:", item_name)
	GameManager.hide_dialogue()  # Stop and clear the dialogue

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if is_in_inventory:
			# Start dragging the item (inventory behavior)
			print("Dragging inventory item:", item_name)
			set_process(true)  # Enable _process() for dragging
		else:
			# Handle world interaction (e.g., collecting the item)
			print("Interacting with world item:", item_name)
			collect_item()

	elif event is InputEventMouseButton and not event.pressed and is_in_inventory:
		# Stop dragging and check for valid drop (inventory behavior)
		print("Dropping inventory item:", item_name)
		set_process(false)  # Disable _process()
		if is_over_chia():
			handle_drop_on_chia()
		elif is_over_glyph_receptacle():
			handle_drop_on_glyph_receptacle()
		else:
			# Snap back to the original position
			position = original_position

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = true
			drag_offset = position - get_global_mouse_position()
			print("Started dragging:", item_name)

	elif event is InputEventMouseButton and not event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = false
			print("Stopped dragging:", item_name)

			# Check if the item is dropped on a valid target
			if is_over_chia():
				handle_drop_on_chia()
			elif is_over_glyph_receptacle():
				handle_drop_on_glyph_receptacle()
			else:
				# Snap back to original position if not dropped on a valid target
				if is_in_inventory:
					position = original_position

func _process(delta):
	# Follow the mouse while dragging (only for inventory items)
	if is_in_inventory and Input.is_mouse_button_pressed(1):  # 1 corresponds to the left mouse button
		position = get_global_mouse_position()
	if is_dragging:
		position = get_global_mouse_position() + drag_offset

func collect_item():
	print("Attempting to collect item:", item_name)
	if InventoryManager.can_add_to_inventory(item_name):
		print("Adding item to inventory:", item_name)
		InventoryManager.add_item(item_texture, item_name, item_type)
		GameManager.update_inventory_ui()
		queue_free()  # Remove the item from the world
	else:
		print(item_name, "cannot be added to the inventory.")

func is_over_chia() -> bool:
	var chia = get_tree().get_root().get_node("Path/To/Chia")  # Replace with actual path
	if chia and chia.get_global_rect().has_point(get_global_mouse_position()):
		return true
	return false

func is_over_glyph_receptacle() -> bool:
	var glyph_receptacle = get_tree().get_root().get_node("Path/To/GlyphReceptacle")  # Replace with actual path
	if glyph_receptacle and glyph_receptacle.get_global_rect().has_point(get_global_mouse_position()):
		return true
	return false

func handle_drop_on_chia():
	print("Dropped on Chia:", item_name)
	if item_type == "Ingredient":
		# Check if the item is overlapping with Chia's collision node
		var chia_collision = get_tree().get_root().get_node("Path/To/Chia/CollisionShape2D")  # Replace with actual path
		if chia_collision and chia_collision.get_global_rect().has_point(get_global_mouse_position()):
			print("Item successfully dropped on Chia:", item_name)
			GameManager.remove_from_inventory(item_texture)
			queue_free()  # Remove the item from the inventory
			GameManager.chia_node.receive_item(item_texture)  # Notify Chia
		else:
			print("Item not dropped on Chia. Returning to inventory.")
			position = original_position  # Snap back to original position

func handle_drop_on_glyph_receptacle():
	print("Dropped on Glyph Receptacle:", item_name)
	if item_type == "Glyph":
		# Check if the item is overlapping with the glyph receptacle
		var glyph_receptacle = get_tree().get_root().get_node("Path/To/GlyphReceptacle/CollisionShape2D")  # Replace with actual path
		if glyph_receptacle and glyph_receptacle.get_global_rect().has_point(get_global_mouse_position()):
			print("Item successfully dropped on Glyph Receptacle:", item_name)
			GameManager.remove_from_inventory(item_texture)
			queue_free()  # Remove the item from the inventory
		else:
			print("Item not dropped on Glyph Receptacle. Returning to inventory.")
			position = original_position  # Snap back to original position

func add_item(texture: Texture2D, item_name: String, item_type: String):
	if texture not in InventoryManager.inventory_items:
		InventoryManager.inventory_items.append({"texture": texture, "name": item_name, "type": item_type})
		print("Item added to inventory:", item_name, "Texture:", texture)
	else:
		print("Item already exists in inventory:", item_name)


