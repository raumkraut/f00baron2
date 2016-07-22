
extends Node2D

export var min_flutter_time = 0.1
export var max_flutter_time = 1.0
export var colour = Color('ffffff')

func _ready():
	set_colour(colour)
	

func set_colour(colour):
	get_node('flag').set_modulate(colour)

func _on_flutter_timeout():
	var flag = get_node("flag")
	flag.flip_v = not flag.flip_v
	# Randomise next flutter
	get_node("flag/flutter").set_wait_time(rand_range(min_flutter_time, max_flutter_time))
	
