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
func pad(button: JoyButton,pressed: bool):
	var event := InputEventJoypadButton.new()
	event.button_index = button
	event.pressed = pressed
	Input.parse_input_event(event)
func axis(which: JoyAxis,value: float):
	var event := InputEventJoypadMotion.new()
	event.axis = which
	event.axis_value = value
	Input.parse_input_event(event)
func mapped(action: String,event: InputEvent) -> bool:
	var input = root.get_node("CombatInput")
	for existing in InputMap.action_get_events(action):
		if input.encode(event)==input.encode(existing): return true
	return false
func clear_actions():
	for action in root.get_node("CombatInput").ACTIONS: Input.action_release(action)
	axis(JOY_AXIS_LEFT_Y,0)
	axis(JOY_AXIS_LEFT_X,0)
	axis(JOY_AXIS_TRIGGER_LEFT,0)
	axis(JOY_AXIS_TRIGGER_RIGHT,0)
func _initialize(): call_deferred("run")
func run():
	var mapping = root.get_node("CombatInput")
	var before := {}
	for action in mapping.ACTIONS: before[action] = InputMap.action_get_events(action).duplicate()
	mapping.restore_defaults()
	for pair in [["attack_punch",JOY_BUTTON_X],["attack_kick",JOY_BUTTON_Y],["guard",JOY_BUTTON_B],["fire",JOY_BUTTON_RIGHT_SHOULDER],["sword",JOY_BUTTON_LEFT_SHOULDER],["jump",JOY_BUTTON_A],["interact",JOY_BUTTON_LEFT_STICK]]:
		var event := InputEventJoypadButton.new()
		event.button_index = pair[1]
		check(mapped(pair[0],event),"PlayStation binding: "+pair[0])
	for pair in [["power",JOY_AXIS_TRIGGER_RIGHT,1.0],["grenade",JOY_AXIS_TRIGGER_LEFT,1.0],["climb_up",JOY_AXIS_LEFT_Y,-1.0],["posture_down",JOY_AXIS_LEFT_Y,1.0]]:
		var event := InputEventJoypadMotion.new()
		event.axis = pair[1]
		event.axis_value = pair[2]
		check(mapped(pair[0],event),"analog binding: "+pair[0])
	change_scene_to_file("res://menus/start_menu.tscn")
	await ticks(4)
	current_scene.open_controls()
	await ticks(3)
	var settings = current_scene.settings
	settings.rows.main_menu.pad.grab_focus()
	await ticks(4)
	check(settings.rows.main_menu.pad.get_global_rect().position.y<142.5,"scrolling controls exposes lower action rows through gamepad focus")
	await capture("res://artifacts/controls-bottom-v10.png")
	settings.first.grab_focus()
	await ticks(4)
	await capture("res://artifacts/controls-v10.png")
	settings.cancel_close()
	await ticks(2)
	change_scene_to_file("res://prototype/laboratory.tscn")
	await ticks(12)
	var scene = current_scene
	var actor = scene.player
	for unit in get_nodes_in_group("lab_enemies"): unit.set_physics_process(false)
	print("Physical controllers detected: ",Input.get_connected_joypads())
	actor.position = Vector2(80,300)
	actor.velocity = Vector2.ZERO
	await ticks(3)
	pad(JOY_BUTTON_A,true)
	await ticks(6)
	check(actor.velocity.y<0,"X initiates jump")
	pad(JOY_BUTTON_A,false)
	await ticks(2)
	pad(JOY_BUTTON_A,true)
	await ticks(3)
	check(not actor.extra_jump and actor.velocity.y < -95,"second distinct X press initiates double jump")
	await ticks(180)
	check(actor.is_on_floor(),"holding X does not auto-jump after landing")
	pad(JOY_BUTTON_A,false)
	await ticks(2)
	axis(JOY_AXIS_LEFT_Y,-1)
	await ticks(4)
	check(actor.is_on_floor(),"left stick up is reserved for ladders")
	axis(JOY_AXIS_LEFT_Y,0)
	pad(JOY_BUTTON_A,true)
	await ticks(4)
	pad(JOY_BUTTON_A,false)
	pad(JOY_BUTTON_Y,true)
	await ticks(16)
	pad(JOY_BUTTON_Y,false)
	check(actor.melee_kind=="air_kick" and actor.get_node("Specimen").animation=="air_kick","jump plus triangle plays original aerial kick")
	await capture("res://artifacts/air-kick-v10.png")
	await ticks(110)
	actor.position = Vector2(80,300)
	actor.velocity = Vector2.ZERO
	var armor = get_nodes_in_group("lab_enemies")[2]
	armor.position = Vector2(125,300)
	await ticks(3)
	pad(JOY_BUTTON_LEFT_SHOULDER,true)
	await ticks(18)
	pad(JOY_BUTTON_LEFT_SHOULDER,false)
	check(armor.health==2 and actor.get_node("Specimen").animation=="sword","L1 sword animation deals damage once")
	await capture("res://artifacts/sword-v10.png")
	await ticks(22)
	for unit in get_nodes_in_group("lab_enemies"): unit.position = Vector2(1500+unit.get_index()*10,300)
	var robot = get_nodes_in_group("lab_enemies")[7]
	robot.position = Vector2(210,300)
	await ticks(2)
	axis(JOY_AXIS_TRIGGER_RIGHT,1)
	await ticks(80)
	check(get_nodes_in_group("energy_rounds").is_empty() and actor.power_charge>1,"R2 charges without early projectile")
	await capture("res://artifacts/charge-v10.png")
	axis(JOY_AXIS_TRIGGER_RIGHT,0)
	await ticks(2)
	check(actor.power_charge==0 and get_nodes_in_group("energy_rounds").is_empty(),"releasing R2 early cancels charge")
	axis(JOY_AXIS_TRIGGER_RIGHT,1)
	await ticks(125)
	check(actor.power_latched and actor.power_cast>0 and get_nodes_in_group("energy_rounds").size()==1,"two seconds of R2 releases one power projectile")
	await capture("res://artifacts/power-v10.png")
	await ticks(55)
	check(is_instance_valid(robot) and robot.health==2,"energy projectile deals three damage")
	await ticks(140)
	check(is_instance_valid(robot) and robot.health==2,"holding R2 continuously does not repeat power")
	axis(JOY_AXIS_TRIGGER_RIGHT,0)
	await ticks(2)
	axis(JOY_AXIS_TRIGGER_LEFT,1)
	await ticks(18)
	check(get_nodes_in_group("combat_grenades").size()==1 and actor.get_node("Specimen").animation=="grenade","L2 throws animated grenade")
	await capture("res://artifacts/grenade-v10.png")
	await ticks(100)
	check(get_nodes_in_group("combat_grenades").is_empty(),"grenade explodes on fuse and holding L2 does not repeat")
	axis(JOY_AXIS_TRIGGER_LEFT,0)
	await ticks(3)
	var blast_target = load("res://prototype/enemies/security_unit.tscn").instantiate()
	blast_target.kind = 2
	blast_target.position = Vector2(130,300)
	scene.add_child(blast_target)
	blast_target.set_physics_process(false)
	var wall := StaticBody2D.new()
	var wall_collision := CollisionShape2D.new()
	var wall_shape := RectangleShape2D.new()
	wall_shape.size = Vector2(4,40)
	wall_collision.shape = wall_shape
	wall.add_child(wall_collision)
	wall.position = Vector2(118,280)
	scene.add_child(wall)
	await ticks(3)
	for attempt in 2:
		var grenade := CharacterBody2D.new()
		grenade.set_script(load("res://prototype/combat/grenade.gd"))
		scene.level.add_child(grenade)
		grenade.global_position = Vector2(105,290)
		await ticks(2)
		grenade.explode()
		await ticks(2)
		if attempt==0:
			check(blast_target.health==4,"solid wall blocks grenade blast damage")
			wall.queue_free()
			await ticks(3)
		else: check(blast_target.health==1,"grenade blast deals three damage once in clear range")
	blast_target.queue_free()
	await ticks(2)
	axis(JOY_AXIS_LEFT_Y,1)
	await ticks(2)
	check(actor.posture=="crouch","down crouches immediately")
	check(actor.get_node("CollisionShape2D").shape.size.y==16,"crouch reduces collider")
	await ticks(65)
	check(actor.posture=="prone" and actor.get_node("Hurtbox/CollisionShape2D").shape.size.y==8,"one second down enters prone with low hurtbox")
	axis(JOY_AXIS_LEFT_Y,0)
	axis(JOY_AXIS_LEFT_X,0.8)
	await ticks(20)
	check(actor.posture=="prone" and actor.velocity.x>0 and actor.velocity.x<=14,"left stick moves prone crawl at controlled speed")
	check(actor.get_node("Specimen").animation=="prone_crawl","crawling uses animation library")
	await capture("res://artifacts/crawl-v10.png")
	axis(JOY_AXIS_LEFT_X,0)
	await ticks(12)
	pad(JOY_BUTTON_B,true)
	await ticks(3)
	check(actor.guarding and actor.posture=="prone","circle also defends without forcing prone character upright")
	var hostile := Area2D.new()
	hostile.add_to_group("enemy_projectiles")
	scene.add_child(hostile)
	var hp: int = root.get_node("PlayerStats").health
	actor._on_hurtbox_hurt(hostile,1)
	check(root.get_node("PlayerStats").health==hp and actor.shield_hits==1,"prone guard absorbs incoming shot")
	pad(JOY_BUTTON_B,false)
	hostile.queue_free()
	await ticks(2)
	var ceiling := StaticBody2D.new()
	var collider := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(80,10)
	collider.shape = box
	ceiling.add_child(collider)
	ceiling.position = actor.position+Vector2(0,-21)
	scene.add_child(ceiling)
	await ticks(2)
	pad(JOY_BUTTON_A,true)
	await ticks(2)
	pad(JOY_BUTTON_A,false)
	check(actor.posture=="prone" and actor.standing_blocked,"low ceiling safely blocks standing up")
	ceiling.queue_free()
	await ticks(3)
	pad(JOY_BUTTON_A,true)
	await ticks(3)
	pad(JOY_BUTTON_A,false)
	check(actor.posture=="standing" and actor.velocity.y<0 and actor.get_node("CollisionShape2D").shape.size.y==26,"jump restores standing collider and leaves crawl")
	var ladder = load("res://prototype/animations/ladder_back.tres")
	check(ladder.has_animation("ladder_back") and ladder.get_frame_count("ladder_back")==6,"rear-view ladder animation saved as standalone resource")
	var aerial = load("res://prototype/animations/air_kick.tres")
	check(aerial.get_frame_count("air_kick")==6,"aerial kick has six original frames")
	clear_actions()
	for action in mapping.ACTIONS:
		InputMap.action_erase_events(action)
		for event in before[action]: InputMap.action_add_event(action,event)
	root.get_node("Music").audio_stream_player.stop()
	for sound in root.get_node("Sound").sound_players: sound.stop()
	await create_timer(0.1).timeout
	print("RESULT: %d checks, %d failures" % [checks,failures])
	quit(failures)
