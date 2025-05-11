extends Node

# References to UI elements
var inventory_grid: GridContainer
var dialogue_label: Label

@export var typing_speed: float = 0.03  # Time delay between each character (adjustable in the editor)

var typing_task_active: bool = false  # To track if a typing task is active

var dragged_item: TextureRect = null  # The item being dragged
var original_position: Vector2 = Vector2.ZERO  # Original position of the dragged item

var chia_node: Node2D  # Reference to the Chia node

func _ready():
	# Ensure inventory_grid is assigned
	if not inventory_grid:
		print("Error: inventory_grid is not assigned!")
		return

	# Assign the Chia node
	chia_node = get_node("creaturescreen/Chia")  # Replace with the actual path to the Chia node

	# Refresh the inventory UI with persistent data
	print("Calling update_inventory_ui() in _ready()")
	update_inventory_ui()

# Add an item to the inventory
func add_to_inventory(texture: Texture2D, item_name: String):
	InventoryManager.add_item(texture, item_name)  # Add to the persistent inventory
	update_inventory_ui()

# Remove an item from the inventory
func remove_from_inventory(texture: Texture2D):
	InventoryManager.remove_item(texture)  # Remove from the persistent inventory
	update_inventory_ui()

# Update the inventory UI
func update_inventory_ui():
	if inventory_grid:
		print("Updating inventory UI...")
		# Clear the inventory grid
		for child in inventory_grid.get_children():
			inventory_grid.remove_child(child)
			child.queue_free()  # Free the child node to avoid memory leaks

		# Populate the grid with items from the persistent inventory
		for texture in InventoryManager.inventory_items:
			var item_icon = TextureRect.new()
			item_icon.texture = texture
			item_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			item_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			item_icon.set_custom_minimum_size(Vector2(48, 48))
			inventory_grid.add_child(item_icon)
			print("Item loaded into inventory grid:", item_icon)
	else:
		print("Error: Inventory grid is not set.")

# Show dialogue in the dialogue label with a typing effect
func show_dialogue(text: String) -> void:
	if dialogue_label:
		# Stop any ongoing typing effect
		if typing_task_active:
			typing_task_active = false  # Stop the current typing task
			dialogue_label.text = ""  # Clear the label text
		
		# Start the typing effect
		await start_typing_effect(text)
	else:
		print("Error: Dialogue label is not set.")

# Coroutine to handle the typing effect
func start_typing_effect(full_text: String) -> void:
	typing_task_active = true
	dialogue_label.text = ""  # Clear the label
	for i in range(full_text.length()):
		if not typing_task_active:
			break  # Stop typing if a new task starts
		dialogue_label.text += full_text[i]
		await get_tree().create_timer(typing_speed).timeout  # Wait before adding the next character
	typing_task_active = false  # Mark the task as complete

# Hide dialogue in the dialogue label
func hide_dialogue():
	if dialogue_label:
		# Stop any ongoing typing effect and clear the text
		typing_task_active = false
		dialogue_label.text = ""  # Clear the dialogue text
	else:
		print("Error: Dialogue label is not set.")

func _on_inventory_item_mouse_pressed(item: TextureRect):
	dragged_item = item
	original_position = item.rect_position
	item.rect_pivot_offset = item.rect_size / 2  # Set pivot to center
	item.rect_global_position = get_viewport().get_mouse_position() - item.rect_pivot_offset

func _on_inventory_item_mouse_released():
	if dragged_item:
		var mouse_pos = get_viewport().get_mouse_position()
		if is_mouse_over_chia(mouse_pos):
			remove_from_inventory(dragged_item.texture)
			dragged_item.queue_free()  # Remove the item from the UI
			chia_node.receive_item(dragged_item.texture)  # Notify Chia of the received item
		else:
			dragged_item.rect_position = original_position  # Reset position
		dragged_item = null

func _process(delta):
	if dragged_item:
		dragged_item.rect_global_position = get_viewport().get_mouse_position() - dragged_item.rect_pivot_offset

func is_mouse_over_chia(mouse_pos: Vector2) -> bool:
	return chia_node.get_global_rect().has_point(mouse_pos)

func use_glyph():
	print("Glyph used!")
	# Notify Chia to provide the next set of items
	chia_node.update_thought_bubble()
