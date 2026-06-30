extends VBoxContainer

onready var NAME = $name/property_editor
onready var DESCRIPTION = $description/property_editor
onready var DEFAULT = $default/property_editor
onready var SCRIPT_PATH = $script_path/property_editor
onready var BUTTON_LABEL = $button_label/property_editor
onready var METHOD = $method/property_editor
onready var REQUIRES_BOOLS = $requires_bools/property_editor
onready var INVERT_BOOL_REQUIREMENT = $invert_bool_requirement/property_editor
onready var DISABLED = $disabled/property_editor

func get_data() -> Dictionary:
	var out = {}
	var nm = NAME.get_property_value()
	var dc = DESCRIPTION.get_property_value()
	var df = DEFAULT.get_property_value()
	var sc = SCRIPT_PATH.get_property_value()
	var bl = BUTTON_LABEL.get_property_value()
	var md = METHOD.get_property_value()
	var rb = REQUIRES_BOOLS.get_property_value()
	var ibr = INVERT_BOOL_REQUIREMENT.get_property_value()
	var db = DISABLED.get_property_value()
	if nm:out["name"] = nm
	if dc:out["description"] = dc
	if df:out["default"] = df
	if sc:out["script_path"] = sc
	if bl:out["button_label"] = bl
	if md:out["method"] = md
	if rb:out["requires_bools"] = rb
	if ibr:out["invert_bool_requirement"] = ibr
	if db:out["disabled"] = db
	return out

func set_data(STATE:Dictionary):
	if "name" in STATE:$name/property_editor.set_property_value(STATE["name"])
	if "description" in STATE:$description/property_editor.set_property_value(STATE["description"])
	if "default" in STATE:$default/property_editor.set_property_value(STATE["default"])
	if "script_path" in STATE:$script_path/property_editor.set_property_value(STATE["script_path"])
	if "button_label" in STATE:$button_label/property_editor.set_property_value(STATE["button_label"])
	if "method" in STATE:$method/property_editor.set_property_value(STATE["method"])
	if "requires_bools" in STATE:$requires_bools/property_editor.set_property_value(STATE["requires_bools"])
	if "invert_bool_requirement" in STATE:$invert_bool_requirement/property_editor.set_property_value(STATE["invert_bool_requirement"])
	if "disabled" in STATE:$disabled/property_editor.set_property_value(STATE["disabled"])
