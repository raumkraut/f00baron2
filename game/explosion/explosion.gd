
extends Node2D

export var flipped = false

var extra_velocity = Vector2(0, 0)

func _ready():
	# Customise the debris, depending on the situation
	for node in get_node('debris').get_children():
		if flipped:
			# Flip the position and velocity when appropriate
			node.set_pos(node.get_pos() * Vector2(-1, 1))
			node.set_linear_velocity(node.get_linear_velocity() * Vector2(-1, 1))
		# Add the original object's "terminal" velocity
		node.set_linear_velocity(node.get_linear_velocity() + extra_velocity)

func set_velocity(velocity):
	""" Apply the given velocity vector to the debris """
	extra_velocity = velocity

func set_colour(colour):
	""" Set the colour of the debris """
	var fuselage = get_node("debris/fuselage/sprite")
	fuselage.set_modulate(colour)
