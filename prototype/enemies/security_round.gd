extends Area2D

var velocity := Vector2.ZERO
var lifetime := 0.0

func _ready():
	collision_layer = 0
	collision_mask = 17
	var collider := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 1.5
	collider.shape = circle
	add_child(collider)
	area_entered.connect(_on_area_entered)
	body_entered.connect(func(_body): queue_free())
	z_index = 8

func _physics_process(delta):
	position += velocity * delta
	lifetime += delta
	if lifetime > 3.5: queue_free()

func _on_area_entered(area):
	if area is Hurtbox:
		area.take_hit(self,1)
		queue_free()

func _draw():
	draw_line(-velocity.normalized()*5,Vector2.ZERO,Color("973e58"),1.5)
	draw_circle(Vector2.ZERO,1.5,Color("ff6979"))
	draw_circle(Vector2.ZERO,0.6,Color("ffe3db"))
