extends Area2D

@export var item_texture: Texture2D
@export var item_name: String = "Beetroot"
@export var item_description: String = "A fresh beetroot, perfect for cooking."  # New description variable

func _ready():
	# Check if this item has already been collected
	if InventoryManager.is_item_collected(item_name):
		queue_free()  # Remove the item from the scene if it's already collected

func _on_mouse_entered():
	print("Hovering over item:", item_name)
	GameManager.show_dialogue(item_description)  # Use the item's description

func _on_mouse_exited():
	print("Mouse exited item:", item_name)
	GameManager.hide_dialogue()  # Stop and clear the dialogue

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		print("Item clicked. Texture:", item_texture)
		print("Item name:", item_name)
		if InventoryManager.can_add_to_inventory(item_name):
			print("Item can be added to inventory.")
			InventoryManager.add_item(item_texture, item_name)
			GameManager.update_inventory_ui()
			queue_free()  # Remove the item from the scene
			GameManager.hide_dialogue()  # Clear the dialogue box
		else:
			print(item_name, "is not part of Chia's desired items.")
