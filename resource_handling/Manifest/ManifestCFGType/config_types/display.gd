tool
extends VBoxContainer

const type = "display"
var boxname = ""

onready var SCENE_PATH = $scene_path/property_editor
onready var LEFT_MARGIN = $left_margin/property_editor
onready var RIGHT_MARGIN = $right_margin/property_editor
onready var DISABLED = $disabled/property_editor

func get_data() -> Dictionary:
	var out = {}
	var sc = SCENE_PATH.get_property_value()[0]
	var lm = LEFT_MARGIN.get_property_value()[0]
	var rm = RIGHT_MARGIN.get_property_value()[0]
	var db = DISABLED.get_property_value()[0]
	if sc:out["scene_path"] = sc
	if lm != 15:out["left_margin"] = lm
	if rm != 15:out["right_margin"] = rm
	if db:out["disabled"] = db
	return out

func set_data(STATE:Dictionary):
	$scene_path/property_editor.set_property_value(STATE.get("scene_path",""))
	$left_margin/property_editor.set_property_value(STATE.get("left_margin",15))
	$right_margin/property_editor.set_property_value(STATE.get("right_margin",15))
	$disabled/property_editor.set_property_value(STATE.get("disabled",false))
