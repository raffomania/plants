extends Sprite

var time = 0
var original_rotation

func _ready():
    original_rotation = rotation

func _process(dt):
    time += dt * 5
    var dx = sin(time + 2) + sin(time * 0.1) * 0.3
    if dx > 0:
        flip('right')
    else:
        flip('left')
    translate(Vector2(dx, sin(sin(time) + sin(time * 0.3) + sin(time * 2))))
    rotate(sin(time * 0.2) * 0.01)

func flip(side):
    if side == 'right' and not flip_h:
        set_flip_h(true)
        rotation = - rotation
    elif side == 'left' and flip_h:
        set_flip_h(false)
        rotation = - rotation

