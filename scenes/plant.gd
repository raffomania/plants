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

func _process(dt):
  var right = PI / 2
  var sway_direction = right - global_rotation
  var wind_change_speed = 0.001
  var wind_force = 0.5
  var wind_coarseness = 10
  var wind_position = Vector2(OS.get_ticks_msec() * wind_change_speed, 0) + global_position / wind_coarseness
  var wind_noise = softnoise.openSimplex2D(wind_position.x, wind_position.y)
  var wind_influence = actual_leafiness * wind_noise * wind_force
  var resting_direction = resting_rotation - rotation
  rotate(dt * sway_direction * wind_influence + dt * resting_direction)
  grow(1 * dt)

func initialize():
  if do_randomize:
    randomize()
  softnoise = softnoiseScript.SoftNoise.new(randi())
  resting_rotation = rotation
  end_position = Vector2(0, - twig_length * 2)
  actual_leafiness = leafiness * (1 - max_size)

  add_twig_line()
  for i in range(round(actual_leafiness * 10)):
    add_leaf(i)

func grow(days):
  size = min(max_size, size + (days / days_until_grown_up))
  update_scale()

  if size > 0.2 and not $twig:
    spawn_children(max_children)

func update_scale():
  set_scale(Vector2(size, size))

func add_twig_line():
  var line = Line2D.new()
  line.name = 'line'
  line.default_color = twig_color
  line.width = twig_thickness
  line.add_point(Vector2(0, 0))
  line.add_point(end_position)
  add_child(line)

func add_leaf(zindex):
  var scene = load("res://scenes/leaf.tscn")
  var leaf = scene.instance()
  var position = randf() * end_position
  leaf.translate(position)
  leaf.rotate(randf() * PI * 2)
  leaf.modulate = leaf_color.lightened(randf() * 0.1 + (zindex * 0.1))
  var leaf_size = rand_range(0.8, 1)
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
  twig.twig_length = twig_length
  twig.gap = gap
  twig.branchiness = branchiness
  twig.straightness = straightness
  twig.leafiness = leafiness
  twig.do_randomize = do_randomize
  twig.leaf_color = leaf_color
  twig.twig_color = twig_color
  twig.sun_affinity = sun_affinity
  twig.days_until_grown_up = days_until_grown_up

  twig.max_size = max_size * rand_range(0.85, 0.99)
  if randf() < branchiness * 0.5:
    twig.max_children = round(branchiness * 5)

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
