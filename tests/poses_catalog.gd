extends SceneTree

func _initialize(): call_deferred("run")
func run():
	root.size = Vector2i(1280,1040)
	root.content_scale_size = Vector2i(1280,1040)
	var stage := Node2D.new()
	root.add_child(stage)
	current_scene = stage
	var background := ColorRect.new()
	background.size = Vector2(1280,1040)
	background.color = Color("09131e")
	stage.add_child(background)
	var title := Label.new()
	title.text = "PERSONAGEM / BIBLIOTECA DE MOVIMENTOS"
	title.position = Vector2(28,16)
	title.add_theme_font_size_override("font_size",30)
	stage.add_child(title)
	var frames = load("res://prototype/animations/actions.tres") as SpriteFrames
	var definitions = load("res://prototype/animations/pose_library.gd").DEFINITIONS
	var selected := [3,3,2,1,4,2,2,3,0,2,2,2,2,3,3,3]
	for index in 16:
		var column := index%4
		var row := floori(index/4.0)
		var panel := ColorRect.new()
		panel.position = Vector2(12+column*320,68+row*240)
		panel.size = Vector2(304,228)
		panel.color = Color("122331")
		stage.add_child(panel)
		var sprite := AnimatedSprite2D.new()
		sprite.sprite_frames = frames
		sprite.centered = false
		sprite.offset = -Vector2(256,352)
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		sprite.position = Vector2(164+column*320,254+row*240)
		sprite.scale = Vector2.ONE*0.59*float(frames.get_meta("pose_scales")[definitions[index][0]])
		sprite.animation = definitions[index][0]
		sprite.frame = selected[index]
		stage.add_child(sprite)
		var label := Label.new()
		label.text = definitions[index][1]
		label.position = Vector2(28+column*320,268+row*240)
		label.add_theme_font_size_override("font_size",21)
		stage.add_child(label)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://artifacts/poses-catalog.png")
	quit()
