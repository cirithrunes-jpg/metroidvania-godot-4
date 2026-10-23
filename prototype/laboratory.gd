extends World

const CYAN := Color("28cfff")
const RED := Color("f34e64")
const BACKDROP = preload("res://prototype/assets/laboratory-wall-v3.png")
const FLOORS := [Rect2(0,152,260,28), Rect2(300,152,310,28), Rect2(660,152,300,28), Rect2(184,120,60,8), Rect2(342,116,70,8), Rect2(446,80,74,8), Rect2(560,112,60,8), Rect2(704,114,70,8)]
var player: CharacterBody2D
var checkpoint := Vector2(36,148)
var relay := false
var finished := false
var paused := false
var elapsed := 0.0
var status: Label
var health: Label

func _enter_tree():
	MainInstances.world = self


func _ready():
	PlayerStats.reset()
	WorldStash.data = {}
	RenderingServer.set_default_clear_color(Color("090e17"))
	var backdrop := Sprite2D.new()
	backdrop.name = "LaboratoryBackdrop"
	backdrop.texture = BACKDROP
	backdrop.centered = false
	backdrop.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	# Preserve proportions; the viewport crops the lower service wall behind the floors.
	backdrop.scale = Vector2.ONE * (960.0 / BACKDROP.get_width())
	backdrop.position = Vector2(0,-36)
	backdrop.modulate = Color(0.72,0.77,0.84,1)
	backdrop.z_index = -5
	add_child(backdrop)
	for rect in FLOORS:
		var body := StaticBody2D.new()
		var shape := CollisionShape2D.new()
		var box := RectangleShape2D.new()
		box.size = rect.size
		shape.shape = box
		body.position = rect.get_center()
		body.add_child(shape)
		add_child(body)
	for x in [-8, 960]:
		var wall := StaticBody2D.new()
		var collision := CollisionShape2D.new()
		var box := RectangleShape2D.new()
		box.size = Vector2(16,400)
		collision.shape = box
		wall.position = Vector2(x,0)
		wall.add_child(collision)
		add_child(wall)
	spawn_player()
	for x in [370,740,840]:
		var enemy = preload("res://enemies/walking_enemy.tscn").instantiate()
		enemy.position = Vector2(x,145)
		enemy.modulate = Color("ec7486")
		add_child(enemy)
	var canvas := CanvasLayer.new()
	add_child(canvas)
	var panel := ColorRect.new()
	panel.color = Color("101927")
	panel.size = Vector2(320,32)
	canvas.add_child(panel)
	health = Label.new()
	health.position = Vector2(7,2)
	health.add_theme_font_size_override("font_size",8)
	canvas.add_child(health)
	status = Label.new()
	status.position = Vector2(7,17)
	status.add_theme_font_size_override("font_size",8)
	canvas.add_child(status)
	Events.player_died.connect(respawn)
	Music.play(Music.main_theme)

func spawn_player():
	player = preload("res://player/player.tscn").instantiate()
	player.position = checkpoint
	add_child(player)
	# Match the taller silhouette only in the laboratory; preserve the original scene.
	for path in ["CollisionShape2D", "Hurtbox/CollisionShape2D"]:
		var collider = player.get_node(path)
		collider.shape = collider.shape.duplicate()
		collider.shape.size = Vector2(10,26)
		collider.position = Vector2(0,-13)
	player.get_node("Sprite2D/RemoteTransform2D").position = Vector2(2,-4)
	var blaster = player.get_node("PlayerBlaster/BlasterSprite")
	blaster.self_modulate.a = 0
	var weapon := Polygon2D.new()
	weapon.polygon = PackedVector2Array([Vector2(-3,-2),Vector2(7,-2),Vector2(9,0),Vector2(7,2),Vector2(-3,2)])
	weapon.color = Color("465e70")
	blaster.add_child(weapon)
	var seam := Line2D.new()
	seam.points = PackedVector2Array([Vector2(0,-1),Vector2(7,-1)])
	seam.width = 0.6
	seam.default_color = CYAN
	blaster.add_child(seam)
	player.get_node("Sprite2D").self_modulate.a = 0
	var art := AnimatedSprite2D.new()
	art.name = "Specimen"
	art.set_script(preload("res://prototype/specimen.gd"))
	art.actor = player
	player.add_child(art)
	var camera: Camera2D = player.get_node("Camera2D")
	camera.limit_left = 0
	camera.limit_right = 960
	camera.limit_top = 0
	camera.limit_bottom = 180

