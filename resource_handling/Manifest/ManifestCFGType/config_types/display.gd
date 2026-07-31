tool
extends VBoxContainer

const type = "display"
var boxname = ""

onready var SCENE_PATH = $scene_path/property_editor
onready var DISABLED = $disabled/property_editor

func get_data() -> Dictionary:
	var out = {}
	var sc = SCENE_PATH.get_property_value()[0]
	var db = DISABLED.get_property_value()[0]
	if sc:out["scene_path"] = sc
	if db:out["disabled"] = db
	return out

func set_data(STATE:Dictionary):
	if "scene_path" in STATE:$scene_path/property_editor.set_property_value(STATE["scene_path"])
	if "disabled" in STATE:$disabled/property_editor.set_property_value(STATE["disabled"])
