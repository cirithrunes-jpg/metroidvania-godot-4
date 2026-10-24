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
var posture := "standing"
var down_hold := 0.0
var standing_blocked := false
var power_charge := 0.0
var power_latched := false
var power_cast := 0.0
var grenade_time := 0.0
var grenade_cooldown := 0.0
var grenade_thrown := false
const VOICES = [preload("res://prototype/assets/audio/hurt-voice-1.wav"),preload("res://prototype/assets/audio/hurt-voice-2.wav")]

func _ready():
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
	$CollisionShape2D.shape = $CollisionShape2D.shape.duplicate()
	$Hurtbox/CollisionShape2D.shape = $Hurtbox/CollisionShape2D.shape.duplicate()
	var art := AnimatedSprite2D.new()
	art.name = "Specimen"
	art.set_script(preload("res://prototype/specimen.gd"))
	art.actor = self
	add_child(art)

func set_posture(value: String):
	posture = value
	var size := Vector2(10,26)
	if value=="crouch": size = Vector2(12,16)
	elif value=="prone": size = Vector2(26,8)
	for collision in [$CollisionShape2D,$Hurtbox/CollisionShape2D]:
		collision.shape.size = size
		collision.position = Vector2(0,-size.y/2)

func stand_up() -> bool:
	var query := PhysicsShapeQueryParameters2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(10,26)
	query.shape = shape
	query.transform = Transform2D(0,global_position+Vector2(0,-13))
	query.collision_mask = 3
	query.exclude = [get_rid()]
	standing_blocked = false
	for hit in get_world_2d().direct_space_state.intersect_shape(query):
		var owner_id: int = hit.collider.shape_find_owner(hit.shape)
		var collision = hit.collider.shape_owner_get_owner(owner_id)
		if collision is CollisionShape2D and collision.one_way_collision: continue
		standing_blocked = true
	if standing_blocked: return false
	set_posture("standing")
	down_hold = 0
	return true

func melee_strike():
	var sword := melee_kind=="sword"
	var kick: bool = melee_kind in ["kick","air_kick"]
	var query := PhysicsShapeQueryParameters2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(44 if sword else (32 if kick else 24),25)
	query.shape = box
	query.transform = Transform2D(0,global_position+Vector2(facing*(28 if sword else 22),-15))
	query.collision_mask = 96
	query.collide_with_areas = true
	query.collide_with_bodies = false
	for hit in get_world_2d().direct_space_state.intersect_shape(query):
		var target = hit.collider
		var ray := PhysicsRayQueryParameters2D.create(global_position+Vector2(0,-15),target.global_position+Vector2(0,-13),1)
		if target is Hurtbox and get_world_2d().direct_space_state.intersect_ray(ray).is_empty(): target.take_hit(self,2 if sword or kick else 1)

func release_power():
	var orb := Node2D.new()
	orb.set_script(preload("res://prototype/combat/energy_round.gd"))
	orb.velocity = Vector2(facing*210,0)
	MainInstances.level.add_child(orb)
	# Start inside the actor's outline so the swept query catches an adjacent wall.
	orb.global_position = global_position+Vector2(0,-19)
	power_cast = 0.4
	power_latched = true
	power_charge = 0
	Sound.play(preload("res://prototype/assets/audio/power-release.wav"),1,-7)

func throw_grenade():
	var grenade := CharacterBody2D.new()
	grenade.set_script(preload("res://prototype/combat/grenade.gd"))
	MainInstances.level.add_child(grenade)
	grenade.global_position = global_position+Vector2(0,-18)
	grenade.velocity = Vector2(facing*105,-85)

