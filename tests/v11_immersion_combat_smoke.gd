extends SceneTree
var checks := 0
var failures := 0
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
func pad(code: JoyButton,pressed: bool):
	var event := InputEventJoypadButton.new()
	event.button_index = code
	event.pressed = pressed
	Input.parse_input_event(event)
func _initialize(): call_deferred("run")
func run():
	var mapping = root.get_node("CombatInput")
	var original := {}
	for action in mapping.ACTIONS: original[action] = InputMap.action_get_events(action).duplicate()
	mapping.restore_defaults()
	var a := InputEventJoypadButton.new()
	a.button_index = JOY_BUTTON_A
	var y := InputEventJoypadButton.new()
	y.button_index = JOY_BUTTON_Y
	check(mapping.events_for("jump","pad").size()==1 and mapping.events_for("jump","pad")[0].button_index==JOY_BUTTON_A,"X/cross is the only controller jump button")
	mapping.assign("fire",a)
	mapping.assign("jump",y)
	check(mapping.events_for("jump","pad")[0].button_index==JOY_BUTTON_A and not InputMap.action_has_event("fire",a),"remapping cannot steal or replace fixed X jump")
	change_scene_to_file("res://prototype/laboratory.tscn")
	await ticks(15)
	var world = current_scene
	var actor = world.player
	var art = actor.get_node("Specimen")
	for unit in get_nodes_in_group("lab_enemies"):
		unit.set_physics_process(false)
		unit.position = Vector2(1600+unit.get_index()*10,300)
	actor.position = Vector2(80,300)
	actor.velocity = Vector2.ZERO
	await ticks(3)
	pad(JOY_BUTTON_A,true)
	await ticks(6)
	pad(JOY_BUTTON_A,false)
	await ticks(2)
	pad(JOY_BUTTON_A,true)
	await ticks(9)
	pad(JOY_BUTTON_A,false)
	check(actor.somersault_time>0 and art.animation=="somersault" and absf(art.rotation)>0.5,"second X jump produces visible full-rotation somersault")
	
	Input.action_press("fire")
	await ticks(2)
	check(get_nodes_in_group("player_rounds").is_empty(),"no disconnected gunfire during somersault")
	Input.action_release("fire")
	await capture("res://artifacts/somersault-v11.png")
	await ticks(90)
	check(is_zero_approx(art.rotation) and art.position==Vector2.ZERO,"somersault restores upright visual transform")
	pad(JOY_BUTTON_DPAD_UP,true)
	await ticks(3)
	pad(JOY_BUTTON_DPAD_UP,false)
	check(actor.is_on_floor(),"up direction no longer triggers a jump")
	Input.action_press("move_right")
	Input.action_press("posture_down")
	await ticks(1)
	check(actor.posture=="crouch" and actor.velocity.x==0,"crouch is immediate and stops horizontal movement")
	var start: float = actor.position.x
	await ticks(20)
	check(actor.posture=="crouch" and absf(actor.position.x-start)<0.1,"holding movement cannot move crouched character")
	await capture("res://artifacts/crouch-v11.png")
	await ticks(45)
	check(actor.posture=="prone","one second down enters prone")
	Input.action_release("posture_down")
	Input.action_release("move_right")
	pad(JOY_BUTTON_A,true)
	await ticks(3)
	pad(JOY_BUTTON_A,false)
	check(actor.posture=="standing" and actor.velocity.y<0,"X exits prone and jumps")
	await ticks(90)
	actor.position = Vector2(80,300)
	actor.velocity = Vector2.ZERO
	await ticks(3)
	check(art.sprite_frames.get_frame_count("punch")==12 and art.sprite_frames.get_frame_count("kick")==12,"punch and kick use twelve-frame sequences")
	var target = get_nodes_in_group("lab_enemies")[2]
	target.position = Vector2(107,300)
	target.health = 4
	await ticks(3)
	Input.action_press("attack_punch")
	await ticks(14)
	
	await ticks(4)
	Input.action_release("attack_punch")
	check(target.health==3,"first jab hits at its contact window")
	await capture("res://artifacts/punch-v11.png")
	await ticks(20)
	check(target.health==2,"second punch in combination hits once")
	await ticks(20)
	check(target.health==2 and actor.melee_time<=0,"combination recovery causes no repeated damage")
	target.health = 4
	Input.action_press("attack_kick")
	await ticks(21)
	Input.action_release("attack_kick")
	check(target.health==2,"extended kick hits once for two damage")
	await capture("res://artifacts/kick-v11.png")
	await ticks(30)
	check(target.health==2,"kick recovery causes no repeated damage")
	target.position = Vector2(1600,300)
	var blaster = actor.get_node("PlayerBlaster")
	for direction in [-1.0,1.0]:
		actor.facing = direction
		actor.velocity = Vector2.ZERO
		blaster.fire_bullet()
		var bullets = get_nodes_in_group("player_rounds")
		check(bullets.size()>0 and bullets[-1].global_position.distance_to(art.muzzle_global_position())<0.001,"bullet originates at animated muzzle facing %d" % int(direction))
		var texture: AtlasTexture = art.sprite_frames.get_frame_texture(art.animation,art.frame)
		var raw: Vector2 = art.to_local(blaster.last_muzzle)-art.offset-texture.margin.position+texture.region.position
		var image: Image = texture.atlas.get_image()
		check(image.get_pixel(int(raw.x)-2,int(raw.y)).a>0.4,"muzzle socket touches opaque rifle barrel")
		for bullet in bullets: bullet.queue_free()
		await ticks(2)
	actor.facing = 1
	actor.get_node("Camera2D").reset_smoothing()
	blaster.fire_bullet()
	await capture("res://artifacts/muzzle-v11.png")
	for bullet in get_nodes_in_group("player_rounds"): bullet.queue_free()
	await ticks(3)
	var upper: Array = world.floors.filter(func(rect): return rect.size.y<10)
	check(world.structure.supports.size()==upper.size(),"every upper platform has structural supports")
	var grounded_supports := true
	for support in world.structure.supports:
		for column in support.columns:
			var grounded := false
			for floor in world.floors:
				if floor.size.y>=10 and column.foot.x>=floor.position.x and column.foot.x<=floor.end.x: grounded = true
			if not grounded or column.foot.y!=300: grounded_supports = false
	check(grounded_supports,"all support feet anchor to solid factory floor")
	check(world.structure.ladders.size()==upper.size() and world.structure.rails.size()==upper.size(),"platforms have ladders and rear safety railings")
	check((target.collision_mask & 128)!=0 and (actor.collision_mask & 128)==0,"safety end posts restrain soldiers without blocking player jumps")
	var ladder: Dictionary = world.structure.ladders[0]
	actor.position = Vector2(ladder.x,ladder.bottom-0.2)
	actor.velocity = Vector2.ZERO
	await ticks(4)
	Input.action_press("climb_up")
	await ticks(18)
	check(actor.climbing and art.animation=="ladder_climb" and actor.position.y<ladder.bottom-6,"up climbs ladder with rear-view animation")
	await capture("res://artifacts/ladder-v11.png")
	await ticks(90)
	Input.action_release("climb_up")
	check(not actor.climbing and actor.collision_mask==3 and absf(actor.position.y-ladder.top)<1,"ladder top exits onto supported platform")
	Input.action_press("posture_down")
	await ticks(90)
	Input.action_release("posture_down")
	check(not actor.climbing and absf(actor.position.y-ladder.bottom)<1,"down descends ladder to lower floor")
	pad(JOY_BUTTON_A,true)
	await ticks(3)
	pad(JOY_BUTTON_A,false)
	await ticks(90)
	actor.position = Vector2(ladder.x,ladder.bottom-0.2)
	actor.velocity = Vector2.ZERO
	await ticks(4)
	Input.action_press("climb_up")
	await ticks(18)
	pad(JOY_BUTTON_A,true)
	await ticks(2)
	pad(JOY_BUTTON_A,false)
	Input.action_release("climb_up")
	check(not actor.climbing and actor.velocity.y<0 and actor.collision_mask==3,"X jumps safely away from ladder")
	await ticks(90)
	actor.position = Vector2(600,300)
	actor.velocity = Vector2.ZERO
	actor.get_node("Camera2D").reset_smoothing()
	await ticks(5)
	await capture("res://artifacts/factory-v11.png")
	var grenade := CharacterBody2D.new()
	grenade.set_script(load("res://prototype/combat/grenade.gd"))
	world.level.add_child(grenade)
	grenade.global_position = Vector2(660,295)
	grenade.explode()
	await ticks(2)
	var explosions = get_nodes_in_group("grenade_explosions")
	check(explosions.size()==1 and explosions[0].fragments.size()==24,"grenade explosion has animated fire smoke and debris")
	check(explosions[0].light.energy>0 and explosions[0].duration>=0.8,"explosion adds short dynamic light and longer smoke animation")
	await ticks(7)
	await capture("res://artifacts/explosion-v11.png")
	await ticks(60)
	check(get_nodes_in_group("grenade_explosions").is_empty(),"explosion particles and light are cleaned up")
	for action in mapping.ACTIONS:
		Input.action_release(action)
		InputMap.action_erase_events(action)
		for event in original[action]: InputMap.action_add_event(action,event)
	root.get_node("Music").audio_stream_player.stop()
	for sound in root.get_node("Sound").sound_players: sound.stop()
	await create_timer(0.1).timeout
	print("RESULT: %d checks, %d failures" % [checks,failures])
	quit(failures)
