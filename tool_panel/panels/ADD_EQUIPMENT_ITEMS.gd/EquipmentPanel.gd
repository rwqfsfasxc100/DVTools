tool
extends "res://addons/DVTools/tool_panel/panels/PanelBase.gd"

func _ready():
	if not this_script_path.begins_with("new://"):
		var data = __get_script_constant_map_without_load(this_script_path)
		print(data)

func save_driver_data() -> String:
	
	
	
	
	
	return ""
