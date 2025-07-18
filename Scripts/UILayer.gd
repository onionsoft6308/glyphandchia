# UILayer.gd
extends CanvasLayer

func _ready():
	add_to_group("ui")
	# Assign the InventoryGrid to GameManager
	GameManager.inventory_grid = $InventoryPanel/InventoryGrid

	# Find Chia anywhere in the scene tree and connect
	var chia = get_tree().get_root().find_child("Chia", true, false)
	if chia:
		chia.connect("hovered", Callable(self, "show_description"))
	else:
		print("Chia not found in scene tree!")

	# Refresh the inventory UI
	GameManager.update_inventory_ui()

	# Use a deferred call to check the current scene
	call_deferred("_check_current_scene")

func _check_current_scene():
	var current_scene = get_tree().current_scene
	if current_scene:
		print("Current scene name (via current_scene):", current_scene.name)
		if current_scene.name == "huntingscreen":
			# Show the arrow to the creature screen
			$ArrowButtonToChiafromHunting.visible = true
			$ArrowButtonToHuntingfromChia.visible = false
			$ArrowButtonToGlyph.visible = false
			$ArrowButtonToChiaFromGlyph.visible = false
			$ArrowButtonToDockfromHunting.visible = true
			$ArrowButtonToHuntingfromDock.visible = false
			print("ArrowButtonToChia and ArrowButtonToDock are now visible.")
		elif current_scene.name == "creaturescreen":
			# Show the arrows for hunting and glyph screens
			$ArrowButtonToHuntingfromChia.visible = true
			$ArrowButtonToGlyph.visible = true
			$ArrowButtonToChiafromHunting.visible = false
			
			$ArrowButtonToChiaFromGlyph.visible = false
			print("ArrowButtonToHunting and ArrowButtonToGlyph are now visible.")
		elif current_scene.name == "glyphscreen":
			# Show the arrow to the creature screen
			
			$ArrowButtonToHuntingfromChia.visible = false
			$ArrowButtonToGlyph.visible = false
			$ArrowButtonToChiafromHunting.visible = false
			$ArrowButtonToChiaFromGlyph.visible = true
			print("ArrowButtonToChiaFromGlyph is now visible.")
		elif current_scene.name == "dock":
			# Show the arrow to the hunting screen from dock
			$ArrowButtonToDockfromHunting.visible = false
			$ArrowButtonToHuntingFromDock.visible = true
			print("ArrowButtonToHuntingFromDock is now visible.")
		else:
			# Hide all arrows
			$ArrowButtonToChiafromHunting.visible = false
			$ArrowButtonToHuntingfromChia.visible = false
			$ArrowButtonToGlyph.visible = false
			
			$ArrowButtonToChiaFromGlyph.visible = false
			$ArrowButtonToDockfromHunting.visible = false
			$ArrowButtonToHuntingfromDock.visible = false
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

func _on_arrow_button_to_dock_pressed():
	# Navigate to the dock screen
	get_tree().change_scene_to_file("res://Scenes/dock.tscn")

func _on_arrow_button_to_hunting_from_dock_pressed():
	# Navigate from dock to hunting screen
	get_tree().change_scene_to_file("res://Scenes/huntingscreen.tscn")


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




func _on_inspect_icon_input_event(viewport, event, shape_idx):
	pass # Replace with function body.


func _on_conversation_icon_input_event(viewport, event, shape_idx):
	pass # Replace with function body.

func show_dialogue_with_overlay(dialogue_data, click_position, immersive = false):
	print("DEBUG: UILayer show_dialogue_with_overlay called")
	var overlay = $DialogueOverlay
	var anim_player = $AnimationPlayer
	overlay.visible = true
	anim_player.play("fade_in_overlay")
	await anim_player.animation_finished
	print("DEBUG: Calling DialoguePanel.show_dialogue")
	$DialoguePanel.show_dialogue(dialogue_data, click_position)

func show_dialogue_panel(dialogue_data, click_position):
	print("DEBUG: UILayer show_dialogue_panel called")
	$DialoguePanel.show_dialogue(dialogue_data, click_position)

func block_canoe():
	var canoe = get_tree().get_root().find_child("Canoe", true, false)
	if canoe:
		canoe.is_blocked = true

func unblock_canoe():
	var canoe = get_tree().get_root().find_child("Canoe", true, false)
	if canoe:
		canoe.is_blocked = false

func show_dungeon_experience(dungeon_json_path):
	var file = FileAccess.open(dungeon_json_path, FileAccess.READ)
	if file:
		var result = JSON.parse_string(file.get_as_text())
		if typeof(result) == TYPE_ARRAY and result.size() > 0:
			$DungeonOverlay.start_dungeon(result)
		else:
			push_error("Dungeon JSON is not a valid array or is empty!")
	else:
		push_error("Dungeon JSON file not found!")

func disable_all_arrows():
	$ArrowButtonToDock.visible = false
	$ArrowButtonToDock.disabled = true
	$ArrowButtonToHuntingFromDock.visible = false
	$ArrowButtonToHuntingFromDock.disabled = true
	# Disable other arrow buttons as needed

func enable_arrows_for_scene():
	_check_current_scene()
	$ArrowButtonToDock.disabled = false
	$ArrowButtonToHuntingFromDock.disabled = false
	# Enable other arrow buttons as needed
