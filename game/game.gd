
extends Node2D

func _init():
	randomize()

func _ready():
	# Set the player colours
	get_node("airspace/player1").set_colour('ff0000')
	get_node("airspace/player2").set_colour('aa88ff')
	
