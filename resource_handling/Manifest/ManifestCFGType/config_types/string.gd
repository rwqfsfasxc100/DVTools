tool
extends VBoxContainer

onready var NAME = $name/property_editor
onready var DESCRIPTION = $description/property_editor
onready var DEFAULT = $default/property_editor
onready var PLACEHOLDER = $placeholder/property_editor
onready var MAX_LENGTH = $max_length/property_editor
onready var SECRET = $secret/property_editor
onready var CLEAR_BUTTON = $clear_button/property_editor
onready var REQUIRES_BOOLS = $requires_bools/property_editor
onready var INVERT_BOOL_REQUIREMENT = $invert_bool_requirement/property_editor
onready var REQUIRE_RESTART = $require_restart/property_editor
onready var DISABLED = $disabled/property_editor

func get_data() -> Dictionary:
	var out = {}
	var nm = NAME.get_property_value()[0]
	var dc = DESCRIPTION.get_property_value()[0]
	var df = DEFAULT.get_property_value()[0]
	var ph = PLACEHOLDER.get_property_value()[0]
	var ml = MAX_LENGTH.get_property_value()[0]
	var sc = SECRET.get_property_value()[0]
	var cb = CLEAR_BUTTON.get_property_value()[0]
	var rb = REQUIRES_BOOLS.get_property_value()[0]
	var ibr = INVERT_BOOL_REQUIREMENT.get_property_value()[0]
	var rr = REQUIRE_RESTART.get_property_value()[0]
	var db = DISABLED.get_property_value()[0]
	if nm:out["name"] = nm
	if dc:out["description"] = dc
	out["default"] = df
	if ph:out["placeholder"] = ph
	if ml:out["max_length"] = ml
	if sc:out["secret"] = sc
	if cb:out["clear_button"] = cb
	if rb:out["requires_bools"] = rb
	if ibr:out["invert_bool_requirement"] = ibr
	if rr:out["require_restart"] = rr
	if db:out["disabled"] = db
	return out

func set_data(STATE:Dictionary):
	if "name" in STATE:$name/property_editor.set_property_value(STATE["name"])
	if "description" in STATE:$description/property_editor.set_property_value(STATE["description"])
	if "default" in STATE:$default/property_editor.set_property_value(STATE["default"])
	if "placeholder" in STATE:$placeholder/property_editor.set_property_value(STATE["placeholder"])
	if "max_length" in STATE:$max_length/property_editor.set_property_value(STATE["max_length"])
	if "secret" in STATE:$secret/property_editor.set_property_value(STATE["secret"])
	if "clear_button" in STATE:$clear_button/property_editor.set_property_value(STATE["clear_button"])
	if "requires_bools" in STATE:$requires_bools/property_editor.set_property_value(STATE["requires_bools"])
	if "invert_bool_requirement" in STATE:$invert_bool_requirement/property_editor.set_property_value(STATE["invert_bool_requirement"])
	if "require_restart" in STATE:$require_restart/property_editor.set_property_value(STATE["require_restart"])
	if "disabled" in STATE:$disabled/property_editor.set_property_value(STATE[""])

