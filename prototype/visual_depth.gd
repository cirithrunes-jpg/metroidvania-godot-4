extends Node2D
var band := 0
var depth := 0.35
var sector := 1
const SHEET = preload("res://prototype/assets/industrial-depth-v12.png")
func _ready():
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
func _process(_delta):
	var camera := get_viewport().get_camera_2d()
	if camera: position.x = fposmod(camera.get_screen_center_position().x*(1-depth),768)
	queue_redraw()
func _draw():
	var h := SHEET.get_height()/3.0
	var source := Rect2(0,band*h,SHEET.get_width(),h)
	var tint: Color = [Color(0.62,0.72,0.82),Color(0.80,0.69,0.56),Color(0.64,0.76,0.69)][sector-1]
	if band==1: tint.a = 0.65
	if band==2: tint = Color(0.34,0.40,0.45,0.80)
	for tile in range(-2,4):
		var destination := Rect2(tile*768,0,768,360)
		if band==1: destination = Rect2(tile*768,155,768,145)
		draw_texture_rect_region(SHEET,destination,source,tint)
