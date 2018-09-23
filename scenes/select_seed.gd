extends ScrollContainer

func _ready():
	var plants = get_available_plants()
	for scene in plants:
		var button = Button.new()
		button.text = scene.instance().plant_name
		button.connect('pressed', self, 'plant_selected', [scene])
		$HBoxContainer.add_child(button)

func plant_selected(scene):
	$'../garden'.add_child(scene.instance())
	self.visible = false

func get_available_plants():
	var scenes = []

	var dir = Directory.new()
	dir.open('res://scenes/plants')

	dir.list_dir_begin()
	while true:
		var path = dir.get_next()
		if path == '':
			break
		elif path != '.' and path != '..':
			scenes.append(load('res://scenes/plants/' + path))
	dir.list_dir_end()

	return scenes
