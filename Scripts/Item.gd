extends Area2D

@export var item_texture: Texture2D
@export var item_name: String = "Mystery Item"

func _ready():
	# Check if this item has already been collected
	if InventoryManager.is_item_collected(item_name):
		queue_free()  # Remove the item from the scene if it's already collected

func _on_mouse_entered():
	GameManager.show_dialogue(item_name)  # Show the item's name in the dialogue box

func _on_mouse_exited():
	GameManager.hide_dialogue()  # Hide the dialogue when the mouse exits

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		print("Item clicked. Texture:", item_texture)
		if not InventoryManager.is_item_collected(item_name):
			InventoryManager.add_item(item_texture, item_name)  # Add to the persistent inventory
			GameManager.update_inventory_ui()  # Update the UI
			InventoryManager.mark_item_collected(item_name)  # Mark the item as collected
			queue_free()  # Remove the item from the scene
			GameManager.hide_dialogue()  # Hide the dialogue text when the item is clicked
