extends AnimatedSprite2D
const SHEET = preload("res://prototype/assets/specimen-female-v2.png")
const COMBAT = preload("res://prototype/assets/specimen-combat-v8.png")
var actor: CharacterBody2D
var clock := 0.0
var was_grounded := true
var landing_time := 0.0
var squash := 0.0
var guard_started := false
var was_posture := "standing"
const CUTS := [0,235,465,695,925,1150,1370,1590,1774]
const ROWS := [0,231,455,675,887]
const REGIONS := [[[38, 8, 175, 218], [286, 9, 162, 217], [552, 8, 98, 219], [721, 8, 170, 208], [931, 10, 177, 216], [1177, 8, 155, 218], [1440, 8, 96, 219]], [[26, 235, 205, 214], [279, 235, 184, 214], [539, 235, 146, 215], [712, 235, 190, 205], [930, 235, 204, 214], [1186, 235, 182, 214], [1438, 235, 142, 214]], [[55, 456, 149, 212], [271, 456, 150, 212], [485, 455, 152, 213], [704, 456, 150, 212], [934, 455, 157, 213], [1150, 456, 157, 212], [1370, 456, 155, 212]], [[47, 675, 137, 206], [274, 676, 134, 205], [494, 675, 135, 206], [710, 675, 134, 206], [929, 683, 155, 196], [1150, 683, 156, 196], [1370, 695, 156, 185]]]
const ANCHORS := [[136,364,585,811,1033,1261,1480],[115,340,565,790,1014,1240,1465],[108,324,542,760,982,1203,1421],[115,335,553,774,1005,1223,1443]]
func _ready():
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	centered = false
	sprite_frames = SpriteFrames.new()
	sprite_frames.remove_animation("default")
	add_combat("run",0,[0,1,2,3,4,5,6,3],12,true)
	add_combat("armed_run",1,[0,1,2,3,4,5,6,3],12,true)
	add_combat("armed_rise",1,[2],1,false)
	add_combat("armed_fall",1,[3],1,false)
	add_combat("idle",2,[0],1,true)
	add_combat("rifle",2,[4,5,6,3],17,false)
	add_combat("guard_raise",3,[0,1,2,3],18,false)
	add_combat("guard",3,[4,5,6,5],6,true)
	add_old("rise",2,[1,2],10,false)
	add_old("apex",2,[3],1,false)
	add_old("fall",2,[4],1,false)
	add_old("wall",2,[5],1,false)
	add_old("land",3,[0,1,2,3,4,5],24,false)
	var actions = preload("res://prototype/animations/actions.tres")
	for action in ["sword","grenade","energy","crouch","prone_crawl","climb"]:
		sprite_frames.add_animation(action)
		sprite_frames.set_animation_speed(action,14)
		sprite_frames.set_animation_loop(action,false)
		for i in actions.get_frame_count(action): sprite_frames.add_frame(action,actions.get_frame_texture(action,i))
	for definition in [["crouch_enter","crouch",[0,1,2,3,4,5],14,false],["crouch_hold","crouch",[5],1,true],["prone_idle","prone_crawl",[2],1,true],["energy_charge","energy",[0,1,2],5,true],["energy_release","energy",[3,4,5],10,false]]:
		sprite_frames.add_animation(definition[0])
		sprite_frames.set_animation_speed(definition[0],definition[3])
		sprite_frames.set_animation_loop(definition[0],definition[4])
		for i in definition[2]: sprite_frames.add_frame(definition[0],actions.get_frame_texture(definition[1],i))
	sprite_frames.set_animation_loop("prone_crawl",true)
	var aerial = preload("res://prototype/animations/air_kick.tres")
	sprite_frames.add_animation("air_kick")
	sprite_frames.set_animation_speed("air_kick",14)
	sprite_frames.set_animation_loop("air_kick",false)
	for i in aerial.get_frame_count("air_kick"): sprite_frames.add_frame("air_kick",aerial.get_frame_texture("air_kick",i))
	var melee_library = preload("res://prototype/animations/melee_v11.tres")
	for action in ["punch","kick"]:
		sprite_frames.add_animation(action)
		sprite_frames.set_animation_speed(action,melee_library.get_animation_speed(action))
		sprite_frames.set_animation_loop(action,false)
		for i in melee_library.get_frame_count(action): sprite_frames.add_frame(action,melee_library.get_frame_texture(action,i))
	var specials = preload("res://prototype/animations/special_melee_v12.tres")
	for action in ["uppercut","reverse_kick","double_kick"]:
		sprite_frames.add_animation(action)
		sprite_frames.set_animation_speed(action,specials.get_animation_speed(action))
		sprite_frames.set_animation_loop(action,false)
		for i in specials.get_frame_count(action): sprite_frames.add_frame(action,specials.get_frame_texture(action,i))
	sprite_frames.add_animation("somersault")
	sprite_frames.set_animation_speed("somersault",9)
	sprite_frames.set_animation_loop("somersault",false)
	for i in [1,2,3,4]: sprite_frames.add_frame("somersault",actions.get_frame_texture("roll",i))
	sprite_frames.add_animation("ladder_climb")
	sprite_frames.set_animation_speed("ladder_climb",10)
	sprite_frames.set_animation_loop("ladder_climb",true)
	for i in actions.get_frame_count("climb"): sprite_frames.add_frame("ladder_climb",actions.get_frame_texture("climb",i))
	play("idle")
