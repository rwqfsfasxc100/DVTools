tool
extends VBoxContainer

const type = "float"
var boxname = ""

onready var NAME = $name/property_editor
onready var DESCRIPTION = $description/property_editor
onready var MIN = $min/property_editor
onready var MAX = $max/property_editor
onready var STEP = $step/property_editor
onready var STYLE = $style/OptionButton
onready var DEFAULT = $default/property_editor
onready var REQUIRES_BOOLS = $requires_bools/property_editor
onready var INVERT_BOOL_REQUIREMENT = $invert_bool_requirement/property_editor
onready var REQUIRE_RESTART = $require_restart/property_editor
onready var DISABLED = $disabled/property_editor

func get_data() -> Dictionary:
	var out = {}
	var nm = NAME.get_property_value()[0]
	var dc = DESCRIPTION.get_property_value()[0]
	var df = DEFAULT.get_property_value()[0]
	var mn = MIN.get_property_value()[0]
	var mx = MAX.get_property_value()[0]
	var sp = STEP.get_property_value()[0]
	var st = get_style_val()
	var rb = REQUIRES_BOOLS.get_property_value()[0]
	var ibr = INVERT_BOOL_REQUIREMENT.get_property_value()[0]
	var rr = REQUIRE_RESTART.get_property_value()[0]
	var db = DISABLED.get_property_value()[0]
	if nm:out["name"] = nm
	if dc:out["description"] = dc
	out["default"] = df
	if mn:out["min"] = mn
	if mx:out["max"] = mx
	if sp:out["step"] = sp
	if st:out["style"] = st
	if rb:out["requires_bools"] = rb
	if ibr:out["invert_bool_requirement"] = ibr
	if rr:out["require_restart"] = rr
	if db:out["disabled"] = db
	return out

func set_data(STATE:Dictionary):
	if "name" in STATE:$name/property_editor.set_property_value(STATE["name"])
	if "description" in STATE:$description/property_editor.set_property_value(STATE["description"])
	if "default" in STATE:$default/property_editor.set_property_value(STATE["default"])
	if "min" in STATE:$min/property_editor.set_property_value(STATE["min"])
	if "max" in STATE:$max/property_editor.set_property_value(STATE["max"])
	if "step" in STATE:$step/property_editor.set_property_value(STATE["step"])
	if "style" in STATE:set_style_val(STATE["style"])
	if "requires_bools" in STATE:$requires_bools/property_editor.set_property_value(STATE["requires_bools"])
	if "invert_bool_requirement" in STATE:$invert_bool_requirement/property_editor.set_property_value(STATE["invert_bool_requirement"])
	if "require_restart" in STATE:$require_restart/property_editor.set_property_value(STATE["require_restart"])
	if "disabled" in STATE:$disabled/property_editor.set_property_value(STATE["disabled"])

var styles = PoolStringArray(["slider","spinbox"])
func _ready():
	STYLE.clear()
	for i in styles:
		STYLE.add_item(i)
	STYLE.select(0)

func get_style_val():
	return styles[STYLE.selected]

func set_style_val(how:String):
	if not STYLE:
		STYLE = $style/OptionButton
		STYLE.clear()
		for i in styles:
			STYLE.add_item(i)
	if how in styles:
		STYLE.select(styles.find(how))
	else:
		STYLE.select(0)
