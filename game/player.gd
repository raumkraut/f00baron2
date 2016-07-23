
extends RigidBody2D

# Initial params
onready var spawn_pos = get_pos()
onready var spawn_rot = get_rot()
onready var undercarriage_shapes = range(get_node('undercarriage').get_collision_object_first_shape(), get_node('undercarriage').get_collision_object_last_shape() + 1)
onready var bullet = preload('res://plane/bullet.tscn')
export var flipped = false
# Personalisation
export var fuselage_colour = Color('ffffff')
# Flight controls
var throttle = 0
var pitching = 0
# Aircraft parameters
var perpendicular_damp = 8
var turn_rate = 4
var min_turn_rate = 0.6
var thrust = 160
var stall_speed = 40
var full_lift_speed = 200
var fair_game = false
var armed = false
var firing = false
var reloading = false
var muzzle_velocity = Vector2(600, 0)
# These determine the max impact we can endure
var undercarriage_strength = 40
var airframe_strength = 10

signal player_death(player, killer)


func _ready():
	set_colour(fuselage_colour)
	# RigidBody2D cannot into scaling,
	# so we need to flip when asked to
	if flipped:
		for node in get_children():
			if node.has_method('set_scale'):
				node.set_scale(node.get_scale() * Vector2(1, -1))
	set_fixed_process(true)
	

func set_colour(colour):
	""" Set the colour of this player """
	fuselage_colour = Color(colour)
	# The plane is all that matters ATM
	return get_node('plane').set_colour(fuselage_colour)

func respawn():
	""" Restore the player to its initial state """
	fair_game = false
	armed = false
	firing = false
	reloading = false
	get_node("invulnerability").start()
	throttle = 0
	pitching = 0
	set_pos(spawn_pos)
	set_rot(spawn_rot)
	set_applied_force(Vector2())
	set_linear_velocity(Vector2())
	set_angular_velocity(0)

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
	pitching = neeow
	
func set_firing(dakka):
	""" Dakkadakka! """
	firing = bool(dakka)
	
func shooty_mcshootface():
	""" SHOOOOOOOOT!" """
	var barrel = get_node('barrel')
	var pew = bullet.instance()
	pew.add_to_group('bullets')
	pew.set_pos(get_pos() + barrel.get_pos().rotated(get_rot()))
	pew.set_linear_velocity(get_linear_velocity() + muzzle_velocity.rotated(get_rot()))
	# Is there a better place to put bullets?
	get_node('..').add_child(pew)
	

func _fixed_process(delta):
	if armed and firing and not reloading:
		reloading = true
		shooty_mcshootface()
		get_node('reloading').start()
	
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
	if abs(speed) > 1:
		# Only turn after we've started moving
		set_angular_velocity(pitching * max(turn_rate * lift_effect, min_turn_rate))
	# Re-angle the forward velocity
	velocity = velocity.rotated(-state.get_angular_velocity() * delta * lift_effect)
	# Apply extra drag perpendicular to the facing
	var perp_drag = perpendicular_damp * delta * lift_effect
	var perp_reaction = facing.tangent()
	var perp_speed = velocity.dot(perp_reaction)
	perp_reaction *= -perp_speed * perp_drag
	state.set_linear_velocity(velocity + perp_reaction)
	

func _on_player_body_enter_shape( body_id, body, body_shape, local_shape ):
	""" The player has hit something, or vice versa """
	if not fair_game:
		# Not sportsmanlike
		return
	
	# Work out the impact velocity
	var impact_v = get_linear_velocity()
	if body.is_type('StaticBody2D'):
		impact_v -= body.get_constant_linear_velocity()
	elif body.is_type('RigidBody2D'):
		impact_v -= body.get_linear_velocity()
		
	if body.is_in_group('floor'):
		# Only direct impact speed matters against floors
		impact_v = Vector2(impact_v.dot(Vector2(0, 1)), 0)
		
	# Work out the toughness of the bit that was hit
	var strength
	if local_shape in undercarriage_shapes:
		strength = undercarriage_strength
	else:
		strength = airframe_strength
	
	if impact_v.length_squared() > pow(strength, 2):
		emit_signal('player_death', self, body)
		
	

func _on_invulnerability_timeout():
	fair_game = true

func _on_reloading_timeout():
	reloading = false
