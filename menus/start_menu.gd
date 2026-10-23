extends ColorRect

@export var completed := false

func _ready():
	PlayerStats.reset()
	WorldStash.data = {}
	color = Color("080f19")
	var ui := Control.new()
	ui.scale = Vector2.ONE/4
	ui.size = Vector2(1280,720)
	add_child(ui)
	var title := Label.new()
	title.text = "Fuga concluída" if completed else "LABORATÓRIO"
	title.position = Vector2(390,170)
	title.add_theme_font_size_override("font_size",46)
	ui.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "Três setores conectados · segurança industrial"
	subtitle.position = Vector2(390,235)
	subtitle.add_theme_font_size_override("font_size",22)
	ui.add_child(subtitle)
	var start := Button.new()
	start.text = "Jogar novamente" if completed else "Jogar"
	start.position = Vector2(390,310)
	start.size = Vector2(500,64)
	start.pressed.connect(_on_start_button_pressed)
	ui.add_child(start)
	var quit := Button.new()
	quit.text = "Sair"
	quit.position = Vector2(390,394)
	quit.size = Vector2(500,64)
	quit.pressed.connect(func(): get_tree().quit())
	ui.add_child(quit)
	start.grab_focus()
	var controls := Label.new()
	controls.text = "A/D: mover   ·   W / espaço: pular   ·   Mouse: mirar e atirar\nEsc: pausa   ·   Tab: menu   ·   R: reiniciar o setor"
	controls.position = Vector2(390,510)
	controls.add_theme_font_size_override("font_size",21)
	ui.add_child(controls)

func _on_start_button_pressed():
	PlayerStats.reset()
	WorldStash.data = {}
	get_tree().change_scene_to_file("res://prototype/laboratory.tscn")
