extends Node2D
var radius := 42.0
var age := 0.0
var duration := 0.42
var energy := false
func _ready(): z_index = 18
func _process(delta):
	age += delta
	if age>=duration: queue_free()
	queue_redraw()
func _draw():
	var ratio := clampf(age/duration,0,1)
	var tint := Color("39ddff") if energy else Color("ffb15e")
	tint.a = 1-ratio
	draw_circle(Vector2.ZERO,radius*ratio,Color(tint,0.13*(1-ratio)))
	draw_arc(Vector2.ZERO,radius*ratio,0,TAU,40,tint,1.5*(1-ratio))
	for i in 12:
		var direction := Vector2.RIGHT.rotated(i*TAU/12)
		draw_line(direction*radius*ratio*0.65,direction*radius*ratio,tint,0.7)
