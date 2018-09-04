extends Sprite

export(Color) var sun_up
export(Color) var sun_down
export(float) var speed

func _process(dt):
    rotate(dt * speed)
    var norm_rotation = fmod(rotation, 2 * PI)
    var distance_from_top = min(norm_rotation, (2 * PI) - norm_rotation) / PI
    get_node('/root/root/bg').material.set_shader_param('color', sun_up.linear_interpolate(sun_down, distance_from_top))

