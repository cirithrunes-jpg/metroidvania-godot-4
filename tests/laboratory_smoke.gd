extends SceneTree

var failures := 0
var checks := 0
func check(condition: bool, message: String):
	checks += 1
	if condition: print("PASS: "+message)
	else:
		failures += 1
		push_error(message)

func ticks(count: int):
	for index in count:
		await physics_frame
		await process_frame

func settle(seconds: float):
	await create_timer(seconds).timeout
	await process_frame

func _initialize(): call_deferred("run")

func freeze_units():
	for unit in get_nodes_in_group("lab_enemies"): unit.set_physics_process(false)

func capture(path: String):
	if DisplayServer.get_name() == "headless": return
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(path)

func run():
	change_scene_to_file("res://prototype/laboratory.tscn")
	await ticks(20)
	var scene = current_scene
	freeze_units()
	check(is_instance_valid(scene.player),"new player spawns")
	check(scene.player.scene_file_path == "res://prototype/player.tscn","legacy model excluded from active player")
	check(scene.player.get_node("Sprite2D").texture == null,"old character texture is not loaded")
	check(scene.player.is_on_floor(),"solid floor supports player")
	check(scene.hud.health.get_theme_font_size("font_size") >= 24,"HUD uses readable font size")
	check(ProjectSettings.get_setting("physics/common/physics_interpolation"),"physics interpolation enabled")
	var music = root.get_node("Music").audio_stream_player
	check(music.stream is AudioStreamMP3 and music.stream.loop and music.playing,"supplied soundtrack plays on loop")
	var art = scene.player.get_node("Specimen")
	check(art.sprite_frames.get_frame_count("run") == 6,"running atlas has six frames")
	var initial_x: float = scene.player.position.x
	Input.action_press("move_right")
	await ticks(30)
	check(scene.player.position.x > initial_x+20,"controller accelerates into movement")
	check(art.animation == "run","run animation follows movement")
	Input.action_release("move_right")
	await ticks(16)
	check(absf(scene.player.velocity.x)<0.5,"controller brakes without drifting")
	Input.action_press("jump")
	await ticks(6)
	Input.action_release("jump")
	check(scene.player.position.y<290,"jump takes player off floor")
	await ticks(2)
	Input.action_press("jump")
	await ticks(2)
	Input.action_release("jump")
	check(scene.player.velocity.y < -95,"double jump responds")
	scene.player.get_node("PlayerBlaster").fire_bullet()
	await ticks(1)
	check(get_nodes_in_group("player_rounds").size()>0,"new ballistic projectile spawns")
	check(scene.level.get_child_count()>=2,"muzzle flash accompanies projectile")
	scene.player.position = Vector2(110,296)
	scene.player.velocity = Vector2.ZERO
	scene.player.reset_physics_interpolation()
	scene.player.get_node("Camera2D").reset_smoothing()
	await ticks(24)
	await capture("res://artifacts/laboratorio-v6-preview.png")
	scene.player.position = scene.relay_point+Vector2(0,-4)
	Input.action_press("interact")
	await ticks(3)
	Input.action_release("interact")
	check(scene.relay,"relay unlocks door")
	scene.player.position = Vector2(1050,410)
	await ticks(3)
	check(scene.player.position.distance_to(scene.checkpoint)<10,"fall returns to checkpoint")
	var old_player = scene.player
	scene.player.die()
	await settle(1.3)
	check(is_instance_valid(scene.player) and scene.player != old_player,"death respawns new controller")
	scene.toggle_pause()
	await ticks(2)
	check(scene.paused and scene.player.process_mode == Node.PROCESS_MODE_DISABLED,"pause freezes player")
	scene.toggle_pause()
	await ticks(2)
	check(not scene.paused,"pause resumes player")
	for sector in [1,2,3]:
		scene = current_scene
		freeze_units()
		check(scene.sector == sector,"sector %d loads" % sector)
		scene.player.position = scene.door_point
		scene.player.velocity = Vector2.ZERO
		scene.player.set_physics_process(false)
		scene.relay = false
		await settle(0.15)
		check(scene.exit_door.openness<0.01 and not scene.exit_door.gate.disabled,"sector %d door physically stays locked before relay" % sector)
		scene.relay = true
		await settle(0.38)
		check(scene.exit_door.openness>0.1 and scene.exit_door.openness<0.95,"sector %d door responds with opening animation" % sector)
		if sector==1:
			scene.player.get_node("Camera2D").reset_smoothing()
			await capture("res://artifacts/door-v6-preview.png")
		await settle(0.9)
	check(current_scene.scene_file_path == "res://prototype/ui/completed.tscn","last door leads to campaign completion")
	var buttons = current_scene.find_children("*","Button",true,false)
	check(buttons.size()==2,"menu has only current game and quit")
	check(not current_scene.has_node("CenterContainer"),"legacy version removed from menu")
	await capture("res://artifacts/menu-v6-preview.png")
	current_scene._on_start_button_pressed()
	await ticks(8)
	if FileAccess.file_exists("res://prototype/assets/video/introduction.ogv"):
		check(current_scene.scene_file_path == "res://prototype/intro.tscn","replay begins video introduction")
		current_scene.start_level()
		await ticks(8)
	else:
		check(current_scene.scene_file_path == "res://prototype/laboratory.tscn","missing local video safely skips introduction")
	check(current_scene.sector==1,"intro skip begins first corridor")
	root.get_node("Music").audio_stream_player.stop()
	for sound in root.get_node("Sound").sound_players: sound.stop()
	await settle(0.1)
	print("RESULT: %d checks, %d failures" % [checks,failures])
	quit(failures)
