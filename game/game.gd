
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
	debug_display = get_node('hud/debug')
	set_score(1, 0)
	set_score(2, 0)
	set_process(true)
	get_tree().set_pause(true)

func debug(string):
	debug_display.set_text(str(string))
	
func set_score(player_id, score):
	""" Set the score for the given player ID """
	var label = get_node('hud/p' + str(player_id) + ' score')
	if not label:
		return
	label.set_text(str(score))
	
func update_score(player_id, diff):
	""" Modify the given player's score """
	var label = get_node('hud/p' + str(player_id) + ' score')
	if not label:
		return
	label.set_text(str(int(label.get_text()) + diff))
	

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
	if not body.is_in_group('players'):
		body.queue_free()
		return
	
	# Whatever remains, however improbable, must be a player
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
		body.set_collision_mask_bit(collision_layer_players, true)
		


func _on_player_death( player, killer ):
	""" A player is kill """
	# Show an explosion
	var boom = explosion.instance()
	boom.flipped = player.flipped
	boom.set_colour(player.fuselage_colour)
	boom.set_pos(player.get_pos())
	boom.set_velocity(player.get_linear_velocity())
	get_node('clouds').add_child(boom)
	
	# work out who to give or take points from
	var killer_id = 0
	if killer.is_in_group('players'):
		killer_id = killer.player_id
	elif killer.is_in_group('bullets'):
		killer_id = killer.firer.player_id
	if not killer_id or killer_id == player.player_id:
		# Someone made an oopsie
		update_score(player.player_id, -1)
	else:
		update_score(killer_id, 1)
	
	# Fetch me a fresh plane!
	player.set_layer_mask_bit(collision_layer_players, false)
	player.set_collision_mask_bit(collision_layer_players, false)
	player.respawn()


func _on_menu_new_game():
	# Move the players back down
	get_node("airspace/player1").respawn()
	get_node("airspace/player2").respawn()
	# Reset the scores
	get_node('hud/p1 score').set_text('0')
	get_node('hud/p2 score').set_text('0')
	# GOGOGO
	get_node('hud/score fadein').play()
	_on_menu_unpause()
	
func _on_menu_unpause():
	get_node("menu/main/continue").show()
	get_node("menu").hide()
	get_tree().set_pause(false)
	
func _on_menu_quit():
	get_tree().quit()
	

