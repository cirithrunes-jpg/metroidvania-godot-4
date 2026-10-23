extends Node2D

# Original procedural placeholder: silhouette follows the existing controller.
var actor: CharacterBody2D
var clock := 0.0

func _process(delta):
	clock += delta
	scale.x = actor.get_node("Sprite2D").scale.x
	visible = actor.get_node("Sprite2D").modulate.a > 0.2
	queue_redraw()

func _draw():
	var step := sin(clock * 15.0) * minf(absf(actor.velocity.x) / 64.0, 1.0) * 2.0
	var skin := Color("647580")
	draw_line(Vector2(-2, -7), Vector2(-3 + step, 0), skin, 3)
	draw_line(Vector2(2, -7), Vector2(3 - step, 0), skin, 3)
	draw_colored_polygon(PackedVector2Array([Vector2(-5,-15),Vector2(3,-16),Vector2(5,-7),Vector2(-3,-6)]), Color("35434e"))
	draw_line(Vector2(-5,-14), Vector2(-7,-5), skin, 3)
	draw_line(Vector2(4,-13), Vector2(7,-7), skin, 3)
	draw_line(Vector2(7,-7), Vector2(9,-9), Color("e26a73"), 1)
	draw_colored_polygon(PackedVector2Array([Vector2(-3,-16),Vector2(-4,-21),Vector2(1,-24),Vector2(5,-20),Vector2(4,-16)]), skin)
	draw_line(Vector2(-3,-21), Vector2(-5,-25), skin, 2)
	draw_line(Vector2(2,-22), Vector2(3,-26), skin, 2)
	draw_rect(Rect2(1,-20,4,1), Color("30d9ff"))
	draw_line(Vector2(-1,-14), Vector2(1,-8), Color("30d9ff"), 1)
