extends Node2D
var sector := 1
var foreground := false
const STEEL = preload("res://prototype/assets/platform-steel-v6.png")
const PROPS = preload("res://prototype/assets/factory-props.png")
const WALL = preload("res://prototype/assets/laboratory-wall-v3.png")

func _ready():
	z_index = 20 if foreground else -4
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	if foreground:
		add_depth(2,1.12,0)
		return
	add_depth(0,0.25,0)
	add_depth(1,0.60,1)

func add_depth(band: int,depth: float,order: int):
	var layer := Node2D.new()
	layer.set_script(preload("res://prototype/visual_depth.gd"))
	layer.band = band
	layer.depth = depth
	layer.sector = sector
	layer.z_index = order
	add_child(layer)

func _draw():
	if foreground: return
	for x in range(60+sector*35,1920,230):
		draw_rect(Rect2(x,12,9,280),Color("17242e"))
		draw_line(Vector2(x,30),Vector2(x+150,110+sector*15),Color("263a45"),5)
	# Sparse floor dressing; the four cans/barrels are separate breakable nodes.
	for index in 3:
		var x: float = [560,1130,1550][index]
		var source := Rect2(1055,286,531,342) if index!=1 else Rect2(1660,449,452,191)
		var height := 10.0 if index!=1 else 5.0
		var width := source.size.x/source.size.y*height
		draw_texture_rect_region(PROPS,Rect2(x,300-height,width,height),source)
