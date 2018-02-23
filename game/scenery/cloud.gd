
extends Sprite

# The rect in which the cloud can respawn
var airspace
# Control cloud motion
var max_speed = 200
var min_speed = 20
var velocity

func _ready():
	# Restrict the cloud to the parent container's rect (eg. a VisibilityNotifier2D)
	airspace = get_node('..').get_rect()
	respawn()
	set_process(true)
	

func _process(delta):
	# Move the cloud a bit
	var new_pos = get_position() + (velocity * delta)
	set_position(new_pos)
	# Respawn if we've gorn orf
	if not airspace.has_point(new_pos):
		respawn()

func respawn():
	"""
		Prep the cloud to (re-)enter the scene
	"""
	var altitude = rand_range(airspace.position.y, airspace.end.y)
	# Whether to enter stage left (1) or right (-1)
	var direction = sign(randf() - 0.5)
	var new_pos
	if direction > 0:
		new_pos = Vector2(airspace.position.x, altitude)
	else:
		new_pos = Vector2(airspace.end.x, altitude)
	set_position(new_pos)
	
	# Motion
	var speed = rand_range(min_speed, max_speed)
	velocity = Vector2(direction * speed, 0)
	