func respawn():
	await get_tree().create_timer(1.1).timeout
	if not is_inside_tree(): return
	for child in get_children():
		if child is Camera2D: child.queue_free()
	PlayerStats.refill()
	spawn_player()

func _process(delta):
	elapsed += delta
	if is_instance_valid(player) and not paused and not finished:
		if player.position.y > 195:
			player.position = checkpoint
			player.velocity = Vector2.ZERO
			PlayerStats.health = maxi(1,PlayerStats.health - 1)
		if player.position.distance_to(Vector2(484,80)) < 24:
			relay = true
			checkpoint = Vector2(570,108)
		if relay and player.position.x > 908:
			finished = true
			player.process_mode = Node.PROCESS_MODE_DISABLED
	health.text = "LAB / 01     INTEGRIDADE %d / %d" % [PlayerStats.health,PlayerStats.max_health]
	status.text = "RELE ATIVO > SAIDA A DIREITA" if relay else "ATIVE O RELE AZUL NA PLATAFORMA ALTA"
	if paused: status.text = "PAUSA / ESC RETOMA / TAB MENU"
	if finished: status.text = "CONTENCAO ROMPIDA / R REINICIA / TAB MENU"
	queue_redraw()

func toggle_pause():
	if finished: return
	paused = not paused
	for child in get_children():
		if child is Node2D: child.process_mode = Node.PROCESS_MODE_DISABLED if paused else Node.PROCESS_MODE_INHERIT

func _unhandled_input(event):
	if event.is_action_pressed("pause") and not event.is_echo():
		toggle_pause()

func _unhandled_key_input(event):
	if not event.pressed or event.echo: return
	if event.physical_keycode == KEY_R:
		get_tree().reload_current_scene()
	elif event.physical_keycode == KEY_TAB:
		get_tree().change_scene_to_file("res://menus/start_menu.tscn")

func _draw():
	for rect in FLOORS:
		draw_rect(rect,Color("303d49"))
		draw_rect(Rect2(rect.position,Vector2(rect.size.x,2)),Color("8295a2"))
		for x in range(int(rect.position.x)+4,int(rect.end.x)-4,12):
			draw_line(Vector2(x,rect.position.y+4),Vector2(x+5,rect.position.y+7),Color("18232e"),2)
	for x in [260,610]:
		draw_rect(Rect2(x,170,50,10),RED)
		for stripe in range(x,x+50,10):
			draw_line(Vector2(stripe,170),Vector2(stripe+6,178),Color("251a27"),3)
	for light in [Vector2(267,55),Vector2(755,59)]:
		draw_circle(light,3,Color(1,0.16,0.25,0.08+sin(elapsed*3)*0.04))
	draw_rect(Rect2(475,61,18,19),Color("224858"))
	draw_rect(Rect2(478,64,12,8),CYAN if not relay else Color("a0ffda"))
	draw_rect(Rect2(908,89,32,63),Color("233747"))
	draw_rect(Rect2(912,93,24,59),CYAN if relay else RED,false,2)
	var font := ThemeDB.fallback_font
	draw_rect(Rect2(16,49,160,59),Color(0.025,0.04,0.065,0.84))
	draw_string(font,Vector2(22,64),"CONTENCAO / 01",HORIZONTAL_ALIGNMENT_LEFT,-1,10,CYAN)
	draw_string(font,Vector2(22,79),"A/D mover | W salto duplo",HORIZONTAL_ALIGNMENT_LEFT,-1,8,Color("99abbc"))
	draw_string(font,Vector2(22,91),"Mouse mira / clique atira",HORIZONTAL_ALIGNMENT_LEFT,-1,8,Color("99abbc"))
	draw_string(font,Vector2(22,103),"ESC pausa | TAB menu | R reinicia",HORIZONTAL_ALIGNMENT_LEFT,-1,7,Color("99abbc"))
	draw_string(font,Vector2(452,54),"RELE / CHECKPOINT",HORIZONTAL_ALIGNMENT_LEFT,-1,8,CYAN)
	draw_string(font,Vector2(895,82),"SAIDA",HORIZONTAL_ALIGNMENT_LEFT,-1,9,CYAN)

func _exit_tree():
	Music.audio_stream_player.stop()
	MainInstances.world = null


