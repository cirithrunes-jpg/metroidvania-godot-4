extends SceneTree

func _initialize():
	var frames = load("res://prototype/animations/pose_library.gd").build()
	var error := ResourceSaver.save(frames,"res://prototype/animations/actions.tres")
	print("Pose library saved: ",error)
	quit(error)
