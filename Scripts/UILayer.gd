# UILayer.gd
extends CanvasLayer

func _ready():
	# Assign the InventoryGrid to GameManager
	
	GameManager.inventory_grid = $InventoryPanel/InventoryGrid


	# Refresh the inventory UI
	GameManager.update_inventory_ui()

	# Use a deferred call to check the current scene
	call_deferred("_check_current_scene")

func _check_current_scene():
	print("DEBUG: _check_current_scene() called")
	var current_scene = get_tree().current_scene
	if current_scene:
		print("Current scene name (via current_scene):", current_scene.name)
		if current_scene.name == "huntingscreen":
			# Show the arrow to the creature screen
			$ArrowButtonToChia.visible = true
			$ArrowButtonToHunting.visible = false
			$ArrowButtonToGlyph.visible = false
			$ArrowButtonToChiaFromGlyph.visible = false
			print("ArrowButtonToChia is now visible.")
		elif current_scene.name == "creaturescreen":
			# Show the arrows for hunting and glyph screens
			$ArrowButtonToHunting.visible = true
			$ArrowButtonToGlyph.visible = true
			$ArrowButtonToChia.visible = false
			
			$ArrowButtonToChiaFromGlyph.visible = false
			print("ArrowButtonToHunting and ArrowButtonToGlyph are now visible.")
		elif current_scene.name == "glyphscreen":
			# Show the arrow to the creature screen
			
			$ArrowButtonToHunting.visible = false
			$ArrowButtonToGlyph.visible = false
			$ArrowButtonToChia.visible = false
			$ArrowButtonToChiaFromGlyph.visible = true
			print("ArrowButtonToChiaFromGlyph is now visible.")
		else:
			# Hide all arrows
			$ArrowButtonToChia.visible = false
			$ArrowButtonToHunting.visible = false
			$ArrowButtonToGlyph.visible = false
			
			$ArrowButtonToChiaFromGlyph.visible = false
			print("All arrows are now hidden.")
	else:
		print("ERROR: current_scene is null")

func _on_arrow_button_to_hunting_pressed():
	# Navigate to the hunting screen
	get_tree().change_scene_to_file("res://Scenes/huntingscreen.tscn")

func _on_arrow_button_to_glyph_pressed():
	# Navigate to the glyph screen
	get_tree().change_scene_to_file("res://Scenes/glyphscreen.tscn")

func _on_arrow_button_to_chia_pressed():
	# Navigate to the creature screen
	get_tree().change_scene_to_file("res://Scenes/creaturescreen.tscn")



func _on_arrow_button_to_chia_from_glyph_pressed():
	# Navigate to the creature screen
	get_tree().change_scene_to_file("res://Scenes/creaturescreen.tscn")


func _on_item_mouse_exited():
	pass # Replace with function body.


func _on_non_collectible_mouse_entered():
	pass # Replace with function body.


func _on_non_collectible_mouse_exited():
	pass # Replace with function body.


func _on_non_collectible_input_event(viewport, event, shape_idx):
	pass # Replace with function body.


func _on_non_collectible_mouse_shape_entered(shape_idx):
	pass # Replace with function body.


func _on_non_collectible_mouse_shape_exited(shape_idx):
	pass # Replace with function body.


func _on_exit_button_pressed():
	pass # Replace with function body.
