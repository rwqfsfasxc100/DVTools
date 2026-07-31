tool
extends VBoxContainer

const type = "input"
var boxname = ""

onready var NAME = $name/property_editor
onready var DESCRIPTION = $description/property_editor
onready var DEFAULT = $default/property_editor
onready var ALWAYS_BINDS = $always_binds/property_editor
onready var REQUIRES_BOOLS = $requires_bools/property_editor
onready var INVERT_BOOL_REQUIREMENT = $invert_bool_requirement/property_editor
onready var DISABLED = $disabled/property_editor

func get_data() -> Dictionary:
	var out = {}
	var nm = NAME.get_property_value()[0]
	var dc = DESCRIPTION.get_property_value()[0]
	var df = DEFAULT.get_property_value()[0]
	var rr = ALWAYS_BINDS.get_property_value()[0]
	var rb = REQUIRES_BOOLS.get_property_value()[0]
	var ibr = INVERT_BOOL_REQUIREMENT.get_property_value()[0]
	var db = DISABLED.get_property_value()[0]
	if nm:out["name"] = nm
	if dc:out["description"] = dc
	out["default"] = df
	if rr:out["always_binds"] = rr
	if rb:out["requires_bools"] = rb
	if ibr:out["invert_bool_requirement"] = ibr
	if db:out["disabled"] = db
	return out

func set_data(STATE:Dictionary):
	$name/property_editor.set_property_value(STATE.get("name","INPUT_MISSING_NAME"))
	$description/property_editor.set_property_value(STATE.get("description",""))
	$default/property_editor.set_property_value(STATE.get("default",PoolStringArray()))
	$always_binds/property_editor.set_property_value(STATE.get("always_binds",PoolStringArray()))
	$requires_bools/property_editor.set_property_value(STATE.get("requires_bools",PoolStringArray()))
	$invert_bool_requirement/property_editor.set_property_value(STATE.get("invert_bool_requirement",false))
	$disabled/property_editor.set_property_value(STATE.get("disabled",false))
