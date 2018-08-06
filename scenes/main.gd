extends Node

func _ready():
	if OS.get_name()=="HTML5":
		OS.set_window_maximized(true)
		
func _unhandled_input(event):
  if event.is_action_pressed('ui_cancel'):
    get_tree().quit()
