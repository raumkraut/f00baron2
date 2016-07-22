
extends Node2D

export var flipped = false

func _ready():
	# Flip the debris when appropriate
	if flipped:
		for node in get_node('debris').get_children():
			node.set_linear_velocity(node.get_linear_velocity() * Vector2(-1, 1))

func set_velocity(velocity):
	""" Apply the given velocity vector to the debris """
	# By "apply" we mean "add"
	for node in get_node("debris").get_children():
		node.set_linear_velocity(node.get_linear_velocity() + velocity)

func set_colour(colour):
	""" Set the colour of the debris """
	var fuselage = get_node("debris/fuselage/sprite")
	fuselage.set_modulate(colour)
