extends Sprite

export(float, 0, 10) var glow

func _ready():
    modulate = modulate * glow

func _process(dt):
    rotate(dt * 0.1)

