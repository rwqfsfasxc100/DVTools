tool
extends VBoxContainer

const type = "color"
var boxname = ""

onready var NAME = $name/property_editor
onready var DESCRIPTION = $description/property_editor
onready var DEFAULT = $default/property_editor
onready var EDIT_ALPHA = $edit_alpha/property_editor
onready var REQUIRES_BOOLS = $requires_bools/property_editor
onready var INVERT_BOOL_REQUIREMENT = $invert_bool_requirement/property_editor
onready var REQUIRE_RESTART = $require_restart/property_editor
onready var DISABLED = $disabled/property_editor

func _ready():
	$default/property_editor.set_property_value(Color(1,1,1,1))
	$edit_alpha/property_editor.set_property_value(true)

func get_data() -> Dictionary:
	var out = {}
	var nm = NAME.get_property_value()[0]
	var dc = DESCRIPTION.get_property_value()[0]
	var df = DEFAULT.get_property_value()[0]
	var ea = EDIT_ALPHA.get_property_value()[0]
	var rb = REQUIRES_BOOLS.get_property_value()[0]
	var ibr = INVERT_BOOL_REQUIREMENT.get_property_value()[0]
	var rr = REQUIRE_RESTART.get_property_value()[0]
	var db = DISABLED.get_property_value()[0]
	if nm:out["name"] = nm
	if dc:out["description"] = dc
	if not ea:
		df.a = 1
	out["default"] = df
	if rb:out["requires_bools"] = rb
	if ibr:out["invert_bool_requirement"] = ibr
	if rr:out["require_restart"] = rr
	if db:out["disabled"] = db
	return out

func set_data(STATE:Dictionary):
	$name/property_editor.set_property_value(STATE.get("name","COLOR_MISSING_NAME"))
	$description/property_editor.set_property_value(STATE.get("description",""))
	$default/property_editor.set_property_value(STATE.get("default",Color(1,1,1,1)))
	$requires_bools/property_editor.set_property_value(STATE.get("requires_bools",PoolStringArray()))
	$invert_bool_requirement/property_editor.set_property_value(STATE.get("invert_bool_requirement",false))
	$require_restart/property_editor.set_property_value(STATE.get("require_restart",false))
	$disabled/property_editor.set_property_value(STATE.get("disabled",false))
