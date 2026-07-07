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
	if "name" in STATE:$name/property_editor.set_property_value(STATE["name"])
	if "description" in STATE:$description/property_editor.set_property_value(STATE["description"])
	if "default" in STATE:$default/property_editor.set_property_value(STATE["default"])
	if "always_binds" in STATE:$always_binds/property_editor.set_property_value(STATE["always_binds"])
	if "requires_bools" in STATE:$requires_bools/property_editor.set_property_value(STATE["requires_bools"])
	if "invert_bool_requirement" in STATE:$invert_bool_requirement/property_editor.set_property_value(STATE["invert_bool_requirement"])
	if "disabled" in STATE:$disabled/property_editor.set_property_value(STATE["disabled"])
