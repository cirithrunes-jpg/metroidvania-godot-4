extends SceneTree
var failures := 0
var checks := 0
func check(ok: bool,label: String):
	checks += 1
	if not ok:
		failures += 1
		push_error(label)
	else: print("PASS: "+label)
func ticks(n: int):
	for i in n: await physics_frame
	await process_frame
func capture(label: String):
	if DisplayServer.get_name()=="headless": return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://artifacts/"+label+"-v12.png")
func _initialize(): call_deferred("run")
func run():
	change_scene_to_file("res://prototype/laboratory.tscn")
	await ticks(15)
	var actor = current_scene.player
	actor.position = Vector2(80,300)
	for unit in get_nodes_in_group("lab_enemies"):
		unit.set_physics_process(false)
		unit.position = Vector2(1700,300)
	await ticks(4)
	for action in ["uppercut","reverse_kick","double_kick"]:
		check(actor.get_node("Specimen").sprite_frames.get_frame_count(action)==6,action+" has six distinct frames")
	for expected in ["punch","uppercut"]:
		Input.action_press("attack_punch")
		await ticks(3)
		Input.action_release("attack_punch")
		check(actor.melee_kind==expected,"successive punch selects "+expected)
		await ticks(21)
		await capture(expected)
		await ticks(35)
	await ticks(140)
	for expected in ["kick","reverse_kick","double_kick"]:
		Input.action_press("attack_kick")
		await ticks(3)
		Input.action_release("attack_kick")
		check(actor.melee_kind==expected,"successive kick selects "+expected)
		await ticks(21)
		await capture(expected)
		await ticks(30)
	actor.position = Vector2(620,300)
	actor.get_node("Camera2D").reset_smoothing()
	await ticks(8)
	await capture("depth")
	var layers := []
	for node in current_scene.get_children():
		for child in node.get_children():
			if child.get_script()==load("res://prototype/visual_depth.gd"): layers.append(child)
	check(layers.size()==3,"three textured depth layers exist")
	var rates := []
	for layer in layers: rates.append(layer.depth)
	check(rates.has(0.25) and rates.has(0.60) and rates.has(1.12),"far middle and foreground use distinct parallax speeds")
	print("RESULT: %d checks, %d failures" % [checks,failures])
	quit(failures)
