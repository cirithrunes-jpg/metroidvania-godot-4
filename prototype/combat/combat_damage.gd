extends RefCounted
static func blast(source: Node2D,point: Vector2,radius: float,damage: int):
	var query := PhysicsShapeQueryParameters2D.new()
	var shape := CircleShape2D.new()
	shape.radius = radius
	query.shape = shape
	query.transform = Transform2D(0,point)
	query.collision_mask = 96
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var hit_once := {}
	for hit in source.get_world_2d().direct_space_state.intersect_shape(query,64):
		var area = hit.collider
		if not area is Hurtbox or hit_once.has(area.get_instance_id()): continue
		hit_once[area.get_instance_id()] = true
		var target: Vector2 = area.global_position+Vector2(0,-12)
		for child in area.get_children():
			if child is CollisionShape2D: target = child.global_position; break
		var ray := PhysicsRayQueryParameters2D.create(point,target,1)
		if source.get_world_2d().direct_space_state.intersect_ray(ray).is_empty(): area.take_hit(source,damage)
