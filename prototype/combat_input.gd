extends Node
signal bindings_changed
const PATH := "user://cyberpunk_controls_v4.cfg"
const ACTIONS := ["move_left","move_right","jump","attack_punch","attack_kick","fire","power","guard","grenade","sword","posture_down","climb_up","interact","pause","restart","main_menu"]
const LABELS := ["Mover para a esquerda","Mover para a direita","Saltar / salto duplo","Soco","Chute / chute aéreo","Atirar","Poder (segurar 2s)","Defender (segurar)","Granada","Espada","Agachar / deitar (1s)","Subir escada","Acionar botão","Pausar","Reiniciar corredor","Menu principal"]
const BUTTON_NAMES := {0:"A / ✕",1:"B / ○",2:"X / □",3:"Y / △",4:"Back / Select",5:"Guia / PS",6:"Menu / Start",7:"L3",8:"R3",9:"LB / L1",10:"RB / R1",11:"Direcional ↑",12:"Direcional ↓",13:"Direcional ←",14:"Direcional →"}
var defaults := {}


func _ready():
	for action in ACTIONS:
		if not InputMap.has_action(action): InputMap.add_action(action,0.22)
		InputMap.action_set_deadzone(action,0.55 if action in ["jump","posture_down"] else 0.22)
	for pair in [["fire",JOY_BUTTON_RIGHT_SHOULDER],["jump",JOY_BUTTON_A],["climb_up",JOY_BUTTON_DPAD_UP],["attack_punch",JOY_BUTTON_X],["attack_kick",JOY_BUTTON_Y],["interact",JOY_BUTTON_LEFT_STICK],["guard",JOY_BUTTON_B],["sword",JOY_BUTTON_LEFT_SHOULDER],["posture_down",JOY_BUTTON_DPAD_DOWN],["pause",JOY_BUTTON_START],["move_left",JOY_BUTTON_DPAD_LEFT],["move_right",JOY_BUTTON_DPAD_RIGHT]]:
		var event := InputEventJoypadButton.new()
		event.device = -1
		event.button_index = pair[1]
		InputMap.action_add_event(pair[0],event)
	for pair in [["move_left",JOY_AXIS_LEFT_X,-1.0],["move_right",JOY_AXIS_LEFT_X,1.0],["climb_up",JOY_AXIS_LEFT_Y,-1.0],["posture_down",JOY_AXIS_LEFT_Y,1.0],["power",JOY_AXIS_TRIGGER_RIGHT,1.0],["grenade",JOY_AXIS_TRIGGER_LEFT,1.0]]:
		var event := InputEventJoypadMotion.new()
		event.device = -1
		event.axis = pair[1]
		event.axis_value = pair[2]
		InputMap.action_add_event(pair[0],event)

	InputMap.action_erase_events("jump")
	var fixed_jump := InputEventJoypadButton.new()
	fixed_jump.device = -1
	fixed_jump.button_index = JOY_BUTTON_A
	InputMap.action_add_event("jump",fixed_jump)
	for pair in [["jump",KEY_SPACE],["restart",KEY_R],["main_menu",KEY_TAB],["power",KEY_C],["grenade",KEY_G],["sword",KEY_H],["posture_down",KEY_S],["posture_down",KEY_DOWN],["climb_up",KEY_W],["climb_up",KEY_UP]]:
		var key := InputEventKey.new()
		key.physical_keycode = pair[1]
		if not InputMap.action_has_event(pair[0],key): InputMap.action_add_event(pair[0],key)
	for action in ACTIONS: defaults[action] = InputMap.action_get_events(action).duplicate()
	load_bindings()

func event_kind(event: InputEvent) -> String:
	if event is InputEventKey: return "key"
	if event is InputEventJoypadButton or event is InputEventJoypadMotion: return "pad"
	return ""

func encode(event: InputEvent) -> Dictionary:
	if event is InputEventKey: return {"type":"key","code":event.physical_keycode if event.physical_keycode else event.keycode}
	if event is InputEventJoypadButton: return {"type":"button","code":event.button_index}
	if event is InputEventJoypadMotion: return {"type":"axis","code":event.axis,"sign":signf(event.axis_value)}
	return {}

func decode(data) -> InputEvent:
	if not data is Dictionary or not data.get("code",null) is int: return null
	var code: int = data.code
	if data.get("type")=="key" and code>0:
		var event := InputEventKey.new()
		event.physical_keycode = code
		return event
	if data.get("type")=="button" and code>=0 and code<21:
		var event := InputEventJoypadButton.new()
		event.device = -1
		event.button_index = code
		return event
	if data.get("type")=="axis" and code>=0 and code<10 and data.get("sign",0) in [-1.0,1.0]:
		var event := InputEventJoypadMotion.new()
		event.device = -1
		event.axis = code
		event.axis_value = data.sign
		return event
	return null

