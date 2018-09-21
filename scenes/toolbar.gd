extends HBoxContainer

onready var select_seed = $'../select_seed'

func _ready():
	pass

func _on_add_plant_pressed():
	select_seed.visible = true
