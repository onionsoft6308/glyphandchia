extends Node

# List of progression stages, each with its own ingredient set
var progression_stages: Array[Dictionary] = [
	{"ingredients": ["res://Images/stage 1 ingredients/Beetroot.png", "res://Images/stage 1 ingredients/BellPepper.png"], "glyph": "res://Images/stage 1 ingredients/glyph test.png"},
	{"ingredients": ["res://Images/stage 2 ingredients/Cauliflower.png", "res://Images/stage 2 ingredients/Carrot.png"], "glyph": "res://Images/stage 1 ingredients/glyph test2.png"},
]

var current_stage_index: int = 0  # Tracks the current progression stage

func get_current_ingredients() -> Array:
	# Return the ingredients for the current stage
	if current_stage_index < progression_stages.size():
		return progression_stages[current_stage_index].get("ingredients", [])
	return []

func get_current_glyph() -> String:
	# Return the glyph for the current stage
	if current_stage_index < progression_stages.size():
		return progression_stages[current_stage_index].get("glyph", "")
	return ""

func advance_to_next_stage():
	# Advance to the next progression stage
	if current_stage_index < progression_stages.size() - 1:
		current_stage_index += 1
		print("Advanced to stage:", current_stage_index)
	else:
		print("No more stages. Game complete!")
