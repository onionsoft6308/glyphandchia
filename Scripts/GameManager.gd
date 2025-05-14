extends Node

# References to UI elements
var inventory_grid: GridContainer
var dialogue_label: Label

@export var typing_speed: float = 0.03  # Time delay between each character (adjustable in the editor)

var typing_task_active: bool = false  # To track if a typing task is active

var dragged_item: Control = null  # The item currently being dragged
var original_position: Vector2 = Vector2.ZERO  # Original position of the dragged item

var chia_node: Node2D  # Reference to the Chia node

func _ready():
	# Connect to the node_added signal to detect when UILayer is added
	get_tree().connect("node_added", Callable(self, "_on_node_added"))

	# Try to find UILayer immediately (in case it's already in the scene)
	assign_ui_layer()

	# Dynamically find the Chia node
	var current_scene = get_tree().get_current_scene()
	if current_scene:
		chia_node = find_node_recursive(current_scene, "Chia")  # Use the custom recursive function
		if not chia_node:
			print("Error: Chia node not found in the current scene!")
	else:
		print("Error: No current scene is loaded!")

	# Refresh the inventory UI with persistent data
	print("Calling update_inventory_ui() in _ready()")
	update_inventory_ui()

# Add an item to the inventory
func add_to_inventory(texture: Texture2D, item_name: String, item_type: String):
	InventoryManager.add_item(texture, item_name, item_type)  # Add to the persistent inventory
	update_inventory_ui()

# Remove an item from the inventory
func remove_from_inventory(texture: Texture2D):
	for item in InventoryManager.inventory_items:
		if item["texture"] == texture:
			InventoryManager.inventory_items.erase(item)
			print("Removed item from inventory:", item["name"])
			update_inventory_ui()  # Refresh the inventory UI
			return
	print("Error: Item not found in inventory.")

# Update the inventory UI
func update_inventory_ui():
	if inventory_grid:
		print("Updating inventory UI...")
		# Clear the inventory grid
		for child in inventory_grid.get_children():
			child.queue_free()  # Free the child node to avoid memory leaks

		# Populate the grid with items from the persistent inventory
		for item in InventoryManager.inventory_items:
			# Load the InventoryItem.tscn scene
			var inv_item = preload("res://Scenes/InventoryItem.tscn").instantiate()
			inv_item.item_texture = item["texture"]
			inv_item.item_name = item["name"]
			inv_item.item_type = item["type"]
			inventory_grid.add_child(inv_item)
			print("Added item to inventory grid:", item["name"])
	else:
		print("Error: Inventory grid is not set.")

func show_dialogue(text: String):
	if dialogue_label:
		# Start the typing effect with the provided text
		start_typing_effect(text)
	else:
		print("Error: Dialogue label is not assigned!")

# Coroutine to handle the typing effect
func start_typing_effect(full_text: String) -> void:
	# Stop any ongoing typing effect
	typing_task_active = false
	await get_tree().process_frame  # Wait for the current frame to finish

	# Start the new typing effect
	typing_task_active = true
	dialogue_label.text = ""  # Clear the label
	for i in range(full_text.length()):
		if not typing_task_active:
			break  # Stop typing if a new task starts or is canceled
		dialogue_label.text += full_text[i]
		await get_tree().create_timer(typing_speed).timeout  # Wait before adding the next character
	typing_task_active = false  # Mark the task as complete

func hide_dialogue():
	if dialogue_label:
		typing_task_active = false  # Stop the typing effect
		dialogue_label.text = " "  # Clear the dialogue box text
	else:
		print("Error: Dialogue label is not assigned!")

func _on_inventory_item_mouse_pressed(item: TextureRect):
	dragged_item = item
	original_position = item.rect_position
	item.rect_pivot_offset = item.rect_size / 2  # Set pivot to center
	item.rect_global_position = get_viewport().get_mouse_position() - item.rect_pivot_offset
	print("Started dragging:", item.name)

func _on_inventory_item_mouse_released():
	if dragged_item:
		var mouse_pos = get_viewport().get_mouse_position()
		
		# Check if the item is over Chia
		if is_mouse_over_chia(mouse_pos):
			if dragged_item.name == "Ingredient":  # Only allow ingredients to be given to Chia
				remove_from_inventory(dragged_item.texture)
				dragged_item.queue_free()  # Remove the item from the UI
				chia_node.receive_item(dragged_item.texture)  # Notify Chia of the received item
			else:
				print("This item cannot be given to Chia.")
		
		# Snap back to the original position if no valid receptacle is found
		else:
			dragged_item.rect_position = original_position
			print("Item returned to original position:", dragged_item.name)
		
		dragged_item = null

func _process(delta):
	if dragged_item:
		dragged_item.position = get_viewport().get_mouse_position()

func is_mouse_over_chia(mouse_pos: Vector2) -> bool:
	return chia_node.get_global_rect().has_point(mouse_pos)

func is_mouse_over_glyph_receptacle(mouse_pos: Vector2) -> bool:
	# Replace with the actual logic to check if the mouse is over a glyph receptacle
	var glyph_receptacle = get_node_or_null("Area2D/GlyphReceptacle")  # Adjust the path as needed
	if glyph_receptacle:
		return glyph_receptacle.get_global_rect().has_point(mouse_pos)
	return false

func use_glyph():
	print("Glyph used!")
	# Notify Chia to provide the next set of items
	chia_node.update_thought_bubble()

func _on_node_added(node):
	if node.name == "UILayer":
		print("UILayer added to the scene tree.")
		assign_ui_layer()
	if node.name == "Chia":
		print("Chia node added to the scene tree.")
		chia_node = node

func assign_ui_layer():
	var current_scene = get_tree().get_current_scene()  # Get the root node of the current scene
	if current_scene:
		var ui_layer = find_node_recursive(current_scene, "UILayer")  # Search for UILayer recursively
		if ui_layer:
			inventory_grid = ui_layer.get_node_or_null("InventoryPanel/InventoryGrid")
			dialogue_label = ui_layer.get_node_or_null("DialogueBox/DialogueLabel")
			print("UILayer assigned successfully.")
		else:
			print("Error: UILayer not found in the current scene!")
	else:
		print("Error: No current scene is loaded!")

# Custom recursive function to find a node by name
func find_node_recursive(parent: Node, name: String) -> Node:
	if parent.name == name:
		return parent
	for child in parent.get_children():
		var found = find_node_recursive(child, name)
		if found:
			return found
	return null

func _on_inventory_item_gui_input(event: InputEvent, item: TextureRect):
	if event is InputEventMouseButton and event.pressed:
		_on_inventory_item_mouse_pressed(item)
	elif event is InputEventMouseButton and not event.pressed:
		_on_inventory_item_mouse_released()
