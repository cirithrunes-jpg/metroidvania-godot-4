extends RefCounted

const DEFINITIONS := [
	["punch","Soco","combat",0,14.0,false],
	["kick","Chute","combat",1,14.0,false],
	["guard","Defesa","combat",2,8.0,false],
	["hit","Reação ao golpe","combat",3,12.0,false],
	["crouch","Agachar","mobility",0,10.0,false],
	["all_fours","Andar de quatro","mobility",1,12.0,true],
	["prone_crawl","Rastejar","mobility",2,10.0,true],
	["fall","Cair","mobility",3,10.0,false],
	["back_idle","De costas","extras",0,6.0,true],
	["turn","Virar o corpo","extras",1,10.0,false],
	["roll","Esquiva / rolamento","extras",2,16.0,false],
	["climb","Escalar","extras",3,10.0,true],
	["rifle","Arma de fogo","weapons",0,14.0,false],
	["sword","Espada","weapons",1,14.0,false],
	["grenade","Granada","weapons",2,12.0,false],
	["energy","Disparo de energia","weapons",3,12.0,false]
]
const ROWS := {
	"combat":[0,275,540,789,1024],
	"mobility":[0,380,587,729,1024],
	"extras":[0,266,550,742,1024],
	"weapons":[0,285,550,775,1024]
}
const BASELINES := {
	"combat":[266,528,777,1016],
	"mobility":[341,550,706,1006],
	"extras":[258,540,734,1012],
	"weapons":[258,516,758,984]
}
const COLUMN_CUTS := {
	"combat_0":[0,270,520,797,1047,1280,1536],
	"combat_1":[0,256,512,794,1065,1280,1536]
}
const FRAME_SIZE := Vector2(512,384)
const FOOT_ANCHOR := Vector2(256,352)
const EXTRA_SPLITS := [743,736,732,735,735,738]

static func build() -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	var images := {}
	for definition in DEFINITIONS:
		var label: String = definition[0]
		var name: String = definition[2]
		var row: int = definition[3]
		var path := "res://prototype/assets/poses/%s.png" % name
		var sheet = load(path) as Texture2D
		if not images.has(name): images[name] = sheet.get_image()
		var image: Image = images[name]
		var sx := image.get_width()/1536.0
		var sy := image.get_height()/1024.0
		var cuts: Array = COLUMN_CUTS.get("%s_%d" % [name,row],[0,256,512,768,1024,1280,1536])
		frames.add_animation(label)
		frames.set_animation_speed(label,definition[4])
		frames.set_animation_loop(label,definition[5])
		for column in 6:
			var source_column: int = column
			if name=="extras" and row==2 and column==5: source_column = 0
			if name=="extras" and row==3 and column==5: source_column = 1
			var top: float = ROWS[name][row]
			var bottom: float = ROWS[name][row+1]
			if name=="extras" and row==2: bottom = EXTRA_SPLITS[source_column]
			if name=="extras" and row==3: top = EXTRA_SPLITS[source_column]
			var region := Rect2i(int(cuts[source_column]*sx),int(top*sy),int((cuts[source_column+1]-cuts[source_column])*sx),int((bottom-top)*sy))
			var cropped := content_bounds(image,region)
			var anchor := Vector2((source_column+0.5)*256*sx,BASELINES[name][row]*sy)
			var atlas := AtlasTexture.new()
			atlas.atlas = sheet
			atlas.region = Rect2(cropped)
			atlas.margin = Rect2(FOOT_ANCHOR+Vector2(cropped.position)-anchor,FRAME_SIZE-Vector2(cropped.size))
			atlas.filter_clip = true
			frames.add_frame(label,atlas)
	frames.set_meta("foot_anchor",FOOT_ANCHOR)
	frames.set_meta("frame_size",FRAME_SIZE)
	var scales := {}
	for definition in DEFINITIONS: scales[definition[0]] = 1.5 if definition[2]=="weapons" else 1.0
	frames.set_meta("pose_scales",scales)
	return frames

static func content_bounds(image: Image, region: Rect2i) -> Rect2i:
	var minimum := region.end
	var maximum := region.position
	var found := false
	for y in range(region.position.y,region.end.y):
		for x in range(region.position.x,region.end.x):
			if image.get_pixel(x,y).a > 0.05:
				found = true
				minimum.x = mini(minimum.x,x)
				minimum.y = mini(minimum.y,y)
				maximum.x = maxi(maximum.x,x)
				maximum.y = maxi(maximum.y,y)
	if not found: return region
	minimum = Vector2i(maxi(region.position.x,minimum.x-2),maxi(region.position.y,minimum.y-2))
	maximum = Vector2i(mini(region.end.x,maximum.x+3),mini(region.end.y,maximum.y+3))
	return Rect2i(minimum,maximum-minimum)
