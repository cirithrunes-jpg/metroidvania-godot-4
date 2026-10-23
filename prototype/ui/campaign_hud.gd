extends CanvasLayer

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
	health = make_label(Vector2(28,14),24)
	objective = make_label(Vector2(28,49),21)
	hint = make_label(Vector2(28,674),20)
	var shadow := ColorRect.new()
	shadow.color = Color(0.015,0.025,0.04,0.9)
	shadow.position = Vector2(12,666)
	shadow.size = Vector2(1256,40)
	shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(shadow)
	canvas.move_child(shadow,canvas.get_child_count()-2)
	hint.text = "A/D mover   ·   W / espaço: salto duplo   ·   Mouse: mirar e atirar   ·   Esc: pausa   ·   Tab: menu"
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
	objective.text = "Porta liberada — siga até a saída à direita." if relay else "Ative o relé luminoso na plataforma alta para liberar a porta."
	objective.modulate = Color("8ee3ef")
	if paused:
		objective.text = "PAUSADO — Esc para continuar. Tab para voltar ao menu."

func fade_out() -> Tween:
	var tween := create_tween()
	tween.tween_property(curtain,"color",Color.BLACK,0.35)
	return tween
