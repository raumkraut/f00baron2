
extends Node2D

signal unpause
signal new_game
signal quit


func _on_menu_visibility_changed():
	if is_visible():
		for node in get_node("main").get_children():
			if node.is_visible():
				node.grab_focus()
				break

func _on_continue_pressed():
	emit_signal('unpause')

func _on_new_game_pressed():
	emit_signal('new_game')

func _on_exit_pressed():
	emit_signal('quit')
	
