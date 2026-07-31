tool
extends VBoxContainer

const type = "int"
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
	$name/property_editor.set_property_value(STATE.get("name","INTFLOAT_MISSING_NAME"))
	$description/property_editor.set_property_value(STATE.get("description",""))
	$default/property_editor.set_property_value(STATE.get("default",10.0))
	$min/property_editor.set_property_value(STATE.get("min",0.0))
	$max/property_editor.set_property_value(STATE.get("max",10.0))
	$step/property_editor.set_property_value(STATE.get("step",1.0))
	set_style_val(STATE.get("style","slider"))
	$requires_bools/property_editor.set_property_value(STATE.get("requires_bools",PoolStringArray()))
	$invert_bool_requirement/property_editor.set_property_value(STATE.get("invert_bool_requirement",false))
	$require_restart/property_editor.set_property_value(STATE.get("require_restart",false))
	$disabled/property_editor.set_property_value(STATE.get("disabled",false))

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
