extends SceneTree
func _initialize():
	var sheet = load("res://prototype/assets/poses/special-melee-v12.png")
	var library := SpriteFrames.new()
	library.remove_animation("default")
	var cuts := [0,336,640,887]
	for row in 3:
		var label: String = ["uppercut","reverse_kick","double_kick"][row]
		library.add_animation(label)
		library.set_animation_speed(label,8.333333)
		library.set_animation_loop(label,false)
		for column in 6:
			var left := int(column*1774.0/6)
			var right := int((column+1)*1774.0/6)
			var region := Rect2(left,cuts[row],right-left,cuts[row+1]-cuts[row])
			var frame := AtlasTexture.new()
			frame.atlas = sheet
			frame.region = region
			frame.margin = Rect2(384-(right-left)/2.0,480-region.size.y,768-region.size.x,512-region.size.y)
			library.add_frame(label,frame)
	ResourceSaver.save(library,"res://prototype/animations/special_melee_v12.tres")
	quit()
