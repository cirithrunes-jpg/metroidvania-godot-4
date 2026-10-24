extends AnimatedSprite2D
const SHEET = preload("res://prototype/assets/specimen-female-v2.png")
const COMBAT = preload("res://prototype/assets/specimen-combat-v8.png")
var actor: CharacterBody2D
var clock := 0.0
var was_grounded := true
var landing_time := 0.0
var squash := 0.0
var guard_started := false
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
	for action in ["punch","kick"]:
		sprite_frames.add_animation(action)
		sprite_frames.set_animation_speed(action,14)
		sprite_frames.set_animation_loop(action,false)
		for i in actions.get_frame_count(action): sprite_frames.add_frame(action,actions.get_frame_texture(action,i))
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
	if actor.guarding:
		if not guard_started:
			guard_started = true
			play("guard_raise")
		target = "guard_raise" if animation=="guard_raise" and is_playing() else "guard"
	else: guard_started = false
	if actor.melee_time>0: target = actor.melee_kind
	if target!=animation:
		stop()
		play(target)
	var old_pose: bool = target in ["rise","apex","fall","wall","land"]
	var melee: bool = target in ["punch","kick"]
	offset = Vector2(-128,-256) if old_pose else Vector2(-256,-352)
	var size := 0.132 if old_pose else (0.12 if melee else 0.145)
	var breath := sin(clock*2.4)*0.004 if target=="idle" else 0.0
	scale = Vector2(actor.facing*size*(1+squash*0.5),size*(1-squash+breath))
	speed_scale = clampf(absf(actor.velocity.x)/72,0.35,1.15) if target=="armed_run" else 1.0
	modulate = actor.get_node("Sprite2D").modulate
	if actor.guard_impact>0: modulate = Color(1.3,1.7,2)
	was_grounded = grounded
