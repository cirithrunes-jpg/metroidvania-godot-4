extends ColorRect

@export var completed := false

var settings: CanvasLayer
var menu_ui: Control
var play_button: Button
func _ready():
	PlayerStats.reset()
	WorldStash.data = {}
	color = Color("080f19")
	var ui := Control.new()
	ui.name = "MenuCanvas"
	ui.scale = Vector2.ONE/4
	ui.size = Vector2(1280,720)
	add_child(ui)
	var poster := TextureRect.new()
	poster.name = "GamePoster"
	poster.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	poster.texture = preload("res://prototype/assets/menu-poster.png")
	poster.position = Vector2(680,0)
	poster.size = Vector2(600,720)
	poster.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	poster.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	poster.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(poster)
	var strip := ColorRect.new()
	strip.position = Vector2(660,0)
	strip.size = Vector2(28,720)
	strip.color = Color("123344")
	ui.add_child(strip)
	menu_ui = Control.new()
	ui.add_child(menu_ui)
	var title := Label.new()
	title.text = "FUGA CONCLUÍDA" if completed else "LABORATÓRIO"
	title.position = Vector2(64,100)
	title.add_theme_font_size_override("font_size",42)
	menu_ui.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "PROTOCOLO DE COMBATE\nTrês corredores. Uma saída."
	subtitle.position = Vector2(64,166)
	subtitle.add_theme_font_size_override("font_size",22)
	menu_ui.add_child(subtitle)
	play_button = menu_button("Jogar novamente" if completed else "Jogar",280,_on_start_button_pressed)
	var y := 360
	if not CampaignSave.read_record().is_empty():
		menu_button("Continuar progresso salvo",y,func(): CampaignSave.continue_game())
		y += 80
	menu_button("Configurar controles",y,open_controls)
	menu_button("Sair",y+80,func(): get_tree().quit())
	play_button.grab_focus()
	var hint := Label.new()
	hint.text = "Personalize teclas e botões em Configurar controles.\nNo jogo, Esc sempre permite acessar a pausa."
	hint.position = Vector2(64,634)
	hint.add_theme_font_size_override("font_size",18)
	menu_ui.add_child(hint)
func menu_button(text: String,y: int,action: Callable) -> Button:
	var item := Button.new()
	item.text = text
	item.position = Vector2(64,y)
	item.size = Vector2(530,60)
	item.pressed.connect(action)
	menu_ui.add_child(item)
	return item
func open_controls():
	menu_ui.hide()
	settings = CanvasLayer.new()
	settings.set_script(preload("res://prototype/ui/control_settings.gd"))
	add_child(settings)
	settings.closed.connect(func(): settings.queue_free(); menu_ui.show(); play_button.grab_focus())

func _on_start_button_pressed():
	CampaignSave.pending = {}
	PlayerStats.reset()
	WorldStash.data = {}
	get_tree().change_scene_to_file("res://prototype/intro.tscn")
