extends SceneTree
const DEFINITIONS := {"punch": [{"region": [85, 13, 225, 349], "anchor": [198.0, 362]}, {"region": [427, 9, 257, 353], "anchor": [560.0, 362]}, {"region": [779, 13, 276, 349], "anchor": [915.5, 362]}, {"region": [1123, 13, 331, 349], "anchor": [1261.5, 362]}, {"region": [1499, 13, 257, 349], "anchor": [1624.5, 362]}, {"region": [1875, 9, 238, 353], "anchor": [1993.0, 362]}, {"region": [68, 367, 259, 352], "anchor": [203.0, 717]}, {"region": [421, 371, 293, 348], "anchor": [560.0, 717]}, {"region": [775, 368, 335, 351], "anchor": [912.0, 717]}, {"region": [1133, 372, 309, 347], "anchor": [1266.0, 717]}, {"region": [1508, 370, 253, 349], "anchor": [1639.0, 717]}, {"region": [1870, 368, 243, 352], "anchor": [1998.0, 718]}], "kick": [{"region": [65, 12, 239, 350], "anchor": [189.5, 360]}, {"region": [446, 17, 244, 343], "anchor": [573.5, 358]}, {"region": [816, 11, 203, 351], "anchor": [923.5, 362]}, {"region": [1178, 11, 198, 351], "anchor": [1246.5, 362]}, {"region": [1508, 15, 285, 347], "anchor": [1592.0, 362]}, {"region": [1800, 11, 346, 349], "anchor": [1904.5, 358]}, {"region": [55, 370, 346, 344], "anchor": [145.0, 712]}, {"region": [482, 377, 192, 336], "anchor": [552.0, 711]}, {"region": [819, 371, 190, 345], "anchor": [884.5, 714]}, {"region": [1187, 373, 195, 343], "anchor": [1221.0, 714]}, {"region": [1506, 372, 225, 343], "anchor": [1622.5, 713]}, {"region": [1863, 368, 236, 346], "anchor": [1983.0, 712]}]}
func _initialize():
	var output := SpriteFrames.new()
	output.remove_animation("default")
	for action in ["punch","kick"]:
		var texture := load("res://prototype/assets/poses/%s-v11.png" % action)
		output.add_animation(action)
		output.set_animation_speed(action,15 if action=="punch" else 16.6667)
		output.set_animation_loop(action,false)
		for entry in DEFINITIONS[action]:
			var data: Array = entry.region
			var region := Rect2(data[0],data[1],data[2],data[3])
			var anchor := Vector2(entry.anchor[0],entry.anchor[1])
			var atlas := AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = region
			atlas.margin = Rect2(Vector2(384,480)+region.position-anchor,Vector2(768,512)-region.size)
			atlas.filter_clip = true
			output.add_frame(action,atlas)
	output.set_meta("foot_anchor",Vector2(384,480))
	output.set_meta("draw_scale",0.095)
	assert(ResourceSaver.save(output,"res://prototype/animations/melee_v11.tres")==OK)
	print("Saved twelve-frame punch and kick sequences.")
	quit()
