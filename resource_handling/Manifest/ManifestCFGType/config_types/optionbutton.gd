tool
extends VBoxContainer

const type = "optionbutton"
var boxname = ""

func get_data() -> Dictionary:
	var out = {}
	var nm = $name/property_editor.get_property_value()[0]
	var dc = $description/property_editor.get_property_value()[0]
	var op = $options/property_editor.get_property_value()[0]
	var sm = get_store_method()
	var df = get_default()
	var rb = $requires_bools/property_editor.get_property_value()[0]
	var ibr = $invert_bool_requirement/property_editor.get_property_value()[0]
	var rr = $require_restart/property_editor.get_property_value()[0]
	var db = $disabled/property_editor.get_property_value()[0]
	if nm:out["name"] = nm
	if dc:out["description"] = dc
	out["options"] = op
	out["store_method"] = sm
	out["default"] = df
	if rb:out["requires_bools"] = rb
	if ibr:out["invert_bool_requirement"] = ibr
	if rr:out["require_restart"] = rr
	if db:out["disabled"] = db
	return out

func set_data(STATE:Dictionary):
	$name/property_editor.set_property_value(STATE.get("name","OPTION_MISSING_NAME"))
	$description/property_editor.set_property_value(STATE.get("description",""))
	$options/property_editor.set_property_value(STATE.get("options",PoolStringArray(["EXAMPLE_OPTION"])))
	set_store_method(STATE.get("store_method","int"))
	set_default(STATE.get("default",0))
	$requires_bools/property_editor.set_property_value(STATE.get("requires_bools",PoolStringArray()))
	$invert_bool_requirement/property_editor.set_property_value(STATE.get("invert_bool_requirement",false))
	$require_restart/property_editor.set_property_value(STATE.get("require_restart",false))
	$disabled/property_editor.set_property_value(STATE.get("disabled",false))

var store_methods = PoolStringArray(["int","string"])

func _ready():
	$options/property_editor.connect("draw",self,"_update_default")
	$options/property_editor.connect("changed",self,"_update_default")
	$default/property_editor.connect("pressed",self,"_update_default")
	defaults = []
	$store_method/property_editor.clear()
	for i in store_methods:
		$store_method/property_editor.add_item(i)
	$store_method/property_editor.select(0)

var defaults = []

func _update_default():
	var oldSelection = $default/property_editor.selected
	$default/property_editor.clear()
	defaults = []
	var opts = $options/property_editor.get_property_value()[0]
	if not opts.size():
		opts = PoolStringArray(["EXAMPLE_OPTION"])
		$options/property_editor.set_property_value(opts)
	for i in opts:
		defaults.append(i)
	for i in defaults:
		$default/property_editor.add_item(i)
	if (oldSelection + 1 > defaults.size()) or (oldSelection < 0):
		oldSelection = 0
	$default/property_editor.select(oldSelection)

func get_default():
	var val = $default/property_editor.selected
	if val >= 0:
		match get_store_method():
			"string":
				val = defaults[val]
	else:
		val = 0
	return val

func get_store_method():
	return store_methods[$store_method/property_editor.selected]

func set_default(how):
	if typeof(how) == TYPE_STRING:
		if how in defaults:
			how = defaults.find(how)
		else:
			how = 0
	$default/property_editor.select(how)

func set_store_method(how:String):
	if how in store_methods:
		$store_method/property_editor.select(store_methods.find(how))
	else:
		$store_method/property_editor.select(0)

func connect_all(to):
	for i in get_children():
		var r = i.get_node("property_editor")
		r.connect("changed",to,"changed")
		if "emit_update_signal" in r:
			r.emit_update_signal = true