func add_combat(label: String,row: int,columns: Array,fps: float,looped: bool):
	sprite_frames.add_animation(label)
	sprite_frames.set_animation_speed(label,fps)
	sprite_frames.set_animation_loop(label,looped)
	for column in columns:
		var texture := AtlasTexture.new()
		texture.atlas = COMBAT
		var bounds: Array = REGIONS[row][column]
		var region := Rect2(bounds[0],bounds[1],bounds[2],bounds[3])
		texture.region = region
		texture.margin = Rect2(Vector2(256-(ANCHORS[row][column]-region.position.x),352-(ROWS[row+1]-region.position.y)),Vector2(512,384)-region.size)
		texture.filter_clip = true
		sprite_frames.add_frame(label,texture)
func add_old(label: String,row: int,columns: Array,fps: float,looped: bool):
	sprite_frames.add_animation(label)
	sprite_frames.set_animation_speed(label,fps)
	sprite_frames.set_animation_loop(label,looped)
	for column in columns:
		var texture := AtlasTexture.new()
		texture.atlas = SHEET
		texture.region = Rect2(column*256,row*256,256,256)
		texture.filter_clip = true
		sprite_frames.add_frame(label,texture)
func _process(delta):
	if not is_instance_valid(actor): return
	clock += delta
	var grounded := actor.is_on_floor()
	if grounded and not was_grounded:
		landing_time = 0.14
		squash = 0.06
	landing_time = maxf(0,landing_time-delta)
	squash = lerpf(squash,0,1-exp(-18*delta))
	var target := "idle"
	if not grounded:
		if actor.is_on_wall(): target = "wall"
		elif actor.velocity.y < 0: target = "armed_rise"
		else: target = "armed_fall"
	elif absf(actor.velocity.x)>5: target = "armed_run"
	elif actor.armed_time>0: target = "rifle"
	if actor.posture=="crouch" and grounded: target = "crouch_hold"
	elif actor.posture=="prone" and grounded: target = "prone_crawl" if absf(actor.velocity.x)>1 else "prone_idle"
	if actor.power_charge>0: target = "energy_charge"
	elif actor.power_cast>0: target = "energy_release"
	elif actor.grenade_time>0: target = "grenade"
	if actor.guarding:
		if actor.posture=="prone":
			target = "prone_idle"
			guard_started = false
		else:
			if not guard_started:
				guard_started = true
				play("guard_raise")
			target = "guard_raise" if animation=="guard_raise" and is_playing() else "guard"
	else: guard_started = false
	if actor.somersault_time>0: target = "somersault"
	if actor.melee_time>0: target = actor.melee_kind
	if actor.climbing: target = "ladder_climb"
	if target!=animation:
		stop()
		play(target)
	apply_visuals(target)
	var breath := sin(clock*2.4)*0.004 if target=="idle" else 0.0
	scale.y *= 1+breath
	speed_scale = 1
	if target=="armed_run": speed_scale = clampf(absf(actor.velocity.x)/72,0.35,1.15)
	elif target=="ladder_climb": speed_scale = 1 if absf(Input.get_axis("climb_up","posture_down"))>0.05 else 0
	modulate = actor.get_node("Sprite2D").modulate
	if actor.guard_impact>0: modulate = Color(1.3,1.7,2)
	was_posture = actor.posture
	was_grounded = grounded

