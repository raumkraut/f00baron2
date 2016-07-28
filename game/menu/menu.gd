
extends Control

signal unpause
signal new_game
signal quit

export var default_colour = Color('ff0000')
export var active_colour = Color('ff8800')

func _ready():
	for node in get_node('main').get_children():
		node.set_modulate(default_colour)
		node.connect("focus_enter", self, '_on_menu_item_focus', [node])
		node.connect("focus_exit", self, '_on_menu_item_unfocus', [node])
		node.connect("mouse_enter", self, '_on_menu_item_hover', [node])
	
# Hover/focus effects without needing additional textures
func _on_menu_item_focus(item):
	item.set_modulate(active_colour)
func _on_menu_item_unfocus(item):
	item.set_modulate(default_colour)
func _on_menu_item_hover(item):
	item.grab_focus()


func _on_menu_visibility_changed():
	if is_visible():
		# Reset everything, and focus the first visible item
		var focussed = false
		for node in get_node("main").get_children():
			node.set_modulate(default_colour)
			if not focussed and node.is_visible():
				node.grab_focus()
				focussed = true
	

func _on_continue_pressed():
	emit_signal('unpause')

func _on_new_game_pressed():
	emit_signal('new_game')

func _on_exit_pressed():
	emit_signal('quit')
	
