extends SceneTree

var failures := 0

func check(condition: bool, message: String):
	if not condition:
		failures += 1
		push_error(message)
	else:
		print("PASS: " + message)

func ticks(count: int):
	for i in count:
		await physics_frame
		await process_frame

func _initialize():
	call_deferred("run")

func run():
	var scene = load("res://prototype/laboratory.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await ticks(20)
	check(is_instance_valid(scene.player), "player spawns")
	check(scene.player.is_on_floor(), "spawn has solid floor")
	var art = scene.player.get_node("Specimen")
	check(art.sprite_frames.get_frame_count("run") == 6, "female running cycle has six frames")
	check(art.animation == "idle", "female sprite settles into idle")
	var initial_x: float = scene.player.position.x
	Input.action_press("move_right")
	await ticks(40)
	Input.action_release("move_right")
	check(scene.player.position.x > initial_x + 20, "existing movement works")
	check(art.animation == "run", "running animation follows movement")
	Input.action_press("jump")
	await ticks(8)
	Input.action_release("jump")
	check(scene.player.position.y < 140, "jump leaves floor")
	check(art.animation in ["rise","apex","fall"], "airborne animation follows jump")
	Input.action_press("fire")
	await ticks(30)
	Input.action_release("fire")
	check(scene.level.get_child_count() > 0, "projectile/effect integration uses level")
	scene.player.position = Vector2(484,74)
	await ticks(2)
	check(scene.relay, "relay activates checkpoint")
	scene.player.position = Vector2(620,210)
	await ticks(2)
	check(scene.player.position.distance_to(scene.checkpoint) < 10, "fall returns to checkpoint")
	var old_player = scene.player
	scene.player.die()
	await create_timer(1.3).timeout
	check(is_instance_valid(scene.player) and scene.player != old_player, "death respawns")
	check(scene.player.position.distance_to(scene.checkpoint) < 20, "death preserves checkpoint")
	scene.toggle_pause()
	await ticks(2)
	check(scene.paused and scene.player.process_mode == Node.PROCESS_MODE_DISABLED, "pause freezes actor")
	await ticks(2)
	scene.toggle_pause()
	await ticks(2)
	check(not scene.paused, "pause resumes")
	scene.player.position = Vector2(920,146)
	await ticks(2)
	check(scene.finished, "exit completes only after relay")
	if not DisplayServer.get_name() == "headless":
		scene.finished = false
		scene.relay = false
		scene.player.position = Vector2(110,148)
		scene.player.velocity = Vector2.ZERO
		scene.player.process_mode = Node.PROCESS_MODE_INHERIT
		scene.player.get_node("Camera2D").reset_smoothing()
		await ticks(24)
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://artifacts/laboratorio-preview.png")
	change_scene_to_file("res://menus/start_menu.tscn")
	await ticks(4)
	check(current_scene.get_node("CenterContainer/VBoxContainer").get_child_count() == 5, "menu exposes prototype and original")
	current_scene._on_start_button_pressed()
	await ticks(8)
	check(current_scene.scene_file_path == "res://world.tscn", "original game still opens")
	print("RESULT: %d failures" % failures)
	root.get_node("Music").audio_stream_player.stop()
	await create_timer(0.1).timeout
	quit(failures)

