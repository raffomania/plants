extends Sprite

var selected_plant_scene

func _ready():
	pass

func _input(event):
	if visible:
		if event is InputEventMouseMotion:
			position = event.position
		elif event is InputEventMouseButton and event.pressed:
			var plant = selected_plant_scene.instance()
			plant.position = $'../garden'.get_global_transform().xform_inv(global_position)
			$'../garden'.add_child(plant)
			visible = false

func _on_select_seed_seed_selected(scene):
	selected_plant_scene = scene
	visible = true
