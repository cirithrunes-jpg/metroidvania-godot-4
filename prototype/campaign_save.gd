extends Node
const PATH := "user://cyberpunk_campaign_v1.json"
var pending: Dictionary = {}

func read_record() -> Dictionary:
	if not FileAccess.file_exists(PATH): return {}
	var file := FileAccess.open(PATH,FileAccess.READ)
	if file == null: return {}
	var value = JSON.parse_string(file.get_as_text())
	if not value is Dictionary: return {}
	if value.get("version",0)!=1: return {}
	for field in ["sector","health"]:
		var number = value.get(field)
		if not (number is float or number is int): return {}
		if not is_finite(float(number)) or float(number)!=float(int(number)): return {}
	if not int(value.sector) in [1,2,3] or not int(value.health) in [1,2,3,4]: return {}
	if not value.get("relay",null) is bool or not value.get("units",null) is Dictionary: return {}
	for key in value.units:
		if not str(key).is_valid_int() or int(key)<0 or int(key)>10: return {}
		var amount = value.units[key]
		if not (amount is float or amount is int): return {}
		if not is_finite(float(amount)) or amount<1 or amount>5: return {}
	value["sector"] = int(value.sector)
	value["health"] = int(value.health)
	return value

func save_scene(scene) -> bool:
	if not is_instance_valid(scene.player): return false
	var units := {}
	for unit in get_tree().get_nodes_in_group("lab_enemies"):
		if not unit.dying: units[str(unit.spawn_id)] = unit.health
	# Resume at the activated checkpoint, avoiding midair or door-trigger saves.
	var record := {"version":1,"sector":scene.sector,"relay":scene.relay,"health":maxi(1,PlayerStats.health),"units":units,"facing":scene.player.facing}
	var file := FileAccess.open(PATH+".tmp",FileAccess.WRITE)
	if file == null: return false
	file.store_string(JSON.stringify(record))
	file.flush()
	file.close()
	return DirAccess.rename_absolute(ProjectSettings.globalize_path(PATH+".tmp"),ProjectSettings.globalize_path(PATH))==OK

func continue_game():
	pending = read_record()
	if pending.is_empty(): return
	var path := "res://prototype/laboratory.tscn" if pending.sector==1 else "res://prototype/sector_%d.tscn" % int(pending.sector)
	get_tree().change_scene_to_file(path)
