extends Player

var grace := 0.0
var jump_buffer := 0.0
var extra_jump := true
var shot_delay := 0.0
var invulnerability := 0.0
var facing := 1.0

func _ready():
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
	var axis := Input.get_axis("move_left","move_right")
	var grounded := is_on_floor()
	grace = 0.1 if grounded else maxf(0,grace-delta)
	jump_buffer = maxf(0,jump_buffer-delta)
	shot_delay = maxf(0,shot_delay-delta)
	invulnerability = maxf(0,invulnerability-delta)
	hurtbox.is_invincible = invulnerability > 0
	if grounded: extra_jump = true
	if Input.is_action_just_pressed("jump"): jump_buffer = 0.12
	var response: float = acceleration if absf(axis)>0 else friction
	if not grounded: response = 260 if absf(axis)>0 else 100
	velocity.x = move_toward(velocity.x,axis*max_velocity,response*delta)
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
	var aim_x := get_global_mouse_position().x-global_position.x
	if absf(aim_x)>8: facing = signf(aim_x)
	sprite_2d.scale.x = facing
	sprite_2d.modulate = Color(1,0.65,0.6,0.55 if sin(invulnerability*35)>0 else 1.0) if invulnerability>0 else Color.WHITE
	player_blaster.position = Vector2(facing*2,-17)
	if Input.is_action_pressed("fire") and shot_delay <= 0:
		player_blaster.fire_bullet()
		shot_delay = 0.17

func _on_hurtbox_hurt(_hitbox,damage):
	if invulnerability > 0: return
	invulnerability = 0.9
	hurtbox.is_invincible = true
	PlayerStats.health -= damage
	Sound.play(Sound.hurt,1,-7)
	Events.add_screenshake.emit(0.6,0.12)
