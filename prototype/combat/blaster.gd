extends Node2D

const ROUND = preload("res://prototype/combat/player_round.gd")
const FX = preload("res://prototype/combat/ballistic_fx.gd")
var recoil := 0.0
@onready var blaster_sprite = $BlasterSprite
@onready var muzzle = $BlasterSprite/Muzzle

func _process(delta):
	recoil = move_toward(recoil,0,24*delta)
	blaster_sprite.rotation = 0 if get_parent().facing > 0 else PI
	blaster_sprite.position.x = -get_parent().facing*recoil

func fire_bullet():
	blaster_sprite.rotation = 0 if get_parent().facing > 0 else PI
	var direction := Vector2(get_parent().facing,0)
	var bullet := Node2D.new()
	bullet.set_script(ROUND)
	bullet.velocity = direction*520
	MainInstances.level.add_child(bullet)
	bullet.global_position = muzzle.global_position
	var flash := Node2D.new()
	flash.set_script(FX)
	flash.mode = "muzzle"
	flash.direction = direction
	MainInstances.level.add_child(flash)
	flash.global_position = muzzle.global_position
	recoil = 1.3
	Sound.play(Sound.bullet,randf_range(0.8,0.93),-13)

func fire_missile():
	fire_bullet()