func _physics_process(delta):
	armed_time = maxf(0,armed_time-delta)
	guard_impact = maxf(0,guard_impact-delta)
	power_cast = maxf(0,power_cast-delta)
	grenade_cooldown = maxf(0,grenade_cooldown-delta)
	stagger = maxf(0,stagger-delta)
	shot_delay = maxf(0,shot_delay-delta)
	invulnerability = maxf(0,invulnerability-delta)
	hurtbox.is_invincible = invulnerability>0
	var grounded := is_on_floor()
	var axis := Input.get_axis("move_left","move_right")
	if absf(axis)>0 and stagger<=0 and power_charge<=0: facing = signf(axis)
	if shield_recovery>0:
		shield_recovery = maxf(0,shield_recovery-delta)
		if shield_recovery<=0: shield_hits = 0
	guarding = Input.is_action_pressed("guard") and shield_recovery<=0 and stagger<=0 and melee_time<=0 and power_cast<=0 and grenade_time<=0
	if not guarding and shield_hits>0 and shield_recovery<=0: shield_recovery = 1.4
	if grounded and stagger<=0 and Input.is_action_pressed("posture_down") and not guarding and melee_time<=0 and power_charge<=0 and power_cast<=0 and grenade_time<=0:
		down_hold += delta
		if down_hold+0.0001>=6 and posture!="prone": set_posture("prone")
		elif down_hold+0.0001>=3 and posture=="standing": set_posture("crouch")
	else: down_hold = 0
	jump_buffer = maxf(0,jump_buffer-delta)
	if Input.is_action_just_pressed("jump") and stagger<=0:
		if posture=="standing" or stand_up(): jump_buffer = 0.12
	grace = 0.1 if grounded else maxf(0,grace-delta)
	if grounded: extra_jump = true
	var busy: bool = guarding or stagger>0 or melee_time>0 or grenade_time>0 or power_cast>0 or posture!="standing"
	if not Input.is_action_pressed("power"):
		power_charge = 0
		power_latched = false
	elif not busy and not power_latched:
		power_charge += delta
		if power_charge+0.0001>=2: release_power()
	else: power_charge = 0
	busy = busy or power_charge>0 or power_cast>0
	if not busy:
		if Input.is_action_just_pressed("grenade") and grenade_cooldown<=0:
			grenade_time = 0.44
			grenade_cooldown = 1.4
			grenade_thrown = false
		elif Input.is_action_just_pressed("sword") or Input.is_action_just_pressed("attack_punch") or Input.is_action_just_pressed("attack_kick"):
			melee_kind = "sword" if Input.is_action_just_pressed("sword") else ("kick" if Input.is_action_just_pressed("attack_kick") else "punch")
			if melee_kind=="kick" and (not grounded or jump_buffer>0): melee_kind = "air_kick"
			melee_time = 0.44
			melee_hit = false
	if grenade_time>0:
		grenade_time = maxf(0,grenade_time-delta)
		if grenade_time<0.24 and not grenade_thrown:
			grenade_thrown = true
			throw_grenade()
	if melee_time>0:
		melee_time = maxf(0,melee_time-delta)
		if melee_time<0.26 and not melee_hit:
			melee_hit = true
			melee_strike()
		if melee_time<=0: melee_kind = ""
	if guarding or power_charge>0 or power_cast>0 or grenade_time>0 or (melee_time>0 and grounded): axis = 0
	var speed: float = max_velocity
	if posture=="crouch": speed = 22
	elif posture=="prone": speed = 14
	var response: float = acceleration if absf(axis)>0 else friction
	if not grounded: response = 260 if absf(axis)>0 else 100
	if stagger<=0: velocity.x = move_toward(velocity.x,axis*speed,response*delta)
	velocity.y = minf(velocity.y+gravity*delta,max_fall_velocity)
	if jump_buffer>0 and power_charge<=0 and power_cast<=0 and grenade_time<=0:
		if grace>0:
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
	if is_on_wall() and velocity.y>44: velocity.y = 44
	move_and_slide()
	sprite_2d.scale.x = facing
	sprite_2d.modulate = Color(1,0.65,0.6,0.55 if sin(invulnerability*35)>0 else 1) if invulnerability>0 else Color.WHITE
	player_blaster.visible = false
	if Input.is_action_pressed("fire") and shot_delay<=0 and not guarding and melee_time<=0 and grenade_time<=0 and power_charge<=0 and power_cast<=0 and stagger<=0 and posture=="standing":
		armed_time = 0.28
		player_blaster.fire_bullet()
		shot_delay = 0.17
	queue_redraw()

func _draw():
	if guarding and posture=="prone":
		draw_arc(Vector2(facing*12,-6),8,-1.3 if facing>0 else 1.84,1.3 if facing>0 else 4.44,18,Color("46dfff"),1.4)
	if power_charge>0:
		var center := Vector2(-facing,-16)
		var radius := 2+power_charge*2
		draw_circle(center,radius+3,Color(0.1,0.8,1,0.12))
		draw_arc(center,radius+2,0,TAU*(power_charge/2),24,Color("e9fcff"),1)

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
	power_charge = 0
	invulnerability = 0.9
	hurtbox.is_invincible = true
	PlayerStats.health -= damage
	Sound.play(VOICES[randi()%VOICES.size()],randf_range(0.96,1.04),-2)
	Events.add_screenshake.emit(0.6,0.12)
