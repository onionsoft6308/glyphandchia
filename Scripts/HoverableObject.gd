extends Area2D

@export var object_name: String = "Object of Interest"  # Name of the object (displayed in dialogue)
@export var can_be_collected: bool = false  # Determines if the object can be added to the inventory
@export var item_texture: Texture2D  # Optional texture for collectible items

func _ready():
	# Connect signals for mouse interactions
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))
	connect("input_event", Callable(self, "_on_input_event"))

func _on_mouse_entered():
	# Show the object's name in the dialogue box
	GameManager.show_dialogue(object_name)

func _on_mouse_exited():
	# Hide the dialogue when the mouse exits
	GameManager.hide_dialogue()

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if can_be_collected:
			if InventoryManager.can_add_to_inventory(object_name):
				if not InventoryManager.is_item_collected(object_name):
					InventoryManager.add_item(item_texture, object_name)
					GameManager.update_inventory_ui()
					InventoryManager.mark_item_collected(object_name)
					queue_free()
					GameManager.hide_dialogue()
			else:
				print(object_name, "is not part of Chia's desired items.")
		else:
			print(object_name, "is not collectible.")
