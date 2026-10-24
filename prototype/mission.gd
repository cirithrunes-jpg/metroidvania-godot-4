extends Control
var leaving := false
var elapsed := 0.0
var caption: Label
func _ready():
	var black := ColorRect.new()
	black.color = Color.BLACK
	black.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(black)
	var ui := Control.new()
	ui.scale = Vector2.ONE/4
	add_child(ui)
	caption = Label.new()
	caption.text = "MISSÃO:\nPROTOCOLO DE COMBATE ATIVADO"
	caption.position = Vector2(80,280)
	caption.size = Vector2(1120,160)
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	caption.add_theme_font_size_override("font_size",38)
	caption.modulate.a = 0
	ui.add_child(caption)
	var tween := create_tween()
	tween.tween_property(caption,"modulate:a",1.0,0.65)
	tween.tween_interval(2.0)
	tween.tween_property(caption,"modulate:a",0.0,0.5)
	tween.tween_callback(finish)
func _process(delta): elapsed += delta
func _unhandled_input(event):
	if elapsed > 0.8 and (event.is_action_pressed("ui_accept") or event.is_action_pressed("pause")): finish()
func finish():
	if leaving: return
	leaving = true
	get_tree().change_scene_to_file("res://prototype/laboratory.tscn")
