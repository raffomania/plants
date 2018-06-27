extends Node2D

export(Color) var twig_color_young
export(Color) var twig_color_adult
export(Color) var leaf_color
export(int) var twig_length
export(int) var twig_thickness
export(int) var gap
export(float, 0, 1) var straightness
export(float, 0, 1) var branchiness
export(float, 0, 1) var leafiness
export(float, 0, 1) var sun_affinity
export(bool) var do_randomize

# two years max, atm
export(int, 0, 730) var days_until_grown_up

var softnoiseScript = preload("res://assets/softnoise.gd")
var softnoise

var size = 0
var max_size = 1
var max_children = 1
var end_position
var actual_leafiness
var resting_rotation
var age = 0
var min_max_size = 0.2
var min_branching_max_size = 0.3
var start_branching_at_size = 0.02
var is_root = false

func _ready():
  add_to_group('twigs')

func _process(dt):
  var right = PI / 2
  var sway_direction = right - global_rotation
  var wind_change_speed = 0.001
  var wind_force = 0.5
  var wind_coarseness = 10
  var wind_position = Vector2(OS.get_ticks_msec() * wind_change_speed, 0) + global_position / wind_coarseness
  var wind_noise = softnoise.openSimplex2D(wind_position.x, wind_position.y)
  var wind_influence = min(1, 0.2 + actual_leafiness) * wind_noise * wind_force
  var resting_direction = resting_rotation - rotation
  rotate(dt * sway_direction * wind_influence + dt * resting_direction)
  if is_root:
    grow(50 * dt)

func initialize():
  if do_randomize:
    randomize()
  is_root = not get_parent().is_in_group('twigs')
  softnoise = softnoiseScript.SoftNoise.new(randi())
  resting_rotation = rotation
  end_position = Vector2(0, - twig_length * max_size * 2)
  actual_leafiness = leafiness * (1 - max_size)

  size_changed()

  add_twig_line()
  for i in range(round(actual_leafiness * 5)):
    add_leaf(i)

func size_after_days(days):
  # Classic sigmoid function
  var curve_steepness = 1 / (days_until_grown_up * 0.15)
  var mid_point = (days_until_grown_up * 0.4)
  return 1 / (1 + exp((- curve_steepness) * (days - mid_point)))

func grow(days):
  age += days
  var size_before = size
  size = size_after_days(age)
  var energy_left = size_before / size
  size_changed()

  if size > start_branching_at_size and not has_node('twig'):
    spawn_children(max_children)
  if max_size > min_max_size and max_children == 0:
    pass

  for child in get_children():
    if child.is_in_group('twigs'):
      child.grow((energy_left * days) / max_children)

func size_changed():
  set_scale(Vector2(size, size))
  var line = $line
  if line:
    line.default_color = twig_color_young.linear_interpolate(twig_color_adult, pow(size, 2))

func add_twig_line():
  var line = Line2D.new()
  line.name = 'line'
  line.default_color = twig_color_young
  line.width = twig_thickness * max_size
  line.add_point(Vector2(0, 0))
  line.add_point(end_position)
  add_child(line)

func add_leaf(zindex):
  var scene = load("res://scenes/leaf.tscn")
  var leaf = scene.instance()
  var position = randf() * end_position
  leaf.translate(position)
  if randf() > 0.5:
    # turn around to the other side
    leaf.rotate(PI)
  leaf.rotate(randf() * PI * 0.5)
  leaf.modulate = leaf_color.lightened(randf() * 0.1 + (zindex * 0.2))
  var leaf_size = rand_range(0.7, 1)
  leaf.apply_scale(Vector2(leaf_size, leaf_size))
  leaf.add_to_group('leafs')
  leaf.z_index = zindex
  add_child(leaf)

func spawn_children(count):
  for i in range(count):
    var scene = load("res://scenes/twig.tscn")
    var twig = scene.instance()
    set_child_props(twig, count, i)
    add_child(twig)

    twig.initialize()

func set_child_props(twig, num_children, child_index):
  twig.twig_thickness = twig_thickness
  twig.gap = gap
  twig.branchiness = branchiness
  twig.straightness = straightness
  twig.leafiness = leafiness
  twig.do_randomize = do_randomize
  twig.leaf_color = leaf_color
  twig.twig_color_young = twig_color_young
  twig.twig_color_adult = twig_color_adult
  twig.sun_affinity = sun_affinity
  twig.days_until_grown_up = days_until_grown_up

  twig.twig_length = twig_length * rand_range(0.9, 1.2)
  twig.max_size = max_size * rand_range(0.85, 0.99)

  if randf() < branchiness * 0.5 and twig.max_size > min_branching_max_size:
    twig.max_children += round(randf() * branchiness * 3)
  elif twig.max_size < min_max_size:
    twig.max_children = 0

  twig.position = end_position + Vector2(0, - gap)
  twig.rotate(get_child_rotation(child_index, num_children))

func get_child_rotation(child_index, num_children):
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
  return upward_correction + sibling_offset + random_offset
