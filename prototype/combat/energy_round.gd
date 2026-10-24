extends Node2D
var velocity := Vector2(210,0)
var lifetime := 0.0
func _ready():
	add_to_group("energy_rounds")
	z_index = 15
func _physics_process(delta):
	var next: Vector2 = global_position+velocity*delta
	var query := PhysicsRayQueryParameters2D.create(global_position,next,97)
	query.collide_with_areas = true
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		if hit.collider is Hurtbox: hit.collider.take_hit(self,3)
		var effect := Node2D.new()
		effect.set_script(preload("res://prototype/combat/ability_fx.gd"))
		effect.radius = 15
		effect.energy = true
		get_parent().add_child(effect)
		effect.global_position = hit.position
		queue_free()
		return
	global_position = next
	lifetime += delta
	if lifetime>2: queue_free()
	queue_redraw()
func _draw():
	var facing := signf(velocity.x)
	draw_line(Vector2(-facing*18,0),Vector2.ZERO,Color(0.1,0.8,1,0.3),7)
	draw_circle(Vector2.ZERO,6,Color(0.1,0.8,1,0.2))
	draw_circle(Vector2.ZERO,4,Color("39d7ff"))
	draw_circle(Vector2(facing,0),2.2,Color("eaffff"))
