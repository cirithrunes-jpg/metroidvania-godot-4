extends CharacterBody2D

# Five restrained variants of the same reusable CC0-derived security family.
enum Kind { PATROL, MARKSMAN, ARMORED, DRONE, ROBOT }
@export var kind: Kind = Kind.PATROL
@export var patrol_radius := 24.0
const HEALTH := [2,2,4,2,5]
const SPEED := [17.0,11.0,10.0,0.0,8.0]
const RANGE := [105.0,150.0,95.0,115.0,100.0]
const COOLDOWN := [2.6,3.1,3.4,2.8,3.8]
const SHOT_SPEED := [65.0,85.0,60.0,55.0,48.0]
const ROUND = preload("res://prototype/enemies/security_round.gd")
const DEATH = preload("res://effects/enemy_death_effect.tscn")
var health := 2
var origin := Vector2.ZERO
var facing := -1.0
var cooldown := 1.5
var warning := 0.0
var aim := Vector2.LEFT
var clock := 0.0
var flash := 0.0
var dying := false
var visual: AnimatedSprite2D
var hurtbox: Hurtbox
var body_size := Vector2(10,24)
var unit_scale := 0.128

func _ready():
	add_to_group("lab_enemies")
	origin = position
	health = HEALTH[kind]
	cooldown += float(kind)*0.3
	if kind == Kind.DRONE:
		body_size = Vector2(18,10)
		unit_scale = 0.10
	elif kind == Kind.ROBOT:
		body_size = Vector2(16,29)
		unit_scale = 0.15
	elif kind == Kind.ARMORED:
		body_size = Vector2(13,27)
		unit_scale = 0.14
	add_collider(self,body_size)
	hurtbox = preload("res://collisions/hurtbox.tscn").instantiate()
	hurtbox.collision_layer = 32
	add_collider(hurtbox,body_size+Vector2(2,2))
	add_child(hurtbox)
	hurtbox.hurt.connect(take_damage)
	var contact = preload("res://collisions/hitbox.tscn").instantiate()
	contact.collision_mask = 16
	add_collider(contact,body_size-Vector2(2,2))
	add_child(contact)
	setup_visual()
	z_index = 6

func add_collider(target: Node2D, size: Vector2):
	var collider := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collider.shape = shape
	collider.position.y = -body_size.y/2
	target.add_child(collider)

func setup_visual():
	visual = AnimatedSprite2D.new()
	visual.name = "Visual"
	visual.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	visual.centered = false
	var sheet = preload("res://prototype/assets/enemies/security-family.png")
	# Explicit row bounds keep the adapted drone and robot clear of neighbouring frames.
	var rows := [Vector2(0,240),Vector2(240,235),Vector2(475,235),Vector2(710,165),Vector2(875,270)]
	var baselines := [224.0,224.0,220.0,150.0,253.0]
	var cell := Vector2(sheet.get_width()/6.0,rows[kind].y)
	visual.offset = Vector2(-cell.x/2,-baselines[kind])
	visual.sprite_frames = SpriteFrames.new()
	visual.sprite_frames.set_animation_speed("default",8.0 if kind != Kind.DRONE else 10.0)
	for column in 6:
		var texture := AtlasTexture.new()
		texture.atlas = sheet
		texture.region = Rect2(Vector2(column*cell.x,rows[kind].x),cell)
		texture.filter_clip = true
		visual.sprite_frames.add_frame("default",texture)
	# Keep a stable game-space size even if the generated atlas resolution changes.
	unit_scale *= 256.0/cell.y
	add_child(visual)
	visual.play()

func _physics_process(delta):
	if dying: return
	clock += delta
	cooldown = maxf(0,cooldown-delta)
	flash = maxf(0,flash-delta)
	var player = MainInstances.player
	var target_visible := false
	if is_instance_valid(player):
		var target: Vector2 = player.global_position+Vector2(0,-13)
		var distance: float = global_position.distance_to(target)
		if distance < RANGE[kind]:
			target_visible = has_line_of_sight(target)
			if target_visible:
				facing = 1.0 if target.x > global_position.x else -1.0
				if cooldown <= 0 and warning <= 0:
					aim = (target-muzzle_position()).normalized()
					warning = 0.65 if kind != Kind.MARKSMAN else 0.9
	if warning > 0:
		warning -= delta
		if warning <= 0:
			if target_visible: fire_round()
			cooldown = COOLDOWN[kind]
	if kind == Kind.DRONE:
		var hover := origin+Vector2(sin(clock*0.7)*patrol_radius,sin(clock*2.2)*3)
		velocity = (hover-position)*3
	else:
		velocity.y = minf(velocity.y+200*delta,128)
		if not target_visible and warning <= 0:
			if position.x > origin.x+patrol_radius: facing = -1
			elif position.x < origin.x-patrol_radius: facing = 1
			if is_on_wall() or (is_on_floor() and not floor_ahead()): facing *= -1
			velocity.x = facing*SPEED[kind]
		else:
			velocity.x = move_toward(velocity.x,0,160*delta)
	move_and_slide()
	visual.scale = Vector2(facing,1)*unit_scale
	visual.modulate = Color(1.8,0.8,0.8) if flash > 0 else Color.WHITE
	visual.speed_scale = 1 if kind == Kind.DRONE or absf(velocity.x)>2 else 0
	if visual.speed_scale == 0: visual.frame = 0
	queue_redraw()

func muzzle_position() -> Vector2:
	return global_position+Vector2(facing*(body_size.x/2+3),-body_size.y*0.62)

func has_line_of_sight(target: Vector2) -> bool:
	var query := PhysicsRayQueryParameters2D.create(muzzle_position(),target,1)
	return get_world_2d().direct_space_state.intersect_ray(query).is_empty()

func floor_ahead() -> bool:
	var point := global_position+Vector2(facing*(body_size.x/2+5),-4)
	var query := PhysicsRayQueryParameters2D.create(point,point+Vector2(0,12),1)
	return not get_world_2d().direct_space_state.intersect_ray(query).is_empty()

func fire_round():
	var bullet := Area2D.new()
	bullet.set_script(ROUND)
	bullet.velocity = aim*SHOT_SPEED[kind]
	MainInstances.level.add_child(bullet)
	bullet.global_position = muzzle_position()

func take_damage(_hitbox, damage):
	if dying: return
	health -= damage
	flash = 0.12
	if health <= 0:
		dying = true
		Utils.instantiate_scene_on_level(DEATH,global_position+Vector2(0,-body_size.y/2))
		queue_free()

func _draw():
	if warning > 0:
		var muzzle := Vector2(facing*(body_size.x/2+3),-body_size.y*0.62)
		draw_line(muzzle,muzzle+aim*24,Color(1,0.2,0.3,0.35),0.6)
		draw_circle(muzzle,1.3,Color("ff6377"))
	if health < HEALTH[kind]:
		draw_rect(Rect2(-8,-body_size.y-4,16,1),Color("273541"))
		draw_rect(Rect2(-8,-body_size.y-4,16*maxf(0,float(health)/HEALTH[kind]),1),Color("f34e64"))
