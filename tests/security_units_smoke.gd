extends SceneTree

var failures := 0
func check(condition: bool, message: String):
	if condition: print("PASS: "+message)
	else:
		failures += 1
		push_error(message)

func ticks(count: int):
	for index in count:
		await physics_frame
		await process_frame

func _initialize():
	call_deferred("run")

func run():
	var scene = load("res://prototype/laboratory.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await ticks(4)
	var units = get_nodes_in_group("lab_enemies")
	check(units.size() == 11,"expanded squad contains eleven units")
	var kinds := []
	for unit in units:
		kinds.append(unit.kind)
		unit.set_physics_process(false)
		check(unit.visual.sprite_frames.get_frame_count("default") == 6,"six animation frames for variant %d" % unit.kind)
	check(kinds.has(0) and kinds.has(1) and kinds.has(2) and kinds.has(3) and kinds.has(4),"all five roles deployed")
	check(units[2].health > units[0].health and units[7].health > units[2].health,"armor and robot have distinct resistance")
	scene.player.set_physics_process(false)
	var patrol = units[0]
	patrol.position = Vector2(90,300)
	patrol.origin = patrol.position
	scene.player.position = Vector2(145,300)
	patrol.cooldown = 0
	patrol.set_physics_process(true)
	await ticks(2)
	check(patrol.warning > 0,"visible target starts warning before firing")
	check(scene.level.get_child_count() == 0,"warning gives time before first projectile")
	await ticks(50)
	check(scene.level.get_child_count() > 0,"single projectile fires after warning")
	patrol.set_physics_process(false)
	await ticks(60)
	check(root.get_node("PlayerStats").health < root.get_node("PlayerStats").max_health,"security shot damages player")
	var wall := StaticBody2D.new()
	var collider := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(8,70)
	collider.shape = box
	wall.position = Vector2(120,270)
	wall.add_child(collider)
	scene.add_child(wall)
	await ticks(2)
	check(not patrol.has_line_of_sight(scene.player.position+Vector2(0,-13)),"solid wall blocks line of sight")
	for child in scene.level.get_children(): child.queue_free()
	await ticks(2)
	patrol.fire_round()
	await ticks(60)
	check(scene.level.get_child_count() == 0,"solid wall stops security projectile and impact expires")
	wall.queue_free()
	await ticks(2)
	var drone = units[9]
	var start_y: float = drone.position.y
	drone.set_physics_process(true)
	await ticks(35)
	drone.set_physics_process(false)
	check(absf(drone.position.y-start_y) < 8,"drone hovers without falling")
	patrol.position = Vector2(430,300)
	patrol.origin = Vector2(420,300)
	patrol.facing = 1
	patrol.cooldown = 100
	scene.player.position = Vector2(36,300)
	patrol.set_physics_process(true)
	await ticks(60)
	patrol.set_physics_process(false)
	check(patrol.position.x < 436 and patrol.position.y < 303,"patrol turns before a pit")
	var armor = units[2]
	armor.take_damage(null,1)
	check(armor.health == 3,"player damage reduces armored health")
	armor.take_damage(null,10)
	await ticks(2)
	check(not is_instance_valid(armor),"lethal damage removes unit")
	root.get_node("Music").audio_stream_player.stop()
	for sound in root.get_node("Sound").sound_players: sound.stop()
	await create_timer(0.1).timeout
	print("RESULT: %d failures" % failures)
	quit(failures)
