extends Node2D

signal entered
const TEXTURE = preload("res://prototype/assets/pressure-door-v6.png")
var unlocked := false
var openness := 0.0
var triggered := false
var paused := false
var gate: CollisionShape2D

func _ready():
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	z_index = 4
	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	gate = CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(28,60)
	gate.shape = shape
	gate.position = Vector2(0,-30)
	body.add_child(gate)
	add_child(body)

func _process(delta):
	if paused or triggered: return
	var player = MainInstances.player
	if not is_instance_valid(player): return
	var distance: Vector2 = player.global_position-global_position
	var near: bool = absf(distance.x)<50 and absf(distance.y)<20
	openness = move_toward(openness,1.0 if unlocked and near else 0.0,delta*1.4)
	gate.set_deferred("disabled",openness>=0.85)
	if unlocked and openness >= 0.98 and distance.x > -7 and distance.x<28 and absf(distance.y)<13:
		triggered = true
		entered.emit()
	queue_redraw()

func _draw():
	var w := float(TEXTURE.get_width())
	var h := float(TEXTURE.get_height())
	var left := -23.0
	var top := -69.0
	# Static jamb, lintel and sill around a recessed opening.
	draw_rect(Rect2(left+6,top+6,34,62),Color("030b10"))
	draw_rect(Rect2(-12,top+12,24,55),Color(0.03,0.15,0.19,openness*0.55))
	var remaining := 1.0-openness
	if remaining>0:
		draw_texture_rect_region(TEXTURE,Rect2(left+7.36,top+6.9,15.64*remaining,58.65),Rect2(w*(0.16+openness*0.34),h*0.10,w*0.34*remaining,h*0.85))
		draw_texture_rect_region(TEXTURE,Rect2(openness*15.64,top+6.9,15.64*remaining,58.65),Rect2(w*0.50,h*0.10,w*0.34*remaining,h*0.85))
	draw_texture_rect_region(TEXTURE,Rect2(left,top,7.36,69),Rect2(0,0,w*0.16,h))
	draw_texture_rect_region(TEXTURE,Rect2(15.64,top,7.36,69),Rect2(w*0.84,0,w*0.16,h))
	draw_texture_rect_region(TEXTURE,Rect2(left+7.36,top,31.28,6.9),Rect2(w*0.16,0,w*0.68,h*0.10))
	draw_texture_rect_region(TEXTURE,Rect2(left+7.36,-3.45,31.28,3.45),Rect2(w*0.16,h*0.95,w*0.68,h*0.05))
	draw_line(Vector2(-15,top+3),Vector2(15,top+3),Color("57dfed") if unlocked else Color("f34e64"),1)