func events_for(action: String,kind: String) -> Array:
	return InputMap.action_get_events(action).filter(func(event): return event_kind(event)==kind)

func set_events(action: String,kind: String,events: Array):
	Input.action_release(action)
	for event in events_for(action,kind): InputMap.action_erase_event(action,event)
	for event in events: InputMap.action_add_event(action,event)

func assign(action: String,event: InputEvent) -> String:
	var kind := event_kind(event)
	if not action in ACTIONS or kind.is_empty(): return "Comando inválido."
	if kind=="pad" and (action=="jump" or (event is InputEventJoypadButton and event.button_index==JOY_BUTTON_A)):
		return "X/cruz (A no Xbox) é fixo para pular."
	if event is InputEventKey and event.physical_keycode==KEY_ESCAPE and action!="pause": return "Esc fica reservado para cancelar e acessar a pausa."
	var previous := events_for(action,kind)
	var conflict := ""
	for other in ACTIONS:
		if other==action: continue
		for existing in events_for(other,kind):
			if encode(existing)==encode(event): conflict = other
	if not conflict.is_empty() and previous.is_empty(): return "Esse botão já está em uso. Escolha um botão livre."
	if not conflict.is_empty(): set_events(conflict,kind,previous)
	set_events(action,kind,[event])
	bindings_changed.emit()
	return "Comandos trocados entre as duas ações." if not conflict.is_empty() else "Comando atualizado."

func save_bindings() -> bool:
	var config := ConfigFile.new()
	for action in ACTIONS:
		var entries := []
		for event in InputMap.action_get_events(action): entries.append(encode(event))
		config.set_value("bindings",action,entries)
	if config.save(PATH+".tmp")!=OK: return false
	return DirAccess.rename_absolute(ProjectSettings.globalize_path(PATH+".tmp"),ProjectSettings.globalize_path(PATH))==OK

func load_bindings():
	var config := ConfigFile.new()
	if config.load(PATH)!=OK: return
	var loaded := {}
	for action in ACTIONS:
		var entries = config.get_value("bindings",action,null)
		if not entries is Array or entries.size()>12: return
		var events := []
		for data in entries:
			var event := decode(data)
			if event==null: return
			events.append(event)
		if events.filter(func(event): return event is InputEventKey).is_empty(): return
		loaded[action] = events
	var jump_pad: Array = loaded.jump.filter(func(event): return event_kind(event)=="pad")
	if jump_pad.size()!=1 or not jump_pad[0] is InputEventJoypadButton or jump_pad[0].button_index!=JOY_BUTTON_A: return
	for action in ACTIONS:
		if action=="jump": continue
		for event in loaded[action]:
			if event is InputEventJoypadButton and event.button_index==JOY_BUTTON_A: return
	for action in ACTIONS:
		InputMap.action_erase_events(action)
		for event in loaded[action]: InputMap.action_add_event(action,event)
	bindings_changed.emit()

func restore_defaults():
	for action in ACTIONS:
		Input.action_release(action)
		InputMap.action_erase_events(action)
		for event in defaults[action]: InputMap.action_add_event(action,event)
	bindings_changed.emit()

func describe(action: String,kind: String) -> String:
	var names := PackedStringArray()
	for event in events_for(action,kind):
		if event is InputEventKey: names.append(key_name(event.physical_keycode if event.physical_keycode else event.keycode))
		elif event is InputEventJoypadButton: names.append(BUTTON_NAMES.get(event.button_index,"Botão %d" % event.button_index))
		elif event is InputEventJoypadMotion:
			if event.axis==JOY_AXIS_TRIGGER_RIGHT: names.append("RT / R2")
			elif event.axis==JOY_AXIS_TRIGGER_LEFT: names.append("LT / L2")
			elif event.axis==JOY_AXIS_LEFT_Y: names.append("Analógico ↑" if event.axis_value<0 else "Analógico ↓")
			elif event.axis==JOY_AXIS_LEFT_X: names.append("Analógico ←" if event.axis_value<0 else "Analógico →")
			else: names.append("Eixo %d %s" % [event.axis,"−" if event.axis_value<0 else "+"])
	return ", ".join(names) if not names.is_empty() else "Não definido"

func key_name(code: int) -> String:
	match code:
		KEY_LEFT: return "←"
		KEY_RIGHT: return "→"
		KEY_UP: return "↑"
		KEY_DOWN: return "↓"
		KEY_SPACE: return "Espaço"
		KEY_ESCAPE: return "Esc"
	return OS.get_keycode_string(code)
