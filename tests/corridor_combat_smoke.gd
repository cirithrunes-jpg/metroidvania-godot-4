extends SceneTree
var failures := 0
var checks := 0
func check(ok: bool, message: String):
	checks += 1
	if ok: print("PASS: "+message)
	else:
		failures += 1
		push_error(message)
func ticks(n: int):
	for i in n:
		await physics_frame
		await process_frame
func _initialize(): call_deferred("run")
func capture(path: String):
	if DisplayServer.get_name() == "headless": return
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(path)
func run():
	change_scene_to_file("res://prototype/laboratory.tscn")
	await ticks(12)
	var scene = current_scene
	var actor = scene.player
	for unit in get_nodes_in_group("lab_enemies"): unit.set_physics_process(false)
	check(scene.corridor_width == 1920 and scene.floors.size()>=15,"corridor doubled with additional platforms")
	check(get_nodes_in_group("lab_enemies").size()==11,"larger security deployment")
	var mouse_bound := false
	for event in InputMap.action_get_events("fire"):
		if event is InputEventMouseButton: mouse_bound = true
	check(not mouse_bound,"shooting has no mouse binding")
	Input.action_press("move_left")
	await ticks(4)
	Input.action_release("move_left")
	await ticks(10)
	check(actor.facing == -1,"walking changes retained facing")
	actor.get_node("PlayerBlaster").fire_bullet()
	var rounds = get_nodes_in_group("player_rounds")
	check(rounds.size()>0 and rounds[-1].velocity.x<0 and is_zero_approx(rounds[-1].velocity.y),"shot travels horizontally toward facing")
	var hp: int = root.get_node("PlayerStats").health
	Input.action_press("guard")
	await ticks(2)
	var shot := Area2D.new()
	shot.add_to_group("enemy_projectiles")
	scene.add_child(shot)
	actor._on_hurtbox_hurt(shot,1)
	actor._on_hurtbox_hurt(shot,1)
	check(actor.shield_hits == 2 and root.get_node("PlayerStats").health==hp,"guard absorbs exactly first two shots without health loss")
	await capture("res://artifacts/guard-v7-preview.png")
	actor._on_hurtbox_hurt(shot,1)
	check(actor.shield_hits==3 and not actor.guarding and actor.stagger>0,"third shot breaks shield")
	check(actor.velocity.x>100 and root.get_node("PlayerStats").health==hp-1,"shield break causes damage and backward knockback")
	Input.action_release("guard")
	await ticks(130)
	check(actor.shield_hits==0 and actor.shield_recovery<=0,"shield recovers after break cooldown")
	shot.queue_free()
	actor.position = Vector2(90,300)
	actor.velocity = Vector2.ZERO
	actor.facing = 1
	var target = get_nodes_in_group("lab_enemies")[2]
	target.position = Vector2(115,300)
	await ticks(3)
	Input.action_press("attack_punch")
	await ticks(18)
	Input.action_release("attack_punch")
	check(target.health==3,"punch hits nearby armored soldier once")
	check(actor.get_node("Specimen").animation=="punch","punch uses action animation")
	await ticks(17)
	Input.action_press("attack_kick")
	await ticks(18)
	Input.action_release("attack_kick")
	check(target.health==1,"kick deals two damage once")
	await ticks(24)
	check(actor.get_node("Specimen").sprite_frames.get_frame_count("idle")==1,"idle holds registered pose without frame jitter")
	actor.position = Vector2(520,300)
	actor.velocity = Vector2.ZERO
	await ticks(3)
	Input.action_press("move_right")
	Input.action_press("jump")
	await ticks(51)
	Input.action_release("jump")
	Input.action_release("move_right")
	await ticks(10)
	check(actor.position.y<270 and actor.is_on_floor(),"first upper platform reachable using actual jump movement")
	for step in 3:
		Input.action_press("move_right")
		var budget := 120
		while actor.position.x < 618+step*90 and budget>0:
			await ticks(1)
			budget -= 1
		Input.action_press("jump")
		await ticks(51)
		Input.action_release("jump")
		Input.action_release("move_right")
		await ticks(10)
		check(actor.is_on_floor() and absf(actor.position.y-(228-step*36))<3,"upper button route step %d is physically reachable" % (step+1))
	actor.position = scene.relay_point+Vector2(0,-2)
	actor.velocity = Vector2.ZERO
	await ticks(4)
	check(not scene.relay,"button requires interaction rather than proximity")
	Input.action_press("interact")
	await ticks(2)
	Input.action_release("interact")
	check(scene.relay and not scene.paused,"E activates high button without pausing")
	actor.position = Vector2(620,264)
	actor.velocity = Vector2.ZERO
	actor.get_node("Camera2D").reset_smoothing()
	await ticks(12)
	await capture("res://artifacts/corridor-v7-preview.png")
	change_scene_to_file("res://prototype/sector_2.tscn")
	await ticks(10)
	scene = current_scene
	for unit in get_nodes_in_group("lab_enemies"): unit.set_physics_process(false)
	check(scene.door_point.y==156 and scene.relay_point.y==156,"second corridor has elevated exit and button")
	scene.player.position = Vector2(1510,300)
	scene.player.velocity = Vector2.ZERO
	await ticks(3)
	for step in 4:
		Input.action_press("move_right")
		var budget := 100
		var takeoff: float = 1510 if step==0 else 1518+step*90
		while scene.player.position.x < takeoff and budget>0:
			await ticks(1)
			budget -= 1
		Input.action_press("jump")
		await ticks(51)
		Input.action_release("jump")
		Input.action_release("move_right")
		await ticks(10)
		check(scene.player.is_on_floor() and absf(scene.player.position.y-(264-step*36))<3,"second corridor exit step %d is physically reachable" % (step+1))
	scene.relay = true
	scene.player.position = Vector2(scene.door_point.x,300)
	scene.player.set_physics_process(false)
	await ticks(50)
	check(scene.exit_door.openness==0 and not scene.transitioning,"standing below elevated door cannot trigger transition")
	scene.player.position = scene.door_point+Vector2(-30,0)
	scene.player.get_node("Camera2D").reset_smoothing()
	await ticks(20)
	await capture("res://artifacts/raised-door-v7-preview.png")
	change_scene_to_file("res://prototype/intro.tscn")
	await ticks(10)
	if FileAccess.file_exists("res://prototype/assets/video/introduction.ogv"):
		check(current_scene.video.stream is VideoStreamTheora and current_scene.video.is_playing(),"supplied video starts in introduction")
		await capture("res://artifacts/intro-v7-preview.png")
		await create_timer(14.0).timeout
		await ticks(8)
	else:
		await create_timer(3.5).timeout
		check(current_scene.scene_file_path=="res://prototype/laboratory.tscn","missing local video safely skipped after mission")
	check(current_scene.scene_file_path=="res://prototype/laboratory.tscn","video completion opens first corridor")
	root.get_node("Music").audio_stream_player.stop()
	for sound in root.get_node("Sound").sound_players: sound.stop()
	await create_timer(0.1).timeout
	print("RESULT: %d checks, %d failures" % [checks,failures])
	quit(failures)
