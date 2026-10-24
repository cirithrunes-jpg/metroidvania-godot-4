extends SceneTree

func _initialize():
	call_deferred("run")

func run():
	var stage := Node2D.new()
	root.add_child(stage)
	current_scene = stage
	var background := Sprite2D.new()
	background.texture = load("res://prototype/assets/laboratory-wall-v3.png")
	background.centered = false
	background.scale = Vector2(320.0/background.texture.get_width(),180.0/background.texture.get_height())
	background.modulate = Color(0.3,0.35,0.4)
	background.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	stage.add_child(background)
	var title := Label.new()
	title.text = "SEGURANCA / LABORATORIO 01"
	title.position = Vector2(15,12)
	title.add_theme_font_size_override("font_size",11)
	stage.add_child(title)
	var names := ["PATRULHA","ATIRADOR","BLINDADO","DRONE","ROBO"]
	for index in 5:
		var unit = load("res://prototype/enemies/security_unit.tscn").instantiate()
		unit.kind = index
		unit.position = Vector2(34+index*63,132)
		stage.add_child(unit)
		unit.set_physics_process(false)
		unit.visual.scale = Vector2.ONE*unit.unit_scale*1.65
		unit.visual.play()
		var label := Label.new()
		label.text = names[index]
		label.position = Vector2(10+index*63,148)
		label.add_theme_font_size_override("font_size",7)
		stage.add_child(label)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://artifacts/security-family-preview.png")
	quit()
