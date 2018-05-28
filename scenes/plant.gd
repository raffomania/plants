extends Node2D

export(Color) var twig_color
export(int) var twig_length
export(int) var twig_thickness
export(int) var gap
export(float, 0, 1) var straightness
export(float, 0, 1) var branchiness
export(float, 0, 1) var leafiness
export(bool) var do_randomize

var size = 1
var end_position

func grow():
  if do_randomize:
    randomize()
  end_position = Vector2(0, - twig_length * 2)
  if size > 0.2:
    if randf() < branchiness:
      spawn_children(2)
    else:
      spawn_children(1)
  add_twig_line()
  var actual_leafiness = leafiness * (1 - size)
  for i in range(round(actual_leafiness * 10)):
    add_leaf()

func add_twig_line():
  var line = Line2D.new()
  line.default_color = twig_color
  line.width = twig_thickness * size
  line.add_point(Vector2(0, 0))
  line.add_point(end_position)
  add_child(line)

func add_leaf():
  var scene = load("res://scenes/leaf.tscn")
  var leaf = scene.instance()
  var position = randf() * end_position
  leaf.translate(position)
  leaf.rotate(randf() * PI * 2)
  var leaf_size = rand_range(0.8, 1)
  leaf.apply_scale(Vector2(leaf_size, leaf_size))
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

  twig.size = size * 0.9

  twig.position = end_position + Vector2(0, - gap)
  var crookedness = (1 - straightness)
  var sibling_range = PI * crookedness
  var sibling_offset = 0
  if num_children > 1:
    var offset_ratio = child_index / (num_children - 1)
    sibling_offset = (offset_ratio * sibling_range) - sibling_range/2
  var random_range = PI * 0.5 * crookedness
  var random_offset = rand_range(-random_range/2, random_range/2)
  var rotation_factor = sibling_offset + random_offset
  twig.rotate(rotation_factor)
