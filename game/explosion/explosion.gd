
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func set_colour(colour):
	""" Set the colour of the debris """
	var fuselage = get_node("fuselage/sprite")
	fuselage.set_modulate(colour)
