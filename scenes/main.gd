extends Node

func _ready():
  $twig.grow()

func _unhandled_input(event):
  if event.is_action_pressed('ui_cancel'):
    get_tree().quit()
