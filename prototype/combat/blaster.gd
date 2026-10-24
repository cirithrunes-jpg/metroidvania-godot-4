extends Node2D
const ROUND = preload("res://prototype/combat/player_round.gd")
const FX = preload("res://prototype/combat/ballistic_fx.gd")
var recoil := 0.0
var last_muzzle := Vector2.ZERO
@onready var blaster_sprite = $BlasterSprite
@onready var muzzle = $BlasterSprite/Muzzle
func _process(delta):
	recoil = move_toward(recoil,0,24*delta)
	blaster_sprite.rotation = 0 if get_parent().facing>0 else PI
func effect(mode: String,point: Vector2,direction: Vector2):
	var item := Node2D.new()
	item.set_script(FX)
	item.mode = mode
	item.direction = direction
	MainInstances.level.add_child(item)
	item.global_position = point
func fire_bullet():
	var actor = get_parent()
	if actor.somersault_time>0 or actor.climbing: return
	actor.armed_time = 0.28
	var direction := Vector2(actor.facing,0)
	last_muzzle = actor.get_node("Specimen").prepare_weapon_muzzle()
	var query := PhysicsRayQueryParameters2D.create(actor.global_position+Vector2(0,-18),last_muzzle,97)
	query.collide_with_areas = true
	query.hit_from_inside = true
	var obstruction: Dictionary = actor.get_world_2d().direct_space_state.intersect_ray(query)
	effect("muzzle",last_muzzle,direction)
	if not obstruction.is_empty():
		if obstruction.collider is Hurtbox: obstruction.collider.take_hit(self,1)
		effect("impact",obstruction.position,-direction)
	else:
		var bullet := Node2D.new()
		bullet.set_script(ROUND)
		bullet.velocity = direction*520
		MainInstances.level.add_child(bullet)
		bullet.global_position = last_muzzle
	recoil = 1.3
	Sound.play(preload("res://prototype/assets/audio/rifle-shot.wav"),randf_range(0.96,1.04),-7)
func fire_missile(): fire_bullet()
