extends CanvasLayer
signal closed
var waiting_action := ""
var waiting_kind := ""
var capture_delay := 0.0
var status: Label
var rows := {}
var snapshot := {}
var first: Button
func _ready():
	layer = 80
	for action in CombatInput.ACTIONS: snapshot[action] = InputMap.action_get_events(action).duplicate()
	var ui := Control.new()
	ui.scale = Vector2.ONE/4
	add_child(ui)
	var shade := ColorRect.new()
	shade.color = Color("08121d")
	shade.size = Vector2(1280,720)
	ui.add_child(shade)
	label(ui,"CONFIGURAR CONTROLES",Vector2(80,24),34)
	label(ui,"Selecione uma ação, pressione a tecla ou botão desejado e salve.",Vector2(80,72),21)
	label(ui,"AÇÃO",Vector2(80,112),20)
	label(ui,"TECLADO",Vector2(420,112),20)
	label(ui,"XBOX / PLAYSTATION",Vector2(800,112),20)
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(70,144)
	scroll.size = Vector2(1140,426)
	scroll.follow_focus = true
	ui.add_child(scroll)
	var list := VBoxContainer.new()
	list.custom_minimum_size.x = 1100
	list.add_theme_constant_override("separation",5)
	scroll.add_child(list)
	for index in CombatInput.ACTIONS.size():
		var action: String = CombatInput.ACTIONS[index]
		var row := HBoxContainer.new()
		row.custom_minimum_size.y = 36
		row.add_theme_constant_override("separation",20)
		list.add_child(row)
		var title := Label.new()
		title.text = CombatInput.LABELS[index]
		title.custom_minimum_size = Vector2(320,36)
		title.add_theme_font_size_override("font_size",20)
		row.add_child(title)
		rows[action] = {}
		for kind in ["key","pad"]:
			var item := Button.new()
			item.custom_minimum_size = Vector2(350,36)
			item.add_theme_font_size_override("font_size",18)
			item.pressed.connect(func(): begin_capture(action,kind))
			row.add_child(item)
			rows[action][kind] = item
			if index==0 and kind=="key": first = item
	status = label(ui,"Conflitos trocam os comandos. Esc cancela a captura. Analógico e gatilhos são aceitos.",Vector2(80,588),20)
	button(ui,"Restaurar padrão",Vector2(80,640),Vector2(330,52),reset_defaults)
	button(ui,"Salvar e voltar",Vector2(470,640),Vector2(330,52),save_close)
	button(ui,"Voltar sem salvar",Vector2(860,640),Vector2(330,52),cancel_close)
	refresh()
	first.grab_focus()
func label(parent: Node,text: String,point: Vector2,size: int) -> Label:
	var item := Label.new()
	item.text = text
	item.position = point
	item.add_theme_font_size_override("font_size",size)
	parent.add_child(item)
	return item
func button(parent: Node,text: String,point: Vector2,size: Vector2,action: Callable) -> Button:
	var item := Button.new()
	item.text = text
	item.position = point
	item.size = size
	item.pressed.connect(action)
	parent.add_child(item)
	return item
func refresh():
	for action in CombatInput.ACTIONS:
		for kind in ["key","pad"]: rows[action][kind].text = CombatInput.describe(action,kind)
func begin_capture(action: String,kind: String):
	waiting_action = action
	waiting_kind = kind
	capture_delay = 0.18
	status.text = "Pressione %s para %s. Esc cancela." % ["uma tecla" if kind=="key" else "um botão / gatilho / analógico",CombatInput.LABELS[CombatInput.ACTIONS.find(action)]]
	rows[action][kind].text = "AGUARDANDO…"
func _process(delta): capture_delay = maxf(0,capture_delay-delta)
func _input(event):
	if waiting_action.is_empty():
		if event.is_action_pressed("ui_cancel"):
			get_viewport().set_input_as_handled()
			cancel_close()
		return
	if event is InputEventMouse: return
	get_viewport().set_input_as_handled()
	if event is InputEventKey and event.pressed and event.physical_keycode==KEY_ESCAPE:
		waiting_action = ""
		refresh()
		status.text = "Captura cancelada."
		return
	if capture_delay>0 or CombatInput.event_kind(event)!=waiting_kind: return
	if event is InputEventKey and (not event.pressed or event.echo): return
	if event is InputEventJoypadButton and not event.pressed: return
	if event is InputEventJoypadMotion and absf(event.axis_value)<0.75: return
	var clean: InputEvent = CombatInput.decode(CombatInput.encode(event))
	if clean==null: return
	status.text = CombatInput.assign(waiting_action,clean)+" Salve para manter."
	waiting_action = ""
	refresh()
func reset_defaults():
	waiting_action = ""
	CombatInput.restore_defaults()
	refresh()
	status.text = "Padrão restaurado. Salve para manter."
func save_close():
	waiting_action = ""
	if CombatInput.save_bindings(): closed.emit()
	else: status.text = "Não foi possível salvar. Tente novamente."
func cancel_close():
	for action in CombatInput.ACTIONS:
		Input.action_release(action)
		InputMap.action_erase_events(action)
		for event in snapshot[action]: InputMap.action_add_event(action,event)
	CombatInput.bindings_changed.emit()
	closed.emit()
