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
	if not CampaignSave.read_record().is_empty():
		var continue_button := Button.new()
		continue_button.text = "Continuar progresso salvo"
		continue_button.position = Vector2(390,394)
		continue_button.size = Vector2(500,64)
		continue_button.pressed.connect(func(): CampaignSave.continue_game())
		ui.add_child(continue_button)
	var quit := Button.new()
	quit.text = "Sair"
	quit.position = Vector2(390,478) if not CampaignSave.read_record().is_empty() else Vector2(390,394)
	quit.size = Vector2(500,64)
	quit.pressed.connect(func(): get_tree().quit())
	ui.add_child(quit)
	start.grab_focus()
	var controls := Label.new()
	controls.text = "A/D mover · Espaço / W pular · Z atirar\nJ soco · K chute · L defesa · E botão\nEsc / Menu / Options: pausa · Controles no menu de pausa"
	controls.position = Vector2(270,570)
	controls.add_theme_font_size_override("font_size",21)
	ui.add_child(controls)

func _on_start_button_pressed():
	CampaignSave.pending = {}
	PlayerStats.reset()
	WorldStash.data = {}
	get_tree().change_scene_to_file("res://prototype/intro.tscn")
