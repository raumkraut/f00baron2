
extends RigidBody2D

func _on_bullet_sleeping_state_changed():
	if is_sleeping():
		queue_free()
