tool
extends VBoxContainer

onready var NAME = $name/property_editor
onready var DESCRIPTION = $description/property_editor
onready var DEFAULT = $default/OptionButton
onready var OPTIONS = $options/property_editor
onready var STORE_METHOD = $store_method/OptionButton
onready var REQUIRES_BOOLS = $requires_bools/property_editor
onready var INVERT_BOOL_REQUIREMENT = $invert_bool_requirement/property_editor
onready var REQUIRE_RESTART = $require_restart/property_editor
onready var DISABLED = $disabled/property_editor

func get_data() -> Dictionary:
	var out = {}
	var nm = NAME.get_property_value()[0]
	var dc = DESCRIPTION.get_property_value()[0]
	var op = OPTIONS.get_property_value()[0]
	var sm = get_store_method()
	var df = get_default()
	var rb = REQUIRES_BOOLS.get_property_value()[0]
	var ibr = INVERT_BOOL_REQUIREMENT.get_property_value()[0]
	var rr = REQUIRE_RESTART.get_property_value()[0]
	var db = DISABLED.get_property_value()[0]
	if nm:out["name"] = nm
	if dc:out["description"] = dc
	if df:out["default"] = df
	if op:out["options"] = op
	if sm:out["store_method"] = sm
	if rb:out["requires_bools"] = rb
	if ibr:out["invert_bool_requirement"] = ibr
	if rr:out["require_restart"] = rr
	if db:out["disabled"] = db
	return out

func set_data(STATE:Dictionary):
	if "name" in STATE:$name/property_editor.set_property_value(STATE["name"])
	if "description" in STATE:$description/property_editor.set_property_value(STATE["description"])
	if "options" in STATE:$options/property_editor.set_property_value(STATE["options"])
	if "store_method" in STATE:set_store_method(STATE["store_method"])
	if "default" in STATE:set_default(STATE["default"])
	if "requires_bools" in STATE:$requires_bools/property_editor.set_property_value(STATE["requires_bools"])
	if "invert_bool_requirement" in STATE:$invert_bool_requirement/property_editor.set_property_value(STATE["invert_bool_requirement"])
	if "require_restart" in STATE:$require_restart/property_editor.set_property_value(STATE["require_restart"])
	if "disabled" in STATE:$disabled/property_editor.set_property_value(STATE["disabled"])

var store_methods = PoolStringArray(["int","string"])

func _ready():
	OPTIONS.connect("draw",self,"_update_default")
	OPTIONS.connect("changed",self,"_update_default")
	DEFAULT.connect("pressed",self,"_update_default")
	defaults = []
	STORE_METHOD.clear()
	for i in store_methods:
		STORE_METHOD.add_item(i)
	STORE_METHOD.select(0)

var defaults = []

func _update_default():
	var oldSelection = DEFAULT.selected
	DEFAULT.clear()
	defaults = []
	for i in OPTIONS.get_property_value()[0]:
		defaults.append(i)
	for i in defaults:
		DEFAULT.add_item(i)
	if (oldSelection + 1 > defaults.size()) or (oldSelection < 0):
		oldSelection = 0
	DEFAULT.select(oldSelection)

func get_default():
	var val = DEFAULT.selected
	if val >= 0:
		match get_store_method():
			"string":
				val = defaults[val]
	else:
		val = 0
	return val

func get_store_method():
	return store_methods[STORE_METHOD.selected]

func set_default(how):
	match get_store_method():
		"string":
			if how in defaults:
				how = defaults.find(how)
			else:
				how = 0
	STORE_METHOD.select(how)

func set_store_method(how:String):
	if how in store_methods:
		STORE_METHOD.select(store_methods.find(how))
	else:
		STORE_METHOD.select(0)
