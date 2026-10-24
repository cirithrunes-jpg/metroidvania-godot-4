extends SceneTree
var failures := 0
var checks := 0
func check(ok: bool,text: String):
	checks += 1
	if ok: print("PASS: "+text)
	else:
		failures += 1
		push_error(text)
func ticks(n: int):
	for i in n:
		await physics_frame
		await process_frame
func capture(path: String):
	if DisplayServer.get_name()=="headless": return
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(path)
func pad(button: JoyButton,down: bool):
	var event := InputEventJoypadButton.new()
	event.button_index = button
	event.pressed = down
	Input.parse_input_event(event)
func stick(value: float):
	var event := InputEventJoypadMotion.new()
	event.axis = JOY_AXIS_LEFT_X
	event.axis_value = value
	Input.parse_input_event(event)
func _initialize(): call_deferred("run")
func run():
	var save_path := ProjectSettings.globalize_path("user://cyberpunk_campaign_v1.json")
	var original := PackedByteArray()
	var had_save := FileAccess.file_exists(save_path)
	if had_save: original = FileAccess.get_file_as_bytes(save_path)
	change_scene_to_file("res://prototype/mission.tscn")
	await ticks(8)
	check(current_scene.caption.text=="MISSÃO:\nPROTOCOLO DE COMBATE ATIVADO","exact mission wording")
	await create_timer(1).timeout
	await capture("res://artifacts/mission-v8.png")
	await create_timer(2.5).timeout
	check(current_scene.scene_file_path=="res://prototype/laboratory.tscn","mission fades into gameplay automatically")
	var scene = current_scene
	var actor = scene.player
	for unit in get_nodes_in_group("lab_enemies"): unit.set_physics_process(false)
	var art = actor.get_node("Specimen")
	check(art.get_child_count()==0 and actor.get_node("PlayerBlaster/BlasterSprite").get_child_count()==1,"no ghost sprite or placeholder gun geometry")
	check(art.sprite_frames.get_frame_count("armed_run")==8,"armed running cycle available")
	await ticks(15)
	check(art.animation=="idle" and art.sprite_frames.get_frame_texture("idle",0).atlas.resource_path.ends_with("specimen-combat-v8.png"),"idle uses actual rifle-in-hands artwork")
	await capture("res://artifacts/armed-v8.png")
	stick(0.8)
	await ticks(25)
	check(actor.velocity.x>30 and art.animation=="armed_run","left stick drives animated armed running")
	var frame_a: int = art.frame
	var progressed := false
	for i in 12:
		await ticks(1)
		if art.frame!=frame_a: progressed = true
	check(progressed,"running advances across poses")
	await capture("res://artifacts/running-v8.png")
	stick(0)
	await ticks(15)
	pad(JOY_BUTTON_A,true)
	await ticks(3)
	pad(JOY_BUTTON_A,false)
	check(actor.velocity.y<0,"fixed X/cross jumps")
	await ticks(85)
	pad(JOY_BUTTON_B,true)
	await ticks(30)
	check(actor.guarding and art.animation=="guard" and art.is_playing(),"Circle/B reaches animated sustained guard")
	var shot := Area2D.new()
	shot.add_to_group("enemy_projectiles")
	scene.add_child(shot)
	var health: int = root.get_node("PlayerStats").health
	actor._on_hurtbox_hurt(shot,1)
	actor._on_hurtbox_hurt(shot,1)
	check(actor.shield_hits==2 and root.get_node("PlayerStats").health==health,"controller guard blocks two shots")
	await ticks(2)
	await capture("res://artifacts/guard-v8.png")
	actor._on_hurtbox_hurt(shot,1)
	check(actor.stagger>0 and not actor.guarding,"third shot visibly breaks guard")
	pad(JOY_BUTTON_B,false)
	shot.queue_free()
	await ticks(130)
	pad(JOY_BUTTON_RIGHT_SHOULDER,true)
	await ticks(2)
	pad(JOY_BUTTON_RIGHT_SHOULDER,false)
	check(actor.armed_time>0,"R1/RB fires rifle and triggers recoil animation")
	var audible := false
	for player in root.get_node("Sound").sound_players:
		if player.playing and player.stream.resource_path.ends_with("rifle-shot.wav"): audible = true
	check(audible,"rifle fires with dedicated sound")
	actor.invulnerability = 0
	actor._on_hurtbox_hurt(null,1)
	var voice := false
	for player in root.get_node("Sound").sound_players:
		if player.playing and "hurt-voice" in player.stream.resource_path: voice = true
	check(voice,"damage triggers female pain vocalization")
	scene.toggle_pause()
	await ticks(2)
	check(scene.paused and scene.pause_menu.visible and not actor.can_process(),"pause exposes menu and freezes gameplay")
	await capture("res://artifacts/pause-v8.png")
	scene.pause_menu.show_controls()
	await ticks(2)
	check(scene.pause_menu.controls.visible,"controls page opens")
	await capture("res://artifacts/controls-v8.png")
	scene.pause_menu.hide_controls()
	scene.relay = true
	scene.checkpoint = scene.relay_checkpoint
	root.get_node("PlayerStats").health = 3
	var enemy = get_nodes_in_group("lab_enemies")[0]
	enemy.take_damage(null,99)
	await ticks(3)
	check(root.get_node("CampaignSave").save_scene(scene),"save writes progress successfully")
	check(root.get_node("CampaignSave").save_scene(scene),"save overwrites previous record atomically")
	check(not root.get_node("CampaignSave").read_record().is_empty(),"saved record validates")
	change_scene_to_file("res://menus/start_menu.tscn")
	await ticks(5)
	var found := false
	for button in current_scene.find_children("*","Button",true,false):
		if button.text=="Continuar progresso salvo": found = true
	check(found,"main menu offers saved-game continuation")
	root.get_node("CampaignSave").continue_game()
	await ticks(5)
	scene = current_scene
	for unit in get_nodes_in_group("lab_enemies"): unit.set_physics_process(false)
	check(scene.sector==1 and scene.relay and root.get_node("PlayerStats").health==3,"continue restores sector button and health")
	check(get_nodes_in_group("lab_enemies").size()==10,"defeated enemy remains defeated after loading")
	check(scene.player.position.distance_to(scene.relay_checkpoint)<10,"continue resumes from activated checkpoint")
	if had_save:
		var file := FileAccess.open(save_path,FileAccess.WRITE)
		file.store_buffer(original)
		file.close()
	else: DirAccess.remove_absolute(save_path)
	root.get_node("Music").audio_stream_player.stop()
	for sound in root.get_node("Sound").sound_players: sound.stop()
	await create_timer(0.1).timeout
	print("RESULT: %d checks, %d failures" % [checks,failures])
	quit(failures)
