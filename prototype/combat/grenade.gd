extends CharacterBody2D
var timer := 1.25
var spent := false
func _ready():
	add_to_group("combat_grenades")
	collision_layer = 0
	collision_mask = 1
	z_index = 12
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 2.5
	collision.shape = shape
	add_child(collision)
func _physics_process(delta):
	if spent: return
	velocity.y += 240*delta
	var collision := move_and_collide(velocity*delta)
	if collision:
		velocity = velocity.bounce(collision.get_normal())*0.55
		if collision.get_normal().y < -0.5: velocity.x = move_toward(velocity.x,0,15*delta)
	timer -= delta
	if timer<=0: explode()
	queue_redraw()
func explode():
	if spent: return
	spent = true
	preload("res://prototype/combat/combat_damage.gd").blast(self,global_position+Vector2(0,-3),42,3)
	Sound.play(preload("res://prototype/assets/audio/grenade-blast.wav"),1,-7)
	var effect := Node2D.new()
	effect.set_script(preload("res://prototype/combat/ability_fx.gd"))
	get_parent().add_child(effect)
	effect.global_position = global_position
	Events.add_screenshake.emit(0.35,0.12)
	queue_free()
func _draw():
	draw_circle(Vector2.ZERO,2.5,Color("49636e"))
	draw_line(Vector2(-1,-2),Vector2(2,-3),Color("a4d6df"),1)
	draw_circle(Vector2(1,-1),0.7,Color("ff7766") if sin(timer*30)>0 else Color("79413e"))
