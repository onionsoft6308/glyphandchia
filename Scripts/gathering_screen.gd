extends Node2D

# References to UI elements
var dialogue_box: Label  # Reference to the DialogueLabel node
var inventory_ui: GridContainer  # Reference to the InventoryGrid node

func _ready():
	# Locate the UILayer instance in the scene
	var ui_layer = get_node("UILayer")  # Adjust the path if necessary
	if ui_layer:
		dialogue_box = ui_layer.get_node("DialogueBox/DialogueLabel")  # Adjust the path if necessary
		inventory_ui = ui_layer.get_node("InventoryPanel/InventoryGrid")  # Adjust the path if necessary
	else:
		print("Error: UILayer not found in the scene!")

	# Initialize the UI
	if dialogue_box:
		dialogue_box.text = " "  # Ensure the dialogue box starts blank but visible
	if inventory_ui:
		print("Inventory UI found!")  # Debugging to confirm the inventory UI is found

	# Set up signals for manually placed interactive objects
	setup_interactive_objects()

func setup_interactive_objects():
	# Connect signals for all manually placed interactive objects
	for child in get_children():
		if child is Area2D and child.has_method("get_item_name"):  # Ensure it's an interactable object
			child.connect("mouse_entered", Callable(self, "_on_Object_hovered").bind(child))
			child.connect("mouse_exited", Callable(self, "_on_Object_unhovered").bind(child))
			child.connect("input_event", Callable(self, "_on_Object_clicked").bind(child))

func _on_Object_hovered(object):
	if dialogue_box:
		GameManager.apply_hover_effect(object)
		dialogue_box.text = "This is a " + object.get_item_name()  # Update dialogue box text

func _on_Object_unhovered(object):
	if dialogue_box:
		GameManager.remove_hover_effect(object)
		dialogue_box.text = " "  # Keep the dialogue box visible but blank

func _on_Object_clicked(viewport, event, shape_idx, object):
	if event is InputEventMouseButton and event.pressed:
		var item_name = object.get_item_name()
		if InventoryManager.can_add_to_inventory(item_name):  # Validate against Chia's ingredients
			GameManager.add_to_inventory(object.texture, item_name, "Ingredient")  # Pass the item type as the third argument
			object.queue_free()  # Remove the object from the scene
			update_inventory_ui()
		else:
			print(item_name, "is not part of Chia's desired items.")

func update_inventory_ui():
	# Update the inventory UI with the current inventory
	if inventory_ui:
		# Get the current items already in the grid
		var existing_items = []
		for child in inventory_ui.get_children():
			if child is TextureRect and child.texture:
				existing_items.append(child.texture)

		# Add only new items to the grid
		for item in InventoryManager.inventory_items:
			if item["texture"] not in existing_items:
				var item_icon = TextureRect.new()
				item_icon.texture = item["texture"]
				item_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				item_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				item_icon.set_custom_minimum_size(Vector2(48, 48))  # Ensure proper size
				inventory_ui.add_child(item_icon)
				print("Added item to inventory UI:", item["name"], "Texture:", item["texture"].resource_path)
	else:
		print("Error: Inventory UI not found!")
