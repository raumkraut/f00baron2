
extends RigidBody2D

# Flight controls
var throttle = 0
var pitching = 0
var firing = false
# Flight parameters
var perpendicular_damp = 12
var turn_rate = 3
var thrust = 150
var stall_speed = 40
var full_lift_speed = 200


func _ready():
	# RigidBody2D cannot into scaling,
	# so we need to flip the graphic when asked to
	var plane = get_node('plane')
	plane.set_scale(plane.get_scale() * get_scale())
	set_scale(Vector2(1, 1))
	

func set_colour(colour):
	""" Set the colour of this player """
	# The plane is all that matters ATM
	return get_node('plane').set_colour(colour)

func set_throttle(brum):
	""" Full speed ahead! Or... not. """
	if brum < 0:
		brum = 0
	elif brum > 1:
		brum = 1
	throttle = float(brum)
	
func set_pitching(neeow):
	""" Pull up! Pull up! Dive! Dive! """
	if neeow < -1:
		neeow = -1
	elif neeow > 1:
		neeow = 1
	set_angular_velocity(neeow * turn_rate)
	
func set_firing(dakka):
	""" Dakkadakka! """
	firing = bool(dakka)
	

func _integrate_forces(state):
	if state.is_sleeping():
		return
	
	var delta = state.get_step()
	var velocity = state.get_linear_velocity()
	var facing = Vector2(1, 0).rotated(get_rot())
	# Standard engine force
	set_applied_force(facing * throttle * thrust)
	
	# How fast we're going determines how well we manoeuvre
	var speed = velocity.dot(facing)
	var lift_effect = min(1, max(0, speed - stall_speed) / (full_lift_speed - stall_speed))
	# Re-angle the forward velocity
	velocity = velocity.rotated(-state.get_angular_velocity() * delta * lift_effect)
	# Apply extra drag perpendicular to the facing
	var perp_drag = perpendicular_damp * delta * lift_effect
	var perp_reaction = facing.tangent()
	var perp_speed = velocity.dot(perp_reaction)
	perp_reaction *= -perp_speed * perp_drag
	state.set_linear_velocity(velocity + perp_reaction)
	

## TODO: Shooooooooooot!