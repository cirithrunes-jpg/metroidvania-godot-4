extends CanvasLayer
var world: Node
var panel: Control
var controls: CanvasLayer
var status: Label
var resume: Button
func _ready():
	layer = 60
	var ui := Control.new()
	ui.scale = Vector2.ONE/4
	add_child(ui)
	var shade := ColorRect.new()
	shade.color = Color(0.01,0.02,0.035,0.96)
	shade.size = Vector2(1280,720)
	ui.add_child(shade)
	panel = Control.new()
	ui.add_child(panel)
	label(panel,"PAUSADO",Vector2(400,100),42)
	resume = button(panel,"Continuar",Vector2(400,200),func(): world.toggle_pause())
	button(panel,"Salvar progresso",Vector2(400,284),save_progress)
	button(panel,"Controles",Vector2(400,368),show_controls)
	button(panel,"Menu principal",Vector2(400,452),func(): get_tree().change_scene_to_file("res://menus/start_menu.tscn"))
	status = label(panel,"Retorno pelo checkpoint. Inimigos vencidos são salvos.",Vector2(250,570),22)
	hide()

func label(parent: Node, text: String, point: Vector2, size: int) -> Label:
	var item := Label.new()
	item.text = text
	item.position = point
	item.add_theme_font_size_override("font_size",size)
	parent.add_child(item)
	return item
func button(parent: Node,text: String,point: Vector2,action: Callable) -> Button:
	var item := Button.new()
	item.text = text
	item.position = point
	item.size = Vector2(480,62)
	item.pressed.connect(action)
	parent.add_child(item)
	return item
func show_pause(open: bool):
	visible = open
	if is_instance_valid(controls): controls.queue_free()
	panel.show()
	if open: resume.grab_focus()
func show_controls():
	panel.hide()
	controls = CanvasLayer.new()
	controls.set_script(preload("res://prototype/ui/control_settings.gd"))
	add_child(controls)
	controls.closed.connect(hide_controls)
func hide_controls():
	if is_instance_valid(controls): controls.queue_free()
	panel.show()
	resume.grab_focus()
func save_progress():
	status.text = "PROGRESSO SALVO — use Continuar no menu principal." if CampaignSave.save_scene(world) else "Não foi possível salvar. Tente novamente."
