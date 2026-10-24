extends SceneTree

var failures := 0
var checks := 0
func check(condition: bool,message: String):
	checks += 1
	if condition: print("PASS: "+message)
	else:
		failures += 1
		push_error(message)
func ticks(count: int):
	for index in count:
		await physics_frame
		await process_frame
func _initialize(): call_deferred("run")
func shoot(scene, point: Vector2):
	var round := Node2D.new()
	round.set_script(load("res://prototype/combat/player_round.gd"))
	round.velocity = Vector2(520,0)
	scene.level.add_child(round)
	round.global_position = point
	return round
func run():
	change_scene_to_file("res://prototype/laboratory.tscn")
	await ticks(4)
	var scene = current_scene
	scene.player.set_physics_process(false)
	var units = get_nodes_in_group("lab_enemies")
	for unit in units: unit.set_physics_process(false)
	var target = units[0]
	target.position = Vector2(150,152)
	var bullet = shoot(scene,Vector2(112,138))
	await ticks(5)
	check(target.health==1,"fast swept projectile damages enemy once")
	check(not is_instance_valid(bullet),"projectile stops on enemy impact")
	check(scene.level.get_child_count()>0,"impact spawns sparks")
	await ticks(30)
	check(scene.level.get_child_count()==0,"impact effects expire")
	var wall := StaticBody2D.new()
	var collider := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(8,70)
	collider.shape = shape
	wall.position = Vector2(130,120)
	wall.add_child(collider)
	scene.add_child(wall)
	await ticks(2)
	bullet = shoot(scene,Vector2(112,138))
	await ticks(6)
	check(not is_instance_valid(bullet),"fast projectile cannot tunnel through wall")
	check(target.health==1,"wall protects enemy behind it")
	wall.queue_free()
	await ticks(30)
	bullet = shoot(scene,Vector2(20,40))
	await ticks(110)
	check(not is_instance_valid(bullet),"offscreen projectile expires")
	root.get_node("Music").audio_stream_player.stop()
	for sound in root.get_node("Sound").sound_players: sound.stop()
	await create_timer(0.1).timeout
	print("RESULT: %d checks, %d failures" % [checks,failures])
	quit(failures)
