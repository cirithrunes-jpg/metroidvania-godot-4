extends World

const CYAN := Color("28cfff")
const RED := Color("f34e64")
const BACKDROP = preload("res://prototype/assets/laboratory-wall-v3.png")
const PLATFORM = preload("res://prototype/assets/platform-steel-v6.png")
const LAB_SOUNDTRACK = preload("res://prototype/assets/steel-dungeon-soundtrack.mp3")
const FLOORS := [Rect2(0,152,260,28),Rect2(300,152,310,28),Rect2(660,152,300,28),Rect2(184,120,60,8),Rect2(342,116,70,8),Rect2(446,80,74,8),Rect2(560,112,60,8),Rect2(704,114,70,8)]
@export_range(1,3) var sector := 1
var floors: Array = FLOORS
var corridor_width := 1920
var door_point := Vector2(1860,300)
var player: CharacterBody2D
var checkpoint := Vector2(36,148)
var relay_point := Vector2(484,80)
var relay_checkpoint := Vector2(570,108)
var deployment := [Vector2(165,152),Vector2(382,116),Vector2(550,152),Vector2(682,77),Vector2(831,152)]
var relay := false
var finished := false
var transitioning := false
var paused := false
var elapsed := 0.0
var hud: CanvasLayer
var exit_door: Node2D
var pause_menu: CanvasLayer
var relay_label: Label

func _enter_tree():
	MainInstances.world = self

func configure_sector():
	floors = [Rect2(0,300,440,60),Rect2(480,300,560,60),Rect2(1080,300,380,60),Rect2(1500,300,420,60)]
	var shift := float((sector-1)*90)
	for step in 4: floors.append(Rect2(540+shift+step*90,264-step*36,112,9))
	relay_point = Vector2(860+shift,156)
	relay_checkpoint = Vector2(842+shift,152)
	for x in [180,350,1100,1280,1450]: floors.append(Rect2(x,250,110,9))
	floors.append(Rect2(1190,212,120,9))
	floors.append(Rect2(1370,210,110,9))
	if sector == 2:
		for step in 4: floors.append(Rect2(1530+step*90,264-step*36,120,9))
		door_point = Vector2(1860,156)
	else: door_point = Vector2(1860,300)
	checkpoint = Vector2(36,296)
	deployment = [Vector2(190,300),Vector2(385,300),Vector2(600,300),Vector2(910,300),Vector2(1160,300),Vector2(1350,300),Vector2(1560,300),Vector2(1740,300),Vector2(650+shift,228),Vector2(1200,170),Vector2(1430,210)]

func _ready():
	configure_sector()
	PlayerStats.reset()
	WorldStash.data = {}
	RenderingServer.set_default_clear_color(Color("090e17"))
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	for front in [false,true]:
		var scenery := Node2D.new()
		scenery.set_script(preload("res://prototype/factory_scenery.gd"))
		scenery.sector = sector
		scenery.foreground = front
		add_child(scenery)
	for rect in floors:
		var body := StaticBody2D.new()
		var shape := CollisionShape2D.new()
		var box := RectangleShape2D.new()
		box.size = rect.size
		shape.shape = box
		shape.one_way_collision = rect.size.y < 10
		body.position = rect.get_center()
		body.add_child(shape)
		add_child(body)
	for x in [-8,corridor_width+8]:
		var wall := StaticBody2D.new()
		var collision := CollisionShape2D.new()
		var box := RectangleShape2D.new()
		box.size = Vector2(16,800)
		collision.shape = box
		wall.position = Vector2(x,0)
		wall.add_child(collision)
		add_child(wall)
	var record: Dictionary = CampaignSave.pending
	CampaignSave.pending = {}
	if not record.is_empty() and int(record.sector)==sector:
		relay = record.relay
		if relay: checkpoint = relay_checkpoint
		PlayerStats.health = int(record.health)
	spawn_player()
	if not record.is_empty(): player.facing = float(record.get("facing",1))
	for index in deployment.size():
		var enemy = preload("res://prototype/enemies/security_unit.tscn").instantiate()
		if not record.is_empty() and not record.units.has(str(index)):
			enemy.free()
			continue
		enemy.spawn_id = index
		enemy.kind = [0,0,2,1,0,2,0,4,1,3,2][index]
		enemy.position = deployment[index]
		enemy.patrol_radius = 16.0 if index == 1 else 20.0
		add_child(enemy)
		if not record.is_empty(): enemy.health = clampi(int(record.units[str(index)]),1,enemy.HEALTH[enemy.kind])
	for index in 4:
		if not record.is_empty() and record.has("props") and not record.props.has(str(index)): continue
		var prop := Node2D.new()
		prop.set_script(preload("res://prototype/breakable_prop.gd"))
		prop.prop_id = index
		prop.kind = index%2
		prop.position = Vector2([300,740,1240,1660][index],300)
		add_child(prop)
		if not record.is_empty() and record.has("props"): prop.health = clampi(int(record.props[str(index)]),1,2 if prop.kind==0 else 1)
	hud = CanvasLayer.new()
	hud.set_script(preload("res://prototype/ui/campaign_hud.gd"))
	add_child(hud)
	pause_menu = CanvasLayer.new()
	pause_menu.set_script(preload("res://prototype/ui/pause_menu.gd"))
	pause_menu.world = self
	add_child(pause_menu)
	exit_door = Node2D.new()
	exit_door.set_script(preload("res://prototype/pressure_door.gd"))
	exit_door.position = door_point
	add_child(exit_door)
	exit_door.entered.connect(begin_transition)
	relay_label = world_label("",relay_point+Vector2(-24,-34))
	CombatInput.bindings_changed.connect(refresh_control_label)
	refresh_control_label()
	world_label("PRÓXIMO SETOR" if sector<3 else "SAÍDA",door_point+Vector2(-24,-82))
	Events.player_died.connect(respawn)
	if Music.audio_stream_player.stream != LAB_SOUNDTRACK or not Music.audio_stream_player.playing:
		Music.play(LAB_SOUNDTRACK)

