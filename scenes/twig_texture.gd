extends Node2D

var leafs = []
var leaf_texture = preload("res://img/leaf.png")

func _draw():
    var viewport_size = $'../../viewport'.size
    for leaf in leafs:
        var position = leaf["position"] + Vector2(viewport_size.x/2, viewport_size.y/2)
        draw_set_transform(position, leaf["rotation"], leaf["scale"])
        draw_texture(leaf_texture, Vector2(), leaf["color"])

