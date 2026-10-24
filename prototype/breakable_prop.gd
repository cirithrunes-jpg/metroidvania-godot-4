extends Node2D
const TEXTURE = preload("res://prototype/assets/factory-props.png")
var prop_id := 0
var kind := 0
var health := 2
var broken := false
var hurtbox: Hurtbox
var flash := 0.0
func _ready():
	add_to_group("breakable_props")
	z_index = 3
	health = 2 if kind==0 else 1
	hurtbox = Hurtbox.new()
	hurtbox.collision_layer = 64
	hurtbox.collision_mask = 0
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(14,21)
	collision.shape = shape
	collision.position = Vector2(0,-10.5)
	hurtbox.add_child(collision)
	add_child(hurtbox)
	hurtbox.hurt.connect(take_damage)
func take_damage(_hitbox,amount):
	if broken: return
	health -= amount
	flash = 0.1
	Sound.play(preload("res://prototype/assets/audio/enemy-impact.wav"),0.72,-9)
	if health<=0:
		broken = true
		var effect := Node2D.new()
		effect.set_script(preload("res://prototype/combat/ballistic_fx.gd"))
		effect.direction = Vector2.UP
		MainInstances.level.add_child(effect)
		effect.global_position = global_position+Vector2(0,-10)
		queue_free()
func _process(delta):
	flash = maxf(0,flash-delta)
	modulate = Color(1.6,1.6,1.6) if flash>0 else (Color("a09b94") if health==1 and kind==0 else Color.WHITE)
func _draw():
	var source := Rect2(106,90,365,556) if kind==0 else Rect2(580,110,406,535)
	var height := 22.0 if kind==0 else 20.0
	var width := source.size.x/source.size.y*height
	draw_texture_rect_region(TEXTURE,Rect2(-width/2,-height,width,height),source)
