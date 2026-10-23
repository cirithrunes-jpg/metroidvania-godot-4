extends Node2D

var velocity := Vector2.ZERO
var life := 0.0
const FX = preload("res://prototype/combat/ballistic_fx.gd")

func _ready():
	z_index = 15
	add_to_group("player_rounds")

func _physics_process(delta):
	var next: Vector2 = global_position+velocity*delta
	var query := PhysicsRayQueryParameters2D.create(global_position,next,33)
	query.collide_with_areas = true
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		if hit.collider is Hurtbox: hit.collider.take_hit(self,1)
		var impact := Node2D.new()
		impact.set_script(FX)
		impact.direction = hit.normal
		get_parent().add_child(impact)
		impact.global_position = hit.position
		queue_free()
		return
	global_position = next
	life += delta
	if life > 1.5: queue_free()
	queue_redraw()

func _draw():
	var trail := -velocity.normalized()
	draw_line(Vector2.ZERO,trail*9,Color(1,0.66,0.28,0.15),2.2)
	draw_line(Vector2.ZERO,trail*6,Color(1,0.9,0.65,0.85),0.65)
