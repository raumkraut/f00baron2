
extends Node2D

# The opacity of the propellor when it's not fully visible
var prop_opacity = 0.7


func _ready():
	pass


func _on_rotator_timeout():
	""" Spin the propellor """
	var prop = get_node('prop')
	if prop.get_opacity() == prop_opacity:
		prop.set_opacity(1)
	else:
		prop.set_opacity(prop_opacity)


func set_colour(colour):
	""" Set the colour of the fuselage and wings """
	var fuselage = get_node('fuselage')
	var wings = get_node('wings')
	fuselage.set_modulate(colour)
	wings.set_modulate(colour)
	
