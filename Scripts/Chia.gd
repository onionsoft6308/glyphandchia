extends Node2D

@export var thought_bubble: Sprite2D  # Reference to the thought bubble sprite
@export var thought_items_container: GridContainer  # Container for item sprites

var current_ingredients: Array = []  # Ingredients for the current stage
var received_ingredients: Array = []  # Ingredients received from the player

func _ready():
	update_thought_bubble()

func update_thought_bubble():
	# Clear existing items in the thought bubble
	for child in thought_items_container.get_children():
		thought_items_container.remove_child(child)
		child.queue_free()

	# Get the current ingredients from the ProgressionManager
	current_ingredients = ProgressionManager.get_current_ingredients()

	# Add new items to the thought bubble
	for ingredient_path in current_ingredients:
		var ingredient_texture = load(ingredient_path)
		if ingredient_texture:
			var item_sprite = TextureRect.new()
			item_sprite.texture = ingredient_texture
			item_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			item_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			item_sprite.set_custom_minimum_size(Vector2(32, 32))
			thought_items_container.add_child(item_sprite)
		else:
			print("Failed to load ingredient texture:", ingredient_path)

func receive_item(item_texture: Texture2D):
	if item_texture.resource_path in current_ingredients:
		received_ingredients.append(item_texture.resource_path)
		current_ingredients.erase(item_texture.resource_path)
		print("Received ingredient:", item_texture.resource_path)
		update_thought_bubble()  # Refresh the thought bubble
		if current_ingredients.size() == 0:
			give_glyph()
	else:
		print("This item is not part of the current ingredient set.")

func give_glyph():
	print("All ingredients delivered! Giving glyph...")
	var glyph_path = ProgressionManager.get_current_glyph()
	var glyph_texture = load(glyph_path)
	if glyph_texture:
		var glyph_drop = preload("res://Scenes/GlyphDrop.tscn").instantiate()
		glyph_drop.glyph_texture = glyph_texture
		glyph_drop.global_position = Vector2(400, 300)  # Set to your desired screen position
		get_tree().get_root().add_child(glyph_drop)
		# Optionally trigger dialogue/cutscene here
	ProgressionManager.advance_to_next_stage()
	update_thought_bubble()