func apply_visuals(target: String):
	position = Vector2.ZERO
	rotation = 0
	var old_pose: bool = target in ["rise","apex","fall","wall","land"]
	var melee: bool = target in ["punch","kick","sword","grenade","energy","energy_charge","energy_release","prone_crawl","prone_idle","crouch_enter","crouch_hold"]
	offset = Vector2(-128,-256) if old_pose else Vector2(-256,-352)
	var size := 0.132 if old_pose else (0.12 if melee else 0.145)
	if target in ["sword","grenade","energy","energy_charge","energy_release"]: size *= 1.5
	if target in ["crouch_enter","crouch_hold"] or (actor.guarding and actor.posture=="crouch"): size = 0.1
	if target=="air_kick":
		offset = Vector2(-300,-580)
		size = 0.072
	if target in ["punch","kick","uppercut","reverse_kick","double_kick"]:
		offset = Vector2(-384,-480)
		size = 0.095
		if target in ["uppercut","reverse_kick","double_kick"]: size = 0.105
		if target=="double_kick": position.y = -10*sin(PI*clampf(actor.melee_elapsed/0.72,0,1))
	elif target=="somersault":
		offset = Vector2(-256,-280)
		position = Vector2(0,-14)
		size = 0.12
		rotation = actor.facing*TAU*clampf(1-actor.somersault_time/0.48,0,1)
	elif target=="ladder_climb": size = 0.132
	scale = Vector2(actor.facing*size*(1+squash*0.5),size*(1-squash))

const MUZZLE_RUN := [[229,312],[462,313],[683,319],[900,314],[1132,313],[1366,313],[1579,313]]
const MUZZLE_RIFLE := [[202,510],[419,518],[635,508],[852,514],[1089,504],[1305,513],[1524,513]]
func prepare_weapon_muzzle() -> Vector2:
	var target := "rifle"
	if not actor.is_on_floor(): target = "armed_rise" if actor.velocity.y<0 else "armed_fall"
	elif absf(actor.velocity.x)>5: target = "armed_run"
	if target=="rifle" or animation!=target:
		stop()
		play(target)
	apply_visuals(target)
	return muzzle_global_position()
func muzzle_global_position() -> Vector2:
	var column := 0
	var point := Vector2.ZERO
	if animation=="armed_run":
		column = [0,1,2,3,4,5,6,3][frame]
		point = Vector2(MUZZLE_RUN[column][0],MUZZLE_RUN[column][1])
	elif animation in ["armed_rise","armed_fall"]:
		column = 2 if animation=="armed_rise" else 3
		point = Vector2(MUZZLE_RUN[column][0],MUZZLE_RUN[column][1])
	else:
		column = [4,5,6,3][frame] if animation=="rifle" else 0
		point = Vector2(MUZZLE_RIFLE[column][0],MUZZLE_RIFLE[column][1])
	var texture: AtlasTexture = sprite_frames.get_frame_texture(animation,frame)
	return to_global(offset+texture.margin.position+point-texture.region.position)
