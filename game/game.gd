
extends Node2D

var debug_display
onready var explosion = preload('res://explosion/explosion.tscn')

# Physics collision layers
const collision_layer_players = 0
const collision_layer_bullets = 1
const collision_layer_scenery = 10
const collision_layer_debris = 11


func _init():
	randomize()

func _ready():
	set_process(true)
	debug_display = get_node('hud/debug')

func debug(string):
	debug_display.set_text(str(string))
	
func _process(delta):
	# Tell the planes what to do
	var player1 = get_node("airspace/player1")
	if Input.is_action_pressed("p1_throttle_up"):
		player1.set_throttle(1)
	elif Input.is_action_pressed("p1_throttle_down"):
		player1.set_throttle(0)
	if Input.is_action_pressed("p1_clockwise"):
		player1.set_pitching(1)
	elif Input.is_action_pressed("p1_anticlockwise"):
		player1.set_pitching(-1)
	else:
		player1.set_pitching(0)
	player1.set_firing(Input.is_action_pressed("p1_fire"))
	
	# Player 2
	var player2 = get_node("airspace/player2")
	if Input.is_action_pressed("p2_throttle_up"):
		player2.set_throttle(1)
	elif Input.is_action_pressed("p2_throttle_down"):
		player2.set_throttle(0)
	if Input.is_action_pressed("p2_clockwise"):
		player2.set_pitching(1)
	elif Input.is_action_pressed("p2_anticlockwise"):
		player2.set_pitching(-1)
	else:
		player2.set_pitching(0)
	player2.set_firing(Input.is_action_pressed("p2_fire"))
	

func _on_airspace_body_exit( body ):
	# Something physics-al has left the arena
	var arena = get_node("airspace/collider")
	var half_width = arena.get_shape().get_extents().x
	var left = arena.get_pos().x - half_width
	var right = arena.get_pos().x + half_width
	var pos = body.get_pos()
	if pos.x < left:
		pos.x = right
		body.set_pos(pos)
	elif pos.x > right:
		pos.x = left
		body.set_pos(pos)
	

func _on_runway_body_exit( body ):
	if body.is_in_group('players'):
		body.armed = true
		# Set the airborne player to collidable
		body.set_layer_mask_bit(collision_layer_players, true)
		


func _on_player_death( player, killer ):
	""" A player is kill """
	# Show an explosion
	var boom = explosion.instance()
	boom.set_colour(player.fuselage_colour)
	boom.set_pos(player.get_pos())
	boom.set_velocity(player.get_linear_velocity())
	boom.flipped = player.flipped
	get_node('clouds').add_child(boom)
	## TODO: SCORE!
	# Fetch me a fresh plane!
	player.set_layer_mask_bit(collision_layer_players, false)
	player.respawn()
