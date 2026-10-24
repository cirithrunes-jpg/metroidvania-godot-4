extends SceneTree
func _initialize():
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	frames.add_animation("air_kick")
	frames.set_animation_speed("air_kick",14)
	frames.set_animation_loop("air_kick",false)
	var texture := load("res://prototype/assets/poses/air-kick-v10.png") as Texture2D
	var regions := [Rect2(0,0,512,512),Rect2(512,0,512,512),Rect2(1024,0,512,512),Rect2(0,512,660,512),Rect2(660,512,440,512),Rect2(1100,512,436,512)]
	var anchors := [Vector2(245,500),Vector2(735,500),Vector2(1180,500),Vector2(230,1010),Vector2(825,1010),Vector2(1285,1010)]
	for i in 6:
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = regions[i]
		atlas.margin = Rect2(Vector2(300,580)+regions[i].position-anchors[i],Vector2(768,640)-regions[i].size)
		atlas.filter_clip = true
		frames.add_frame("air_kick",atlas)
	frames.set_meta("foot_anchor",Vector2(300,580))
	frames.set_meta("draw_scale",0.072)
	assert(ResourceSaver.save(frames,"res://prototype/animations/air_kick.tres")==OK)
	var library = load("res://prototype/animations/actions.tres")
	var ladder := SpriteFrames.new()
	ladder.remove_animation("default")
	ladder.add_animation("ladder_back")
	ladder.set_animation_speed("ladder_back",10)
	ladder.set_animation_loop("ladder_back",true)
	for i in library.get_frame_count("climb"): ladder.add_frame("ladder_back",library.get_frame_texture("climb",i))
	ladder.set_meta("foot_anchor",Vector2(256,352))
	ladder.set_meta("draw_scale",0.132)
	assert(ResourceSaver.save(ladder,"res://prototype/animations/ladder_back.tres")==OK)
	print("Air kick and rear-view ladder animations saved.")
	quit()
