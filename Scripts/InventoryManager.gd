extends Node

# Persistent inventory items
var inventory_items: Array = []
# Track collected items by their unique names
var collected_items: Dictionary = {}
var chia_desired_items: Array = []  # Items Chia wants for the current level

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Add an item to the inventory
func add_item(texture: Texture2D, item_name: String):
	if texture not in inventory_items:
		inventory_items.append(texture)
		print("Item added to inventory:", texture)

# Remove an item from the inventory
func remove_item(texture: Texture2D):
	if texture in inventory_items:
		inventory_items.erase(texture)
		print("Item removed from inventory:", texture)

# Mark an item as collected
func mark_item_collected(item_name: String):
	collected_items[item_name] = true
	print("Item marked as collected:", item_name)

# Check if an item has been collected
func is_item_collected(item_name: String) -> bool:
	return collected_items.get(item_name, false)

func set_chia_desired_items(items: Array):
	chia_desired_items = items

func can_add_to_inventory(item_name: String) -> bool:
	return item_name in ProgressionManager.get_current_ingredients()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
