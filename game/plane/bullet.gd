
extends RigidBody2D

var firer

func _on_bullet_sleeping_state_changed():
	if is_sleeping():
		queue_free()
