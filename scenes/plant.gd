extends Node2D

export(Color) var twig_color
export(Color) var leaf_color
export(int) var twig_length
export(int) var twig_thickness
export(int) var gap
export(float, 0, 1) var straightness
export(float, 0, 1) var branchiness
export(float, 0, 1) var leafiness
export(float, 0, 1) var sun_affinity
export(bool) var do_randomize

var size = 1
var end_position
var actual_leafiness
var resting_rotation

func _process(dt):
  var right = PI / 2
  var sway_direction = right - global_rotation
  var wind_influence = actual_leafiness * rand_range(0, 3)
  var resting_direction = resting_rotation - rotation
  rotate(dt * sway_direction * wind_influence + dt * resting_direction)

func grow():
  if do_randomize:
    randomize()

  resting_rotation = rotation
  end_position = Vector2(0, - twig_length * size * 2)
  actual_leafiness = leafiness * (1 - size)
  if size > 0.2:
    if randf() < branchiness:
      spawn_children(2)
    else:
      spawn_children(1)
  add_twig_line()
  for i in range(round(actual_leafiness * 10)):
    add_leaf(i)

func add_twig_line():
  var line = Line2D.new()
  line.default_color = twig_color.darkened(size * 0.2)
  line.width = twig_thickness * size
  line.add_point(Vector2(0, 0))
  line.add_point(end_position)
  add_child(line)

func add_leaf(zindex):
  var scene = load("res://scenes/leaf.tscn")
  var leaf = scene.instance()
  var position = randf() * end_position
  leaf.translate(position)
  leaf.rotate(randf() * PI * 2)
  leaf.modulate = leaf_color.lightened(randf() * 0.2)
  var leaf_size = rand_range(0.8, 1)
  leaf.apply_scale(Vector2(leaf_size, leaf_size))
  leaf.add_to_group('leafs')
  add_child(leaf)

func spawn_children(count):
  for i in range(count):
    var scene = load("res://scenes/twig.tscn")
    var twig = scene.instance()
    set_child_props(twig, count, i)
    add_child(twig)

    twig.grow()

func set_child_props(twig, num_children, child_index):
  twig.twig_thickness = twig_thickness
  twig.twig_length = twig_length
  twig.gap = gap
  twig.branchiness = branchiness
  twig.straightness = straightness
  twig.leafiness = leafiness
  twig.do_randomize = do_randomize
  twig.leaf_color = leaf_color
  twig.twig_color = twig_color
  twig.sun_affinity = sun_affinity

  twig.size = size * rand_range(0.8, 0.99)

  twig.position = end_position + Vector2(0, - gap)
  var upwards = 0
  var upward_correction = (upwards - global_rotation) * sun_affinity
  var crookedness = (1 - straightness)
  var sibling_range = PI * 0.75 * crookedness
  var sibling_offset = 0
  if num_children > 1:
    var offset_ratio = child_index / (num_children - 1)
    sibling_offset = (offset_ratio * sibling_range) - sibling_range/2
  var random_range = PI * 0.5 * crookedness
  var random_offset = rand_range(-random_range/2, random_range/2)
  var rotation_factor = upward_correction + sibling_offset + random_offset
  twig.rotate(rotation_factor)
  resting_rotation = rotation
