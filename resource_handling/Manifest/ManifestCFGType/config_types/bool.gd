tool
extends VBoxContainer

const type = "bool"
var boxname = ""

func get_data() -> Dictionary:
	var out = {}
	var nm = $name/property_editor.get_property_value()[0]
	var dc = $description/property_editor.get_property_value()[0]
	var df = $default/property_editor.get_property_value()[0]
	var rb = $requires_bools/property_editor.get_property_value()[0]
	var ibr = $invert_bool_requirement/property_editor.get_property_value()[0]
	var rr = $require_restart/property_editor.get_property_value()[0]
	var db = $disabled/property_editor.get_property_value()[0]
	if nm:out["name"] = nm
	if dc:out["description"] = dc
	out["default"] = df
	if rb:out["requires_bools"] = rb
	if ibr:out["invert_bool_requirement"] = ibr
	if rr:out["require_restart"] = rr
	if db:out["disabled"] = db
	return out

func set_data(STATE:Dictionary):
	$name/property_editor.set_property_value(STATE.get("name","BOOL_MISSING_NAME"))
	$description/property_editor.set_property_value(STATE.get("description",""))
	$default/property_editor.set_property_value(STATE.get("default",false))
	$requires_bools/property_editor.set_property_value(STATE.get("requires_bools",PoolStringArray()))
	$invert_bool_requirement/property_editor.set_property_value(STATE.get("invert_bool_requirement",false))
	$require_restart/property_editor.set_property_value(STATE.get("require_restart",false))
	$disabled/property_editor.set_property_value(STATE.get("disabled",false))

func connect_all(to):
	for i in get_children():
		var r = i.get_node("property_editor")
		r.connect("changed",to,"changed")
		if "emit_update_signal" in r:
			r.emit_update_signal = true
