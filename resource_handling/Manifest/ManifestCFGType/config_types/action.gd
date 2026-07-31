tool
extends VBoxContainer

const type = "action"
var boxname = ""

onready var NAME = $name/property_editor
onready var DESCRIPTION = $description/property_editor
onready var SCRIPT_PATH = $script_path/property_editor
onready var BUTTON_LABEL = $button_label/property_editor
onready var METHOD = $method/property_editor
onready var REQUIRES_BOOLS = $requires_bools/property_editor
onready var INVERT_BOOL_REQUIREMENT = $invert_bool_requirement/property_editor
onready var DISABLED = $disabled/property_editor

func get_data() -> Dictionary:
	var out = {}
	var nm = NAME.get_property_value()[0]
	var dc = DESCRIPTION.get_property_value()[0]
	var sc = SCRIPT_PATH.get_property_value()[0]
	var bl = BUTTON_LABEL.get_property_value()[0]
	var md = METHOD.get_property_value()[0]
	var rb = REQUIRES_BOOLS.get_property_value()[0]
	var ibr = INVERT_BOOL_REQUIREMENT.get_property_value()[0]
	var db = DISABLED.get_property_value()[0]
	if nm:out["name"] = nm
	if dc:out["description"] = dc
	if sc:out["script_path"] = sc
	if bl:out["button_label"] = bl
	if md:out["method"] = md
	if rb:out["requires_bools"] = rb
	if ibr:out["invert_bool_requirement"] = ibr
	if db:out["disabled"] = db
	return out

func set_data(STATE:Dictionary):
	$name/property_editor.set_property_value(STATE.get("name","ACTION_MISSING_NAME"))
	$description/property_editor.set_property_value(STATE.get("description",""))
	$script_path/property_editor.set_property_value(STATE.get("script_path",""))
	$button_label/property_editor.set_property_value(STATE.get("button_label",""))
	$method/property_editor.set_property_value(STATE.get("method","_pressed"))
	$requires_bools/property_editor.set_property_value(STATE.get("requires_bools",PoolStringArray()))
	$invert_bool_requirement/property_editor.set_property_value(STATE.get("invert_bool_requirement",false))
	$disabled/property_editor.set_property_value(STATE.get("disabled",false))
