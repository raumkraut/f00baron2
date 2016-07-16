
extends Node2D

# The opacity of the propellor when it's not fully visible
var prop_opacity = 0.7
# Flight controls
var throttle = 0
var pitching = 0
var firing = false
# Flight parameters
var drag = 0.98
var vertical_drag = 0.4
var lift = 1000
var turn_rate = 3
var thrust = 300
var velocity = Vector2()
var stall_speed = 100

func _ready():
	set_process(true)

func _process(delta):
	# Move
	set_pos(get_pos() + (velocity * delta))
	# Rotate
	set_rot(get_rot() + (pitching * turn_rate * delta))
	# Accelerations and decelerations
	var facing = Vector2(1, 0).rotated(get_rot())
	var speed = velocity.dot(facing) * drag
	var belly = Vector2(0, 1).rotated(get_rot())
	var belly_speed = velocity.dot(belly) * vertical_drag
	velocity = Vector2(speed + (throttle * thrust * delta), belly_speed).rotated(get_rot())
	
	## TODO: Shoot

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
	
func set_throttle(brum):
	""" Full throttle or no throttle, nothing else """
	throttle = float(brum)
	
func set_pitching(neeyow):
	""" You're either with the clock or against the clock """
	if neeyow == 0:
		pitching = 0
	else:
		pitching = sign(neeyow)
	
func set_firing(dakka):
	""" Dakka dakka dakka! """
	firing = bool(dakka)
	
