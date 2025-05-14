extends Area2D

@export var scene_path: String = ""

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if scene_path != "":
			get_tree().change_scene_to_file(scene_path)
		else:
			print("No scene_path set for SceneChangeOnClick!")
