extends CanvasLayer

var shield: Label
var health: Label
var objective: Label
var hint: Label
var curtain: ColorRect
var root: Control
var canvas: Control

func _ready():
	layer = 30
	root = Control.new()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	root.scale = Vector2.ONE/4
	canvas = Control.new()
	canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(canvas)
	var bar := ColorRect.new()
	bar.color = Color(0.025,0.045,0.065,0.94)
	bar.size = Vector2(1280,88)
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(bar)
	shield = make_label(Vector2(850,14),21)
	health = make_label(Vector2(28,14),24)
	objective = make_label(Vector2(28,49),21)
	hint = make_label(Vector2(28,656),19)
	var shadow := ColorRect.new()
	shadow.color = Color(0.015,0.025,0.04,0.9)
	shadow.position = Vector2(12,648)
	shadow.size = Vector2(1256,64)
	shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(shadow)
	canvas.move_child(shadow,canvas.get_child_count()-2)
	CombatInput.bindings_changed.connect(refresh_bindings)
	refresh_bindings()
	curtain = ColorRect.new()
	curtain.size = Vector2(1280,720)
	curtain.color = Color(0,0,0,0)
	curtain.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(curtain)

func make_label(point: Vector2, size: int) -> Label:
	var label := Label.new()
	label.position = point
	label.add_theme_font_size_override("font_size",size)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(label)
	return label

func update_readout(sector: int, hp: int, maximum: int, relay: bool, paused: bool):
	health.text = "SETOR %02d   /   INTEGRIDADE  %d / %d" % [sector,hp,maximum]
	objective.text = "Porta liberada — siga até a saída à direita." if relay else "Suba até o botão e use %s para liberar a porta." % CombatInput.describe("interact","key")
	objective.modulate = Color("8ee3ef")
	if paused:
		objective.text = "PAUSADO — use Continuar, Salvar, Controles ou Menu principal."

func fade_out() -> Tween:
	var tween := create_tween()
	tween.tween_property(curtain,"color",Color.BLACK,0.35)
	return tween

func update_shield(hits: int, recovery: float, defending: bool):
	shield.text = "ESCUDO: RECARGA %.1fs" % recovery if recovery > 0 else "ESCUDO: %d/2%s" % [maxi(0,2-hits)," DEFENDENDO" if defending else ""]
	shield.modulate = Color("ff9a79") if hits>=2 else Color("8ee3ef")

func refresh_bindings():
	var names := []
	for action in ["move_left","move_right","jump","fire","attack_punch","attack_kick","guard","interact","pause"]:
		names.append(CombatInput.describe(action,"key").split(", ")[0])
	hint.text = "%s/%s mover · %s salto · %s tiro · %s soco · %s chute · %s defesa\n%s botão · %s pausa · Esc: acesso de emergência · Controles configuráveis na pausa" % names
