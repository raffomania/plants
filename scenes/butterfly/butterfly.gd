extends Sprite

var time = 0
func _process(dt):
    time += dt * 5
    var dx = sin(time + 2) + sin(time * 0.1) * 0.3
    if dx > 0:
        # global_scale = Vector2(-1, 1)
        set_flip_h(true)
    else:
        # global_scale = Vector2(1, 1)
        set_flip_h(true)
    translate(Vector2(dx, sin(sin(time) + sin(time * 0.3) + sin(time * 2))))
    # rotate(sin(time * 0.5) * 0.01)
