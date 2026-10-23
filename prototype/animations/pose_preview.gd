extends Control

const LIBRARY = preload("res://prototype/animations/pose_library.gd")
var sprite: AnimatedSprite2D
var heading: Label
var description: Label
var selected := 0
var replay_wait := 0.0
var canvas: Control
var pose_buttons: Array[Button] = []

func _ready():
	var backdrop := ColorRect.new()
	backdrop.color = Color("08111b")
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)
	canvas = Control.new()
	canvas.scale = Vector2.ONE/4
	canvas.size = Vector2(1280,720)
	add_child(canvas)
	heading = label_at("MOVIMENTOS / PERSONAGEM",Vector2(38,26),30)
	label_at("Biblioteca de animações — selecione uma pose para visualizar",Vector2(38,72),21)
	var panel := ColorRect.new()
	panel.position = Vector2(505,118)
	panel.size = Vector2(730,480)
	panel.color = Color("101f2d")
	canvas.add_child(panel)
	var line := ColorRect.new()
	line.position = Vector2(540,545)
	line.size = Vector2(660,2)
	line.color = Color("315264")
	canvas.add_child(line)
	sprite = AnimatedSprite2D.new()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	sprite.sprite_frames = load("res://prototype/animations/actions.tres")
	sprite.centered = false
	sprite.position = Vector2(870,545)
	canvas.add_child(sprite)
	sprite.animation_finished.connect(func(): replay_wait = 0.55)
	for index in LIBRARY.DEFINITIONS.size():
		var button := Button.new()
		button.position = Vector2(28+floori(index/8.0)*230,120+(index%8)*58)
		button.size = Vector2(218,44)
		button.text = LIBRARY.DEFINITIONS[index][1]
		button.add_theme_font_size_override("font_size",18)
		button.pressed.connect(select_pose.bind(index))
		canvas.add_child(button)
		pose_buttons.append(button)
	description = label_at("",Vector2(530,620),21)
	label_at("← / → trocar   ·   Espaço repetir   ·   F espelhar   ·   Esc menu",Vector2(38,675),20)
	select_pose(0)

func label_at(text: String, point: Vector2, size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.position = point
	label.add_theme_font_size_override("font_size",size)
	canvas.add_child(label)
	return label

func select_pose(index: int):
	selected = posmod(index,LIBRARY.DEFINITIONS.size())
	var definition = LIBRARY.DEFINITIONS[selected]
	var texture = sprite.sprite_frames.get_frame_texture(definition[0],0)
	var cell: Vector2 = texture.get_size()
	sprite.offset = -LIBRARY.FOOT_ANCHOR
	sprite.scale = Vector2.ONE*1.15*float(sprite.sprite_frames.get_meta("pose_scales")[definition[0]])
	sprite.play(definition[0])
	sprite.frame = 0
	replay_wait = 0
	heading.text = "MOVIMENTO / "+String(definition[1]).to_upper()
	description.text = "%d / 16   ·   6 quadros   ·   %s" % [selected+1,"Ciclo contínuo" if definition[5] else "Ação com recuperação"]
	pose_buttons[selected].grab_focus()

func _process(delta):
	if replay_wait>0:
		replay_wait -= delta
		if replay_wait<=0:
			sprite.frame = 0
			sprite.play()

func _input(event):
	if not event is InputEventKey or not event.pressed or event.echo: return
	match event.physical_keycode:
		KEY_RIGHT: select_pose(selected+1)
		KEY_LEFT: select_pose(selected-1)
		KEY_SPACE:
			sprite.frame = 0
			sprite.play()
		KEY_F: sprite.flip_h = not sprite.flip_h
		KEY_ESCAPE:
			if ResourceLoader.exists("res://menus/start_menu.tscn"):
				get_tree().change_scene_to_file("res://menus/start_menu.tscn")
			else: get_tree().quit()
