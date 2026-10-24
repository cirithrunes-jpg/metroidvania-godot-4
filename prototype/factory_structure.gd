extends Node2D
const STEEL = preload("res://prototype/assets/platform-steel-v6.png")
var floors: Array = []
var supports: Array = []
var ladders: Array = []
var rails: Array = []
func _ready():
	z_index = -1
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	for index in floors.size():
		var platform: Rect2 = floors[index]
		if platform.size.y>=10: continue
		var columns := []
		for x in [platform.position.x+10,platform.end.x-10]:
			var foot_x: float = x
			var distance := INF
			for ground in floors:
				if ground.size.y<10: continue
				var candidate: float = clampf(x,ground.position.x+6,ground.end.x-6)
				if absf(x-candidate)<distance:
					distance = absf(x-candidate)
					foot_x = candidate
			columns.append({"top":Vector2(x,platform.end.y),"foot":Vector2(foot_x,300)})
		supports.append({"platform":platform,"columns":columns})
		var ladder_x := platform.position.x+24 if index%2==0 else platform.end.x-24
		var bottom := 300.0
		for lower in floors:
			if lower.position.y>platform.position.y+16 and ladder_x>lower.position.x+4 and ladder_x<lower.end.x-4:
				bottom = minf(bottom,lower.position.y)
		ladders.append({"x":ladder_x,"top":platform.position.y,"bottom":bottom})
		rails.append(platform)
		for edge in [platform.position.x+2,platform.end.x-2]:
			var barrier := StaticBody2D.new()
			barrier.collision_layer = 128
			barrier.collision_mask = 0
			var collision := CollisionShape2D.new()
			var shape := RectangleShape2D.new()
			shape.size = Vector2(2,18)
			collision.shape = shape
			barrier.position = Vector2(edge,platform.position.y-9)
			barrier.add_child(collision)
			add_child(barrier)
	queue_redraw()
func ladder_at(point: Vector2,direction: float) -> Dictionary:
	for ladder in ladders:
		if absf(point.x-ladder.x)>12 or point.y<ladder.top-3 or point.y>ladder.bottom+4: continue
		if direction<0 and point.y>ladder.top+1: return ladder
		if direction>0 and point.y<ladder.bottom-1: return ladder
	return {}
func beam(start: Vector2,end: Vector2,width: float):
	var span := end-start
	if span.length()<1: return
	draw_set_transform(start,span.angle())
	draw_texture_rect_region(STEEL,Rect2(0,-width/2,span.length(),width),Rect2(0,90,STEEL.get_width(),420),Color("677b88"))
	draw_line(Vector2(0,-width/2),Vector2(span.length(),-width/2),Color("8396a1"),0.5)
	draw_line(Vector2(0,width/2),Vector2(span.length(),width/2),Color("172630"),0.8)
	draw_set_transform(Vector2.ZERO)
func _draw():
	for support in supports:
		var columns: Array = support.columns
		for column in columns:
			beam(column.top,column.foot,4)
			draw_rect(Rect2(column.foot+Vector2(-5,-2),Vector2(10,2)),Color("647480"))
		var left: Vector2 = columns[0].top
		var right: Vector2 = columns[1].top
		var height: float = minf(28,300-left.y)
		beam(left,Vector2(right.x,left.y+height),2)
		beam(right,Vector2(left.x,right.y+height),2)
	for ladder in ladders:
		var x: float = ladder.x
		var top: float = ladder.top
		var bottom: float = ladder.bottom
		beam(Vector2(x-5,top-10),Vector2(x-5,bottom),1.7)
		beam(Vector2(x+5,top-10),Vector2(x+5,bottom),1.7)
		for y in range(int(top)+3,int(bottom),6):
			draw_line(Vector2(x-5,y),Vector2(x+5,y),Color("acb5b6"),1.3)
	for platform in rails:
		var y: float = platform.position.y
		# Rear safety rails stay behind actors and never block the playable route.
		for x in range(int(platform.position.x)+4,int(platform.end.x),26):
			draw_line(Vector2(x,y-2),Vector2(x,y-18),Color("7c847c"),1.6)
			draw_circle(Vector2(x,y-17),1,Color("d0aa56"))
		draw_line(Vector2(platform.position.x+4,y-18),Vector2(platform.end.x-4,y-18),Color("b49a5c"),1.6)
		draw_line(Vector2(platform.position.x+4,y-9),Vector2(platform.end.x-4,y-9),Color("626f72"),1)
