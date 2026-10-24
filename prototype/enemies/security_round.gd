extends Area2D

var velocity := Vector2.ZERO
var lifetime := 0.0
var spent := false
const FX = preload("res://prototype/combat/ballistic_fx.gd")

func _ready():
	add_to_group("enemy_projectiles")
	collision_layer = 0
	collision_mask = 81
	var collider := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 1.5
	collider.shape = circle
	add_child(collider)
	area_entered.connect(_on_area_entered)
	body_entered.connect(func(_body): queue_free())
	z_index = 8

func _physics_process(delta):
	if spent: return
	var next: Vector2 = global_position+velocity*delta
	var query := PhysicsRayQueryParameters2D.create(global_position,next,81)
	query.collide_with_areas = true
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		global_position = hit.position
		_on_area_entered(hit.collider)
		return
	global_position = next
	lifetime += delta
	if lifetime > 3.5: queue_free()

func _on_area_entered(area):
	if spent: return
	spent = true
	if area is Hurtbox:
		area.take_hit(self,1)
	var impact := Node2D.new()
	impact.set_script(FX)
	impact.direction = -velocity.normalized()
	get_parent().add_child(impact)
	impact.global_position = global_position
	queue_free()

func _draw():
	draw_line(-velocity.normalized()*7,Vector2.ZERO,Color(1,0.53,0.24,0.2),2)
	draw_line(-velocity.normalized()*5,Vector2.ZERO,Color("ffe2a8"),0.7)
