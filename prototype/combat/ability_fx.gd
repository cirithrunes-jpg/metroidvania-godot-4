extends Node2D
const EXPLOSION = preload("res://prototype/assets/grenade-explosion-v11.png")
var radius := 42.0
var age := 0.0
var duration := 0.85
var energy := false
var fragments: Array = []
var light: PointLight2D
func _ready():
	z_index = 18
	if energy:
		duration = 0.42
		return
	add_to_group("grenade_explosions")
	for i in 24:
		fragments.append({"velocity":Vector2.RIGHT.rotated(randf_range(-PI,-0.05))*randf_range(35,105),"size":randf_range(0.5,1.5)})
	light = PointLight2D.new()
	var texture := GradientTexture2D.new()
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([Color.WHITE,Color(1,1,1,0)])
	texture.gradient = gradient
	texture.width = 128
	texture.height = 128
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5,0.5)
	texture.fill_to = Vector2(1,0.5)
	light.texture = texture
	light.texture_scale = 0.9
	light.color = Color("ffb154")
	light.energy = 2.0
	add_child(light)
func _process(delta):
	age += delta
	if is_instance_valid(light): light.energy = maxf(0,1-age/0.2)*2
	if age>=duration: queue_free()
	queue_redraw()
func _draw():
	var ratio := clampf(age/duration,0,1)
	if energy:
		var tint := Color("39ddff")
		tint.a = 1-ratio
		draw_circle(Vector2.ZERO,radius*ratio,Color(tint,0.13*(1-ratio)))
		draw_arc(Vector2.ZERO,radius*ratio,0,TAU,40,tint,1.5*(1-ratio))
		return
	var frame := mini(7,int(ratio*8))
	var cell := Vector2(EXPLOSION.get_width()/4.0,EXPLOSION.get_height()/2.0)
	var source := Rect2(Vector2(frame%4,floori(frame/4.0))*cell,cell)
	draw_texture_rect_region(EXPLOSION,Rect2(-radius,-radius*1.7,radius*2,radius*2),source)
	if age<0.065: draw_circle(Vector2(0,-7),11*(1-age/0.065),Color(1,0.96,0.75,0.8*(1-age/0.065)))
	for fragment in fragments:
		var tip: Vector2 = fragment.velocity*age+Vector2(0,100*age*age)
		var tint := Color(1,0.48+0.4*(1-ratio),0.12,1-ratio)
		draw_line(tip-fragment.velocity.normalized()*3,tip,tint,fragment.size)
