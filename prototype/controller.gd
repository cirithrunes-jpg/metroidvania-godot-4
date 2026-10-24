extends Player

var grace := 0.0
var jump_buffer := 0.0
var extra_jump := true
var shot_delay := 0.0
var invulnerability := 0.0
var facing := 1.0
var guarding := false
var shield_hits := 0
var shield_recovery := 0.0
var stagger := 0.0
var melee_kind := ""
var melee_time := 0.0
var melee_hit := false
var armed_time := 0.0
var guard_impact := 0.0
const VOICES = [preload("res://prototype/assets/audio/hurt-voice-1.wav"),preload("res://prototype/assets/audio/hurt-voice-2.wav")]

func bind_key(action: String, key: int):
	if not InputMap.has_action(action): InputMap.add_action(action)
	var event := InputEventKey.new()
	event.physical_keycode = key
	if not InputMap.action_has_event(action,event): InputMap.action_add_event(action,event)

func melee_strike():
	var query := PhysicsShapeQueryParameters2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(30 if melee_kind == "kick" else 24,25)
	query.shape = box
	query.transform = Transform2D(0,global_position+Vector2(facing*22,-15))
	query.collision_mask = 32
	query.collide_with_areas = true
	query.collide_with_bodies = false
	for hit in get_world_2d().direct_space_state.intersect_shape(query):
		var target = hit.collider
		var ray := PhysicsRayQueryParameters2D.create(global_position+Vector2(0,-15),target.global_position+Vector2(0,-13),1)
		if target is Hurtbox and get_world_2d().direct_space_state.intersect_ray(ray).is_empty():
			target.take_hit(self,2 if melee_kind == "kick" else 1)

func _ready():
	bind_key("fire",KEY_Z)
	bind_key("attack_punch",KEY_J)
	bind_key("attack_kick",KEY_K)
	bind_key("guard",KEY_L)
	bind_key("interact",KEY_E)
	bind_key("pause",KEY_ESCAPE)
	var space := InputEventKey.new()
	space.physical_keycode = KEY_SPACE
	if not InputMap.action_has_event("jump",space): InputMap.action_add_event("jump",space)
	PlayerStats.no_health.connect(die)
	max_velocity = 72
	acceleration = 360
	friction = 580
	gravity = 240
	jump_force = 142
	max_fall_velocity = 170
	camera_2d.position_smoothing_enabled = true
	camera_2d.position_smoothing_speed = 8
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON
	var art := AnimatedSprite2D.new()
	art.name = "Specimen"
	art.set_script(preload("res://prototype/specimen.gd"))
	art.actor = self
	add_child(art)

func _physics_process(delta):
	armed_time = maxf(0,armed_time-delta)
	guard_impact = maxf(0,guard_impact-delta)
	var axis := Input.get_axis("move_left","move_right")
	var grounded := is_on_floor()
	stagger = maxf(0,stagger-delta)
	if shield_recovery > 0:
		shield_recovery = maxf(0,shield_recovery-delta)
		if shield_recovery <= 0: shield_hits = 0
	guarding = Input.is_action_pressed("guard") and shield_recovery <= 0 and stagger <= 0 and melee_time <= 0
	if not guarding and shield_hits > 0 and shield_recovery <= 0:
		shield_recovery = 1.4
	if absf(axis)>0 and stagger <= 0: facing = signf(axis)
	if melee_time <= 0 and not guarding and stagger <= 0:
		if Input.is_action_just_pressed("attack_punch") or Input.is_action_just_pressed("attack_kick"):
			melee_kind = "kick" if Input.is_action_just_pressed("attack_kick") else "punch"
			melee_time = 0.44
			melee_hit = false
	if melee_time > 0:
		melee_time = maxf(0,melee_time-delta)
		if melee_time < 0.26 and not melee_hit:
			melee_hit = true
			melee_strike()
		if melee_time <= 0: melee_kind = ""
	if guarding or melee_time > 0: axis = 0
	queue_redraw()
	grace = 0.1 if grounded else maxf(0,grace-delta)
	jump_buffer = maxf(0,jump_buffer-delta)
	shot_delay = maxf(0,shot_delay-delta)
	invulnerability = maxf(0,invulnerability-delta)
	hurtbox.is_invincible = invulnerability > 0
	if grounded: extra_jump = true
	if Input.is_action_just_pressed("jump"): jump_buffer = 0.12
	var response: float = acceleration if absf(axis)>0 else friction
	if not grounded: response = 260 if absf(axis)>0 else 100
	if stagger <= 0: velocity.x = move_toward(velocity.x,axis*max_velocity,response*delta)
	velocity.y = minf(velocity.y+gravity*delta,max_fall_velocity)
	if jump_buffer > 0:
		if grace > 0:
			velocity.y = -jump_force
			jump_buffer = 0
			grace = 0
		elif is_on_wall():
			velocity = Vector2(get_wall_normal().x*82,-132)
			jump_buffer = 0
		elif extra_jump:
			velocity.y = -118
			extra_jump = false
			jump_buffer = 0
	if Input.is_action_just_released("jump") and velocity.y < -76: velocity.y = -76
	if is_on_wall() and velocity.y > 44: velocity.y = 44
	move_and_slide()

	sprite_2d.scale.x = facing
	sprite_2d.modulate = Color(1,0.65,0.6,0.55 if sin(invulnerability*35)>0 else 1.0) if invulnerability>0 else Color.WHITE
	player_blaster.position = Vector2(facing*2,-17)
	player_blaster.visible = false
	if Input.is_action_pressed("fire") and shot_delay <= 0 and not guarding and melee_time <= 0 and stagger <= 0:
		armed_time = 0.28
		player_blaster.fire_bullet()
		shot_delay = 0.17

func _on_hurtbox_hurt(_hitbox,damage):
	if invulnerability > 0: return
	if guarding and is_instance_valid(_hitbox) and _hitbox.is_in_group("enemy_projectiles"):
		shield_hits += 1
		guard_impact = 0.16
		Sound.play(preload("res://prototype/assets/audio/shield-impact.wav"),1,-8)
		if shield_hits <= 2:
			queue_redraw()
			return
		guarding = false
		shield_recovery = 2.0
		stagger = 0.35
		velocity = Vector2(-facing*120,-65)
	invulnerability = 0.9
	hurtbox.is_invincible = true
	PlayerStats.health -= damage
	Sound.play(VOICES[randi()%VOICES.size()],randf_range(0.96,1.04),-2)
	Events.add_screenshake.emit(0.6,0.12)
