extends Node2D

# References to UI elements
onready var dialogue_box = $DialogueBox
onready var inventory_ui = $InventoryUI

func _ready():
	# Initialize the UI and set up interactive objects
	dialogue_box.text = " "  # Ensure the dialogue box starts blank but visible
	inventory_ui.text = "Inventory: "  # Ensure the inventory UI starts blank but visible
	setup_interactive_objects()

func setup_interactive_objects():
	# Connect signals for all interactive objects
	for child in get_children():
		if child is Area2D:  # Ensure it's an interactable object
			child.connect("mouse_entered", self, "_on_Object_hovered", [child])
			child.connect("mouse_exited", self, "_on_Object_unhovered", [child])
			child.connect("input_event", self, "_on_Object_clicked", [child])

func _on_Object_hovered(object):
	GameManager.apply_hover_effect(object)
	dialogue_box.text = "This is a " + object.name  # Update dialogue box text

func _on_Object_unhovered(object):
	GameManager.remove_hover_effect(object)
	dialogue_box.text = " "  # Keep the dialogue box visible but blank

func _on_Object_clicked(viewport, event, shape_idx, object):
	if event is InputEventMouseButton and event.pressed:
		GameManager.add_to_inventory(object.name)
		object.queue_free()  # Remove the object from the scene
		update_inventory_ui()

func update_inventory_ui():
	# Update the inventory UI with the current inventory
	inventory_ui.text = "Inventory: " + ", ".join(GameManager.inventory)
