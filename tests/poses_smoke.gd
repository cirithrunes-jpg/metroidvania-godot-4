extends SceneTree

var failures := 0
var checks := 0
func check(condition: bool,message: String):
	checks += 1
	if condition: print("PASS: "+message)
	else:
		failures += 1
		push_error(message)
func _initialize(): call_deferred("run")
func run():
	var frames = load("res://prototype/animations/actions.tres") as SpriteFrames
	check(frames.get_animation_names().size()==16,"sixteen action sequences exported")
	var total := 0
	var bounds_ok := true
	var sizes_ok := true
	for name in frames.get_animation_names():
		total += frames.get_frame_count(name)
		for index in frames.get_frame_count(name):
			var texture = frames.get_frame_texture(name,index) as AtlasTexture
			bounds_ok = bounds_ok and texture.region.position.x>=0 and texture.region.position.y>=0 and texture.region.end.x<=texture.atlas.get_width() and texture.region.end.y<=texture.atlas.get_height()
			sizes_ok = sizes_ok and texture.get_size()==Vector2(512,384)
	check(total==96,"ninety-six frames available")
	check(bounds_ok,"all atlas cuts stay within image bounds")
	check(sizes_ok,"frames share one normalized canvas")
	for name in ["combat","mobility","extras","weapons"]:
		var image = load("res://prototype/assets/poses/%s.png" % name).get_image()
		check(image.get_pixel(0,0).a<0.01,"transparent background for "+name)
	change_scene_to_file("res://prototype/animations/pose_preview.tscn")
	await process_frame
	await process_frame
	var preview = current_scene
	check(preview.pose_buttons.size()==16,"all action buttons available")
	for index in 16:
		preview.select_pose(index)
		await process_frame
		check(preview.sprite.animation == preview.LIBRARY.DEFINITIONS[index][0],"preview switches action %d" % index)
	if DisplayServer.get_name() != "headless":
		preview.select_pose(15)
		preview.sprite.pause()
		preview.sprite.frame = 3
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://artifacts/poses-preview.png")
	print("RESULT: %d checks, %d failures" % [checks,failures])
	quit(failures)
