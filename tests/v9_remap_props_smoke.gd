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
func key(code: Key) -> InputEventKey:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = true
	return event
func pad(code: JoyButton) -> InputEventJoypadButton:
	var event := InputEventJoypadButton.new()
	event.device = -1
	event.button_index = code
	event.pressed = true
	return event
func contains(action: String,event: InputEvent) -> bool:
	for entry in InputMap.action_get_events(action):
		if root.get_node("CombatInput").encode(entry)==root.get_node("CombatInput").encode(event): return true
	return false
func _initialize(): call_deferred("run")
func run():
	var mapping = root.get_node("CombatInput")
	var campaign = root.get_node("CampaignSave")
	var paths := [ProjectSettings.globalize_path(mapping.PATH),ProjectSettings.globalize_path(campaign.PATH)]
	var backups := {}
	for path in paths:
		if FileAccess.file_exists(path): backups[path] = FileAccess.get_file_as_bytes(path)
	var original := {}
	for action in mapping.ACTIONS: original[action] = InputMap.action_get_events(action).duplicate()
	mapping.restore_defaults()
	change_scene_to_file("res://menus/start_menu.tscn")
	await ticks(5)
	check(current_scene.get_node("MenuCanvas/GamePoster").texture.resource_path.ends_with("menu-poster.png"),"main menu displays original character poster")
	check(current_scene.get_node("MenuCanvas/GamePoster").size==Vector2(600,720),"poster fits designated area without cropping face or menu")
	await capture("res://artifacts/menu-v9.png")
	current_scene.open_controls()
	await ticks(3)
	var settings = current_scene.settings
	check(settings.rows.size()==11,"all eleven actions can be configured")
	check(settings.rows.fire.key.text.contains("Z"),"current keyboard binding is displayed")
	await capture("res://artifacts/settings-v9.png")
	settings.begin_capture("fire","key")
	settings.capture_delay = 0
	Input.parse_input_event(key(KEY_P))
	await ticks(2)
	check(contains("fire",key(KEY_P)) and not contains("fire",key(KEY_Z)),"capture replaces keyboard binding")
	settings.cancel_close()
	await ticks(2)
	check(contains("fire",key(KEY_Z)),"back without saving restores original commands")
	mapping.assign("fire",key(KEY_K))
	check(contains("fire",key(KEY_K)) and contains("attack_kick",key(KEY_Z)),"conflicting keyboard bindings swap actions")
	mapping.assign("fire",pad(JOY_BUTTON_A))
	check(contains("fire",pad(JOY_BUTTON_A)) and contains("jump",pad(JOY_BUTTON_RIGHT_SHOULDER)),"conflicting gamepad buttons swap actions")
	check(mapping.describe("fire","pad").contains("✕"),"gamepad label includes PlayStation symbol")
	var axis := InputEventJoypadMotion.new()
	axis.axis = JOY_AXIS_TRIGGER_LEFT
	axis.axis_value = 1
	axis.device = -1
	mapping.assign("guard",axis)
	check(contains("guard",axis),"analog trigger can be assigned")
	mapping.assign("jump",key(KEY_F))
	check(mapping.save_bindings(),"custom controls save successfully")
	mapping.restore_defaults()
	mapping.load_bindings()
	check(contains("jump",key(KEY_F)) and not contains("jump",key(KEY_SPACE)),"custom bindings reload from disk")
	mapping.assign("fire",key(KEY_ESCAPE))
	check(not contains("fire",key(KEY_ESCAPE)),"escape remains reserved for emergency access")
	change_scene_to_file("res://prototype/laboratory.tscn")
	await ticks(12)
	var scene = current_scene
	for unit in get_nodes_in_group("lab_enemies"): unit.set_physics_process(false)
	check(contains("jump",key(KEY_F)) and not contains("jump",key(KEY_SPACE)),"player spawn does not overwrite customized controls")
	check(scene.hud.hint.text.contains("F salto"),"HUD reflects customized keys")
	Input.parse_input_event(key(KEY_ESCAPE))
	await ticks(2)
	check(scene.paused,"escape opens pause even after remapping")
	scene.pause_menu.show_controls()
	await ticks(2)
	check(is_instance_valid(scene.pause_menu.controls) and scene.pause_menu.controls.rows.size()==11,"pause opens same remapping screen")
	scene.pause_menu.controls.begin_capture("fire","pad")
	scene.pause_menu.controls.capture_delay = 0
	Input.parse_input_event(pad(JOY_BUTTON_START))
	await ticks(2)
	check(contains("fire",pad(JOY_BUTTON_START)) and scene.paused,"capturing Start rebinds without unpausing gameplay")
	scene.pause_menu.controls.cancel_close()
	await ticks(2)
	scene.toggle_pause()
	await ticks(2)
	var props = get_nodes_in_group("breakable_props")
	check(props.size()==4,"only four cans and barrels appear in corridor")
	var barrel = props[0]
	var barrel_id: int = barrel.prop_id
	for hit in 2:
		var bullet := Node2D.new()
		bullet.set_script(load("res://prototype/combat/player_round.gd"))
		bullet.velocity = Vector2(520,0)
		scene.level.add_child(bullet)
		bullet.global_position = barrel.global_position+Vector2(-36,-13)
		await ticks(6)
		if hit==0: check(is_instance_valid(barrel) and barrel.health==1,"first player shot damages barrel")
	check(not is_instance_valid(barrel),"second player shot breaks barrel")
	var can = get_nodes_in_group("breakable_props")[0]
	var bullet := Area2D.new()
	bullet.set_script(load("res://prototype/enemies/security_round.gd"))
	bullet.velocity = Vector2(100,0)
	scene.level.add_child(bullet)
	bullet.global_position = can.global_position+Vector2(-25,-13)
	await ticks(18)
	check(not is_instance_valid(can),"enemy projectile also breaks can")
	var target = get_nodes_in_group("breakable_props")[0]
	scene.player.position = target.global_position+Vector2(-23,0)
	scene.player.velocity = Vector2.ZERO
	scene.player.facing = 1
	scene.player.melee_kind = "kick"
	await ticks(3)
	scene.player.melee_strike()
	await ticks(2)
	check(not is_instance_valid(target),"kick breaks barrel through melee collision")
	await capture("res://artifacts/props-v9.png")
	check(campaign.save_scene(scene),"progress saves destruction state")
	var record: Dictionary = campaign.read_record()
	check(record.has("props") and record.props.size()==1 and not record.props.has(str(barrel_id)),"save records surviving props only")
	campaign.continue_game()
	await ticks(5)
	check(get_nodes_in_group("breakable_props").size()==1,"broken props remain broken after continuing")
	for path in paths:
		if backups.has(path):
			var file := FileAccess.open(path,FileAccess.WRITE)
			file.store_buffer(backups[path])
			file.close()
		else: DirAccess.remove_absolute(path)
	for action in mapping.ACTIONS:
		InputMap.action_erase_events(action)
		for event in original[action]: InputMap.action_add_event(action,event)
	root.get_node("Music").audio_stream_player.stop()
	for sound in root.get_node("Sound").sound_players: sound.stop()
	await create_timer(0.1).timeout
	print("RESULT: %d checks, %d failures" % [checks,failures])
	quit(failures)
