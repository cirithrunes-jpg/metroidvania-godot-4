extends Node2D

var mode := "impact"
var direction := Vector2.RIGHT
var age := 0.0
var ttl := 0.32
var sparks: Array[Vector2] = []

func _ready():
	z_index = 20
	if mode == "muzzle": ttl = 0.09
	for index in 8:
		sparks.append(direction.rotated(randf_range(-1.8,1.8))*randf_range(15,48))

func _process(delta):
	age += delta
	if age >= ttl: queue_free()
	queue_redraw()

func _draw():
	var fade := maxf(0,1-age/ttl)
	if mode == "muzzle":
		var side := direction.orthogonal()
		draw_circle(Vector2.ZERO,8*fade,Color(1,0.6,0.25,0.08*fade))
		draw_colored_polygon(PackedVector2Array([Vector2.ZERO,direction*5+side*2,direction*randf_range(8,12)*fade,direction*5-side*2]),Color(1,0.76,0.35,fade))
		draw_line(Vector2.ZERO,direction*7*fade,Color(1,0.97,0.8,fade),1)
	else:
		draw_circle(Vector2.ZERO,5*(1-fade),Color(0.23,0.27,0.3,0.18*fade))
		for spark in sparks:
			var tip := spark*age+Vector2(0,28*age*age)
			draw_line(tip-spark.normalized()*2*fade,tip,Color(1,0.65,0.3,fade),0.65)
		if age < 0.05: draw_circle(Vector2.ZERO,2*fade,Color(1,0.9,0.65,fade))