func world_label(text: String, point: Vector2):
	var label := Label.new()
	label.text = text
	label.position = point
	label.scale = Vector2.ONE/4
	label.add_theme_font_size_override("font_size",19)
	label.modulate = Color("b2e4ea")
	add_child(label)
	return label

func refresh_control_label():
	if is_instance_valid(relay_label): relay_label.text = "%s: ACIONAR BOTÃO" % CombatInput.describe("interact","key")

func spawn_player():
	player = preload("res://prototype/player.tscn").instantiate()
	player.position = checkpoint
	add_child(player)
	var camera: Camera2D = player.get_node("Camera2D")
	camera.limit_left = 0
	camera.limit_right = corridor_width
	camera.limit_top = 0
	camera.limit_bottom = 360
	player.reset_physics_interpolation()
	camera.reset_smoothing()

func respawn():
	await get_tree().create_timer(1.1).timeout
	if not is_inside_tree() or transitioning: return
	for child in get_children():
		if child is Camera2D: child.queue_free()
	PlayerStats.refill()
	spawn_player()

func _process(delta):
	if not paused: elapsed += delta
	if is_instance_valid(player) and not paused and not finished:
		if player.position.y > 390:
			player.position = checkpoint
			player.velocity = Vector2.ZERO
			player.reset_physics_interpolation()
			player.get_node("Camera2D").reset_smoothing()
			PlayerStats.health = maxi(1,PlayerStats.health-1)
		if player.position.distance_to(relay_point)<24 and Input.is_action_just_pressed("interact"):
			relay = true
			checkpoint = relay_checkpoint
	exit_door.unlocked = relay
	exit_door.paused = paused
	hud.update_readout(sector,PlayerStats.health,PlayerStats.max_health,relay,paused)
	if is_instance_valid(player): hud.update_shield(player.shield_hits,player.shield_recovery,player.guarding)
	queue_redraw()

func begin_transition():
	if transitioning: return
	finished = true
	transitioning = true
	player.process_mode = Node.PROCESS_MODE_DISABLED
	for enemy in get_tree().get_nodes_in_group("lab_enemies"): enemy.process_mode = Node.PROCESS_MODE_DISABLED
	level.process_mode = Node.PROCESS_MODE_DISABLED
	var tween: Tween = hud.fade_out()
	await tween.finished
	var path := "res://prototype/sector_%d.tscn" % (sector+1) if sector<3 else "res://prototype/ui/completed.tscn"
	get_tree().change_scene_to_file(path)

func toggle_pause():
	if finished: return
	paused = not paused
	pause_menu.show_pause(paused)
	for child in get_children():
		if child is Node2D: child.process_mode = Node.PROCESS_MODE_DISABLED if paused else Node.PROCESS_MODE_INHERIT

func _unhandled_input(event):
	if event.is_echo() or transitioning: return
	if event.is_action_pressed("pause") or (event is InputEventKey and event.pressed and event.physical_keycode==KEY_ESCAPE):
		toggle_pause()
	elif not paused:
		if event.is_action_pressed("restart"): get_tree().reload_current_scene()
		elif event.is_action_pressed("main_menu"): get_tree().change_scene_to_file("res://menus/start_menu.tscn")

func _draw():
	var source := Rect2(0,PLATFORM.get_height()*0.11,PLATFORM.get_width(),PLATFORM.get_height()*0.77)
	for rect in floors:
		var x: float = rect.position.x
		while x < rect.end.x:
			var width: float = minf(90,rect.end.x-x)
			draw_texture_rect_region(PLATFORM,Rect2(x,rect.position.y,width,rect.size.y),Rect2(source.position,Vector2(source.size.x*width/90,source.size.y)))
			x += width
		draw_line(rect.position,Vector2(rect.end.x,rect.position.y),Color("a8b9c0"),0.45)
		if rect.size.y < 10:
			draw_line(rect.position+Vector2(4,8),rect.position+Vector2(12,13),Color("263a44"),1.2)
			draw_line(rect.position+Vector2(rect.size.x-4,8),rect.position+Vector2(rect.size.x-12,13),Color("263a44"),1.2)
	for x in [440,1040,1460]:
		draw_rect(Rect2(x,354,40,6),Color("712433"))
		draw_line(Vector2(x,352),Vector2(x+40,352),RED,0.7)
	var panel := Rect2(relay_point+Vector2(-9,-22),Vector2(18,22))
	draw_style_box(relay_style(),panel)
	draw_rect(Rect2(relay_point+Vector2(-6,-18),Vector2(12,6)),CYAN if not relay else Color("a0ffda"))
	draw_line(relay_point+Vector2(-5,-8),relay_point+Vector2(5,-8),Color("6b8b98"),1)

func relay_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("1b2a35")
	style.border_color = Color("6c8a97")
	style.set_border_width_all(1)
	return style

func _exit_tree():
	if not transitioning: Music.audio_stream_player.stop()
	MainInstances.world = null
