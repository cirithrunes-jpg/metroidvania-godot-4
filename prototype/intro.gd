extends Control
var leaving := false
var video: VideoStreamPlayer
func _ready():
	Music.audio_stream_player.stop()
	if not FileAccess.file_exists("res://prototype/assets/video/introduction.ogv"):
		start_level.call_deferred()
		return
	video = VideoStreamPlayer.new()
	video.name = "IntroductionVideo"
	video.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	video.expand = true
	video.stream = load("res://prototype/assets/video/introduction.ogv")
	add_child(video)
	video.finished.connect(start_level)
	video.play()
	var label := Label.new()
	label.text = "ESPAÇO / ENTER: PULAR INTRODUÇÃO"
	label.position = Vector2(12,162)
	label.scale = Vector2.ONE/4
	label.add_theme_font_size_override("font_size",20)
	add_child(label)
func _unhandled_input(event):
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("jump") or event.is_action_pressed("pause"): start_level()
func start_level():
	if leaving: return
	leaving = true
	get_tree().change_scene_to_file("res://prototype/mission.tscn")
