
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func set_velocity(velocity):
	""" Apply the given velocity vector to the debris """
	# By "apply" we mean "add"
	for node in get_node("debris").get_children():
		node.set_linear_velocity(node.get_linear_velocity() + velocity)

func set_colour(colour):
	""" Set the colour of the debris """
	var fuselage = get_node("debris/fuselage/sprite")
	fuselage.set_modulate(colour)
