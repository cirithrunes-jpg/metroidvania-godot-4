extends AnimatedSprite2D

# Original generated atlas; the controller still owns movement and combat.
const SHEET = preload("res://prototype/assets/specimen-female-v2.png")
const CELL := Vector2(256,256)
const DRAW_SCALE := 0.132
var actor: CharacterBody2D
var clock := 0.0
var was_grounded := true
var landing_time := 0.0
var motion_blend := 0.0
var squash := 0.0
var facing := 1.0

func _ready():
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	centered = false
	offset = Vector2(-128,-256)
	sprite_frames = SpriteFrames.new()
	sprite_frames.remove_animation("default")
	add_sequence("idle",0,[0,1,2,3,4,5],7.0,true)
	add_sequence("run",1,[0,1,2,3,4,5],12.0,true)
	add_sequence("rise",2,[1,2],10.0,false)
	add_sequence("apex",2,[3],1.0,false)
	add_sequence("fall",2,[4],1.0,false)
	add_sequence("wall",2,[5],1.0,false)
	add_sequence("land",3,[0,1,2,3,4,5],24.0,false)
	play("idle")
	was_grounded = actor.is_on_floor()

func add_sequence(label: String, row: int, columns: Array, fps: float, looped: bool):
	sprite_frames.add_animation(label)
	sprite_frames.set_animation_speed(label,fps)
	sprite_frames.set_animation_loop(label,looped)
	for column in columns:
		var atlas := AtlasTexture.new()
		atlas.atlas = SHEET
		atlas.region = Rect2(Vector2(column,row)*CELL,CELL)
		atlas.filter_clip = true
		sprite_frames.add_frame(label,atlas)

func _process(delta):
	if not is_instance_valid(actor): return
	clock += delta
	var grounded := actor.is_on_floor()
	var blend := 1.0-exp(-14.0*delta)
	motion_blend = lerpf(motion_blend,clampf(absf(actor.velocity.x)/64.0,0,1),blend)
	facing = actor.get_node("Sprite2D").scale.x
	if grounded and not was_grounded:
		landing_time = 0.18
		squash = 0.10
	landing_time = maxf(0,landing_time-delta)
	squash = lerpf(squash,0,1.0-exp(-18.0*delta))
	var target := "idle"
	if not grounded:
		if actor.is_on_wall(): target = "wall"
		elif actor.velocity.y < -25: target = "rise"
		elif actor.velocity.y > 25: target = "fall"
		else: target = "apex"
	elif absf(actor.velocity.x) > 6:
		target = "run"
	elif landing_time > 0:
		target = "land"
	if animation != target: play(target)
	speed_scale = lerpf(0.65,1.15,motion_blend) if target == "run" else 1.0
	if target == "run" and actor.velocity.x*facing < 0: speed_scale *= -1.0
	var breathe := sin(clock*2.6)*0.004 if target == "idle" else 0.0
	scale = Vector2(facing*DRAW_SCALE*(1.0+squash*0.5),DRAW_SCALE*(1.0-squash+breathe))
	rotation = lerpf(rotation,clampf(actor.velocity.x/64.0,-1,1)*0.025,blend)
	modulate = actor.get_node("Sprite2D").modulate
	was_grounded = grounded
