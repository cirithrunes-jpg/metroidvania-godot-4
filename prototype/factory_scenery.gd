extends Node2D
var sector := 1
var foreground := false
const STEEL = preload("res://prototype/assets/platform-steel-v6.png")
const PROPS = preload("res://prototype/assets/factory-props.png")
const WALL = preload("res://prototype/assets/laboratory-wall-v3.png")

func _ready():
	z_index = 20 if foreground else -4
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	if foreground: return
	var texture: Texture2D = WALL
	if ResourceLoader.exists("res://prototype/assets/corridor-backgrounds.png"):
		var atlas := AtlasTexture.new()
		atlas.atlas = load("res://prototype/assets/corridor-backgrounds.png")
		var height := atlas.atlas.get_height()/3.0
		atlas.region = Rect2(0,(sector-1)*height,atlas.atlas.get_width(),height)
		texture = atlas
	for tile in 2:
		var wall := Sprite2D.new()
		wall.z_index = -1
		wall.texture = texture
		wall.centered = false
		wall.position = Vector2(tile*960,0)
		wall.scale = Vector2(960.0/texture.get_width(),360.0/texture.get_height())
		wall.modulate = Color(0.65,0.70,0.76)
		add_child(wall)

func _draw():
	if foreground:
		for x in [320,705,1175,1585]:
			draw_rect(Rect2(x-2,0,12,348),Color(0.025,0.04,0.055,0.9))
			draw_texture_rect_region(STEEL,Rect2(x,0,6,348),Rect2(200,100,80,500),Color(0.3,0.36,0.4,0.9))
			draw_line(Vector2(x,0),Vector2(x,348),Color("617482"),0.6)
			for y in range(24,340,48): draw_circle(Vector2(x+3,y),0.8,Color("8f999e"))
		return
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
