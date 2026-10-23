extends ColorRect

func _ready():
	PlayerStats.reset()
	color = Color("0b111c")
	var column = $CenterContainer/VBoxContainer
	var title := Label.new()
	title.text = "LABORATORIO / 01"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.modulate = Color("28cfff")
	column.add_child(title)
	column.move_child(title,0)
	var prototype_button := Button.new()
	prototype_button.text = "Jogar laboratorio (prototipo)"
	prototype_button.pressed.connect(func(): get_tree().change_scene_to_file("res://prototype/laboratory.tscn"))
	column.add_child(prototype_button)
	column.move_child(prototype_button,1)
	$CenterContainer/VBoxContainer/StartButton.text = "Jogar versao original"
	$CenterContainer/VBoxContainer/LoadButton.text = "Carregar original"
	$CenterContainer/VBoxContainer/QuitButton.text = "Sair"
	prototype_button.grab_focus()

func _on_start_button_pressed():
	Sound.play(Sound.click, 1.0, -10.0)
	WorldStash.data = {}
	get_tree().change_scene_to_file("res://world.tscn")

func _on_load_button_pressed():
	Sound.play(Sound.click, 1.0, -10.0)
	SaveManager.is_loading = true
	get_tree().change_scene_to_file("res://world.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
