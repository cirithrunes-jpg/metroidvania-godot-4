extends Node

func _ready():
	for action in ["fire","attack_punch","attack_kick","guard","interact","pause","jump","move_left","move_right"]:
		if not InputMap.has_action(action): InputMap.add_action(action,0.22)
	for pair in [["fire",JOY_BUTTON_RIGHT_SHOULDER],["jump",JOY_BUTTON_A],["attack_punch",JOY_BUTTON_X],["attack_kick",JOY_BUTTON_B],["interact",JOY_BUTTON_Y],["guard",JOY_BUTTON_LEFT_SHOULDER],["pause",JOY_BUTTON_START],["move_left",JOY_BUTTON_DPAD_LEFT],["move_right",JOY_BUTTON_DPAD_RIGHT]]:
		var event := InputEventJoypadButton.new()
		event.device = -1
		event.button_index = pair[1]
		InputMap.action_add_event(pair[0],event)
	for pair in [["move_left",JOY_AXIS_LEFT_X,-1.0],["move_right",JOY_AXIS_LEFT_X,1.0],["fire",JOY_AXIS_TRIGGER_RIGHT,1.0],["guard",JOY_AXIS_TRIGGER_LEFT,1.0]]:
		var event := InputEventJoypadMotion.new()
		event.device = -1
		event.axis = pair[1]
		event.axis_value = pair[2]
		InputMap.action_add_event(pair[0],event)
